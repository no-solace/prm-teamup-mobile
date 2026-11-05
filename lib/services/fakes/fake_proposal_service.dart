import 'dart:async';

import '../../models/major.dart';
import '../../models/proposal.dart';
import '../app_error.dart';
import '../proposal_service.dart';
import 'sample_data.dart';

class FakeProposalService implements ProposalService {
  FakeProposalService({bool empty = false}) {
    if (!empty) {
      final students = SampleData.students();
      _items.addAll(SampleData.proposals(students, SampleData.teams(students)));
    }
  }

  final List<Proposal> _items = [];
  final _changes = StreamController<void>.broadcast();

  Stream<T> _watch<T>(T Function() read) async* {
    yield read();
    await for (final _ in _changes.stream) {
      yield read();
    }
  }

  void _replace(Proposal p) {
    final i = _items.indexWhere((e) => e.id == p.id);
    if (i >= 0) _items[i] = p;
    _changes.add(null);
  }

  Proposal _get(String id) =>
      _items.firstWhere((p) => p.id == id, orElse: () => throw const NotFoundError('Proposal not found'));

  Proposal _withStatus(Proposal p, ProposalStatus status) => Proposal(
        id: p.id,
        classId: p.classId,
        teamId: p.teamId,
        teamName: p.teamName,
        currentMemberIds: p.currentMemberIds,
        currentMajors: p.currentMajors,
        addStudentIds: p.addStudentIds,
        addMajors: p.addMajors,
        fit: p.fit,
        reasons: p.reasons,
        status: status,
        source: p.source,
      );

  @override
  Stream<List<Proposal>> watchPending(String classId) =>
      _watch(() => _items.where((p) => p.classId == classId && p.status == ProposalStatus.pending).toList());

  @override
  Stream<List<Proposal>> watchAllPending() =>
      _watch(() => _items.where((p) => p.status == ProposalStatus.pending).toList());

  @override
  Stream<Proposal> watchProposal(String proposalId) => _watch(() => _get(proposalId));

  @override
  Future<void> savePending(List<Proposal> proposals) async {
    _items
      ..removeWhere((p) => p.status == ProposalStatus.pending)
      ..addAll(proposals);
    _changes.add(null);
  }

  @override
  Future<Proposal> updateMembers(String proposalId,
      {required List<String> addStudentIds, required List<String> currentMemberIds}) async {
    if (addStudentIds.length + currentMemberIds.length > TeamRules.maxMembers) {
      throw const ValidationError('Max 6 members');
    }
    final p = _get(proposalId);
    final updated = Proposal(
      id: p.id,
      classId: p.classId,
      teamId: p.teamId,
      teamName: p.teamName,
      currentMemberIds: currentMemberIds,
      currentMajors: p.currentMajors.take(currentMemberIds.length).toList(),
      addStudentIds: addStudentIds,
      addMajors: p.addMajors.take(addStudentIds.length).toList(),
      fit: p.fit,
      reasons: p.reasons,
      source: p.source,
    );
    _replace(updated);
    return updated;
  }

  @override
  Future<void> approve(String proposalId) async {
    final p = _get(proposalId);
    if (!p.canApprove) {
      throw ValidationError('Needs at least ${TeamRules.minMembers} members (now ${p.resultingSize})');
    }
    _replace(_withStatus(p, ProposalStatus.approved));
  }

  @override
  Future<void> undoApprove(String proposalId) async => _replace(_withStatus(_get(proposalId), ProposalStatus.pending));

  @override
  Future<void> discard(String proposalId) async => _replace(_withStatus(_get(proposalId), ProposalStatus.discarded));

  @override
  Future<Proposal> createManual(
      {required String classId, required String teamId, required List<String> addStudentIds}) async {
    final p = Proposal(
      id: 'manual-${DateTime.now().millisecondsSinceEpoch}',
      classId: classId,
      teamId: teamId,
      teamName: 'FinLite',
      currentMemberIds: const ['190701', '190702', '190703', '190704'],
      currentMajors: const [Major.mkt, Major.se, Major.gd, Major.se],
      addStudentIds: addStudentIds,
      addMajors: const [Major.ai],
      fit: ProposalFit.good,
      reasons: const ['Added by you'],
      source: ProposalSource.manual,
    );
    _items.add(p);
    _changes.add(null);
    return p;
  }
}
