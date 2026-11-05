import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_router.dart';
import '../../router/routes.dart';

import '../../theme/app_spacing.dart';
import '../../viewmodels/auth/session_view_model.dart';
import '../../viewmodels/profile/profile_view_model.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';

/// S6 Profile. Owner: Ken (profile), Cuong (Firebase demo section).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider).value;
    final vm = ref.read(profileViewModelProvider.notifier);
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
          Center(child: Text('Mentor', style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant))),
          if (user?.email != null)
            Center(child: Text(user!.email!, style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant))),
          const SizedBox(height: kSpaceLg),
          // TODO(Dan): bind to NotificationService permission (POST_NOTIFICATIONS).
          const ListTile(
            leading: Icon(Icons.notifications_outlined),
            title: Text('Notifications'),
            trailing: Switch(value: true, onChanged: null),
          ),
          const ListTile(
            leading: Icon(Icons.language),
            title: Text('Language'),
            trailing: Text('English'),
          ),
          const SizedBox(height: kSpaceLg),
          // TODO(Cuong): Firebase demo section (FCM token, Remote Config values,
          // last fetch status, upload test). Lab 3 demo only.
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Firebase demo', style: text.titleMedium),
                const SizedBox(height: kSpaceSm),
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
          AppButton(label: 'Sign out', variant: AppButtonVariant.text, onPressed: vm.signOut),
        ],
      ),
    );
  }
}
