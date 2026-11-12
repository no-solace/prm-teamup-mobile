import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/proposal.dart';
import '../../models/student.dart';
import '../../models/team.dart';
import '../../providers/service_providers.dart';
import '../../services/app_error.dart';
import '../telemetry.dart';

final pendingProposalsProvider = StreamProvider.autoDispose<List<Proposal>>(
  (ref) => ref.watch(proposalServiceProvider).watchAllPending(),
);

/// Streams one proposal and logs view_item for it on the first emission.
final proposalDetailProvider = StreamProvider.autoDispose
    .family<Proposal, String>((ref, id) async* {
      var viewLogged = false;
      await for (final proposal
          in ref.watch(proposalServiceProvider).watchProposal(id)) {
        if (!viewLogged && ref.mounted) {
          viewLogged = true;
          unawaited(
            bestEffort(
              () => ref
                  .read(analyticsServiceProvider)
                  .logViewItem(itemCategory: 'proposal', itemId: id),
            ),
          );
        }
        yield proposal;
      }
    });

final proposalStudentsProvider = StreamProvider.autoDispose
    .family<List<Student>, String>(
      (ref, classId) => ref.watch(classServiceProvider).watchStudents(classId),
    );

final proposalTeamsProvider = StreamProvider.autoDispose
    .family<List<Team>, String>(
      (ref, classId) => ref.watch(classServiceProvider).watchTeams(classId),
    );

/// Actions centralize writes, busy state and analytics for Flows B and C.
class ProposalActionViewModel extends Notifier<bool> {
  @override
  bool build() => false;

  Future<void> logMemberLimit() async {
    try {
      await ref
          .read(analyticsServiceProvider)
          .logMemberChangeBlocked(reason: 'max_6');
    } catch (_) {
      // Analytics is best effort and must not interrupt the edit flow.
    }
  }

  Future<T> _run<T>(Future<T> Function() operation) async {
    if (state) throw const ValidationError('Another action is in progress');
    state = true;
    try {
      return await operation();
    } finally {
      state = false;
    }
  }

  Future<void> approve(Proposal proposal) => _run(() async {
    await ref.read(proposalServiceProvider).approve(proposal.id);
    try {
      await ref
          .read(analyticsServiceProvider)
          .logProposalApprove(
            memberCount: proposal.resultingSize,
            majorCount: proposal.resultingMajorCount,
            source: proposal.source.name,
            edited: false,
          );
    } catch (_) {
      // A tracking outage must not roll back a committed roster.
    }
  });

  Future<void> undo(String id) =>
      _run(() => ref.read(proposalServiceProvider).undoApprove(id));

  Future<void> discard(Proposal proposal) => _run(() async {
    await ref.read(proposalServiceProvider).discard(proposal.id);
    try {
      await ref
          .read(analyticsServiceProvider)
          .logProposalDiscard(source: proposal.source.name);
    } catch (_) {
      // Best effort.
    }
  });

  Future<Proposal> updateMembers(Proposal proposal, List<String> ids) => _run(
    () => ref
        .read(proposalServiceProvider)
        .updateMembers(
          proposal.id,
          addStudentIds: ids,
          currentMemberIds: proposal.currentMemberIds,
        ),
  );

  Future<Proposal> createManual(
    String classId,
    String teamId,
    List<String> ids,
  ) => _run(
    () => ref
        .read(proposalServiceProvider)
        .createManual(classId: classId, teamId: teamId, addStudentIds: ids),
  );
}

final proposalActionProvider = NotifierProvider<ProposalActionViewModel, bool>(
  ProposalActionViewModel.new,
);
