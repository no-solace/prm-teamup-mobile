import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamup_exe/providers/fake_overrides.dart';
import 'package:teamup_exe/services/app_error.dart';
import 'package:teamup_exe/services/fakes/fake_auth_service.dart';
import 'package:teamup_exe/services/fakes/fake_infra_services.dart';
import 'package:teamup_exe/viewmodels/auth/sign_in_view_model.dart';
import 'package:teamup_exe/viewmodels/profile/profile_view_model.dart';

class _BrokenAnalytics extends FakeAnalyticsService {
  @override
  Future<void> logLogin({String method = 'google'}) async => throw StateError('analytics unavailable');
  @override
  Future<void> logLogout() async => throw StateError('analytics unavailable');
}

void main() {
  late ProviderContainer container;
  late FakeAuthService auth;
  late FakeAnalyticsService analytics;
  setUp(() {
    auth = FakeAuthService(latency: Duration.zero);
    analytics = FakeAnalyticsService();
    container = ProviderContainer(
      overrides: fakeOverrides(
        signedIn: false,
        authService: auth,
        analyticsService: analytics,
      ),
    );
    container.listen(signInViewModelProvider, (_, _) {});
    container.listen(profileViewModelProvider, (_, _) {});
  });
  tearDown(() async {
    container.dispose();
    await auth.dispose();
  });

  test('Google loading prevents duplicate requests and logs a successful login', () async {
    final vm = container.read(signInViewModelProvider.notifier);
    final pending = vm.signIn();
    expect(container.read(signInViewModelProvider).loading, true);
    await vm.signIn();
    await pending;
    expect(auth.signInCalls, 1);
    expect(auth.currentUser, isNotNull);
    expect(container.read(signInViewModelProvider).loading, false);
    expect(analytics.events, contains('login {method: google}'));
  });
  for (final error in [const CancelledError(), const NetworkError()]) {
    test('S19 handles ${error.runtimeType} and permits retry', () async {
      auth.failWith = error;
      final vm = container.read(signInViewModelProvider.notifier);
      await vm.signIn();
      expect(container.read(signInViewModelProvider).error, same(error));
      expect(auth.currentUser, isNull);
      auth.failWith = null;
      await vm.signIn();
      expect(container.read(signInViewModelProvider).error, isNull);
    });
  }
  test('invalid email never reaches auth; registration checks confirmation', () async {
    final vm = container.read(signInViewModelProvider.notifier)..selectMethod(SignInMethod.email);
    await vm.submitEmail('invalid', 'password');
    expect(auth.signInCalls, 0);
    expect(container.read(signInViewModelProvider).error, isA<ValidationError>());
    vm.toggleRegistration();
    await vm.submitEmail('mentor@example.com', 'secret', confirmation: 'different');
    expect(auth.signInCalls, 0);
    await vm.submitEmail(' mentor@example.com ', 'secret', confirmation: 'secret');
    expect(auth.currentUser?.email, 'mentor@example.com');
    expect(analytics.events, contains('login {method: password}'));
  });
  test('phone requires consent, supports incorrect code then successful retry', () async {
    final vm = container.read(signInViewModelProvider.notifier)..selectMethod(SignInMethod.phone);
    vm.requestPhoneCode('+84912345678', consent: false);
    expect(container.read(signInViewModelProvider).error, isA<ValidationError>());
    vm.requestPhoneCode('+84912345678', consent: true);
    await pumpEventQueue();
    expect(container.read(signInViewModelProvider).codeSent, true);
    expect(container.read(signInViewModelProvider).resendSeconds, 60);
    await vm.confirmPhoneCode('654321');
    expect(container.read(signInViewModelProvider).error, isA<ValidationError>());
    await vm.confirmPhoneCode(FakeAuthService.testSmsCode);
    expect(auth.currentUser?.phoneNumber, '+84912345678');
    expect(analytics.events, contains('login {method: phone}'));
  });
  test('phone auto retrieval timeout keeps manual code entry available', () async {
    auth.autoRetrievalTimeout = true;
    final vm = container.read(signInViewModelProvider.notifier)..selectMethod(SignInMethod.phone);
    vm.requestPhoneCode('+84912345678', consent: true);
    await pumpEventQueue();
    final state = container.read(signInViewModelProvider);
    expect(state.loading, false);
    expect(state.codeSent, true);
    expect(state.info, contains('Automatic SMS retrieval ended'));
    await vm.confirmPhoneCode(FakeAuthService.testSmsCode);
    expect(auth.currentUser, isNotNull);
  });
  test('phone automatic verification signs in', () async {
    auth.autoVerifyPhone = true;
    final vm = container.read(signInViewModelProvider.notifier)..selectMethod(SignInMethod.phone);
    vm.requestPhoneCode('+84912345678', consent: true);
    await pumpEventQueue();
    expect(auth.currentUser?.phoneNumber, '+84912345678');
    expect(container.read(signInViewModelProvider).error, isNull);
  });
  test('phone cancel suppresses a late SMS callback and clears pending verification', () async {
    final vm = container.read(signInViewModelProvider.notifier)..selectMethod(SignInMethod.phone);
    vm.requestPhoneCode('+84912345678', consent: true);
    vm.cancelPhone();
    await pumpEventQueue();
    expect(container.read(signInViewModelProvider).codeSent, false);
    expect(container.read(signInViewModelProvider).error, isA<CancelledError>());
    expect(auth.currentUser, isNull);
  });
  test('phone provider failure is visible and retryable', () async {
    auth.failWith = const NetworkError();
    final vm = container.read(signInViewModelProvider.notifier)..selectMethod(SignInMethod.phone);
    vm.requestPhoneCode('+84912345678', consent: true);
    await pumpEventQueue();
    expect(container.read(signInViewModelProvider).error, isA<NetworkError>());
    expect(container.read(signInViewModelProvider).loading, false);
    auth.failWith = null;
    vm.requestPhoneCode('+84912345678', consent: true);
    await pumpEventQueue();
    expect(container.read(signInViewModelProvider).codeSent, true);
  });
  test('profile surfaces signout failure without claiming session ended', () async {
    await auth.signInWithGoogle();
    auth.signOutError = const NetworkError();
    await container.read(profileViewModelProvider.notifier).signOut();
    expect(container.read(profileViewModelProvider).error, isA<NetworkError>());
    expect(container.read(profileViewModelProvider).signingOut, false);
    expect(auth.currentUser, isNotNull);
  });
  test('profile clears analytics identity after successful signout', () async {
    await auth.signInWithGoogle();
    await container.read(profileViewModelProvider.notifier).signOut();
    expect(auth.currentUser, isNull);
    expect(analytics.events, contains('clear_user_id {}'));
  });
  test('telemetry errors cannot fail login or block signout', () async {
    container.dispose();
    container = ProviderContainer(
      overrides: fakeOverrides(
        signedIn: false,
        authService: auth,
        analyticsService: _BrokenAnalytics(),
      ),
    );
    container.listen(signInViewModelProvider, (_, _) {});
    container.listen(profileViewModelProvider, (_, _) {});
    await container.read(signInViewModelProvider.notifier).signIn();
    expect(auth.currentUser, isNotNull);
    expect(container.read(signInViewModelProvider).error, isNull);
    await container.read(profileViewModelProvider.notifier).signOut();
    expect(auth.currentUser, isNull);
  });
}
