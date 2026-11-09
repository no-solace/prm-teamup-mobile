import '../models/app_notification.dart';

/// Implementations must scope every operation to the captured authenticated UID.
abstract interface class NotificationStore {
  Stream<List<AppNotification>> watch(String uid);
  Future<void> save(String uid, AppNotification notification);
  Future<void> markRead(String uid, String id);
  Future<void> saveToken(String uid, String token);
  Future<void> removeToken(String uid, String token);
}

/// Shared policy for OS taps and inbox taps; never accepts arbitrary URLs.
abstract final class NotificationRoutes {
  static final _patterns = [
    RegExp(r'^/classes$'),
    RegExp(r'^/classes/[\w-]+$'),
    RegExp(r'^/classes/[\w-]+/(no-team|need-members|no-match)$'),
    RegExp(r'^/proposals$'),
    RegExp(r'^/proposals/[\w-]+$'),
    RegExp(r'^/profile$'),
  ];

  static bool isAllowed(String? route) =>
      route != null &&
      route != '/classes/import' &&
      _patterns.any((p) => p.hasMatch(route));
}
