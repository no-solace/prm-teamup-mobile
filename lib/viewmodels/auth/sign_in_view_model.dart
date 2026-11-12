import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/app_user.dart';
import '../../providers/service_providers.dart';
import '../../services/app_error.dart';
import '../../services/auth_service.dart';
import '../../services/auth_validation.dart';
import '../view_state.dart';

enum SignInMethod { google, email, phone }

class SignInState {
  const SignInState({
    this.method = SignInMethod.google,
    this.loading = false,
    this.registering = false,
    this.codeSent = false,
    this.resendSeconds = 0,
    this.info,
    this.error,
  });

  final SignInMethod method;
  final bool loading;
  final bool registering;
  final bool codeSent;
  final int resendSeconds;
  final String? info;
  final AppError? error;
}

class SignInViewModel extends Notifier<SignInState> {
  StreamSubscription<PhoneAuthEvent>? _phoneSub;
  Timer? _requestTimeout;
  Timer? _resendTimer;
  int _attempt = 0;

  @override
  SignInState build() {
    final auth = ref.read(authServiceProvider);
    ref.onDispose(() {
      _attempt++;
      _phoneSub?.cancel();
      _requestTimeout?.cancel();
      _resendTimer?.cancel();
      auth.cancelPhoneVerification();
    });
    return const SignInState();
  }

  SignInState _copy({
    bool? loading,
    bool? codeSent,
    int? resendSeconds,
    String? info,
    AppError? error,
  }) => SignInState(
    method: state.method,
    registering: state.registering,
    loading: loading ?? state.loading,
    codeSent: codeSent ?? state.codeSent,
    resendSeconds: resendSeconds ?? state.resendSeconds,
    info: info,
    error: error,
  );

  void selectMethod(SignInMethod method) {
    if (state.loading) return;
    _cancelPhone();
    state = SignInState(method: method);
  }

  void toggleRegistration() {
    if (state.loading) return;
    state = SignInState(
      method: SignInMethod.email,
      registering: !state.registering,
    );
  }

  Future<void> signIn() =>
      _authenticate(() => ref.read(authServiceProvider).signInWithGoogle());

  Future<void> submitEmail(
    String email,
    String password, {
    String? confirmation,
  }) => _authenticate(() {
    final normalized = AuthValidation.email(email);
    AuthValidation.password(password, registering: state.registering);
    if (state.registering && confirmation != password) {
      throw const ValidationError('Passwords do not match');
    }
    final auth = ref.read(authServiceProvider);
    return state.registering
        ? auth.registerWithEmail(email: normalized, password: password)
        : auth.signInWithEmail(email: normalized, password: password);
  });

  Future<void> _authenticate(Future<AppUser> Function() action) async {
    if (state.loading) return;
    state = _copy(loading: true);
    try {
      final user = await action();
      if (!ref.mounted) return;
      state = _copy(loading: false);
      await _recordLogin(user);
    } catch (error) {
      if (ref.mounted) state = _copy(loading: false, error: toAppError(error));
    }
  }

  Future<void> _recordLogin(AppUser user) async {
    final analytics = ref.read(analyticsServiceProvider);
    final crash = ref.read(crashServiceProvider);
    // Observability cannot fail authentication; do not forward credentials.
    await Future.wait([
      _bestEffort(() => analytics.setUser(user.uid)),
      _bestEffort(
        () => analytics.logLogin(
          method: state.method.name == 'email' ? 'password' : state.method.name,
        ),
      ),
      _bestEffort(() => crash.setUser(uid: user.uid, role: user.role?.name ?? 'unassigned')),
    ]);
  }

  Future<void> _bestEffort(Future<void> Function() action) async {
    try {
      await action();
    } catch (_) {
      /* Auth is already complete. */
    }
  }

  void requestPhoneCode(
    String phoneNumber, {
    bool resend = false,
    required bool consent,
  }) {
    if (state.loading || (resend && state.resendSeconds > 0)) return;
    try {
      if (!consent) {
        throw const ValidationError(
          'Agree to phone verification before requesting an SMS',
        );
      }
      final normalized = AuthValidation.phone(phoneNumber);
      final previousSub = _phoneSub;
      _requestTimeout?.cancel();
      final attempt = ++_attempt;
      state = _copy(loading: true, codeSent: false);
      final stream = ref
          .read(authServiceProvider)
          .requestPhoneCode(normalized, resend: resend);
      previousSub?.cancel();
      _requestTimeout = Timer(const Duration(seconds: 90), () {
        if (!ref.mounted || attempt != _attempt) return;
        _cancelPhone();
        state = _copy(
          loading: false,
          codeSent: false,
          error: const TimeoutAppError('No SMS response. Please try again.'),
        );
      });
      _phoneSub = stream.listen(
        (event) {
          if (!ref.mounted || attempt != _attempt) return;
          _requestTimeout?.cancel();
          switch (event) {
            case PhoneCodeSent():
              _startResendTimer();
              state = _copy(
                loading: false,
                codeSent: true,
                resendSeconds: 60,
                info: 'SMS code sent. Enter it below.',
              );
            case PhoneAutoRetrievalTimedOut():
              state = _copy(
                loading: false,
                codeSent: true,
                info: 'Automatic SMS retrieval ended. Enter your code or request a new one.',
              );
            case PhoneSignedIn(:final user):
              state = _copy(loading: false);
              unawaited(_recordLogin(user));
          }
        },
        onError: (Object error) {
          if (!ref.mounted || attempt != _attempt) return;
          _requestTimeout?.cancel();
          state = _copy(loading: false, error: toAppError(error));
        },
      );
    } catch (error) {
      state = _copy(loading: false, error: toAppError(error));
    }
  }

  void _startResendTimer() {
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!ref.mounted || state.resendSeconds <= 1) {
        timer.cancel();
        if (ref.mounted) {
          state = _copy(resendSeconds: 0, info: state.info, error: state.error);
        }
      } else {
        state = _copy(
          resendSeconds: state.resendSeconds - 1,
          info: state.info,
          error: state.error,
        );
      }
    });
  }

  Future<void> confirmPhoneCode(String smsCode) => _authenticate(
    () => ref.read(authServiceProvider).confirmPhoneCode(smsCode),
  );

  void _cancelPhone() {
    _attempt++;
    _requestTimeout?.cancel();
    _resendTimer?.cancel();
    _phoneSub?.cancel();
    _phoneSub = null;
    ref.read(authServiceProvider).cancelPhoneVerification();
  }

  void cancelPhone() {
    if (state.loading && state.codeSent) return;
    _cancelPhone();
    state = const SignInState(
      method: SignInMethod.phone,
      error: CancelledError('Phone sign-in was cancelled'),
    );
  }
}

final signInViewModelProvider =
    NotifierProvider.autoDispose<SignInViewModel, SignInState>(
      SignInViewModel.new,
    );
