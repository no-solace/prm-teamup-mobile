import '../models/app_user.dart';

/// Owner: Ken. Google Sign-In + Firebase Auth (S1, S19, S6).
abstract interface class AuthService {
  /// Emits the signed-in mentor or null. Drives the router redirect (D7).
  Stream<AppUser?> authStateChanges();

  AppUser? get currentUser;

  /// Throws [CancelledError] when the user closes the account picker,
  /// [NetworkError] when offline.
  Future<AppUser> signInWithGoogle();

  /// Signs out of Firebase and Google; callers clear local state.
  Future<void> signOut();
}
