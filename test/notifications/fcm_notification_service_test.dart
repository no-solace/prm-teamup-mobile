// Android Console registration-token APIs are intentionally retained.
// ignore_for_file: deprecated_member_use
import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:teamup_exe/firebase/fcm_notification_service.dart';
import 'package:teamup_exe/firebase/notification_presenter.dart';
import 'package:teamup_exe/models/app_notification.dart';
import 'package:teamup_exe/services/notification_service.dart';
import 'package:teamup_exe/services/notification_store.dart';

class Messaging extends Mock implements FirebaseMessaging {}

class Settings extends Mock implements NotificationSettings {}

class MemoryStore implements NotificationStore {
  final items = <String, Map<String, AppNotification>>{};
  final tokens = <String, Set<String>>{};
  final changes = <String, StreamController<List<AppNotification>>>{};
  bool failWrites = false;

  /// Number of upcoming saveToken calls that fail (profile not created yet, F2).
  int tokenFailures = 0;
  @override
  Stream<List<AppNotification>> watch(String uid) async* {
    yield items[uid]?.values.toList() ?? [];
    yield* (changes[uid] ??= StreamController.broadcast()).stream;
  }

  @override
  Future<void> save(String uid, AppNotification item) async {
    if (failWrites) throw StateError('offline');
    final inbox = items.putIfAbsent(uid, () => {});
    inbox[item.id] = item.copyWith(
      read: item.read || inbox[item.id]?.read == true,
    );
  }

  @override
  Future<void> markRead(String uid, String id) async {
    if (failWrites) throw StateError('offline');
    final item = items[uid]?[id];
    if (item != null) items[uid]![id] = item.copyWith(read: true);
  }

  @override
  Future<void> saveToken(String uid, String token) async {
    if (tokenFailures > 0) {
      tokenFailures--;
      throw StateError('permission-denied: profile not created yet');
    }
    (tokens[uid] ??= {}).add(token);
  }
  @override
  Future<void> removeToken(String uid, String token) async =>
      tokens[uid]?.remove(token);
  Future<void> dispose() async {
    for (final stream in changes.values) {
      await stream.close();
    }
  }
}

class Presenter implements NotificationPresenter {
  void Function(String)? onTap;
  String? initialPayload;
  final shown = <String>[];
  int clears = 0;
  @override
  Future<String?> initialize(void Function(String) tap) async {
    onTap = tap;
    return initialPayload;
  }

  @override
  Future<void> show(RemoteMessage message, String payload) async =>
      shown.add(payload);
  @override
  Future<void> clear() async {
    clears++;
  }
}

