import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/app_error.dart';

/// Creates the mentor record required by Firestore rules before opening data.
class FirestoreMentorProfileService {
  FirestoreMentorProfileService({FirebaseFirestore? db})
    : _db = db ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  Future<void> ensure(User user) async {
    final name = (user.displayName?.trim().isNotEmpty == true
        ? user.displayName!.trim()
        : user.email?.trim().isNotEmpty == true
        ? user.email!.trim()
        : 'Mentor');
    final displayName = name.length > 120 ? name.substring(0, 120) : name;
    final reference = _db.collection('users').doc(user.uid);

    try {
      await _db.runTransaction((transaction) async {
        final existing = await transaction.get(reference);
        if (!existing.exists) {
          transaction.set(reference, {
            'displayName': displayName,
            'role': 'mentor',
            'lastSignInAt': FieldValue.serverTimestamp(),
          });
          return;
        }
        if (existing.data()?['role'] != 'mentor') {
          throw const PermissionDeniedError('This account is not a mentor');
        }
        transaction.update(reference, {
          'displayName': displayName,
          'lastSignInAt': FieldValue.serverTimestamp(),
        });
      });
    } on FirebaseException catch (error) {
      switch (error.code) {
        case 'permission-denied':
        case 'unauthenticated':
          throw const PermissionDeniedError('Mentor profile is unavailable');
        case 'unavailable':
          throw const NetworkError();
        case 'deadline-exceeded':
          throw const TimeoutAppError();
        default:
          throw UnknownError('Could not initialize mentor profile', error);
      }
    }
  }
}
