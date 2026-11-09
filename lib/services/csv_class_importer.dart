import 'dart:convert';

import 'package:csv/csv.dart';

import '../models/data_validation.dart';
import '../models/major.dart';
import '../models/student.dart';
import '../models/team.dart';
import 'app_error.dart';
import 'class_service.dart';

/// Strict, UTF-8 CSV import. Parsing never writes data.
class CsvClassImporter {
  const CsvClassImporter();

  static const maxBytes = 1024 * 1024;
  // Keep one class + all students + all teams within a single small batch.
  static const maxWrites = 400;
  static const columns = ['MSSV', 'Full name', 'Class name', 'Group', 'Major'];

  ImportPreview parse({required String fileName, required List<int> bytes}) {
    if (!fileName.toLowerCase().endsWith('.csv')) {
      throw const ValidationError('Choose a UTF-8 .csv file');
    }
    if (bytes.isEmpty || bytes.length > maxBytes) {
      throw const ValidationError('CSV must contain data and be at most 1 MiB');
    }
    try {
      final text = utf8.decode(bytes).replaceFirst(RegExp(r'^\uFEFF'), '');
      _validateQuotes(text);
      final rows = const CsvDecoder(fieldDelimiter: ',').convert(text);
      if (rows.length < 2) throw const ValidationError('CSV contains no students');
      final headers = rows.first.map((v) => _header(v.toString())).toList();
      if (headers.length != columns.length || headers.toSet().length != columns.length ||
          !headers.toSet().containsAll(columns)) {
        throw const ValidationError('Required columns: MSSV, Full name, Class name, Group, Major');
      }
      final students = <Student>[];
      String? className;
      for (var i = 1; i < rows.length; i++) {
        final row = rows[i];
        if (row.every((v) => v.toString().trim().isEmpty)) continue;
        if (row.length != headers.length) {
          throw ValidationError('Row ${i + 1}: expected ${headers.length} columns');
        }
        String value(String column) => row[headers.indexOf(column)].toString().trim();
        final name = value('Class name');
        if (className != null && name != className) {
          throw ValidationError('Row ${i + 1}: import one class at a time');
        }
        className = name;
        final major = Major.fromCode(value('Major'));
        if (major == null) throw ValidationError('Row ${i + 1}: major must be SE, AI, MKT or GD');
        students.add(Student(
          mssv: value('MSSV').toUpperCase(),
          fullName: value('Full name'),
          major: major,
          classId: 'csv-preview',
          teamId: value('Group').isEmpty ? null : value('Group'),
        ));
      }
      final preview = ImportPreview(
        fileName: fileName,
        className: className ?? '',
        rowCount: students.length,
        detectedColumns: {for (final c in columns) c: true},
        students: List.unmodifiable(students),
      );
      validate(preview);
      return preview;
    } on FormatException {
      throw const ValidationError('Invalid CSV or UTF-8 encoding');
    }
  }

  /// Re-run at the persistence boundary; ImportPreview is a public DTO.
  void validate(ImportPreview preview) {
    _text(preview.className, 'Class name');
    if (preview.students.isEmpty || preview.rowCount != preview.students.length ||
        preview.students.length >= maxWrites) {
      throw const ValidationError('Invalid student count or class too large');
    }
    final ids = <String>{};
    final groupSizes = <String, int>{};
    for (final student in preview.students) {
      if (!DataValidation.isId(student.mssv) || !ids.add(student.mssv.toUpperCase())) {
        throw const ValidationError('Student IDs must be unique and use letters, digits, _ or -');
      }
      _text(student.fullName, 'Full name');
      if (student.semester != null) _text(student.semester!, 'Semester', max: 32);
      if (student.teamId case final String group) {
        if (!DataValidation.isId(group)) throw const ValidationError('Invalid Group ID');
        groupSizes[group] = (groupSizes[group] ?? 0) + 1;
        if (groupSizes[group]! > TeamRules.maxMembers) {
          throw const ValidationError('A group can contain at most 6 students');
        }
      }
    }
    if (1 + ids.length + groupSizes.length > maxWrites) {
      throw const ValidationError('Class is too large for an atomic import (400 writes)');
    }
  }

  List<Team> teams(ImportPreview preview, String classId) {
    validate(preview);
    final groups = <String, List<Student>>{};
    for (final student in preview.students) {
      if (student.teamId case final String id) (groups[id] ??= []).add(student);
    }
    return [
      for (final entry in groups.entries)
        Team(
          id: entry.key,
          classId: classId,
          name: 'Group ${entry.key}',
          memberIds: List.unmodifiable(entry.value.map((s) => s.mssv)),
          majors: List.unmodifiable(entry.value.map((s) => s.major)),
        ),
    ];
  }

  static void _text(String value, String field, {int max = 120}) {
    if (value.trim().isEmpty || value.length > max ||
        RegExp(r'[\x00-\x1F\x7F]').hasMatch(value) ||
        RegExp(r'^[=+@-]').hasMatch(value.trimLeft())) {
      throw ValidationError('$field is empty, too long or contains unsafe characters');
    }
  }

  static String _header(String value) => switch (value.trim().toLowerCase()) {
        'mssv' || 'student id' || 'student id (mssv)' => 'MSSV',
        'full name' || 'fullname' || 'name' || 'họ tên' => 'Full name',
        'class' || 'class name' || 'lớp' => 'Class name',
        'group' || 'nhóm' => 'Group',
        'major' || 'ngành' => 'Major',
        _ => value.trim(),
      };

  // csv 8 tolerates an unfinished quoted field. Reject it and any quote
  // embedded in an unquoted value before decoding (RFC 4180 shape).
  static void _validateQuotes(String text) {
    var state = 0; // 0 field start, 1 unquoted, 2 quoted, 3 after quote.
    for (var i = 0; i < text.length; i++) {
      final ch = text[i];
      if (state == 2) {
        if (ch == '"') {
          if (i + 1 < text.length && text[i + 1] == '"') {
            i++;
          } else {
            state = 3;
          }
        }
      } else if (ch == ',' || ch == '\n' || ch == '\r') {
        state = 0;
      } else if (ch == '"' && state == 0) {
        state = 2;
      } else if (ch == '"' || state == 3) {
        throw const ValidationError('Malformed CSV quotes');
      } else {
        state = 1;
      }
    }
    if (state == 2) throw const ValidationError('Unclosed CSV quote');
  }
}
