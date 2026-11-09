import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../router/routes.dart';
import '../../theme/app_spacing.dart';
import '../../viewmodels/classes/student_detail_view_model.dart';
import '../../viewmodels/view_state.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/student_row.dart';
import '../../widgets/view_state_builder.dart';
import 'flow_a_layout.dart';

/// S7. In selection mode, pop the MSSV to the caller (S11); otherwise open
/// Flow C's team-selection route with this student as a suggested selection.
class StudentDetailScreen extends ConsumerWidget {
  const StudentDetailScreen({
    super.key,
    required this.classId,
    required this.studentId,
    this.selectionMode = false,
  });
  final String classId;
  final String studentId;
  final bool selectionMode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final key = (classId: classId, studentId: studentId);
    final state = ref.watch(studentDetailViewModelProvider(key));
    final profile = state is Data<StudentProfile> ? state.value : null;
    final student = profile?.student;
    return FlowAScaffold(
      title: student?.fullName ?? 'Student detail',
      body: ViewStateBuilder<StudentProfile>(
        state: state,
        onRetry: () =>
            ref.read(studentDetailViewModelProvider(key).notifier).retry(),
        data: (context, profile) => ListView(
          padding: kScreenPadding,
          children: [
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  StudentRow(student: profile.student),
                  const Divider(),
                  Chip(
                    avatar: Icon(
                      profile.student.hasTeam
                          ? Icons.group_outlined
                          : Icons.person_off_outlined,
                    ),
                    label: Text(
                      profile.student.hasTeam ? 'In a team' : 'No team',
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: kSpaceLg),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Student info',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: kSpaceSm),
                  FlowAInfoRow(
                    label: 'Student ID',
                    value: profile.student.mssv,
                  ),
                  const Divider(),
                  FlowAInfoRow(label: 'Class', value: profile.className),
                  const Divider(),
                  FlowAInfoRow(
                    label: 'Group',
                    value: profile.student.teamId ?? 'None',
                  ),
                  const Divider(),
                  FlowAInfoRow(
                    label: 'Major',
                    value: profile.student.major.code,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottom: AppButton(
        label: 'Add to team',
        semanticsLabel: student?.hasTeam == true
            ? 'Add to team unavailable: student is already in a team'
            : 'Add to team',
        onPressed: student == null || student.hasTeam
            ? null
            : () {
                if (selectionMode && context.canPop()) {
                  context.pop(student.mssv);
                } else {
                  context.push(
                    Routes.addStudent(classId, studentId: student.mssv),
                  );
                }
              },
      ),
    );
  }
}
