import 'dart:async';

import '../../models/app_user.dart';
import '../app_error.dart';
import '../auth_service.dart';
import 'sample_data.dart';

class FakeAuthService implements AuthService {
  FakeAuthService({this.signedIn = false, this.failWith}) {
    _current = signedIn ? _lan : null;
  }

  final bool signedIn;

  /// Set to simulate S19 (for example `CancelledError()`).
  AppError? failWith;

  static const _lan = AppUser(uid: SampleData.mentorUid, displayName: 'Lan Nguyen', email: 'lan@example.com');

  AppUser? _current;
  final _controller = StreamController<AppUser?>.broadcast();

  @override
  Stream<AppUser?> authStateChanges() async* {
    yield _current;
    yield* _controller.stream;
  }

  @override
  AppUser? get currentUser => _current;

  @override
  Future<AppUser> signInWithGoogle() async {
    await Future<void>.delayed(const Duration(milliseconds: 400));
    final error = failWith;
    if (error != null) throw error;
    _current = _lan;
    _controller.add(_current);
    return _lan;
  }

  @override
  Future<void> signOut() async {
    _current = null;
    _controller.add(null);
  }
}
