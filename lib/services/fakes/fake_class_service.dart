import 'dart:async';

import '../../models/class_room.dart';
import '../../models/major.dart';
import '../../models/proposal.dart';
import '../../models/student.dart';
import '../../models/team.dart';
import '../app_error.dart';
import '../class_service.dart';
import 'sample_data.dart';

/// In-memory class data. Only Class A has students; B and C are empty shells.
class FakeClassService implements ClassService {
  FakeClassService({
    this.latency = const Duration(milliseconds: 500),
    bool empty = false,
  }) : _classes = empty ? [] : [...SampleData.classes],
       _students = empty ? [] : SampleData.students();

  final Duration latency;
  final List<ClassRoom> _classes;
  final List<Student> _students;
  final _changes = StreamController<void>.broadcast();
  final Map<String, String> _teamNames = {
    'class-a/team-tutor': 'Tutor Match',
    'class-a/team-green': 'GreenLoop',
    'class-a/team-fin': 'FinLite',
  };

  List<Student> studentsFor(String classId) =>
      _students.where((s) => s.classId == classId).toList();

  List<Team> teamsFor(String classId) {
    final groups = <String, List<Student>>{};
    for (final student in studentsFor(classId)) {
      if (student.teamId case final String id) {
        (groups[id] ??= []).add(student);
      }
    }
    // Keep empty teams imported from files and the three original demo teams.
    for (final key in _teamNames.keys) {
      if (key.startsWith('$classId/')) {
        groups.putIfAbsent(key.substring(classId.length + 1), () => []);
      }
    }
    return [
      for (final entry in groups.entries)
        Team(
          id: entry.key,
          classId: classId,
          name: _teamNames['$classId/${entry.key}'] ?? 'Group ${entry.key}',
          memberIds: [for (final student in entry.value) student.mssv],
          majors: [for (final student in entry.value) student.major],
        ),
    ];
  }

  List<Team> get _teams => [for (final room in _classes) ...teamsFor(room.id)];

  void _notify() => _changes.add(null);

  /// Applies the complete roster change or throws before mutating demo data.
  void approve(Proposal proposal) {
    final team = teamsFor(proposal.classId)
        .where((t) => t.id == proposal.teamId)
        .firstOrNull;
    if (team == null ||
        team.memberIds.join('|') != proposal.currentMemberIds.join('|') ||
        team.majors.join('|') != proposal.currentMajors.join('|') ||
        !proposal.canApprove ||
        proposal.addStudentIds.toSet().length !=
            proposal.addStudentIds.length ||
        proposal.addMajors.length != proposal.addStudentIds.length ||
        proposal.addStudentIds
            .toSet()
            .intersection(team.memberIds.toSet())
            .isNotEmpty) {
      throw const ValidationError('Team changed. Refresh proposal');
    }
    final additions = <Student>[];
    for (var i = 0; i < proposal.addStudentIds.length; i++) {
      final id = proposal.addStudentIds[i];
      final student = studentsFor(proposal.classId)
          .where((s) => s.mssv == id)
          .firstOrNull;
      if (student == null ||
          student.hasTeam ||
          student.major != proposal.addMajors[i]) {
        throw const ValidationError('Student is unavailable. Refresh proposal');
      }
      additions.add(student);
    }
    for (final student in additions) {
      final index = _students.indexOf(student);
      _students[index] = student.copyWith(teamId: team.id);
    }
    _notify();
  }

  void undo(Proposal proposal) {
    final team = teamsFor(proposal.classId)
        .where((t) => t.id == proposal.teamId)
        .firstOrNull;
    final expected = [...proposal.currentMemberIds, ...proposal.addStudentIds];
    if (team == null ||
        team.memberIds.length != expected.length ||
        team.memberIds.toSet().difference(expected.toSet()).isNotEmpty ||
        expected.toSet().difference(team.memberIds.toSet()).isNotEmpty ||
        proposal.addStudentIds.any(
          (id) =>
              studentsFor(proposal.classId)
                  .where((s) => s.mssv == id && s.teamId == team.id)
                  .isEmpty,
        )) {
      throw const ValidationError('Team changed since approval');
    }
    for (final id in proposal.addStudentIds) {
      final index = _students.indexWhere(
        (s) => s.classId == proposal.classId && s.mssv == id,
      );
      _students[index] = _students[index].copyWith(clearTeam: true);
    }
    _notify();
  }

