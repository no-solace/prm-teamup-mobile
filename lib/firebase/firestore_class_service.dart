import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/class_room.dart';
import '../models/data_validation.dart';
import '../models/student.dart';
import '../models/team.dart';
import '../services/app_error.dart';
import '../services/class_service.dart';
import '../services/csv_class_importer.dart';

/// Live class data, scoped to the current mentor by both query and rules.
class FirestoreClassService implements ClassService {
  FirestoreClassService({FirebaseFirestore? db, FirebaseAuth? auth})
      : _db = db ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  static const _csv = CsvClassImporter();

  CollectionReference<Map<String, dynamic>> get _classes => _db.collection('classes');

  String _uid() => _auth.currentUser?.uid ??
      (throw const PermissionDeniedError('Sign in to access classes'));

  DocumentReference<Map<String, dynamic>> _class(String id) {
    if (!DataValidation.isId(id)) throw const ValidationError('Invalid class ID');
    return _classes.doc(id);
  }

  Stream<List<Student>> _students(String id) => _class(id)
      .collection('students').snapshots().map((s) => [
            for (final d in s.docs) Student.fromMap(d.id, id, d.data()),
          ]..sort((a, b) => a.mssv.compareTo(b.mssv)));

  Stream<List<Team>> _teams(String id) => _class(id)
      .collection('teams').snapshots().map((s) => [
            for (final d in s.docs) Team.fromMap(d.id, id, d.data()),
          ]..sort((a, b) => a.name.compareTo(b.name)));

  ClassRoom _ownedRoom(DocumentSnapshot<Map<String, dynamic>> doc, String uid) {
          if (!doc.exists) throw const NotFoundError('Class not found');
          final room = ClassRoom.fromMap(doc.id, doc.data()!);
          if (room.mentorUid != uid) throw const PermissionDeniedError();
          return room;
  }

  Stream<ClassRoom> _room(String id, String uid) => combineDataStreams<Object>([
        _class(id).snapshots().map((doc) => _ownedRoom(doc, uid)),
        _students(id),
        _teams(id),
      ]).map((values) {
        final room = values[0] as ClassRoom;
        final students = values[1] as List<Student>;
        final teams = values[2] as List<Team>;
        return room.copyWith(
          studentCount: students.length,
          withoutTeamCount: students.where((s) => !s.hasTeam).length,
          teamsNeedingMembers: teams.where((t) => !t.isFull).length,
        );
      });

  @override
  Stream<List<ClassRoom>> watchMyClasses() => _session((uid) => switchDataStream(
        _classes.where('mentorUid', isEqualTo: uid).snapshots(),
        (snapshot) => combineDataStreams([
          for (final doc in snapshot.docs) _room(doc.id, uid),
        ]).map((rooms) => rooms..sort((a, b) => a.name.compareTo(b.name))),
      ));

  @override
  Stream<ClassRoom> watchClass(String classId) => _session((uid) => _room(classId, uid));

  @override
  Stream<List<Student>> watchStudents(String classId) => _session((uid) => switchDataStream(
        _class(classId).snapshots(),
        (doc) { _ownedRoom(doc, uid); return _students(classId); },
      ));

  @override
  Stream<List<Team>> watchTeams(String classId) => _session((uid) => switchDataStream(
        _class(classId).snapshots(),
        (doc) { _ownedRoom(doc, uid); return _teams(classId); },
      ));

  // Switch listeners on sign-out/account changes; an old account cannot keep
  // emitting cached data into the new account's UI. Errors stay AppError.
  Stream<T> _session<T>(Stream<T> Function(String uid) open) =>
      switchDataStream(_auth.authStateChanges(), (user) {
        if (user == null) return Stream<T>.error(const PermissionDeniedError('Sign in to access classes'));
        return open(user.uid);
      }).transform(StreamTransformer<T, T>.fromHandlers(
        handleError: (Object error, StackTrace stack, EventSink<T> sink) =>
            sink.addError(_error(error), stack),
      ));

  @override
  Stream<({Team team, List<Student> members})> watchMyTeam(
    String classId,
    String teamId,
  ) => _session((_) {
    if (!DataValidation.isId(teamId)) {
      return Stream.error(const ValidationError('Invalid team ID'));
    }
    // Rules: a student reads only their team and students with that teamId.
    return combineDataStreams<Object>([
      _class(classId).collection('teams').doc(teamId).snapshots().map((doc) {
        if (!doc.exists) throw const NotFoundError('Team not found');
        return Team.fromMap(doc.id, classId, doc.data()!);
      }),
      _class(classId)
          .collection('students')
          .where('teamId', isEqualTo: teamId)
          .snapshots()
          .map((s) => [for (final d in s.docs) Student.fromMap(d.id, classId, d.data())]),
    ]).map((v) => (team: v[0] as Team, members: v[1] as List<Student>));
  });

