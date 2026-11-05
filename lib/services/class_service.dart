import '../models/class_room.dart';
import '../models/student.dart';
import '../models/team.dart';

/// Result of parsing an import file (S22), before it is written.
class ImportPreview {
  const ImportPreview({
    required this.fileName,
    required this.className,
    required this.rowCount,
    required this.detectedColumns,
    required this.students,
  });

  final String fileName;
  final String className;
  final int rowCount;

  /// Column name -> detected? (S22 "Columns detected").
  final Map<String, bool> detectedColumns;
  final List<Student> students;
}

/// Result shown on S23.
class ImportResult {
  const ImportResult({
    required this.classId,
    required this.imported,
    required this.inAGroup,
    required this.available,
  });

  final String classId;
  final int imported;
  final int inAGroup;
  final int available;
}

/// Owner: Dan. Classes, students and teams of the signed-in mentor (Flow A).
abstract interface class ClassService {
  Stream<List<ClassRoom>> watchMyClasses();

  Stream<ClassRoom> watchClass(String classId);

  Stream<List<Student>> watchStudents(String classId);

  Stream<List<Team>> watchTeams(String classId);

  Future<Student> getStudent(String classId, String mssv);

  /// Parses a CSV picked by the user. Throws [ValidationError] on a wrong
  /// format or missing column (S22 error state).
  Future<ImportPreview> parseImportFile({required String fileName, required List<int> bytes});

  Future<ImportResult> importClass(ImportPreview preview);
}
