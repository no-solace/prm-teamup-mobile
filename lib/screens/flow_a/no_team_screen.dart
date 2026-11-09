import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/student.dart';
import '../../router/routes.dart';
import '../../theme/app_spacing.dart';
import '../../viewmodels/classes/flow_a_config.dart';
import '../../viewmodels/classes/no_team_view_model.dart';
import '../../viewmodels/view_state.dart';
import '../../widgets/app_button.dart';
import '../../widgets/major_filter_chips.dart';
import '../../widgets/status_view.dart';
import '../../widgets/student_row.dart';
import '../../widgets/view_state_builder.dart';
import 'flow_a_layout.dart';

/// S4, including distinct all-matched and filtered-empty states.
class NoTeamScreen extends ConsumerWidget {
  const NoTeamScreen({super.key, required this.classId});
  final String classId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(noTeamViewModelProvider(classId));
    final model = ref.read(noTeamViewModelProvider(classId).notifier);
    return FlowAScaffold(
      title: 'No team',
      body: Column(
        children: [
          MajorFilterChips(
            selected: state.major,
            onSelected: model.selectMajor,
          ),
          const SizedBox(height: kSpaceSm),
          Expanded(
            child: ViewStateBuilder<List<Student>>(
              state: state.students,
              onRetry: model.retry,
              empty: (_) => StatusView(
                icon: Icons.check_circle_outline,
                title: 'All matched',
                message: 'No students without a team in this class.',
                actionLabel: 'View proposals',
                onAction: () => context.go(Routes.proposals),
              ),
              data: (context, _) {
                final students = state.visibleStudents;
                if (students.isEmpty) {
                  return StatusView(
                    icon: Icons.search_off,
                    title: 'No students in this major',
                    actionLabel: 'Clear filter',
                    onAction: () => model.selectMajor(null),
                  );
                }
                return ListView.separated(
                  itemCount: students.length,
                  separatorBuilder: (_, _) => const Divider(),
                  itemBuilder: (context, i) => StudentRow(
                    student: students[i],
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () =>
                        context.push(Routes.student(classId, students[i].mssv)),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottom: !ref.watch(flowAMatchingEnabledProvider)
          ? null
          : AppButton(
              label: 'Match with AI',
              icon: Icons.auto_awesome,
              semanticsLabel: state.students is Empty<List<Student>>
                  ? 'Match with AI unavailable: no students without a team'
                  : 'Match with AI',
              onPressed: state.students is Data<List<Student>>
                  ? () => context.push(Routes.matching(classId))
                  : null,
            ),
    );
  }
}