  @override
  Future<Student> getStudent(String classId, String mssv) async {
    try {
      final uid = _uid();
      if (!DataValidation.isId(mssv)) throw const ValidationError('Invalid student ID');
      _ownedRoom(await _class(classId).get(), uid);
      final doc = await _class(classId).collection('students').doc(mssv).get();
      if (_uid() != uid) throw const PermissionDeniedError('Account changed');
      if (!doc.exists) throw const NotFoundError('Student not found');
      return Student.fromMap(doc.id, classId, doc.data()!);
    } catch (error) {
      throw _error(error);
    }
  }

  @override
  Future<ImportPreview> parseImportFile({required String fileName, required List<int> bytes}) async =>
      _csv.parse(fileName: fileName, bytes: bytes);

  @override
  Future<ImportResult> importClass(ImportPreview preview) async {
    try {
      final uid = _uid();
      _csv.validate(preview);
      // A new auto ID never overwrites another import or its proposals.
      final ref = _classes.doc();
      final teams = _csv.teams(preview, ref.id);
      final batch = _db.batch();
      batch.set(ref, {
        ...ClassRoom(id: ref.id, name: preview.className, mentorUid: uid).toMap(),
        'createdAt': FieldValue.serverTimestamp(),
      });
      for (final student in preview.students) {
        batch.set(ref.collection('students').doc(student.mssv), student.toMap());
      }
      for (final team in teams) {
        batch.set(ref.collection('teams').doc(team.id), team.toMap());
      }
      if (_uid() != uid) throw const PermissionDeniedError('Account changed');
      await batch.commit();
      if (_uid() != uid) throw const PermissionDeniedError('Account changed');
      final grouped = preview.students.where((s) => s.hasTeam).length;
      return ImportResult(
        classId: ref.id,
        imported: preview.students.length,
        inAGroup: grouped,
        available: preview.students.length - grouped,
      );
    } catch (error) {
      throw _error(error);
    }
  }

  static AppError _error(Object error) {
    if (error is AppError) return error;
    if (error is FormatException) return const ValidationError('Stored class data is invalid');
    if (error is FirebaseException) {
      return switch (error.code) {
        'permission-denied' || 'unauthenticated' => const PermissionDeniedError(),
        'not-found' => const NotFoundError(),
        'unavailable' => const NetworkError(),
        'deadline-exceeded' => const TimeoutAppError(),
        'invalid-argument' => const ValidationError('Invalid class data'),
        _ => UnknownError('Could not access class data', error),
      };
    }
    return UnknownError('Could not access class data', error);
  }
}

/// Latest values, with cancellation propagated to every underlying listener.
Stream<List<T>> combineDataStreams<T>(List<Stream<T>> sources) {
  if (sources.isEmpty) return Stream.value(<T>[]);
  final values = List<T?>.filled(sources.length, null);
  final ready = List<bool>.filled(sources.length, false);
  final subscriptions = <StreamSubscription<T>>[];
  var finished = 0;
  late StreamController<List<T>> controller;
  controller = StreamController<List<T>>(
    onListen: () {
      for (var i = 0; i < sources.length; i++) {
        final index = i;
        subscriptions.add(sources[i].listen((value) {
          values[index] = value;
          ready[index] = true;
          if (ready.every((v) => v)) controller.add(values.cast<T>().toList());
        }, onError: controller.addError, onDone: () {
          if (++finished == sources.length) unawaited(controller.close());
        }));
      }
    },
    onCancel: () async {
      for (final subscription in subscriptions) { await subscription.cancel(); }
    },
    onPause: () { for (final s in subscriptions) { s.pause(); } },
    onResume: () { for (final s in subscriptions) { s.resume(); } },
  );
  return controller.stream;
}

/// A small switchMap: detach old data immediately and suppress late events.
Stream<R> switchDataStream<T, R>(Stream<T> source, Stream<R> Function(T) open) {
  StreamSubscription<T>? outer;
  StreamSubscription<R>? inner;
  var generation = 0;
  var outerDone = false;
  var active = false;
  var cancelled = false;
  late StreamController<R> controller;
  controller = StreamController<R>(
    onListen: () {
      outer = source.listen((value) async {
        final current = ++generation;
        active = true;
        await inner?.cancel();
        if (cancelled || current != generation) return;
        try {
          inner = open(value).listen((event) {
            if (current == generation) controller.add(event);
          }, onError: (Object error, StackTrace stack) {
            if (current == generation) controller.addError(error, stack);
          }, onDone: () {
            if (current == generation) {
              active = false;
              if (outerDone) unawaited(controller.close());
            }
          });
          if (controller.isPaused) inner!.pause();
        } catch (error, stack) {
          active = false;
          controller.addError(error, stack);
          if (outerDone) unawaited(controller.close());
        }
      }, onError: controller.addError, onDone: () {
        outerDone = true;
        if (!active) unawaited(controller.close());
      });
    },
    onCancel: () async {
      cancelled = true;
      generation++;
      await outer?.cancel();
      await inner?.cancel();
    },
    onPause: () { outer?.pause(); inner?.pause(); },
    onResume: () { outer?.resume(); inner?.resume(); },
  );
  return controller.stream;
}
