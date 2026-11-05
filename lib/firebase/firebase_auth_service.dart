import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/app_user.dart';
import '../services/app_error.dart';
import '../services/auth_service.dart';

/// Owner: Ken. Google Sign-In (google_sign_in 7.x API) -> Firebase Auth.
class FirebaseAuthService implements AuthService {
  FirebaseAuthService({FirebaseAuth? auth, GoogleSignIn? google, FirebaseFirestore? db})
      : _auth = auth ?? FirebaseAuth.instance,
        _google = google ?? GoogleSignIn.instance,
        _db = db ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final GoogleSignIn _google;
  final FirebaseFirestore _db;
  Future<void>? _init;

  /// Reads the web client ID from google-services.json (via the
  /// google-services Gradle plugin), so no ID is hard-coded here.
  Future<void> _ensureInitialized() => _init ??= _google.initialize();

  static AppUser? _map(User? u) => u == null
      ? null
      : AppUser(
          uid: u.uid,
          displayName: u.displayName ?? u.email ?? 'Mentor',
          email: u.email,
          photoUrl: u.photoURL,
        );

  @override
  Stream<AppUser?> authStateChanges() => _auth.authStateChanges().map(_map);

  @override
  AppUser? get currentUser => _map(_auth.currentUser);

  @override
  Future<AppUser> signInWithGoogle() async {
    try {
      await _ensureInitialized();
      final account = await _google.authenticate();
      final credential = GoogleAuthProvider.credential(idToken: account.authentication.idToken);
      final result = await _auth.signInWithCredential(credential);
      final user = _map(result.user)!;
      // users/{uid}: created on first sign-in, role = mentor (data-model.md).
      await _db.collection('users').doc(user.uid).set(
        {'displayName': user.displayName, 'role': user.role, 'lastSignInAt': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );
      return user;
    } on GoogleSignInException catch (e) {
      throw switch (e.code) {
        GoogleSignInExceptionCode.canceled => const CancelledError(),
        GoogleSignInExceptionCode.interrupted => const CancelledError(),
        _ => UnknownError('Google sign-in failed', e),
      };
    } on FirebaseAuthException catch (e) {
      throw e.code == 'network-request-failed' ? const NetworkError() : UnknownError('Sign-in failed', e);
    } on FirebaseException catch (e) {
      throw e.code == 'unavailable' ? const NetworkError() : UnknownError('Sign-in failed', e);
    }
  }

  @override
  Future<void> signOut() async {
    await _ensureInitialized();
    await _google.signOut();
    await _auth.signOut();
  }
}
