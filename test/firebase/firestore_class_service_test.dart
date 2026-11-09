// Firebase's sealed reference interfaces are mocked here to verify service calls.
// ignore_for_file: subtype_of_sealed_class

import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:teamup_exe/firebase/firestore_class_service.dart';
import 'package:teamup_exe/services/app_error.dart';

class MockDb extends Mock implements FirebaseFirestore {}
class MockAuth extends Mock implements FirebaseAuth {}
class MockUser extends Mock implements User {}
class MockCollection extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockDoc extends Mock implements DocumentReference<Map<String, dynamic>> {}
class MockSnapshot extends Mock implements DocumentSnapshot<Map<String, dynamic>> {}
class MockQuery extends Mock implements Query<Map<String, dynamic>> {}
class MockQuerySnapshot extends Mock implements QuerySnapshot<Map<String, dynamic>> {}

class RecordingBatch extends Fake implements WriteBatch {
  final writes = <String, Map<String, dynamic>>{};
  int commits = 0;
  Object? failure;
  @override
  void set<T>(DocumentReference<T> document, T data, [SetOptions? options]) {
    writes[document.path] = data as Map<String, dynamic>;
  }
  @override
  Future<void> commit() async { commits++; if (failure != null) throw failure!; }
}

void main() {
  late MockDb db;
  late MockAuth auth;
  late MockUser user;
  late MockCollection classes;
  late MockDoc room;
  late MockCollection students;
  late MockCollection teams;
  late MockDoc studentDoc;
  late RecordingBatch batch;
  late FirestoreClassService service;

  MockSnapshot snapshot(String id, Map<String, dynamic>? data) {
    final result = MockSnapshot();
    when(() => result.id).thenReturn(id);
    when(() => result.exists).thenReturn(data != null);
    when(() => result.data()).thenReturn(data);
    return result;
  }

  setUp(() {
    db = MockDb(); auth = MockAuth(); user = MockUser(); classes = MockCollection();
    room = MockDoc(); students = MockCollection(); teams = MockCollection();
    studentDoc = MockDoc(); batch = RecordingBatch();
    when(() => user.uid).thenReturn('mentor');
    when(() => auth.currentUser).thenReturn(user);
    when(() => auth.authStateChanges()).thenAnswer((_) => Stream.value(user));
    when(() => db.collection('classes')).thenReturn(classes);
    when(() => db.batch()).thenReturn(batch);
    when(() => classes.doc()).thenReturn(room);
    when(() => classes.doc('newClass')).thenReturn(room);
    when(() => room.id).thenReturn('newClass');
    when(() => room.path).thenReturn('classes/newClass');
    when(() => room.collection('students')).thenReturn(students);
    when(() => room.collection('teams')).thenReturn(teams);
    when(() => room.get()).thenAnswer((_) async => snapshot('newClass', {'name': 'EXE', 'mentorUid': 'mentor'}));
    when(() => students.doc(any())).thenAnswer((invocation) {
      final ref = MockDoc();
      when(() => ref.path).thenReturn('classes/newClass/students/${invocation.positionalArguments.first}');
      return ref;
    });
    when(() => teams.doc(any())).thenAnswer((invocation) {
      final ref = MockDoc();
      when(() => ref.path).thenReturn('classes/newClass/teams/${invocation.positionalArguments.first}');
      return ref;
    });
    service = FirestoreClassService(db: db, auth: auth);
  });

  test('import commits one batch with class/student/team maps and derived totals', () async {
    final parsed = await service.parseImportFile(fileName: 'a.csv', bytes: utf8.encode(
      'MSSV,name,class,group,major\n001,An,EXE,1,SE\n002,Binh,EXE,,AI'));
    expect(batch.commits, 0); // preview is read-only
    final result = await service.importClass(parsed);
    expect(batch.commits, 1);
    expect(batch.writes.length, 4);
    expect(batch.writes['classes/newClass']!['mentorUid'], 'mentor');
    expect(batch.writes['classes/newClass/students/002']!['teamId'], null);
    expect(batch.writes['classes/newClass/teams/1']!['memberIds'], ['001']);
    expect(result.imported, 2); expect(result.inAGroup, 1); expect(result.available, 1);
    expect(result.classId, 'newClass');
  });
  test('batch permission/network errors translated without success result', () async {
    final parsed = await service.parseImportFile(fileName: 'a.csv', bytes: utf8.encode(
      'MSSV,name,class,group,major\n001,An,EXE,,SE'));
    batch.failure = FirebaseException(plugin: 'cloud_firestore', code: 'permission-denied');
    await expectLater(service.importClass(parsed), throwsA(isA<PermissionDeniedError>()));
    batch.failure = FirebaseException(plugin: 'cloud_firestore', code: 'unavailable');
    await expectLater(service.importClass(parsed), throwsA(isA<NetworkError>()));
  });
  test('signed out cannot import/read/watch; parse still works', () async {
    when(() => auth.currentUser).thenReturn(null);
    when(() => auth.authStateChanges()).thenAnswer((_) => Stream.value(null));
    final parsed = await service.parseImportFile(fileName: 'a.csv', bytes: utf8.encode(
      'MSSV,name,class,group,major\n001,An,EXE,,SE'));
    await expectLater(service.importClass(parsed), throwsA(isA<PermissionDeniedError>()));
    await expectLater(service.getStudent('newClass', '001'), throwsA(isA<PermissionDeniedError>()));
    await expectLater(service.watchMyClasses(), emitsError(isA<PermissionDeniedError>()));
    expect(batch.commits, 0);
  });
  test('getStudent distinguishes missing record and invalid stored data', () async {
    when(() => students.doc('001')).thenReturn(studentDoc);
    when(() => studentDoc.get()).thenAnswer((_) async => snapshot('001', null));
    await expectLater(service.getStudent('newClass', '001'), throwsA(isA<NotFoundError>()));
    when(() => studentDoc.get()).thenAnswer((_) async => snapshot('001', {'fullName': 'An', 'major': 'BAD', 'teamId': null}));
    await expectLater(service.getStudent('newClass', '001'), throwsA(isA<ValidationError>()));
  });
  test('cached records of another owner never reach child consumers', () async {
    when(() => room.get()).thenAnswer((_) async => snapshot('newClass', {'name': 'EXE', 'mentorUid': 'other'}));
    when(() => room.snapshots()).thenAnswer((_) => Stream.value(snapshot('newClass', {'name': 'EXE', 'mentorUid': 'other'})));
    await expectLater(service.getStudent('newClass', '001'), throwsA(isA<PermissionDeniedError>()));
    await expectLater(service.watchStudents('newClass'), emitsError(isA<PermissionDeniedError>()));
    await expectLater(service.watchTeams('newClass'), emitsError(isA<PermissionDeniedError>()));
    verifyNever(() => students.snapshots());
  });
  test('my classes query includes owner, empty snapshot emits empty', () async {
    final query = MockQuery(); final result = MockQuerySnapshot();
    when(() => classes.where('mentorUid', isEqualTo: 'mentor')).thenReturn(query);
    when(() => query.snapshots()).thenAnswer((_) => Stream.value(result));
    when(() => result.docs).thenReturn([]);
    expect(await service.watchMyClasses().first, isEmpty);
  });
}
