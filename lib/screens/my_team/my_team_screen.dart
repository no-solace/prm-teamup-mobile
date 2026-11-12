import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_spacing.dart';
import '../../viewmodels/auth/session_view_model.dart';
import '../../viewmodels/classes/my_team_view_model.dart';
import '../../widgets/action_feedback.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_view.dart';
import '../my_classes/my_classes_screen.dart';

/// Tab 1: mentors see their classes (S2), students their own team.
class ClassesTab extends ConsumerWidget {
  const ClassesTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) =>
      ref.watch(sessionProvider).value?.isStudent ?? false
      ? const MyTeamScreen()
      : const MyClassesScreen();
}

class MyTeamScreen extends ConsumerWidget {
  const MyTeamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider).value;
    final team = ref.watch(myTeamProvider);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('My team')),
      body: team.when(
        loading: () => const LoadingView(),
        error: (e, _) => StatusView.error(
          message: errorText(e),
          onRetry: () => ref.invalidate(myTeamProvider),
        ),
        data: (t) => ListView(
          padding: kScreenPadding,
          children: [
            Text(t.team.name, style: text.headlineSmall),
            const SizedBox(height: kSpaceXs),
            Text('${t.team.size} members · ${user?.roleLabel ?? ''} · class code ${user?.classId ?? ''}'),
            const SizedBox(height: kSpaceMd),
            for (final m in t.members)
              AppCard(
                child: Row(
                  children: [
                    Expanded(child: Text(m.fullName, style: text.titleMedium)),
                    Text('${m.mssv} · ${m.major.code}'),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
