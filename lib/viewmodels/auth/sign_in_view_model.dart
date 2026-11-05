import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/service_providers.dart';
import '../../services/app_error.dart';
import '../view_state.dart';

/// S1 / S19 state. Not a data-loading screen, so it has its own small model.
class SignInState {
  const SignInState({this.loading = false, this.error});

  final bool loading;

  /// Non-null shows S19 (cancelled, offline, unknown).
  final AppError? error;
}

/// Owner: Ken.
class SignInViewModel extends Notifier<SignInState> {
  @override
  SignInState build() => const SignInState();

  Future<void> signIn() async {
    if (state.loading) return;
    state = const SignInState(loading: true);
    try {
      final user = await ref.read(authServiceProvider).signInWithGoogle();
      await ref.read(analyticsServiceProvider).setUser(user.uid);
      await ref.read(analyticsServiceProvider).logLogin();
      await ref.read(crashServiceProvider).setUser(uid: user.uid, role: user.role);
      state = const SignInState();
      // The router redirect moves to /classes when the session changes.
    } catch (e) {
      state = SignInState(error: toAppError(e));
    }
  }
}

final signInViewModelProvider = NotifierProvider<SignInViewModel, SignInState>(SignInViewModel.new);
