import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' hide PhoneCodeSent;
import 'package:google_sign_in/google_sign_in.dart';

import '../models/app_user.dart';
import '../services/app_error.dart';
import '../services/auth_service.dart';
import '../services/auth_validation.dart';
import 'auth_error_mapper.dart';
import 'firestore_mentor_profile_service.dart';

/// Firebase is the session authority. Only a provisioned mentor session may
/// access the app's Firestore-backed screens.
class FirebaseAuthService implements AuthService {
  FirebaseAuthService({
    FirebaseAuth? auth,
    GoogleSignIn? google,
    this._profileService,
  }) : _auth = auth ?? FirebaseAuth.instance,
       _google = google ?? GoogleSignIn.instance;

  final FirebaseAuth _auth;
  final GoogleSignIn _google;
  final FirestoreMentorProfileService? _profileService;
  late final FirestoreMentorProfileService _profiles =
      _profileService ?? FirestoreMentorProfileService();
  Future<void>? _init;
  StreamController<PhoneAuthEvent>? _phoneEvents;
  String? _verificationId;
  String? _phoneNumber;
  int? _resendToken;
  int _phoneAttempt = 0;
  bool _phoneCompleting = false;

  Future<void> _ensureInitialized() async {
    try {
      await (_init ??= _google.initialize());
    } catch (_) {
      _init = null;
      rethrow;
    }
  }

  static AppUser? _map(User? user) => user == null
      ? null
      : AppUser(
          uid: user.uid,
          displayName: user.displayName ?? user.email ?? 'Mentor',
          email: user.email,
          photoUrl: user.photoURL,
          phoneNumber: user.phoneNumber,
        );

  AppUser _requireUser(UserCredential result) {
    final user = _map(result.user);
    if (user == null) {
      throw const UnknownError(
        'Sign-in did not return a user. Please try again.',
      );
    }
    return user;
  }

  @override
  Stream<AppUser?> authStateChanges() => _auth.userChanges().asyncMap((
    user,
  ) async {
    if (user == null) return null;
    // Also runs for restored Firebase sessions after an app restart.
    try {
      await _profiles.ensure(user);
    } on NetworkError {
      // Transient (finding F1): keep the valid Firebase session instead of
      // showing the sign-in screen; the next userChanges event retries.
    } on TimeoutAppError {
      // Same as above.
    } on PermissionDeniedError {
      // Not a mentor, or the rules refuse the profile: do not leave the
      // account signed in to Firebase while the app treats it as signed out.
      try {
        await _auth.signOut();
      } catch (_) {
        // The error below still blocks routing.
      }
      rethrow;
    }
    // Sign-out/account switch can occur while Firestore is responding.
    if (_auth.currentUser?.uid != user.uid) return null;
    return _map(user);
  });

  @override
  AppUser? get currentUser => _map(_auth.currentUser);

  @override
  Future<AppUser> signInWithGoogle() async {
    try {
      await _ensureInitialized();
      final account = await _google.authenticate();
      final token = account.authentication.idToken;
      if (token == null) {
        throw const ValidationError(
          'Google did not return an identity token. Please try again.',
        );
      }
      return _requireUser(
        await _auth.signInWithCredential(
          GoogleAuthProvider.credential(idToken: token),
        ),
      );
    } catch (error) {
      throw mapAuthError(error);
    }
  }

  @override
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final normalized = AuthValidation.email(email);
      AuthValidation.password(password);
      return _requireUser(
        await _auth.signInWithEmailAndPassword(
          email: normalized,
          password: password,
        ),
      );
    } catch (error) {
      throw mapAuthError(error);
    }
  }

  @override
  Future<AppUser> registerWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      final normalized = AuthValidation.email(email);
      AuthValidation.password(password, registering: true);
      return _requireUser(
        await _auth.createUserWithEmailAndPassword(
          email: normalized,
          password: password,
        ),
      );
    } catch (error) {
      throw mapAuthError(error);
    }
  }

  @override
  Stream<PhoneAuthEvent> requestPhoneCode(
    String phoneNumber, {
    bool resend = false,
  }) {
    final normalized = AuthValidation.phone(phoneNumber);
    final token = resend && normalized == _phoneNumber ? _resendToken : null;
    cancelPhoneVerification();
    _phoneNumber = normalized;
    final attempt = _phoneAttempt;
    late final StreamController<PhoneAuthEvent> events;
    bool active() => attempt == _phoneAttempt && !events.isClosed;
    void fail(Object error) {
      if (!active()) return;
      events.addError(mapAuthError(error));
      unawaited(events.close());
    }

    events = StreamController<PhoneAuthEvent>(
      onCancel: () {
        if (attempt == _phoneAttempt) cancelPhoneVerification();
      },
    );
    _phoneEvents = events;
    unawaited(() async {
      try {
        await _auth.verifyPhoneNumber(
          phoneNumber: normalized,
          timeout: const Duration(seconds: 60),
          forceResendingToken: token,
          verificationCompleted: (credential) async {
            if (!active() || _phoneCompleting) return;
            _phoneCompleting = true;
            try {
              final user = _requireUser(
                await _auth.signInWithCredential(credential),
              );
              if (active()) events.add(PhoneSignedIn(user));
            } catch (error) {
              fail(error);
            } finally {
              _phoneCompleting = false;
            }
          },
          verificationFailed: fail,
          codeSent: (id, resendToken) {
            if (!active()) return;
            _verificationId = id;
            _resendToken = resendToken;
            events.add(const PhoneCodeSent());
          },
          codeAutoRetrievalTimeout: (id) {
            if (!active()) return;
            _verificationId = id;
            events.add(const PhoneAutoRetrievalTimedOut());
          },
        );
      } catch (error) {
        fail(error);
      }
    }());
    return events.stream;
  }

  @override
  Future<AppUser> confirmPhoneCode(String smsCode) async {
    final code = AuthValidation.smsCode(smsCode);
    final id = _verificationId;
    if (id == null) throw const ValidationError('Request an SMS code first');
    if (_phoneCompleting) {
      throw const ValidationError('Phone verification is already in progress');
    }
    _phoneCompleting = true;
    try {
      return _requireUser(
        await _auth.signInWithCredential(
          PhoneAuthProvider.credential(verificationId: id, smsCode: code),
        ),
      );
    } catch (error) {
      throw mapAuthError(error);
    } finally {
      _phoneCompleting = false;
    }
  }

  @override
  void cancelPhoneVerification() {
    _phoneAttempt++;
    _verificationId = null;
    _resendToken = null;
    _phoneNumber = null;
    final events = _phoneEvents;
    _phoneEvents = null;
    if (events != null && !events.isClosed) unawaited(events.close());
  }

  @override
  Future<void> signOut() async {
    cancelPhoneVerification();
    try {
      try {
        // Email/phone sessions do not initialize Google merely to sign out.
        if (_init != null) await _google.signOut();
      } finally {
        await _auth.signOut();
      }
    } catch (error) {
      if (_auth.currentUser != null) throw mapAuthError(error);
    }
  }
}
