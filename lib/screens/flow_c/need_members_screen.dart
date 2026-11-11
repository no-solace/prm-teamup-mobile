import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/major.dart';
import '../../router/routes.dart';
import '../../theme/app_spacing.dart';
import '../../viewmodels/proposals/proposal_view_model.dart';
import '../../widgets/app_card.dart';
import '../../widgets/major_slot.dart';
import '../../widgets/status_view.dart';
import '../flow_a/flow_a_layout.dart';

/// S5. Teams with a vacant place can start a manual proposal.
///
/// Lab 2 S5 shows the row of major slots (40 dp) and the line
/// "Needs `majors` to reach 5".
class NeedMembersScreen extends ConsumerWidget {
  const NeedMembersScreen({super.key, required this.classId});
  final String classId;

  @override
  Widget build(BuildContext context, WidgetRef ref) => FlowAScaffold(
    title: 'Teams needing members',
    body: ref
        .watch(proposalTeamsProvider(classId))
        .when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, _) => StatusView.error(
            message: '$error',
            onRetry: () => ref.invalidate(proposalTeamsProvider(classId)),
          ),
          data: (teams) {
            final candidates = teams.where((team) => !team.isFull).toList();
            if (candidates.isEmpty) {
              return const StatusView(
                icon: Icons.check_circle_outline,
                title: 'All teams are full',
              );
            }
            return ListView.builder(
              padding: kScreenPadding,
              itemCount: candidates.length,
              itemBuilder: (context, i) {
                final team = candidates[i];
                final missing = team.missingMajors.toList();
                return AppCard(
                  onTap: () => context.push(
                    Routes.addStudent(classId, teamId: team.id),
                  ),
                  semanticsLabel:
                      '${team.name}, ${team.size} members, '
                      'needs ${missing.length} more',
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              team.name,
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                      const SizedBox(height: kSpaceSm),
                      Text('${team.size} members'),
                      const SizedBox(height: kSpaceSm),
                      MajorSlotRow(members: team.majors),
                      const SizedBox(height: kSpaceSm),
                      Text(
                        missing.isEmpty
                            ? 'Full to reach 6'
                            : 'Needs ${missing.map((m) => m.code).join(', ')} '
                                  'to reach ${TeamRules.minMembers}',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
  );
}
