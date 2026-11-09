import 'dart:convert';

import '../models/major.dart';
import '../models/proposal.dart';
import '../models/student.dart';
import '../models/team.dart';
import 'app_error.dart';
import 'matching_service.dart';

/// Owner: Dan. The real Lab 3 matching (no ML model, as in Lab 2):
/// - only students without a team, only teams with room (R2);
/// - complete teams to five before filling spare sixth places (R1);
/// - prefer missing majors, aiming for at least three (R3).
///
/// Stable IDs break ties; input order and student names do not affect allocation.
/// Conflicting records are quarantined rather than guessed. This is a greedy
/// suggestion service, not an optimal class-wide solver or an approval service.
/// Pure Dart: test it in test/services/rule_based_matching_service_test.dart.
class RuleBasedMatchingService implements MatchingService {
  @override
  Future<List<Proposal>> propose({
    required String classId,
    required List<Student> students,
    required List<Team> teams,
  }) async {
    if (classId.trim().isEmpty) {
      throw const ValidationError('Select a class before matching');
    }

    final localStudents = students.where((s) => s.classId == classId);
    final byStudent = <String, Student>{};
    final conflictingStudents = <String>{};
    final occupied = <String>{};
    for (final student in localStudents) {
      if (student.mssv.trim().isEmpty) continue;
      if (student.hasTeam) occupied.add(student.mssv);
      final previous = byStudent[student.mssv];
      if (previous != null &&
          (previous.major != student.major ||
              previous.teamId != student.teamId)) {
        conflictingStudents.add(student.mssv);
      }
      byStudent[student.mssv] = student;
    }

    final byTeam = <String, Team>{};
    final sourceTeams = <String, Team>{};
    final conflictingTeams = <String>{};
    final rosterOwner = <String, String>{};
    for (final team in teams.where((t) => t.classId == classId)) {
      // Even malformed/full rosters reserve their members (R2).
      occupied.addAll(team.memberIds);
      for (final id in team.memberIds) {
        final owner = rosterOwner[id];
        if (owner != null && owner != team.id) {
          conflictingTeams.addAll([owner, team.id]);
        }
        rosterOwner[id] = team.id;
      }
      if (team.id.trim().isEmpty ||
          team.memberIds.any((id) => id.trim().isEmpty) ||
          team.memberIds.toSet().length != team.size ||
          team.majors.length != team.size ||
          team.size > TeamRules.maxMembers) {
        conflictingTeams.add(team.id);
        continue;
      }

      // Canonicalize paired member/major lists without changing the input.
      final order = List.generate(team.size, (i) => i)
        ..sort((a, b) => team.memberIds[a].compareTo(team.memberIds[b]));
      final canonical = Team(
        id: team.id,
        classId: classId,
        name: team.name,
        memberIds: [for (final i in order) team.memberIds[i]],
        majors: [for (final i in order) team.majors[i]],
      );
      final previous = byTeam[team.id];
      if (previous != null && !_sameTeam(previous, canonical)) {
        conflictingTeams.add(team.id);
      }
      byTeam[team.id] = canonical;
      sourceTeams[team.id] = team;
    }

    // A claimed assignment missing from the roster makes its size unreliable.
    for (final student in localStudents) {
      final teamId = student.teamId;
      if (teamId != null &&
          byTeam.containsKey(teamId) &&
          !byTeam[teamId]!.memberIds.contains(student.mssv)) {
        conflictingTeams.add(teamId);
      }
    }
    for (final team in byTeam.values) {
      for (var i = 0; i < team.size; i++) {
        final id = team.memberIds[i];
        final student = byStudent[id];
        if (conflictingStudents.contains(id) ||
            (student != null &&
                (student.major != team.majors[i] ||
                    (student.hasTeam && student.teamId != team.id)))) {
          conflictingTeams.add(team.id);
        }
      }
    }

    final pool =
        byStudent.values
            .where(
              (s) =>
                  !occupied.contains(s.mssv) &&
                  !conflictingStudents.contains(s.mssv),
            )
            .toList()
          ..sort((a, b) => a.mssv.compareTo(b.mssv));
    final targets = byTeam.values
        .where((t) => !conflictingTeams.contains(t.id) && !t.isFull)
        .toList();
    final plans = <_Plan>[];
    while (targets.isNotEmpty && pool.isNotEmpty) {
      final options = [
        for (final team in targets)
          if (_plan(team, pool) case final _Plan plan) plan,
      ]..sort(_comparePlans);
      if (options.isEmpty) break;
      final best = options.first;
      plans.add(best);
      targets.removeWhere((t) => t.id == best.team.id);
      final used = best.added.map((s) => s.mssv).toSet();
      pool.removeWhere((s) => used.contains(s.mssv));
    }

    // Only after completing feasible groups may a spare student fill place six.
    plans.sort((a, b) => a.team.id.compareTo(b.team.id));
    for (final plan in plans) {
      if (pool.isEmpty) break;
      if (plan.size < TeamRules.maxMembers) {
        final student = _pick(pool, plan.majors);
        plan.added.add(student);
        pool.remove(student);
      }
    }
    return [
      for (final plan in plans)
        _proposal(classId, plan, sourceTeams[plan.team.id]!),
    ];
  }

