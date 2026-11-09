import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:teamup_exe/models/major.dart';
import 'package:teamup_exe/models/student.dart';
import 'package:teamup_exe/services/app_error.dart';
import 'package:teamup_exe/services/class_service.dart';
import 'package:teamup_exe/services/csv_class_importer.dart';

void main() {
  const importer = CsvClassImporter();
  ImportPreview parse(String text, {String fileName = 'class.csv'}) =>
      importer.parse(fileName: fileName, bytes: utf8.encode(text));
  const header = 'MSSV,Full name,Class name,Group,Major\n';
  const row = '001,Nguyễn An,EXE101,1,SE\n';

  test('UTF-8, BOM, CRLF, leading zero IDs, blank groups and quoted commas', () {
    final preview = parse('\uFEFF${header.replaceAll('\n', '\r\n')}001,"Nguyễn, An",EXE101,1,se\r\n002,Bình,EXE101,,AI\r\n');
    expect(preview.students.first.mssv, '001');
    expect(preview.students.first.fullName, 'Nguyễn, An');
    expect(preview.students.last.hasTeam, isFalse);
    expect(preview.rowCount, 2);
    expect(importer.teams(preview, 'new-class').single.memberIds, ['001']);
    expect(preview.detectedColumns.values.every((v) => v), isTrue);
  });

  test('column aliases and reordered columns', () {
    final preview = parse('major,class,name,group,student id\nGD,EXE101,An,,SE001\n');
    expect(preview.students.single.major, Major.gd);
  });

  test('escaped quote accepted', () {
    expect(parse('${header}001,"An ""A""",EXE101,,SE').students.single.fullName, 'An "A"');
  });

  for (final entry in {
    'missing column': 'MSSV,name,class,major\n001,An,A,SE',
    'duplicate column': 'MSSV,name,class,major,major\n001,An,A,SE,SE',
    'extra column': 'MSSV,name,class,group,major,extra\n001,An,A,,SE,x',
    'empty file': '',
    'header only': header,
    'unknown major': '${header}001,An,EXE101,,CS',
    'duplicate ID ignoring case': '${header}se001,An,EXE101,,SE\nSE001,Bình,EXE101,,AI',
    'mixed classes': '$header${row}002,Bình,OTHER,,AI',
    'missing name': '${header}001,,EXE101,,SE',
    'unsafe group path': '${header}001,An,EXE101,../x,SE',
    'unsafe ID path': '${header}a/b,An,EXE101,,SE',
    'formula injection': '${header}001,=HYPERLINK(x),EXE101,,SE',
    'formula after whitespace': '${header}001,  +SUM(1),EXE101,,SE',
    'extra row field': '${header}001,An,EXE101,,SE,x',
    'unclosed quote': '${header}001,"An,EXE101,,SE',
    'quote inside unquoted field': '${header}001,A"n,EXE101,,SE',
    'content after closing quote': '${header}001,"An"bad,EXE101,,SE',
  }.entries) {
    test('rejects ${entry.key}', () {
      expect(() => parse(entry.value), throwsA(isA<ValidationError>()));
    });
  }

  test('only CSV extension, valid UTF-8 and bounded bytes', () {
    expect(() => parse('$header$row', fileName: 'class.xlsx'), throwsA(isA<ValidationError>()));
    expect(() => importer.parse(fileName: 'a.csv', bytes: [0xff]), throwsA(isA<ValidationError>()));
    expect(() => importer.parse(fileName: 'a.csv', bytes: List.filled(CsvClassImporter.maxBytes + 1, 65)),
        throwsA(isA<ValidationError>()));
  });

  test('6 members allowed, 7 rejected', () {
    String rows(int n) => [for (var i = 0; i < n; i++) '$i,Student $i,A,1,SE'].join('\n');
    expect(importer.teams(parse('$header${rows(6)}'), 'a').single.isFull, isTrue);
    expect(() => parse('$header${rows(7)}'), throwsA(isA<ValidationError>()));
  });

  test('atomic write budget includes teams, not just rows', () {
    final rows = [for (var i = 0; i < 200; i++) '$i,Student $i,A,$i,SE'].join('\n');
    expect(() => parse('$header$rows'), throwsA(isA<ValidationError>()));
  });

  test('persistence revalidates manually constructed previews', () {
    const preview = ImportPreview(fileName: 'x.csv', className: 'A', rowCount: 2,
      detectedColumns: {}, students: [
        Student(mssv: '1', fullName: 'A', major: Major.se, classId: 'x'),
      ]);
    expect(() => importer.validate(preview), throwsA(isA<ValidationError>()));
  });

  test('fixture contains both available students and full/incomplete teams', () {
    final preview = importer.parse(fileName: 'lab3-demo.csv',
        bytes: File('tool/fixtures/lab3-demo.csv').readAsBytesSync());
    final teams = importer.teams(preview, 'demo');
    expect(preview.rowCount, 12);
    expect(preview.students.where((s) => !s.hasTeam).length, 3);
    expect(teams.map((t) => t.size), [6, 3]);
  });
}
