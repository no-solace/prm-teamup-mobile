import 'dart:convert';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../models/app_notification.dart';
import '../services/notification_store.dart';
import 'firestore_notification_store.dart';
import 'notification_presenter.dart';

/// Called from the top-level entry point after Firebase.initializeApp.
/// The background isolate never navigates and never shares UI controllers.
Future<void> keepBackgroundNotification(RemoteMessage message) async {
  final uid = FirebaseAuth.instance.currentUser?.uid;
  if (uid == null || message.data['uid'] != uid) return;
  final rawId = message.data['id'] ?? message.messageId;
  final id = base64Url.encode(
    utf8.encode(
      rawId is String
          ? rawId
          : '${message.sentTime?.millisecondsSinceEpoch}:${message.data}:${message.notification?.title}',
    ),
  );
  final rawRoute = message.data['route'];
  final route = rawRoute is String && NotificationRoutes.isAllowed(rawRoute)
      ? rawRoute
      : null;
  final notification = AppNotification(
    id: id,
    title:
        message.notification?.title ??
        message.data['title'] as String? ??
        'TeamUp EXE',
    body: message.notification?.body ?? message.data['body'] as String? ?? '',
    receivedAt: message.sentTime ?? DateTime.now(),
    route: route,
  );
  try {
    await FirestoreNotificationStore()
        .save(uid, notification)
        .timeout(const Duration(seconds: 10));
  } catch (_) {
    // A normal notification payload is still displayed by Android. The sender
    // must write the authoritative inbox record before sending for delivery
    // when this isolate cannot run (force-stop, notification-only, no network).
  }
  if (message.notification == null) {
    try {
      final permission =
          (await FirebaseMessaging.instance.getNotificationSettings())
              .authorizationStatus;
      if (permission != AuthorizationStatus.authorized &&
          permission != AuthorizationStatus.provisional) {
        return;
      }
      final presenter = AndroidNotificationPresenter();
      await presenter.initialize((_) {});
      await presenter.show(
        message,
        notificationPayload(uid: uid, id: id, route: route),
      );
    } catch (_) {
      // No UI exists in this isolate. The Firestore inbox is the recovery path.
    }
  }
}
