// Android Console test-send requires the registration token exposed by these
// still-supported APIs in the pinned 17.0.1 SDK, rather than an Installation ID.
// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../models/app_notification.dart';
import '../services/notification_service.dart';
import '../services/notification_store.dart';
import 'firestore_notification_store.dart';
import 'notification_presenter.dart';

/// SDK boundaries are injectable; one inbox and one token owner per session.
class FcmNotificationService implements NotificationService {
  FcmNotificationService({
    FirebaseMessaging? messaging,
    NotificationStore? store,
    NotificationPresenter? presenter,
    Stream<String?>? userIds,
    String? Function()? currentUserId,
    Stream<RemoteMessage>? foregroundMessages,
    Stream<RemoteMessage>? openedMessages,
    this._tokenRetryDelays = const [
      Duration(seconds: 1),
      Duration(seconds: 2),
      Duration(seconds: 4),
    ],
  }) : _messaging = messaging ?? FirebaseMessaging.instance,
       _store = store ?? FirestoreNotificationStore(),
       _presenter = presenter ?? AndroidNotificationPresenter(),
       _userIds =
           userIds ??
           FirebaseAuth.instance.authStateChanges().map((u) => u?.uid),
       _currentUserId =
           currentUserId ?? (() => FirebaseAuth.instance.currentUser?.uid),
       _foreground = foregroundMessages ?? FirebaseMessaging.onMessage,
       _opened = openedMessages ?? FirebaseMessaging.onMessageOpenedApp;

  final FirebaseMessaging _messaging;
  final NotificationStore _store;
  final NotificationPresenter _presenter;
  final Stream<String?> _userIds;
  final String? Function() _currentUserId;
  final List<Duration> _tokenRetryDelays;
  final Stream<RemoteMessage> _foreground, _opened;
  final _taps = StreamController<String>.broadcast();
  final _changes = StreamController<List<AppNotification>>.broadcast();
  final _issues = StreamController<String?>.broadcast();
  final _subscriptions = <StreamSubscription<dynamic>>[];
  StreamSubscription<List<AppNotification>>? _inboxSubscription;
  final _inbox = <String, AppNotification>{};
  String? _uid, _token, _pendingRoute, _initialLocal, _issue;
  RemoteMessage? _initial;
  bool _started = false, _disposed = false, _hasAuthEvent = false;
  int _generation = 0, _tokenEpoch = 0;
  Future<void> _tokenWork = Future.value();

  static NotificationPermission _map(AuthorizationStatus status) =>
      switch (status) {
        AuthorizationStatus.authorized ||
        AuthorizationStatus.provisional => NotificationPermission.granted,
        AuthorizationStatus.denied ||
        AuthorizationStatus.deniedPermanently => NotificationPermission.denied,
        AuthorizationStatus.notDetermined =>
          NotificationPermission.notDetermined,
      };

  void _report(String? message) {
    _issue = message;
    if (!_disposed) _issues.add(message);
  }

  List<AppNotification> get _items => List.unmodifiable(
    _inbox.values.toList()
      ..sort((a, b) => b.receivedAt.compareTo(a.receivedAt)),
  );
  void _emit() {
    if (!_disposed) _changes.add(_items);
  }

  bool _isCurrent(String uid, int generation) =>
      !_disposed &&
      _uid == uid &&
      _currentUserId() == uid &&
      _generation == generation;

  @override
  Future<NotificationPermission> currentPermission() async =>
      _map((await _messaging.getNotificationSettings()).authorizationStatus);

  @override
  Future<NotificationPermission> requestPermission() async {
    final permission = _map(
      (await _messaging.requestPermission()).authorizationStatus,
    );
    if (permission == NotificationPermission.granted) {
      await _queueTokenSync();
    } else {
      await unregisterToken();
    }
    return permission;
  }

  @override
  Future<String?> getToken() async =>
      await currentPermission() == NotificationPermission.granted
      ? _messaging.getToken()
      : null;

