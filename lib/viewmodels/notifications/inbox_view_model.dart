import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/app_notification.dart';
import '../../providers/service_providers.dart';
import '../../services/notification_service.dart';
import '../../services/notification_store.dart';
import '../auth/session_view_model.dart';

final inboxProvider = StreamProvider.autoDispose<List<AppNotification>>((ref) {
  // Recreate per account; old account state cannot linger during sign-out.
  final session = ref.watch(sessionProvider).value;
  if (session == null) return Stream.value(const []);
  return ref.watch(notificationServiceProvider).watchInbox();
});

final unreadCountProvider = Provider.autoDispose<int>(
  (ref) => ref.watch(inboxProvider).value?.where((n) => !n.read).length ?? 0,
);

final notificationIssueProvider = StreamProvider.autoDispose<String?>(
  (ref) => ref.watch(notificationServiceProvider).issues,
);

final notificationPermissionProvider =
    FutureProvider.autoDispose<NotificationPermission>(
      (ref) => ref.watch(notificationServiceProvider).currentPermission(),
    );

final notificationTokenProvider = FutureProvider.autoDispose<String?>(
  (ref) => ref.watch(notificationServiceProvider).getToken(),
);

final notificationSettingsActionsProvider = Provider<NotificationSettingsActions>(
  (ref) => NotificationSettingsActions(ref.watch(notificationServiceProvider)),
);

class NotificationSettingsActions {
  const NotificationSettingsActions(this._service);
  final NotificationService _service;

  Future<void> requestPermission() async {
    await _service.requestPermission();
  }
}

class InboxActions {
  InboxActions(this._service);
  final NotificationService _service;

  Future<String?> open(AppNotification notification) async {
    await _service.markRead(notification.id);
    return NotificationRoutes.isAllowed(notification.route)
        ? notification.route
        : null;
  }

  Future<void> markAllRead(List<AppNotification> items) async {
    await Future.wait(
      items.where((n) => !n.read).map((n) => _service.markRead(n.id)),
    );
  }
}

final inboxActionsProvider = Provider.autoDispose<InboxActions>(
  (ref) => InboxActions(ref.watch(notificationServiceProvider)),
);