void main() {
  late Messaging messaging;
  late Settings settings;
  late MemoryStore store;
  late Presenter presenter;
  late StreamController<String?> auth;
  late StreamController<String> tokens;
  late StreamController<RemoteMessage> foreground, opened;
  late FcmNotificationService service;
  late List<AppNotification> inbox;
  late List<String> routes;
  late List<String?> issues;
  late List<StreamSubscription<dynamic>> subscriptions;
  String? uid;
  RemoteMessage? initial;

  RemoteMessage message({
    String id = 'n1',
    String target = 'alice',
    String route = '/proposals',
  }) => RemoteMessage(
    messageId: 'transport-$id',
    data: {'id': id, 'uid': target, 'route': route},
    notification: const RemoteNotification(
      title: 'Ready',
      body: 'Review teams',
    ),
    sentTime: DateTime(2026, 11, 6),
  );
  Future<void> signIn(String? next) async {
    uid = next;
    auth.add(next);
    await pumpEventQueue();
  }

  setUp(() {
    uid = null;
    initial = null;
    inbox = [];
    routes = [];
    issues = [];
    messaging = Messaging();
    settings = Settings();
    store = MemoryStore();
    presenter = Presenter();
    auth = StreamController.broadcast();
    tokens = StreamController.broadcast();
    foreground = StreamController.broadcast();
    opened = StreamController.broadcast();
    when(() => settings.authorizationStatus)
        .thenReturn(AuthorizationStatus.authorized);
    when(() => messaging.getNotificationSettings())
        .thenAnswer((_) async => settings);
    when(() => messaging.requestPermission()).thenAnswer((_) async => settings);
    when(() => messaging.getToken()).thenAnswer((_) async => 'token1');
    when(() => messaging.deleteToken()).thenAnswer((_) async {});
    when(() => messaging.onTokenRefresh).thenAnswer((_) => tokens.stream);
    when(() => messaging.getInitialMessage()).thenAnswer((_) async => initial);
    service = FcmNotificationService(
      messaging: messaging,
      store: store,
      presenter: presenter,
      userIds: auth.stream,
      currentUserId: () => uid,
      foregroundMessages: foreground.stream,
      openedMessages: opened.stream,
      tokenRetryDelays: const [Duration.zero, Duration.zero, Duration.zero],
    );
    subscriptions = [
      service.watchInbox().listen((value) => inbox = value),
      service.tappedRoutes.listen(routes.add),
      service.issues.listen(issues.add),
    ];
  });
  tearDown(() async {
    for (final subscription in subscriptions) {
      await subscription.cancel();
    }
    await service.dispose();
    await store.dispose();
    await auth.close();
    await tokens.close();
    await foreground.close();
    await opened.close();
  });

  // Review finding F2: the first write can be denied until users/{uid} exists.
  test('token registration retries until the profile exists', () async {
    store.tokenFailures = 2;
    await service.start();
    await signIn('alice');
    expect(store.tokens['alice'], {'token1'});
    expect(issues.whereType<String>(), isEmpty);
  });
  test('token registration gives up after the retries and reports it', () async {
    store.tokenFailures = 10;
    await service.start();
    await signIn('alice');
    expect(store.tokens['alice'], isNull);
    expect(issues.whereType<String>(), isNotEmpty);
  });

  test('registers only after authenticated UID, rotates token, removes before sign-out', () async {
    await service.start();
    await signIn(null);
    expect(store.tokens, isEmpty);
    await signIn('alice');
    expect(store.tokens['alice'], {'token1'});
    tokens.add('token2');
    await pumpEventQueue();
    expect(store.tokens['alice'], {'token2'});
    await service.unregisterToken();
    expect(store.tokens['alice'], isEmpty);
    await signIn(null);
    expect(inbox, isEmpty);
    verify(() => messaging.deleteToken()).called(greaterThanOrEqualTo(1));
  });

  test(
    'foreground, background tap and duplicate delivery keep one read message',
    () async {
      await service.start();
      await signIn('alice');
      foreground.add(message());
      await pumpEventQueue();
      expect(inbox.single.read, isFalse);
      expect(presenter.shown, hasLength(1));
      opened.add(message());
      await pumpEventQueue();
      expect(inbox.single.read, isTrue);
      expect(routes, ['/proposals']);
      foreground.add(message());
      await pumpEventQueue();
      expect(inbox, hasLength(1));
      expect(inbox.single.read, isTrue);
      expect(presenter.shown, hasLength(1));
    },
  );

  test(
    'terminated message waits for auth and routes after subscription',
    () async {
      initial = message(route: '/classes/class-a');
      await service.start();
      await pumpEventQueue();
      expect(routes, isEmpty);
      await signIn('alice');
      expect(routes, ['/classes/class-a']);
      expect(inbox.single.read, isTrue);
    },
  );

  test(
    'startup local tap is replayed for a router subscribing later',
    () async {
      await subscriptions[1].cancel();
      presenter.initialPayload = notificationPayload(
        uid: 'alice',
        id: 'n1',
        route: '/proposals/p-1',
      );
      await service.start();
      await signIn('alice');
      subscriptions[1] = service.tappedRoutes.listen(routes.add);
      await pumpEventQueue();
      expect(routes, ['/proposals/p-1']);
    },
  );

  test('denied permission prevents token persistence and OS popup but keeps inbox', () async {
    when(() => settings.authorizationStatus)
        .thenReturn(AuthorizationStatus.denied);
    await service.start();
    await signIn('alice');
    expect(await service.requestPermission(), NotificationPermission.denied);
    foreground.add(message());
    await pumpEventQueue();
    expect(store.tokens, isEmpty);
    expect(presenter.shown, isEmpty);
    expect(inbox, hasLength(1));
    // Denial/token invalidation must not invalidate the account inbox listener.
    store.changes['alice']!.add([
      AppNotification(
        id: 'server',
        title: 'Server',
        body: '',
        receivedAt: DateTime(2026),
      ),
    ]);
    await pumpEventQueue();
    expect(inbox, hasLength(2));
  });

  test('rejects previous-user payloads and unsafe routes; clears inbox on account switch', () async {
    await service.start();
    await signIn('alice');
    foreground.add(message());
    await pumpEventQueue();
    expect(inbox, isNotEmpty);
    await signIn('bob');
    expect(inbox, isEmpty);
    opened.add(message());
    await pumpEventQueue();
    expect(routes, isEmpty);
    expect(inbox, isEmpty);
    opened.add(message(target: 'bob', route: 'https://evil.invalid'));
    await pumpEventQueue();
    expect(inbox.single.route, isNull);
    expect(routes, isEmpty);
    presenter.onTap!(
      notificationPayload(uid: 'alice', id: 'n1', route: '/profile'),
    );
    await pumpEventQueue();
    expect(routes, isEmpty);
    expect(store.tokens['bob'], {'token1'});
  });

  test('slow token lookup for previous user cannot write into their session after switch', () async {
    final lookup = Completer<String?>();
    when(() => messaging.getToken()).thenAnswer((_) => lookup.future);
    await service.start();
    uid = 'alice';
    auth.add(uid);
    await pumpEventQueue();
    uid = 'bob';
    auth.add(uid);
    await pumpEventQueue();
    lookup.complete('delayed');
    await pumpEventQueue();
    expect(store.tokens['alice'], isNull);
    expect(store.tokens['bob'], {'delayed'});
  });

  test(
    'sync failures surface a message and leave local read/unread usable',
    () async {
      store.failWrites = true;
      await service.start();
      await signIn('alice');
      foreground.add(message());
      await pumpEventQueue();
      expect(inbox.single.read, isFalse);
      await service.markRead(inbox.single.id);
      await pumpEventQueue();
      expect(inbox.single.read, isTrue);
      expect(issues.whereType<String>().last, contains('Could not sync'));
    },
  );

  test('route allow-list blocks URLs, sign-in and admin routes', () {
    for (final route in [
      '/sign-in',
      '/_gallery',
      '/admin',
      '//example.com',
      '/classes/import',
      '/proposals/x?admin=true',
    ]) {
      expect(NotificationRoutes.isAllowed(route), isFalse, reason: route);
    }
    expect(NotificationRoutes.isAllowed('/proposals/p-1'), isTrue);
  });
}
