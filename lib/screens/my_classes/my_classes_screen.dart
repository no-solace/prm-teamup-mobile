import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/class_room.dart';
import '../../router/routes.dart';
import '../../theme/app_spacing.dart';
import '../../viewmodels/classes/my_classes_view_model.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_view.dart';
import '../../widgets/view_state_builder.dart';

/// S2 My classes. Owner: Dan.
/// REFERENCE SCREEN: watch the ViewModel, render with ViewStateBuilder,
/// navigate with Routes helpers. Copy this shape for every data screen.
class MyClassesScreen extends ConsumerWidget {
  const MyClassesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(myClassesViewModelProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('My classes')),
      body: ViewStateBuilder<List<ClassRoom>>(
        state: state,
        onRetry: () => ref.read(myClassesViewModelProvider.notifier).retry(),
        empty: (context) => StatusView(
          icon: Icons.school_outlined,
          title: 'No classes yet',
          message: 'Import a class list to get started.',
          actionLabel: 'Import class list',
          onAction: () => context.go(Routes.importClass),
        ),
        data: (context, classes) => RefreshIndicator(
          onRefresh: () async =>
              ref.read(myClassesViewModelProvider.notifier).retry(),
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: kMaxContentWidth),
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: kScreenPadding,
                itemCount: classes.length + 1,
                separatorBuilder: (_, _) => const SizedBox(height: kSpaceMd),
                itemBuilder: (context, i) => i < classes.length
                    ? _ClassCard(classRoom: classes[i])
                    : AppButton(
                        label: 'Import class list',
                        icon: Icons.upload_file,
                        variant: AppButtonVariant.tonal,
                        onPressed: () => context.go(Routes.importClass),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ClassCard extends StatelessWidget {
  const _ClassCard({required this.classRoom});

  final ClassRoom classRoom;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final status = classRoom.allMatched
        ? 'All matched'
        : '${classRoom.withoutTeamCount} without a team, ${classRoom.teamsNeedingMembers} teams need members';
    return AppCard(
      semanticsLabel:
          '${classRoom.name}, ${classRoom.studentCount} students, $status',
      onTap: () => context.go(Routes.classDetail(classRoom.id)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(
          minHeight: kTouchTarget * 2 - kSpaceXl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    classRoom.name,
                    style: text.titleMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: kSpaceSm),
                Text(
                  '${classRoom.studentCount} students',
                  style: text.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: kSpaceSm),
            const Divider(),
            const SizedBox(height: kSpaceSm),
            _StatusLine(
              icon: Icons.group_outlined,
              label: '${classRoom.withoutTeamCount} without team',
            ),
            const SizedBox(height: kSpaceSm),
            _StatusLine(
              icon: classRoom.allMatched
                  ? Icons.check_circle_outline
                  : Icons.group_add_outlined,
              label: classRoom.allMatched
                  ? 'All matched'
                  : '${classRoom.teamsNeedingMembers} teams need members',
              color: classRoom.allMatched ? scheme.tertiary : null,
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  const _StatusLine({required this.icon, required this.label, this.color});
  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Icon(icon, color: color),
      const SizedBox(width: kSpaceSm),
      Expanded(
        child: Text(
          label,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: color),
        ),
      ),
    ],
  );
}
