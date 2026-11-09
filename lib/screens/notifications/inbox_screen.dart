import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_spacing.dart';
import '../../viewmodels/notifications/inbox_view_model.dart';
import '../../widgets/status_view.dart';
import 'notification_settings_panel.dart';

class InboxScreen extends ConsumerWidget {
  const InboxScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inbox = ref.watch(inboxProvider);
    return Scaffold(
      appBar: AppBar(
        title: Text('Notifications (${ref.watch(unreadCountProvider)} unread)'),
        actions: [
          IconButton(
            tooltip: 'Mark all read',
            icon: const Icon(Icons.done_all),
            onPressed: () async {
              try {
                await ref
                    .read(inboxActionsProvider)
                    .markAllRead(inbox.value ?? []);
              } catch (_) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Could not mark all messages read. Try again.',
                      ),
                    ),
                  );
                }
              }
            },
          ),
        ],
      ),
      body: ListView(
        children: [
          const Padding(
            padding: kScreenPadding,
            child: NotificationSettingsPanel(),
          ),
          inbox.when(
            loading: () => const LoadingView(),
            error: (_, _) => StatusView.error(
              message: 'Could not load notifications.',
              onRetry: () => ref.invalidate(inboxProvider),
            ),
            data: (items) => items.isEmpty
                ? const StatusView(
                    icon: Icons.notifications_none,
                    title: 'No notifications yet',
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: items.length,
                    separatorBuilder: (_, _) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return Semantics(
                        label:
                            '${item.read ? 'Read' : 'Unread'}: ${item.title}',
                        child: ListTile(
                          leading: Icon(
                            item.read
                                ? Icons.drafts_outlined
                                : Icons.mark_email_unread_outlined,
                          ),
                          title: Text(item.title),
                          subtitle: Text(
                            '${item.body}\n${item.read ? 'Read' : 'Unread'} · ${item.receivedAt.toLocal()}',
                          ),
                          isThreeLine: true,
                          onTap: () async {
                            try {
                              final route = await ref
                                  .read(inboxActionsProvider)
                                  .open(item);
                              if (context.mounted && route != null) {
                                context.go(route);
                              }
                            } catch (_) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'Could not open this notification. Try again.',
                                    ),
                                  ),
                                );
                              }
                            }
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
