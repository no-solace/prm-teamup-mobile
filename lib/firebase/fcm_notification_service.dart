import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';

import '../models/app_notification.dart';
import '../services/notification_service.dart';

/// Owner: Dan. Skeleton: permission, token, tapped routes.
/// TODO(Dan): show foreground notifications with flutter_local_notifications,
/// persist the inbox to Firestore users/{uid}/notifications, save the token.
class FcmNotificationService implements NotificationService {
  FcmNotificationService({FirebaseMessaging? messaging}) : _m = messaging ?? FirebaseMessaging.instance;

  final FirebaseMessaging _m;
  final _taps = StreamController<String>.broadcast();
  final _inbox = <AppNotification>[];
  final _inboxChanges = StreamController<List<AppNotification>>.broadcast();
  bool _started = false;

  static NotificationPermission _map(AuthorizationStatus s) => switch (s) {
        AuthorizationStatus.authorized || AuthorizationStatus.provisional => NotificationPermission.granted,
        AuthorizationStatus.denied || AuthorizationStatus.deniedPermanently => NotificationPermission.denied,
        AuthorizationStatus.notDetermined => NotificationPermission.notDetermined,
      };

  @override
  Future<NotificationPermission> requestPermission() async => _map((await _m.requestPermission()).authorizationStatus);

  @override
  Future<NotificationPermission> currentPermission() async =>
      _map((await _m.getNotificationSettings()).authorizationStatus);

  @override
  // TODO(Dan): firebase_messaging 17 prefers register() + onRegistered;
  // getToken() still works on Android for Lab 3.
  // ignore: deprecated_member_use
  Future<String?> getToken() => _m.getToken();

  void _keep(RemoteMessage msg) {
    _inbox.insert(
      0,
      AppNotification(
        id: msg.messageId ?? DateTime.now().microsecondsSinceEpoch.toString(),
        title: msg.notification?.title ?? 'TeamUp EXE',
        body: msg.notification?.body ?? '',
        receivedAt: msg.sentTime ?? DateTime.now(),
        route: msg.data['route'] as String?,
      ),
    );
    _inboxChanges.add(List.unmodifiable(_inbox));
  }

  void _open(RemoteMessage msg) {
    _keep(msg);
    final route = msg.data['route'];
    if (route is String && route.startsWith('/')) _taps.add(route);
  }

  @override
  Future<void> start() async {
    if (_started) return;
    _started = true;
    FirebaseMessaging.onMessage.listen(_keep); // foreground
    FirebaseMessaging.onMessageOpenedApp.listen(_open); // background -> tapped
    final initial = await _m.getInitialMessage(); // terminated -> tapped
    if (initial != null) _open(initial);
  }

  @override
  Stream<String> get tappedRoutes => _taps.stream;

  @override
  Stream<List<AppNotification>> watchInbox() async* {
    yield List.unmodifiable(_inbox);
    yield* _inboxChanges.stream;
  }

  @override
  Future<void> markRead(String id) async {}
}
