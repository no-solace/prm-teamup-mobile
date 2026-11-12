import '../models/proposal.dart';

/// Owner: Cuong. Team-matching proposals (Flow B; Flow C reuses approve/discard).
abstract interface class ProposalService {
  Stream<List<Proposal>> watchPending(String classId);

  /// Pending proposals of every class of the mentor (tab Proposals, S9).
  Stream<List<Proposal>> watchAllPending();

  Stream<Proposal> watchProposal(String proposalId);

  /// Reconcile AI drafts for the class and return the pending drafts selected
  /// by this run. An empty run can still retire stale drafts.
  Future<List<Proposal>> savePending(String classId, List<Proposal> proposals);

  /// Change the students added by a proposal (S11, S24). Throws
  /// [ValidationError] when the team would exceed 6 (S13).
  Future<Proposal> updateMembers(String proposalId, {required List<String> addStudentIds, required List<String> currentMemberIds});

  /// Writes team + students + proposal in one batch (D11). Throws
  /// [ValidationError] when the team is outside 5..6 (S25).
  Future<void> approve(String proposalId);

  /// Reverses the last approve (S14 Undo, 5 seconds).
  Future<void> undoApprove(String proposalId);

  Future<void> discard(String proposalId);

  /// Hand-built proposal from S16 (S20, source = manual).
  Future<Proposal> createManual({required String classId, required String teamId, required List<String> addStudentIds});
}
