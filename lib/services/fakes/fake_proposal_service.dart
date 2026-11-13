import 'dart:async';

import '../../models/major.dart';
import '../../models/proposal.dart';
import '../../models/student.dart' as imported;
import '../../models/team.dart' as imported;
import '../app_error.dart';
import '../matching_drafts.dart';
import '../proposal_service.dart';
import 'fake_class_service.dart';
import 'sample_data.dart';

class FakeProposalService implements ProposalService {
  FakeProposalService({bool empty = false, this._classes}) {
    if (!empty) {
      final students = _students('class-a');
      final teams = _teams('class-a');
      if (teams.length >= 3) {
        _items.addAll(SampleData.proposals(students, teams));
      }
    }
  }

  final FakeClassService? _classes;
  final List<Proposal> _items = [];
  final _changes = StreamController<void>.broadcast();
  final Map<String, DateTime> _approvedAt = {};

  List<imported.Student> _students(String classId) =>
      _classes?.studentsFor(classId) ??
      SampleData.students().where((s) => s.classId == classId).toList();

  List<imported.Team> _teams(String classId) =>
      _classes?.teamsFor(classId) ?? SampleData.teams(_students(classId));

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

  Proposal _get(String id) => _items.firstWhere(
    (p) => p.id == id,
    orElse: () => throw const NotFoundError('Proposal not found'),
  );

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
  Stream<List<Proposal>> watchPending(String classId) => _watch(
    () => _items
        .where(
          (p) => p.classId == classId && p.status == ProposalStatus.pending,
        )
        .toList()
      // Same order as FirestoreProposalService, so the Remote Config cap
      // `max_proposals_shown` selects the same cards in tests and in the app.
      ..sort((a, b) => a.teamName.compareTo(b.teamName)),
  );

  @override
  Stream<List<Proposal>> watchAllPending() => _watch(
    () => _items
        .where((p) => p.status == ProposalStatus.pending)
        .toList()
      ..sort((a, b) => a.teamName.compareTo(b.teamName)),
  );

  @override
  Stream<Proposal> watchProposal(String proposalId) =>
      _watch(() => _get(proposalId));

  @override
  Future<List<Proposal>> savePending(
    String classId,
    List<Proposal> proposals,
  ) async {
    validateMatchingDrafts(classId, proposals);
    final plan = reconcileMatchingDrafts(
      proposed: proposals,
      existing: {
        for (final item in _items)
          if (item.classId == classId) item.id: item,
      },
      teams: {for (final team in _teams(classId)) team.id: team},
      students: {
        for (final student in _students(classId)) student.mssv: student,
      },
    );
    for (final proposal in plan.writes) {
      final existing = _items.indexWhere(
        (item) => item.id == proposal.id && item.classId == proposal.classId,
      );
      if (existing == -1) {
        _items.add(proposal);
      } else {
        _items[existing] = proposal;
      }
    }
    for (var i = 0; i < _items.length; i++) {
      final item = _items[i];
      if (item.classId == classId && plan.retire.contains(item.id)) {
        _items[i] = _withStatus(item, ProposalStatus.superseded);
      }
    }
    _changes.add(null);
    return plan.pending;
  }

  @override
  Future<Proposal> updateMembers(
    String proposalId, {
    required List<String> addStudentIds,
    required List<String> currentMemberIds,
  }) async {
    final p = _get(proposalId);
    if (p.status != ProposalStatus.pending) {
      throw const ValidationError('Only pending proposals can be edited');
    }
    final team = _teams(p.classId).where((t) => t.id == p.teamId).firstOrNull;
    if (team == null ||
        currentMemberIds.join('|') != team.memberIds.join('|')) {
      throw const ValidationError('Team changed. Refresh proposal');
    }
    if (addStudentIds.length + currentMemberIds.length > TeamRules.maxMembers ||
        addStudentIds.toSet().length != addStudentIds.length ||
        addStudentIds
            .toSet()
            .intersection(currentMemberIds.toSet())
            .isNotEmpty) {
      throw const ValidationError('Max 6 distinct members');
    }
    final byId = {for (final s in _students(p.classId)) s.mssv: s};
    if (addStudentIds.any((id) => byId[id] == null || byId[id]!.hasTeam)) {
      throw const ValidationError('Student is unavailable');
    }
    final updated = Proposal(
      id: p.id,
      classId: p.classId,
      teamId: p.teamId,
      teamName: p.teamName,
      currentMemberIds: currentMemberIds,
      currentMajors: team.majors,
      addStudentIds: addStudentIds,
      addMajors: [for (final id in addStudentIds) byId[id]!.major],
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
    if (p.status != ProposalStatus.pending) {
      throw const ValidationError('This proposal has already been handled');
    }
    if (!p.canApprove) {
      throw ValidationError(
        'Needs at least ${TeamRules.minMembers} members (now ${p.resultingSize})',
      );
    }
    _classes?.approve(p);
    _approvedAt[p.id] = DateTime.now();
    _replace(_withStatus(p, ProposalStatus.approved));
  }

  @override
  Future<void> undoApprove(String proposalId) async {
    final proposal = _get(proposalId);
    final approvedAt = _approvedAt[proposalId];
    if (proposal.status != ProposalStatus.approved ||
        approvedAt == null ||
        DateTime.now().difference(approvedAt) > const Duration(seconds: 5)) {
      throw const ValidationError('Undo period has expired');
    }
    _classes?.undo(proposal);
    _approvedAt.remove(proposalId);
    _replace(_withStatus(proposal, ProposalStatus.pending));
  }

  @override
  Future<void> discard(String proposalId) async {
    final proposal = _get(proposalId);
    if (proposal.status != ProposalStatus.pending) {
      throw const ValidationError('Only pending proposals can be discarded');
    }
    _replace(_withStatus(proposal, ProposalStatus.discarded));
  }

  @override
  Future<Proposal> createManual({
    required String classId,
    required String teamId,
    required List<String> addStudentIds,
  }) async {
    final team = _teams(classId).where((t) => t.id == teamId).firstOrNull;
    final byId = {for (final s in _students(classId)) s.mssv: s};
    if (team == null ||
        addStudentIds.isEmpty ||
        addStudentIds.toSet().length != addStudentIds.length ||
        team.size + addStudentIds.length > TeamRules.maxMembers ||
        addStudentIds.any((id) => byId[id] == null || byId[id]!.hasTeam)) {
      throw const ValidationError(
        'Choose available students and a team with room',
      );
    }
    final majors = [
      ...team.majors,
      ...addStudentIds.map((id) => byId[id]!.major),
    ];
    final p = Proposal(
      id: 'manual-${DateTime.now().microsecondsSinceEpoch}',
      classId: classId,
      teamId: teamId,
      teamName: team.name,
      currentMemberIds: team.memberIds,
      currentMajors: team.majors,
      addStudentIds: addStudentIds,
      addMajors: [for (final id in addStudentIds) byId[id]!.major],
      fit: majors.toSet().length >= TeamRules.targetMajors
          ? ProposalFit.strong
          : ProposalFit.good,
      reasons: const ['Added by you'],
      source: ProposalSource.manual,
    );
    _items.add(p);
    _changes.add(null);
    return p;
  }
}