  static bool _sameTeam(Team a, Team b) =>
      a.name == b.name &&
      a.size == b.size &&
      Iterable<int>.generate(a.size).every(
        (i) => a.memberIds[i] == b.memberIds[i] && a.majors[i] == b.majors[i],
      );

  static _Plan? _plan(Team team, List<Student> pool) {
    if (team.size + pool.length < TeamRules.minMembers) return null;
    final remaining = List<Student>.of(pool);
    final plan = _Plan(team);
    if (!team.needsMembers && remaining.isNotEmpty) {
      plan.added.add(_pick(remaining, plan.majors));
      return plan;
    }
    while (remaining.isNotEmpty && plan.size < TeamRules.minMembers) {
      final student = _pick(remaining, plan.majors);
      plan.added.add(student);
      remaining.remove(student);
    }
    return plan.added.isEmpty ? null : plan;
  }

  static Student _pick(List<Student> pool, Set<Major> current) {
    final counts = <Major, int>{};
    for (final student in pool) {
      counts.update(student.major, (n) => n + 1, ifAbsent: () => 1);
    }
    final majors = counts.keys.toList()
      ..sort((a, b) {
        final missing = (current.contains(a) ? 1 : 0).compareTo(
          current.contains(b) ? 1 : 0,
        );
        if (missing != 0) return missing;
        // Prefer abundant majors to preserve scarce options for other teams.
        final abundance = counts[b]!.compareTo(counts[a]!);
        return abundance != 0 ? abundance : a.index.compareTo(b.index);
      });
    return pool.firstWhere((s) => s.major == majors.first);
  }

  static int _comparePlans(_Plan a, _Plan b) {
    final completion = (a.team.needsMembers ? 0 : 1).compareTo(
      b.team.needsMembers ? 0 : 1,
    );
    if (completion != 0) return completion;
    final quality = (b.majors.length >= TeamRules.targetMajors ? 1 : 0)
        .compareTo(a.majors.length >= TeamRules.targetMajors ? 1 : 0);
    if (quality != 0) return quality;
    final cost = a.added.length.compareTo(b.added.length);
    return cost != 0 ? cost : a.team.id.compareTo(b.team.id);
  }

  static Proposal _proposal(String classId, _Plan plan, Team sourceTeam) {
    final majors = plan.majors.toList()
      ..sort((a, b) => a.index.compareTo(b.index));
    final addedMajors =
        plan.added
            .map((s) => s.major)
            .toSet()
            .difference(plan.team.majors.toSet())
            .toList()
          ..sort((a, b) => a.index.compareTo(b.index));
    final reachesTarget = majors.length >= TeamRules.targetMajors;
    return Proposal(
      // Firestore rules allow only safe IDs up to 64 characters.
      // A changed roster or selection creates a new suggestion while
      // preserving the mentor's edits to the original pending draft.
      id: 'rule-${_stableHash(classId)}-${_stableHash(plan.team.id)}-${_stableHash([...plan.team.memberIds, ...plan.added.map((student) => student.mssv)].join('|'))}',
      classId: classId,
      teamId: plan.team.id,
      teamName: plan.team.name,
      // Firestore approval compares against the persisted roster order.
      currentMemberIds: List.unmodifiable(sourceTeam.memberIds),
      currentMajors: List.unmodifiable(sourceTeam.majors),
      addStudentIds: List.unmodifiable(plan.added.map((s) => s.mssv)),
      addMajors: List.unmodifiable(plan.added.map((s) => s.major)),
      fit: reachesTarget ? ProposalFit.strong : ProposalFit.good,
      reasons: List.unmodifiable([
        'Team reaches ${plan.size} members (required 5–6).',
        'Team reaches ${majors.length} majors: ${majors.map((m) => m.code).join(', ')}.',
        if (addedMajors.isNotEmpty)
          'Adds missing majors: ${addedMajors.map((m) => m.code).join(', ')}.',
        if (!reachesTarget) 'The available pool or remaining places cannot provide 3 majors; mentor review is needed.',
      ]),
    );
  }

  static String _stableHash(String value) {
    var hash = 0x811c9dc5;
    for (final byte in utf8.encode(value)) {
      hash = ((hash ^ byte) * 0x01000193) & 0xffffffff;
    }
    return hash.toRadixString(16).padLeft(8, '0');
  }
}

class _Plan {
  _Plan(this.team);

  final Team team;
  final List<Student> added = [];

  int get size => team.size + added.length;
  Set<Major> get majors => {...team.majors, ...added.map((s) => s.major)};
}