  ClassRoom _withCounts(ClassRoom c) {
    final students = _students.where((s) => s.classId == c.id).toList();
    final teams = _teams.where((t) => t.classId == c.id).toList();
    return c.copyWith(
      studentCount: students.length,
      withoutTeamCount: students.where((s) => !s.hasTeam).length,
      teamsNeedingMembers: teams.where((t) => !t.isFull).length,
    );
  }

  @override
  Stream<List<ClassRoom>> watchMyClasses() async* {
    await Future<void>.delayed(latency);
    yield [for (final c in _classes) _withCounts(c)];
    yield* _changes.stream.map(
      (_) => [for (final c in _classes) _withCounts(c)],
    );
  }

  @override
  Stream<ClassRoom> watchClass(String classId) async* {
    await Future<void>.delayed(latency);
    final c = _classes.where((c) => c.id == classId).firstOrNull;
    if (c == null) throw const NotFoundError('Class not found');
    yield _withCounts(c);
    yield* _changes.stream.map((_) => _withCounts(c));
  }

  @override
  Stream<List<Student>> watchStudents(String classId) async* {
    await Future<void>.delayed(latency);
    yield studentsFor(classId);
    yield* _changes.stream.map((_) => studentsFor(classId));
  }

  @override
  Stream<List<Team>> watchTeams(String classId) async* {
    await Future<void>.delayed(latency);
    yield teamsFor(classId);
    yield* _changes.stream.map((_) => teamsFor(classId));
  }

  @override
  Stream<({Team team, List<Student> members})> watchMyTeam(
    String classId,
    String teamId,
  ) => watchTeams(classId).map((teams) {
    final team = teams.where((t) => t.id == teamId).firstOrNull;
    if (team == null) throw const NotFoundError('Team not found');
    return (
      team: team,
      members: studentsFor(classId).where((s) => s.teamId == teamId).toList(),
    );
  });

  @override
  Future<Student> getStudent(String classId, String mssv) async {
    await Future<void>.delayed(latency);
    return _students.firstWhere(
      (s) => s.classId == classId && s.mssv == mssv,
      orElse: () => throw const NotFoundError('Student not found'),
    );
  }

  @override
  Future<ImportPreview> parseImportFile({
    required String fileName,
    required List<int> bytes,
  }) async {
    await Future<void>.delayed(latency);
    if (!fileName.toLowerCase().endsWith('.csv')) {
      throw const ValidationError(
        'Use a .csv file with MSSV, name, class, group and major',
      );
    }
    return ImportPreview(
      fileName: fileName,
      className: 'Class A',
      rowCount: 42,
      detectedColumns: const {
        'Student ID (MSSV)': true,
        'Full name': true,
        'Class name': true,
        'Group': true,
        'Major': true,
      },
      students: [
        for (var i = 0; i < 42; i++)
          Student(
            mssv: '2001${i.toString().padLeft(2, '0')}',
            fullName: 'Student $i',
            major: Major.values[i % Major.values.length],
            classId: 'class-a',
            teamId: i < 30 ? 'team-${i ~/ 5}' : null,
          ),
      ],
    );
  }

  @override
  Future<ImportResult> importClass(ImportPreview preview) async {
    await Future<void>.delayed(latency);
    if (preview.students.isEmpty) {
      throw const ValidationError('No students to import');
    }
    final classId = 'import-${_classes.length + 1}';
    _classes.add(
      ClassRoom(
        id: classId,
        name: preview.className,
        mentorUid: SampleData.mentorUid,
      ),
    );
    for (final student in preview.students) {
      _students.add(
        Student(
          mssv: student.mssv,
          fullName: student.fullName,
          major: student.major,
          classId: classId,
          teamId: student.teamId,
          semester: student.semester,
        ),
      );
      if (student.teamId case final String teamId) {
        _teamNames.putIfAbsent('$classId/$teamId', () => 'Group $teamId');
      }
    }
    _notify();
    final inGroup = preview.students.where((s) => s.hasTeam).length;
    return ImportResult(
      classId: classId,
      imported: preview.students.length,
      inAGroup: inGroup,
      available: preview.students.length - inGroup,
    );
  }
}
