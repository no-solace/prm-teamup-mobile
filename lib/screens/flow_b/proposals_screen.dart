import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/proposal.dart';
import '../../router/routes.dart';
import '../../theme/app_spacing.dart';
import '../../viewmodels/proposals/proposal_view_model.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_view.dart';

/// S9. Proposals across all classes owned by the signed-in mentor.
class ProposalsScreen extends ConsumerWidget {
  const ProposalsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final proposals = ref.watch(pendingProposalsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Proposals')),
      body: proposals.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => StatusView.error(
          message: '$error',
          onRetry: () => ref.invalidate(pendingProposalsProvider),
        ),
        data: (items) => items.isEmpty
            ? StatusView(
                icon: Icons.inbox_outlined,
                title: 'No pending proposals',
                message: 'Open a class to run matching or create a proposal manually.',
                actionLabel: 'View classes',
                onAction: () => context.go(Routes.classes),
              )
            : ListView.builder(
                padding: kScreenPadding,
                itemCount: items.length,
                itemBuilder: (context, i) {
                  final proposal = items[i];
                  return AppCard(
                    onTap: () => context.push(Routes.proposal(proposal.id)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                proposal.teamName,
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        const SizedBox(height: kSpaceSm),
                        Text(
                          '${proposal.resultingSize} members · '
                          '${proposal.resultingMajorCount} majors · '
                          '${proposal.source == ProposalSource.manual ? 'Manual' : 'AI matching'}',
                        ),
                        const SizedBox(height: kSpaceXs),
                        Text(
                          'Class ${proposal.classId} · '
                          '${proposal.fit == ProposalFit.strong ? 'Strong fit' : 'Good fit'}',
                        ),
                      ],
                    ),
                  );
                },
              ),
      ),
    );
  }
}
