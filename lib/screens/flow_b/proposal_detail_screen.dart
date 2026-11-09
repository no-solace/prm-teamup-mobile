import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/proposal.dart';
import '../../router/routes.dart';
import '../../theme/app_spacing.dart';
import '../../viewmodels/proposals/proposal_view_model.dart';
import '../../viewmodels/view_state.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_view.dart';
import '../flow_a/flow_a_layout.dart';

/// S10/S12/S14/S17/S20/S24/S25.
class ProposalDetailScreen extends ConsumerWidget {
  const ProposalDetailScreen({super.key, required this.proposalId});
  final String proposalId;

  Future<bool> _confirm(
    BuildContext context,
    String title,
    String details,
  ) async =>
      await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: Text(title),
          content: Text(details),
          actions: [
            TextButton(
              onPressed: () => context.pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => context.pop(true),
              child: const Text('Confirm'),
            ),
          ],
        ),
      ) ??
      false;

  void _message(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            Text(
              proposal.teamName,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: kSpaceSm),
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
                    'Suggested members',
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
                                      final confirmed = await _confirm(
                                        context,
                                        'Remove member?',
                                        'Remove this student from the proposal?',
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
              const SizedBox(height: kSpaceLg),
              AppButton(
                label: 'Add member',
                variant: AppButtonVariant.tonal,
                onPressed: busy
                    ? null
                    : () => context.push(Routes.addMember(proposal.id)),
              ),
              const SizedBox(height: kSpaceSm),
              if (!proposal.canApprove)
                const Text('Approval needs at least 5 and at most 6 members.'),
              AppButton(
                label: 'Approve proposal',
                loading: busy,
                onPressed: !proposal.canApprove || busy
                    ? null
                    : () async {
                        final confirmed = await _confirm(
                          context,
                          'Approve team?',
                          'Assign ${proposal.addStudentIds.length} students to ${proposal.teamName}?',
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
                              content: const Text('Team approved'),
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
                        final confirmed = await _confirm(
                          context,
                          'Discard proposal?',
                          'This suggestion will be removed from pending proposals.',
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
