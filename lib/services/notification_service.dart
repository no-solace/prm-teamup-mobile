import '../models/app_notification.dart';

enum NotificationPermission { granted, denied, notDetermined }

/// Owner: Dan. FCM + in-app notification center.
abstract interface class NotificationService {
  /// Asks for POST_NOTIFICATIONS on Android 13+.
  Future<NotificationPermission> requestPermission();

  Future<NotificationPermission> currentPermission();

  /// FCM registration token (shown on the demo area, saved to Firestore).
  Future<String?> getToken();

  /// Starts foreground / background / opened-app listeners.
  Future<void> start();

  /// Routes from tapped notifications (D7). The router listens and calls go().
  Stream<String> get tappedRoutes;

  Stream<List<AppNotification>> watchInbox();

  Future<void> markRead(String id);
}
