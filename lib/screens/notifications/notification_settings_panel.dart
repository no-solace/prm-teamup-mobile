import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/notification_service.dart';
import '../../theme/app_spacing.dart';
import '../../viewmodels/notifications/inbox_view_model.dart';
import '../../widgets/app_button.dart';

class NotificationSettingsPanel extends ConsumerStatefulWidget {
  const NotificationSettingsPanel({super.key});
  @override
  ConsumerState<NotificationSettingsPanel> createState() =>
      _NotificationSettingsPanelState();
}

class _NotificationSettingsPanelState
    extends ConsumerState<NotificationSettingsPanel>
    with WidgetsBindingObserver {
  bool _busy = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(notificationPermissionProvider);
      ref.invalidate(notificationTokenProvider);
    }
  }

  Future<void> _request() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(notificationSettingsActionsProvider).requestPermission();
      ref.invalidate(notificationPermissionProvider);
      ref.invalidate(notificationTokenProvider);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Could not update notification permission. Try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final permission = ref.watch(notificationPermissionProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Push notifications',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: kSpaceSm),
        permission.when(
          loading: () => const LinearProgressIndicator(),
          error: (_, _) => const Text('Notification permission unavailable.'),
          data: (value) => Text(switch (value) {
            NotificationPermission.granted =>
              'Allowed. Manage permission in Android Settings.',
            NotificationPermission.denied => 'Not allowed. Your inbox still works. If Android no longer prompts, enable notifications in Android Settings > Apps > TeamUp EXE.',
            NotificationPermission.notDetermined =>
              'Allow class and proposal updates on this device.',
          }),
        ),
        const SizedBox(height: kSpaceSm),
        AppButton(
          label: 'Enable / check notifications',
          icon: Icons.notifications_outlined,
          loading: _busy,
          onPressed: _request,
          variant: AppButtonVariant.tonal,
        ),
        if (_error != null)
          Text(_error!, style: Theme.of(context).textTheme.bodyMedium),
        if (ref.watch(notificationIssueProvider).value
            case final String message) ...[
          const SizedBox(height: kSpaceSm),
          Text(message),
        ],
      ],
    );
  }
}
