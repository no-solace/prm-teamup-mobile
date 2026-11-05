import 'dart:async';

import '../../models/class_room.dart';
import '../../models/major.dart';
import '../../models/student.dart';
import '../../models/team.dart';
import '../app_error.dart';
import '../class_service.dart';
import 'sample_data.dart';

/// In-memory class data. Only Class A has students; B and C are empty shells.
class FakeClassService implements ClassService {
  FakeClassService({this.latency = const Duration(milliseconds: 500), bool empty = false})
      : _classes = empty ? [] : [...SampleData.classes],
        _students = empty ? [] : SampleData.students();

  final Duration latency;
  final List<ClassRoom> _classes;
  final List<Student> _students;

  List<Team> get _teams => SampleData.teams(_students);

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
  }

  @override
  Stream<ClassRoom> watchClass(String classId) async* {
    await Future<void>.delayed(latency);
    final c = _classes.where((c) => c.id == classId).firstOrNull;
    if (c == null) throw const NotFoundError('Class not found');
    yield _withCounts(c);
  }

  @override
  Stream<List<Student>> watchStudents(String classId) async* {
    await Future<void>.delayed(latency);
    yield _students.where((s) => s.classId == classId).toList();
  }

  @override
  Stream<List<Team>> watchTeams(String classId) async* {
    await Future<void>.delayed(latency);
    yield _teams.where((t) => t.classId == classId).toList();
  }

  @override
  Future<Student> getStudent(String classId, String mssv) async {
    await Future<void>.delayed(latency);
    return _students.firstWhere(
      (s) => s.classId == classId && s.mssv == mssv,
      orElse: () => throw const NotFoundError('Student not found'),
    );
  }

  @override
  Future<ImportPreview> parseImportFile({required String fileName, required List<int> bytes}) async {
    await Future<void>.delayed(latency);
    if (!fileName.toLowerCase().endsWith('.csv')) {
      throw const ValidationError('Use a .csv file with MSSV, name, class, group and major');
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
    final inGroup = preview.students.where((s) => s.hasTeam).length;
    return ImportResult(
      classId: 'class-a',
      imported: preview.rowCount,
      inAGroup: inGroup,
      available: preview.rowCount - inGroup,
    );
  }
}
