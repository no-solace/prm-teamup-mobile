import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/class_room.dart';
import '../../router/routes.dart';
import '../../theme/app_spacing.dart';
import '../../viewmodels/classes/class_detail_view_model.dart';
import '../../viewmodels/classes/flow_a_config.dart';
import '../../viewmodels/view_state.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/stat_triple.dart';
import '../../widgets/view_state_builder.dart';
import 'flow_a_layout.dart';

/// S3.
class ClassDetailScreen extends ConsumerWidget {
  const ClassDetailScreen({super.key, required this.classId});
  final String classId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(classDetailViewModelProvider(classId));
    final room = state is Data<ClassRoom> ? state.value : null;
    final matchingEnabled = ref.watch(flowAMatchingEnabledProvider);
    return FlowAScaffold(
      title: room?.name ?? 'Class detail',
      body: ViewStateBuilder<ClassRoom>(
        state: state,
        onRetry: () =>
            ref.read(classDetailViewModelProvider(classId).notifier).retry(),
        data: (context, room) => ListView(
          padding: kScreenPadding,
          children: [
            AppCard(
              child: StatTriple(
                stats: [
                  Stat(room.studentCount, 'students'),
                  Stat(room.withoutTeamCount, 'without team'),
                  Stat(room.teamsNeedingMembers, 'need members'),
                ],
              ),
            ),
            const SizedBox(height: kSpaceLg),
            ClassDestinations(room: room),
            const SizedBox(height: kSpaceLg),
            FlowANote(
              title: 'Automated grouping',
              message:
                  'AI matching balances majors and team size (5–6 members) for the ${room.withoutTeamCount} students without a team.',
            ),
          ],
        ),
      ),
      bottom: !matchingEnabled
          ? null
          : AppButton(
              label: 'Match with AI',
              semanticsLabel: room != null && room.withoutTeamCount == 0
                  ? 'Match with AI unavailable: no students without a team'
                  : 'Match with AI',
              onPressed: room != null && room.withoutTeamCount > 0
                  ? () => context.push(Routes.matching(classId))
                  : null,
            ),
    );
  }
}

/// Shared by S3 and S23, showing counts from the class stream.
class ClassDestinations extends StatelessWidget {
  const ClassDestinations({super.key, required this.room});
  final ClassRoom room;

  @override
  Widget build(BuildContext context) => AppCard(
    child: Column(
      children: [
        ClassDestinationRow(
          label: 'Students without team',
          count: room.withoutTeamCount,
          icon: Icons.person_off_outlined,
          onTap: () => context.push(Routes.noTeam(room.id)),
        ),
        const Divider(),
        ClassDestinationRow(
          label: 'Teams needing members',
          count: room.teamsNeedingMembers,
          icon: Icons.group_add_outlined,
          onTap: () => context.push(Routes.needMembers(room.id)),
        ),
      ],
    ),
  );
}