  Future<void> _queueTokenSync([String? refreshed]) {
    final uid = _uid;
    final generation = _generation;
    final epoch = _tokenEpoch;
    _tokenWork = _tokenWork
        .then((_) async {
          if (uid == null ||
              !_isCurrent(uid, generation) ||
              epoch != _tokenEpoch) {
            return;
          }
          if (await currentPermission() != NotificationPermission.granted) {
            return;
          }
          final next = refreshed ?? await getToken();
          if (next == null ||
              !_isCurrent(uid, generation) ||
              epoch != _tokenEpoch) {
            return;
          }
          final old = _token;
          if (old != null && old != next) {
            await _store
                .removeToken(uid, old)
                .timeout(const Duration(seconds: 10));
          }
          if (!_isCurrent(uid, generation) || epoch != _tokenEpoch) return;
          _token = next;
          await _saveTokenWithRetry(uid, next, generation, epoch);
        })
        .catchError((Object _) {
          _report(
            'Push registration could not sync. Enable notifications again to retry.',
          );
        });
    return _tokenWork;
  }

  /// On a first sign-in this listener fires on the raw FirebaseAuth stream,
  /// before FirebaseAuthService has created users/{uid}; the fcmTokens rule then
  /// denies the write. Retry a few times while the same session is current
  /// (finding F2); the last failure is rethrown and reported to the user.
  Future<void> _saveTokenWithRetry(
    String uid,
    String token,
    int generation,
    int epoch,
  ) async {
    for (var attempt = 0; ; attempt++) {
      try {
        await _store.saveToken(uid, token).timeout(const Duration(seconds: 10));
        return;
      } catch (_) {
        if (attempt >= _tokenRetryDelays.length) rethrow;
        await Future<void>.delayed(_tokenRetryDelays[attempt]);
        if (!_isCurrent(uid, generation) || epoch != _tokenEpoch) return;
      }
    }
  }

  void _bindUser(String? uid) {
    if (_hasAuthEvent && uid == _uid) return;
    _hasAuthEvent = true;
    final previous = _uid;
    _uid = uid;
    _generation++;
    _token = null;
    _pendingRoute = null;
    _inbox.clear();
    _emit();
    unawaited(_inboxSubscription?.cancel());
    final generation = _generation;
    if (previous != null) {
      // Auth may already have changed: invalidate the OS token even when old
      // account rules now prevent removal of its stale Firestore document.
      _tokenWork = _tokenWork.then((_) => _messaging.deleteToken()).catchError((
        Object _,
      ) {
        _report(
          'Could not reset push registration. Enable notifications again.',
        );
      });
      unawaited(_presenter.clear().catchError((Object _) {}));
    }
    if (uid == null) return;
    _inboxSubscription = _store
        .watch(uid)
        .listen(
          (items) {
            if (!_isCurrent(uid, generation)) return;
            for (final item in items) {
              final local = _inbox[item.id];
              _inbox[item.id] = item.copyWith(
                read: item.read || local?.read == true,
              );
            }
            _emit();
          },
          onError: (Object _) {
            if (_isCurrent(uid, generation)) {
              _report(
                'Inbox could not sync. Recent messages remain available on this screen.',
              );
            }
          },
        );
    unawaited(_queueTokenSync());
    _consumeInitial();
  }

  void _consumeInitial() {
    final remote = _initial;
    if (remote != null) {
      _initial = null;
      _receive(remote, tapped: true);
    }
    final local = _initialLocal;
    if (local != null) {
      _initialLocal = null;
      _openLocal(local);
    }
  }

  void _receive(RemoteMessage message, {bool tapped = false}) {
    final uid = _uid;
    // Console test pushes must also carry data.uid; stale account pushes drop.
    if (uid == null || uid != _currentUserId() || message.data['uid'] != uid) {
      return;
    }
    final rawId = message.data['id'] ?? message.messageId;
    final id = base64Url.encode(
      utf8.encode(
        rawId is String
            ? rawId
            : '${message.sentTime?.millisecondsSinceEpoch}:${message.data}:${message.notification?.title}',
      ),
    );
    final rawRoute = message.data['route'];
    final item = AppNotification(
      id: id,
      title:
          message.notification?.title ??
          message.data['title'] as String? ??
          'TeamUp EXE',
      body: message.notification?.body ?? message.data['body'] as String? ?? '',
      receivedAt: message.sentTime ?? DateTime.now(),
      route: rawRoute is String && NotificationRoutes.isAllowed(rawRoute)
          ? rawRoute
          : null,
      read: tapped || _inbox[id]?.read == true,
    );
    final isNew = !_inbox.containsKey(id);
    _inbox[id] = item;
    _emit();
    unawaited(
      _store.save(uid, item).timeout(const Duration(seconds: 10)).catchError((
        Object _,
      ) {
        if (_uid == uid) {
          _report(
            'Message kept for this session. Inbox sync failed; try again when online.',
          );
        }
      }),
    );
    if (tapped) {
      _navigate(item.route);
    } else if (isNew && message.data['silent'] != '1') {
      // Silent: activity found on app start goes to the inbox only.
      unawaited(_show(message, item, uid));
    }
  }

