import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_router.dart';
import '../../router/routes.dart';

import '../../theme/app_spacing.dart';
import '../../viewmodels/auth/session_view_model.dart';
import '../../viewmodels/notifications/inbox_view_model.dart';
import '../../viewmodels/profile/profile_view_model.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/error_banner.dart';
import '../notifications/config_demo_panel.dart';
import 'report_demo_panel.dart';

/// S6 Profile. Owner: Ken (profile), Cuong (Firebase demo section).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider).value;
    final vm = ref.read(profileViewModelProvider.notifier);
    final state = ref.watch(profileViewModelProvider);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: ListView(
        padding: kScreenPadding,
        children: [
          Center(
            child: CircleAvatar(
              radius: kSpaceXl,
              backgroundColor: scheme.primaryContainer,
              foregroundColor: scheme.onPrimaryContainer,
              child: Text(user?.initials ?? '?', style: text.titleLarge),
            ),
          ),
          const SizedBox(height: kSpaceSm),
          Center(child: Text(user?.displayName ?? '', style: text.titleLarge)),
          Center(
            child: Text(
              user?.roleLabel ?? '',
              style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
            ),
          ),
          if (user?.email != null)
            Center(
              child: Text(
                user!.email!,
                style: text.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          if (user?.phoneNumber != null)
            Center(
              child: Text(
                user!.phoneNumber!,
                style: text.bodyMedium?.copyWith(
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ),
          const SizedBox(height: kSpaceLg),
          ListTile(
            leading: const Icon(Icons.notifications_outlined),
            title: const Text('Notifications'),
            subtitle: Text('${ref.watch(unreadCountProvider)} unread'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.notifications),
          ),
          const ListTile(
            leading: Icon(Icons.language),
            title: Text('Language'),
            trailing: Text('English'),
          ),
          const SizedBox(height: kSpaceLg),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Firebase demo', style: text.titleMedium),
                const SizedBox(height: kSpaceSm),
                const ConfigDemoPanel(),
                // Class reports read mentor-owned data only.
                if (user?.isMentor ?? false) ...[
                  const SizedBox(height: kSpaceMd),
                  const ReportDemoPanel(),
                ],
                const SizedBox(height: kSpaceMd),
                AppButton(
                  label: 'Test crash',
                  variant: AppButtonVariant.tonal,
                  icon: Icons.bug_report_outlined,
                  onPressed: vm.testCrash,
                ),
              ],
            ),
          ),
          if (ref.watch(galleryEnabledProvider))
            ListTile(
              leading: const Icon(Icons.widgets_outlined),
              title: const Text('Widget gallery (dev)'),
              onTap: () => context.push(Routes.gallery),
            ),
          const SizedBox(height: kSpaceLg),
          if (state.error != null) ErrorBanner(message: state.error!.message),
          AppButton(
            label: 'Sign out',
            variant: AppButtonVariant.text,
            loading: state.signingOut,
            onPressed: vm.signOut,
          ),
        ],
      ),
    );
  }
}
