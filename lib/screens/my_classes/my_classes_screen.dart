import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/class_room.dart';
import '../../router/routes.dart';
import '../../theme/app_spacing.dart';
import '../../viewmodels/classes/my_classes_view_model.dart';
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
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.go(Routes.importClass),
        icon: const Icon(Icons.upload_file),
        label: const Text('Import class'),
      ),
      body: ViewStateBuilder<List<ClassRoom>>(
        state: state,
        onRetry: () => ref.read(myClassesViewModelProvider.notifier).retry(),
        empty: (context) => StatusView(
          icon: Icons.school_outlined,
          title: 'No classes yet',
          message: 'Import a class list to get started.',
          actionLabel: 'Import class',
          onAction: () => context.go(Routes.importClass),
        ),
        data: (context, classes) => ListView.separated(
          padding: kScreenPadding,
          itemCount: classes.length,
          separatorBuilder: (_, _) => const SizedBox(height: kSpaceSm),
          itemBuilder: (context, i) => _ClassCard(classRoom: classes[i]),
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
      semanticsLabel: '${classRoom.name}, ${classRoom.studentCount} students, $status',
      onTap: () => context.go(Routes.classDetail(classRoom.id)),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(classRoom.name, style: text.titleMedium),
                const SizedBox(height: kSpaceXs),
                Text('${classRoom.studentCount} students', style: text.bodyMedium),
                Text(status, style: text.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
          Icon(Icons.chevron_right, color: scheme.onSurfaceVariant),
        ],
      ),
    );
  }
}
