import '../models/app_user.dart';

/// Owner: Ken. Firebase Auth (S1, S19, S6). No SDK types cross this boundary.
abstract interface class AuthService {
  /// Emits the signed-in mentor or null. Drives the router redirect (D7).
  Stream<AppUser?> authStateChanges();

  AppUser? get currentUser;

  /// Throws [CancelledError] when the user closes the account picker,
  /// [NetworkError] when offline.
  Future<AppUser> signInWithGoogle();

  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  });

  Future<AppUser> registerWithEmail({
    required String email,
    required String password,
  });

  /// Native Android verification, including automatic SMS retrieval.
  Stream<PhoneAuthEvent> requestPhoneCode(
    String phoneNumber, {
    bool resend = false,
  });

  Future<AppUser> confirmPhoneCode(String smsCode);

  /// Ignores late native callbacks; an already sent SMS cannot be recalled.
  void cancelPhoneVerification();

  /// First sign-in only: creates users/{uid} with role mentor.
  Future<void> completeMentorProfile();

  /// First sign-in only: links the account to an imported student who
  /// already has a team. Throws [ValidationError] when the class code/MSSV
  /// does not match, or the student has no team yet.
  Future<void> completeStudentProfile({
    required String classId,
    required String studentId,
    required bool leader,
  });

  /// Signs out of Firebase and Google; callers clear local state.
  Future<void> signOut();
}

sealed class PhoneAuthEvent {
  const PhoneAuthEvent();
}

class PhoneCodeSent extends PhoneAuthEvent {
  const PhoneCodeSent();
}

/// Automatic retrieval timed out; the user can still enter the SMS code.
class PhoneAutoRetrievalTimedOut extends PhoneAuthEvent {
  const PhoneAutoRetrievalTimedOut();
}

class PhoneSignedIn extends PhoneAuthEvent {
  const PhoneSignedIn(this.user);
  final AppUser user;
}