  Future<void> _show(
    RemoteMessage message,
    AppNotification item,
    String uid,
  ) async {
    try {
      if (await currentPermission() != NotificationPermission.granted ||
          _uid != uid) {
        return;
      }
      await _presenter.show(
        message,
        notificationPayload(uid: uid, id: item.id, route: item.route),
      );
    } catch (_) {
      _report(
        'System notification unavailable. Read the message in Notifications.',
      );
    }
  }

  void _navigate(String? route) {
    if (!NotificationRoutes.isAllowed(route)) return;
    if (_taps.hasListener) {
      _taps.add(route!);
    } else {
      _pendingRoute = route;
    }
  }

  void _openLocal(String payload) {
    try {
      final data = jsonDecode(payload) as Map<String, dynamic>;
      if (data['uid'] != _uid || _uid == null || _uid != _currentUserId()) {
        return;
      }
      final id = data['id'];
      if (id is String) unawaited(markRead(id));
      _navigate(data['route'] is String ? data['route'] as String : null);
    } catch (_) {
      _report('This notification could not be opened.');
    }
  }

  @override
  Future<void> start() async {
    if (_started || _disposed) return;
    _started = true;
    _subscriptions.add(_foreground.listen(_receive));
    _subscriptions.add(
      _opened.listen((message) => _receive(message, tapped: true)),
    );
    _subscriptions.add(
      _messaging.onTokenRefresh.listen(
        (token) => unawaited(_queueTokenSync(token)),
        onError: (Object _) =>
            _report('Push token refresh failed. Enable notifications again.'),
      ),
    );
    _subscriptions.add(
      _userIds.listen(
        _bindUser,
        onError: (Object _) => _report('Notification account unavailable.'),
      ),
    );
    // A local presenter failure must not prevent FCM terminated-message delivery.
    try {
      _initialLocal = await _presenter.initialize(_openLocal);
    } catch (_) {
      _report(
        'System notification setup failed. Your inbox remains available.',
      );
    }
    try {
      _initial = await _messaging.getInitialMessage();
    } catch (_) {
      _report('Could not restore the startup notification.');
    }
    if (_hasAuthEvent && _uid != null) _consumeInitial();
  }

  @override
  Stream<String> get tappedRoutes async* {
    final pending = _pendingRoute;
    _pendingRoute = null;
    if (pending != null) yield pending;
    yield* _taps.stream;
  }

  @override
  Stream<List<AppNotification>> watchInbox() async* {
    yield _items;
    yield* _changes.stream;
  }

  @override
  Stream<String?> get issues async* {
    yield _issue;
    yield* _issues.stream;
  }

  @override
  Future<void> markRead(String id) async {
    final uid = _uid;
    if (uid == null || uid != _currentUserId()) return;
    final item = _inbox[id];
    if (item != null) {
      _inbox[id] = item.copyWith(read: true);
      _emit();
    }
    try {
      await _store.markRead(uid, id).timeout(const Duration(seconds: 10));
    } catch (_) {
      if (_uid == uid) {
        _report('Marked read on this screen. Could not sync read status.');
      }
    }
  }

  @override
  Future<void> unregisterToken() async {
    final uid = _uid;
    final token = _token;
    _tokenEpoch++; // Cancel registration waiting for the SDK, keep inbox active.
    try {
      if (uid != null && token != null && uid == _currentUserId()) {
        await _store
            .removeToken(uid, token)
            .timeout(const Duration(seconds: 5));
      }
    } catch (_) {
      _report(
        'Token cleanup could not sync; resetting this device registration.',
      );
    } finally {
      _token = null;
      await _messaging.deleteToken();
      await _presenter.clear();
    }
  }

  @override
  Future<void> dispose() async {
    _disposed = true;
    _generation++;
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    await _inboxSubscription?.cancel();
    await _taps.close();
    await _changes.close();
    await _issues.close();
  }
}
