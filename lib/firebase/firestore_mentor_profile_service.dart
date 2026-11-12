import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/data_validation.dart';
import '../services/app_error.dart';

/// users/{uid}: the role profile required by Firestore rules. A new account
/// has no profile until onboarding creates a mentor or a student one.
/// (Name kept from Lab 3 baseline, which only had mentors.)
class FirestoreMentorProfileService {
  FirestoreMentorProfileService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  DocumentReference<Map<String, dynamic>> _ref(String uid) =>
      _db.collection('users').doc(uid);

  static String _name(User user) {
    final name = (user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : user.email?.trim().isNotEmpty == true
        ? user.email!.trim()
        : 'TeamUp user');
    return name.length > 120 ? name.substring(0, 120) : name;
  }

  /// Refreshes lastSignInAt of an existing profile; no-op for a new account.
  Future<void> ensure(User user) => _guard(() async {
    final reference = _ref(user.uid);
    await _db.runTransaction((transaction) async {
      final existing = await transaction.get(reference);
      if (!existing.exists) return;
      transaction.update(reference, {
        'displayName': _name(user),
        'lastSignInAt': FieldValue.serverTimestamp(),
      });
    });
  });

  /// The profile document, or null before onboarding.
  Stream<Map<String, dynamic>?> watch(String uid) => _ref(uid)
      .snapshots()
      .map((doc) => doc.data())
      .handleError((Object error) => throw _map(error));

  Future<void> createMentor(User user) => _guard(() async {
    final reference = _ref(user.uid);
    await _db.runTransaction((transaction) async {
      if ((await transaction.get(reference)).exists) {
        throw const ValidationError('This account already has a role');
      }
      transaction.set(reference, {
        'displayName': _name(user),
        'role': 'mentor',
        'lastSignInAt': FieldValue.serverTimestamp(),
      });
    });
  });

  /// Rules re-check that the MSSV belongs to the class and to [teamId].
  Future<void> createStudent(
    User user, {
    required String classId,
    required String studentId,
    required bool leader,
  }) => _guard(() async {
    if (!DataValidation.isId(classId) || !DataValidation.isId(studentId)) {
      throw const ValidationError('Check the class code and student ID');
    }
    final reference = _ref(user.uid);
    final classRef = _db.collection('classes').doc(classId);
    await _db.runTransaction((transaction) async {
      if ((await transaction.get(reference)).exists) {
        throw const ValidationError('This account already has a role');
      }
      final room = await transaction.get(classRef);
      final student = await transaction.get(
        classRef.collection('students').doc(studentId),
      );
      if (!room.exists || !student.exists) {
        throw const ValidationError('Class code or student ID not found');
      }
      final teamId = student.data()?['teamId'];
      if (teamId is! String) {
        throw const ValidationError(
          'You are not in a team yet. Ask your mentor to approve your team first.',
        );
      }
      transaction.set(reference, {
        'displayName': _name(user),
        'role': leader ? 'leader' : 'member',
        'lastSignInAt': FieldValue.serverTimestamp(),
        'classId': classId,
        'teamId': teamId,
        'studentId': studentId,
        'mentorUid': room.data()?['mentorUid'],
      });
    });
  });

  Future<void> _guard(Future<void> Function() body) async {
    try {
      await body();
    } catch (error) {
      throw _map(error);
    }
  }

  static AppError _map(Object error) {
    if (error is AppError) return error;
    if (error is FirebaseException) {
      return switch (error.code) {
        'permission-denied' || 'unauthenticated' => const PermissionDeniedError(
          'Profile is unavailable for this account',
        ),
        'unavailable' => const NetworkError(),
        'deadline-exceeded' => const TimeoutAppError(),
        _ => UnknownError('Could not load your profile', error),
      };
    }
    return UnknownError('Could not load your profile', error);
  }
}
