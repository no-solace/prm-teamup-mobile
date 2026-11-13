import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/major.dart';
import '../../models/proposal.dart';
import '../../viewmodels/proposals/proposal_view_model.dart';
import '../../viewmodels/view_state.dart';
import '../../widgets/app_button.dart';
import '../../widgets/proposal_student_picker.dart';
import '../../widgets/status_view.dart';
import '../flow_a/flow_a_layout.dart';

/// S11 and S13. Changes stay in a draft until the mentor approves S12.
///
/// S13: when the team is full the picker refuses the extra pick, shows
/// "Max 6 members" and this screen locks its confirm button until the
/// selection is fixed.
class AddMemberScreen extends ConsumerStatefulWidget {
  const AddMemberScreen({super.key, required this.proposalId});
  final String proposalId;

  @override
  ConsumerState<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends ConsumerState<AddMemberScreen> {
  Set<String>? _selected;

  /// False while the S13 error is on screen: the confirm button is locked.
  bool _selectionValid = true;

  @override
  Widget build(BuildContext context) {
    final proposal = ref.watch(proposalDetailProvider(widget.proposalId));
    final busy = ref.watch(proposalActionProvider);
    return FlowAScaffold(
      title: 'Add member',
      body: proposal.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => StatusView.error(message: '$error'),
        data: (value) {
          if (value.status != ProposalStatus.pending) {
            return const StatusView(
              icon: Icons.info_outline,
              title: 'Proposal has been handled',
            );
          }
          _selected ??= value.addStudentIds.toSet();
          final members = ref.watch(proposalStudentsProvider(value.classId));
          return members.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, _) => StatusView.error(
              message: '$error',
              onRetry: () =>
                  ref.invalidate(proposalStudentsProvider(value.classId)),
            ),
            data: (students) => ProposalStudentPicker(
              students: students
                  .where((s) => !value.currentMemberIds.contains(s.mssv))
                  .toList(),
              selected: _selected!,
              capacity: TeamRules.maxMembers - value.currentMemberIds.length,
              teamName: value.teamName,
              currentSize: value.currentMemberIds.length,
              onChanged: (next) => setState(() => _selected = next),
              onValidityChanged: (valid) =>
                  setState(() => _selectionValid = valid),
              onLimit: () async =>
                  ref.read(proposalActionProvider.notifier).logMemberLimit(),
            ),
          );
        },
      ),
      bottom:
          proposal.value == null ||
              proposal.value!.status != ProposalStatus.pending
          ? null
          : AppButton(
              label: 'Save selection',
              loading: busy,
              // S13: the button is locked exactly while the error is visible.
              onPressed: busy || !_selectionValid
                  ? null
                  : () async {
                      try {
                        final value = proposal.value!;
                        final selected =
                            _selected ?? value.addStudentIds.toSet();
                        await ref
                            .read(proposalActionProvider.notifier)
                            .updateMembers(value, selected.toList()..sort());
                        if (context.mounted) context.pop();
                      } catch (error) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text(toAppError(error).message)),
                          );
                        }
                      }
                    },
            ),
    );
  }
}
