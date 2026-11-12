import 'dart:async';

import '../../models/app_user.dart';
import '../app_error.dart';
import '../auth_service.dart';
import '../auth_validation.dart';
import 'sample_data.dart';

/// Development only. Configurable latency/errors without network or Firebase.
class FakeAuthService implements AuthService {
  FakeAuthService({
    bool signedIn = false,
    this.failWith,
    this.latency = const Duration(milliseconds: 400),
    AppUser? user,
  }) {
    _current = user ?? (signedIn ? _lan : null);
  }

  /// Leader of Tutor Match in class-a (Flow D/E/F demos and tests).
  static const leader = AppUser(
    uid: 'fake-leader',
    displayName: 'An Pham',
    role: UserRole.leader,
    classId: 'class-a',
    teamId: 'team-tutor',
    studentId: '190501',
    mentorUid: SampleData.mentorUid,
  );

  AppError? failWith;
  AppError? signOutError;
  final Duration latency;
  int signInCalls = 0;
  int signOutCalls = 0;
  bool autoVerifyPhone = false;
  bool autoRetrievalTimeout = false;
  static const testSmsCode = '123456';
  static const _lan = AppUser(
    uid: SampleData.mentorUid,
    displayName: 'Lan Nguyen',
    email: 'lan@example.com',
  );
  AppUser? _current;
  String? _phoneNumber;
  int _phoneAttempt = 0;
  final _controller = StreamController<AppUser?>.broadcast();

  @override
  Stream<AppUser?> authStateChanges() => Stream<AppUser?>.multi((events) {
    final sub = _controller.stream.listen(events.add, onError: events.addError);
    events.add(_current);
    events.onCancel = sub.cancel;
  });

  @override
  AppUser? get currentUser => _current;

  Future<void> _wait() async {
    await Future<void>.delayed(latency);
    final error = failWith;
    if (error != null) throw error;
  }

  AppUser _signedIn(AppUser user) {
    _current = user;
    _controller.add(user);
    return user;
  }

  @override
  Future<AppUser> signInWithGoogle() async {
    signInCalls++;
    await _wait();
    return _signedIn(_lan);
  }

  @override
  Future<AppUser> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final normalized = AuthValidation.email(email);
    AuthValidation.password(password);
    signInCalls++;
    await _wait();
    return _signedIn(
      AppUser(uid: _lan.uid, displayName: 'Mentor', email: normalized),
    );
  }

  @override
  Future<AppUser> registerWithEmail({
    required String email,
    required String password,
  }) async {
    AuthValidation.password(password, registering: true);
    return signInWithEmail(email: email, password: password);
  }

  @override
  Stream<PhoneAuthEvent> requestPhoneCode(
    String phoneNumber, {
    bool resend = false,
  }) async* {
    final normalized = AuthValidation.phone(phoneNumber);
    final attempt = ++_phoneAttempt;
    _phoneNumber = normalized;
    await _wait();
    if (attempt != _phoneAttempt) return;
    yield const PhoneCodeSent();
    if (autoVerifyPhone) {
      yield PhoneSignedIn(
        _signedIn(
          AppUser(
            uid: _lan.uid,
            displayName: 'Mentor',
            phoneNumber: normalized,
          ),
        ),
      );
    } else if (autoRetrievalTimeout) {
      yield const PhoneAutoRetrievalTimedOut();
    }
  }

  @override
  Future<AppUser> confirmPhoneCode(String smsCode) async {
    final code = AuthValidation.smsCode(smsCode);
    final number = _phoneNumber;
    if (number == null) {
      throw const ValidationError('Request an SMS code first');
    }
    await _wait();
    if (code != testSmsCode) {
      throw const ValidationError('The SMS code is incorrect. Try again.');
    }
    return _signedIn(
      AppUser(uid: _lan.uid, displayName: 'Mentor', phoneNumber: number),
    );
  }

  @override
  void cancelPhoneVerification() {
    _phoneAttempt++;
    _phoneNumber = null;
  }

  @override
  Future<void> completeMentorProfile() async {
    final user = _current;
    if (user == null) throw const PermissionDeniedError('Sign in first');
    _signedIn(AppUser(uid: user.uid, displayName: user.displayName, email: user.email));
  }

  @override
  Future<void> completeStudentProfile({
    required String classId,
    required String studentId,
    required bool leader,
  }) async {
    final user = _current;
    if (user == null) throw const PermissionDeniedError('Sign in first');
    final student = SampleData.students()
        .where((s) => s.classId == classId.trim() && s.mssv == studentId.trim())
        .firstOrNull;
    if (student == null) {
      throw const ValidationError('Class code or student ID not found');
    }
    if (student.teamId == null) {
      throw const ValidationError(
        'You are not in a team yet. Ask your mentor to approve your team first.',
      );
    }
    _signedIn(
      AppUser(
        uid: user.uid,
        displayName: user.displayName,
        email: user.email,
        role: leader ? UserRole.leader : UserRole.member,
        classId: student.classId,
        teamId: student.teamId,
        studentId: student.mssv,
        mentorUid: SampleData.mentorUid,
      ),
    );
  }

  @override
  Future<void> signOut() async {
    signOutCalls++;
    final error = signOutError;
    if (error != null) throw error;
    cancelPhoneVerification();
    _current = null;
    _controller.add(null);
  }

  Future<void> dispose() => _controller.close();
}
