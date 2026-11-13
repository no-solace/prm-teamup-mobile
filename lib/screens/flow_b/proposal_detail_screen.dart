import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/major.dart';
import '../../models/proposal.dart';
import '../../router/routes.dart';
import '../../theme/app_spacing.dart';
import '../../viewmodels/proposals/proposal_view_model.dart';
import '../../viewmodels/view_state.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/error_banner.dart';
import '../../widgets/fit_chip.dart';
import '../../widgets/major_slot.dart';
import '../../widgets/status_view.dart';
import '../flow_a/flow_a_layout.dart';

/// S10/S12/S14/S17/S20/S24/S25.
///
/// The Lab 2 components are used as designed: the row of major slots
/// (48 dp on S10), the fit chip, the "Added by you" tag on a hand-built team
/// and the shared confirmation dialog.
class ProposalDetailScreen extends ConsumerWidget {
  const ProposalDetailScreen({super.key, required this.proposalId});
  final String proposalId;

  void _message(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // view_item is logged once per visit (docs/analytics-plan.md).
    ref.watch(proposalViewTrackerProvider(proposalId));
    final result = ref.watch(proposalDetailProvider(proposalId));
    final busy = ref.watch(proposalActionProvider);
    final actions = ref.read(proposalActionProvider.notifier);
    return FlowAScaffold(
      title: 'Proposal detail',
      body: result.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => StatusView.error(
          message: '$error',
          onRetry: () => ref.invalidate(proposalDetailProvider(proposalId)),
        ),
        data: (proposal) => ListView(
          padding: kScreenPadding,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    proposal.teamName,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                FitChip(fit: proposal.fit),
              ],
            ),
            const SizedBox(height: kSpaceSm),
            if (proposal.source == ProposalSource.manual)
              const TagChip(label: 'Added by you'),
            const SizedBox(height: kSpaceSm),
            // S10 uses the 48 dp major slot row.
            MajorSlotRow(
              members: proposal.currentMajors,
              proposed: proposal.addMajors,
              size: kMajorSlotLarge,
            ),
            const SizedBox(height: kSpaceMd),
            Wrap(
              spacing: kSpaceSm,
              children: [
                Chip(label: Text('${proposal.resultingSize}/6 members')),
                Chip(label: Text('${proposal.resultingMajorCount} majors')),
                Chip(
                  label: Text(
                    proposal.source == ProposalSource.manual
                        ? 'Manual'
                        : 'AI matching',
                  ),
                ),
                Chip(label: Text(proposal.status.name)),
              ],
            ),
            const SizedBox(height: kSpaceMd),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Current members',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  for (var i = 0; i < proposal.currentMemberIds.length; i++)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.person_outline),
                      title: Text(proposal.currentMemberIds[i]),
                      subtitle: Text(proposal.currentMajors[i].code),
                    ),
                  const Divider(),
                  Text(
                    'New member',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  for (var i = 0; i < proposal.addStudentIds.length; i++)
                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(proposal.addStudentIds[i]),
                      subtitle: Text(proposal.addMajors[i].code),
                      trailing: proposal.status == ProposalStatus.pending
                          ? IconButton(
                              tooltip: 'Remove proposed member',
                              icon: const Icon(Icons.remove_circle_outline),
                              onPressed: busy
                                  ? null
                                  : () async {
                                      final remaining =
                                          proposal.resultingSize - 1;
                                      final confirmed = await showConfirmDialog(
                                        context,
                                        title: 'Remove member?',
                                        message:
                                            'Team will have $remaining members.',
                                        confirmLabel: 'Remove',
                                        destructive: true,
                                      );
                                      if (!confirmed || !context.mounted) {
                                        return;
                                      }
                                      try {
                                        await actions.updateMembers(proposal, [
                                          for (final id
                                              in proposal.addStudentIds)
                                            if (id != proposal.addStudentIds[i])
                                              id,
                                        ]);
                                      } catch (error) {
                                        if (context.mounted) {
                                          _message(
                                            context,
                                            toAppError(error).message,
                                          );
                                        }
                                      }
                                    },
                            )
                          : null,
                    ),
                  if (proposal.addStudentIds.isEmpty)
                    const Text('No new members selected.'),
                ],
              ),
            ),
            const SizedBox(height: kSpaceMd),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Why this team?',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  for (final reason in proposal.reasons)
                    Padding(
                      padding: const EdgeInsets.only(top: kSpaceSm),
                      child: Text('• $reason'),
                    ),
                ],
              ),
            ),
            if (proposal.status == ProposalStatus.pending) ...[
              const SizedBox(height: kSpaceMd),
              // S25: the approval is blocked below five members and the
              // reason is shown, not just a disabled button.
              if (!proposal.canApprove)
                ErrorBanner(
                  message: proposal.resultingSize < TeamRules.minMembers
                      ? 'Needs at least ${TeamRules.minMembers} members '
                            '(now ${proposal.resultingSize})'
                      : 'A team can have at most ${TeamRules.maxMembers} members',
                ),
              const SizedBox(height: kSpaceMd),
              AppButton(
                label: 'Add member',
                variant: AppButtonVariant.tonal,
                onPressed: busy
                    ? null
                    : () => context.push(Routes.addMember(proposal.id)),
              ),
              const SizedBox(height: kSpaceSm),
              AppButton(
                label: 'Approve proposal',
                loading: busy,
                onPressed: !proposal.canApprove || busy
                    ? null
                    : () async {
                        final confirmed = await showConfirmDialog(
                          context,
                          title: 'Approve team?',
                          message:
                              'Students will be notified. '
                              '${proposal.addStudentIds.length} students are '
                              'assigned to ${proposal.teamName}.',
                          confirmLabel: 'Approve',
                        );
                        if (!confirmed || !context.mounted) return;
                        try {
                          await actions.approve(proposal);
                          if (!context.mounted) return;
                          final messenger = ScaffoldMessenger.of(context);
                          messenger.clearSnackBars();
                          messenger.showSnackBar(
                            SnackBar(
                              duration: const Duration(seconds: 5),
                              content: const Text('Approved'),
                              action: SnackBarAction(
                                label: 'Undo',
                                onPressed: () async {
                                  try {
                                    await actions.undo(proposal.id);
                                    if (context.mounted) {
                                      _message(context, 'Approval undone');
                                    }
                                  } catch (error) {
                                    if (context.mounted) {
                                      _message(
                                        context,
                                        toAppError(error).message,
                                      );
                                    }
                                  }
                                },
                              ),
                            ),
                          );
                        } catch (error) {
                          if (context.mounted) {
                            _message(context, toAppError(error).message);
                          }
                        }
                      },
              ),
              const SizedBox(height: kSpaceSm),
              AppButton(
                label: 'Discard proposal',
                variant: AppButtonVariant.destructive,
                onPressed: busy
                    ? null
                    : () async {
                        final confirmed = await showConfirmDialog(
                          context,
                          title: 'Discard proposal?',
                          message: 'AI will not suggest it again.',
                          confirmLabel: 'Discard',
                          destructive: true,
                        );
                        if (!confirmed || !context.mounted) return;
                        try {
                          await actions.discard(proposal);
                          if (context.mounted) context.go(Routes.proposals);
                        } catch (error) {
                          if (context.mounted) {
                            _message(context, toAppError(error).message);
                          }
                        }
                      },
              ),
            ],
          ],
        ),
      ),
    );
  }
}
