import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/proposal.dart';
import '../../router/routes.dart';
import '../../theme/app_spacing.dart';
import '../../viewmodels/proposals/proposal_view_model.dart';
import '../../widgets/app_card.dart';
import '../../widgets/fit_chip.dart';
import '../../widgets/major_slot.dart';
import '../../widgets/status_view.dart';
import '../app_shell.dart';

/// S9. Proposals across all classes owned by the signed-in mentor.
///
/// The number of cards is capped by the Remote Config parameter
/// `max_proposals_shown`, so changing the value in the Firebase Console
/// changes what the mentor sees without a new build.
class ProposalsScreen extends ConsumerWidget {
  const ProposalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proposals = ref.watch(visibleProposalsProvider);
    final pending = ref.watch(pendingProposalsProvider).value?.length ?? 0;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Proposals'),
        actions: [
          if (pending > 0)
            Padding(
              padding: const EdgeInsets.only(right: kSpaceMd),
              child: Center(child: ProposalsBadge(count: pending)),
            ),
        ],
      ),
      body: proposals.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => StatusView.error(
          message: '$error',
          onRetry: () => ref.invalidate(visibleProposalsProvider),
        ),
        data: (items) => items.isEmpty
            ? StatusView(
                icon: Icons.inbox_outlined,
                title: 'No pending proposals',
                message:
                    'Open a class to run matching or create a proposal manually.',
                actionLabel: 'View classes',
                onAction: () => context.go(Routes.classes),
              )
            : ListView.builder(
                padding: kScreenPadding,
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final proposal = items[i];
                  return ProposalCard(proposal: proposal);
                },
              ),
      ),
    );
  }
}

/// Lab 2 S9: team name, row of major slots, fit chip and the summary line.
class ProposalCard extends StatelessWidget {
  const ProposalCard({super.key, required this.proposal});

  final Proposal proposal;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return AppCard(
      onTap: () => context.push(Routes.proposal(proposal.id)),
      semanticsLabel:
          '${proposal.teamName}, ${proposal.resultingSize} members, '
          '${proposal.resultingMajorCount} majors, '
          '${proposal.fit == ProposalFit.strong ? 'strong fit' : 'good fit'}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  proposal.teamName,
                  style: text.titleMedium,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              FitChip(fit: proposal.fit),
            ],
          ),
          const SizedBox(height: kSpaceSm),
          MajorSlotRow(
            members: proposal.currentMajors,
            proposed: proposal.addMajors,
          ),
          const SizedBox(height: kSpaceSm),
          Text(
            '${proposal.resultingSize} members · '
            '${proposal.resultingMajorCount} majors · '
            '${proposal.source == ProposalSource.manual ? 'Manual' : 'AI matching'}',
            style: text.bodyMedium,
          ),
          Text(
            'Class ${proposal.classId}',
            style: text.bodySmall,
          ),
        ],
      ),
    );
  }
}
