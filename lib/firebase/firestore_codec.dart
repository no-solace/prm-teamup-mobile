import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../services/app_error.dart';

/// Document data with Timestamps turned into DateTime (models stay SDK-free).
/// A pending serverTimestamp() (*At fields) reads as null locally until the
/// write lands; it is shown as "now" instead of failing validation.
Map<String, dynamic>? plainData(DocumentSnapshot<Map<String, dynamic>> doc) =>
    doc.data()?.map(
      (k, v) => MapEntry(
        k,
        v is Timestamp
            ? v.toDate()
            : v == null && k.endsWith('At')
            ? DateTime.now()
            : v,
      ),
    );

String currentUid(FirebaseAuth auth) =>
    auth.currentUser?.uid ?? (throw const PermissionDeniedError('Sign in first'));

AppError toFirestoreAppError(Object error, String what) {
  if (error is AppError) return error;
  if (error is FormatException) return ValidationError('Stored $what data is invalid');
  if (error is FirebaseException) {
    return switch (error.code) {
      'permission-denied' || 'unauthenticated' => const PermissionDeniedError(),
      'not-found' => const NotFoundError(),
      'unavailable' => const NetworkError(),
      'deadline-exceeded' => const TimeoutAppError(),
      'aborted' || 'failed-precondition' => ValidationError('The $what changed. Try again'),
      _ => UnknownError('Could not access $what', error),
    };
  }
  return UnknownError('Could not access $what', error);
}

/// Maps every stream error to [AppError].
Stream<T> appErrors<T>(Stream<T> source, String what) =>
    source.handleError((Object e) => throw toFirestoreAppError(e, what));

/// Maps a failed write to [AppError].
Future<T> guardWrite<T>(String what, Future<T> Function() body) async {
  try {
    return await body();
  } catch (e) {
    throw toFirestoreAppError(e, what);
  }
}
