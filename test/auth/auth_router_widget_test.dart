import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamup_exe/app.dart';
import 'package:teamup_exe/models/app_user.dart';
import 'package:teamup_exe/providers/fake_overrides.dart';
import 'package:teamup_exe/router/app_router.dart';
import 'package:teamup_exe/services/app_error.dart';
import 'package:teamup_exe/services/fakes/fake_auth_service.dart';
import 'package:teamup_exe/viewmodels/auth/sign_in_view_model.dart';
import 'package:teamup_exe/widgets/status_view.dart';

class _DelayedSession extends FakeAuthService {
  final events = StreamController<AppUser?>();
  @override
  Stream<AppUser?> authStateChanges() => events.stream;
}

Future<ProviderContainer> _mount(WidgetTester tester, FakeAuthService auth) async {
  final container = ProviderContainer(
    overrides: fakeOverrides(signedIn: false, authService: auth),
  );
  addTearDown(() async { container.dispose(); await auth.dispose(); });
  await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const TeamUpApp()));
  await tester.pump();
  return container;
}

void main() {
  testWidgets('initial unresolved session and private deep links never show protected pages', (tester) async {
    final auth = _DelayedSession();
    addTearDown(auth.events.close);
    final container = await _mount(tester, auth);
    expect(
      tester.widget<LoadingView>(find.byType(LoadingView)).label,
      'Checking sign-in',
    );
    expect(find.byType(NavigationBar), findsNothing);
    container.read(appRouterProvider).go('/proposals/p-1/add-member');
    await tester.pump();
    expect(find.byType(NavigationBar), findsNothing);
    auth.events.add(null);
    await tester.pumpAndSettle();
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(container.read(appRouterProvider).routeInformationProvider.value.uri.path, '/sign-in');
  });
  testWidgets('S19 cancellation recovers, profile signs out, stale private link is blocked', (tester) async {
    final auth = FakeAuthService(latency: Duration.zero, failWith: const CancelledError());
    final container = await _mount(tester, auth);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();
    expect(find.text('Sign-in was cancelled'), findsOneWidget);
    auth.failWith = null;
    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsOneWidget);
    container.read(appRouterProvider).go('/profile');
    await tester.pumpAndSettle();
    expect(find.text('Lan Nguyen'), findsOneWidget);
    expect(find.text('lan@example.com'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Sign out'),
      250,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Sign out'));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(container.read(signInViewModelProvider).error, isNull);
    container.read(appRouterProvider).go('/profile');
    await tester.pumpAndSettle();
    expect(container.read(appRouterProvider).routeInformationProvider.value.uri.path, '/sign-in');
    expect(find.text('lan@example.com'), findsNothing);
  });
  for (final width in [360.0, 412.0]) {
    testWidgets('email and phone fit ${width.toInt()}dp with keyboard and larger text', (tester) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final auth = FakeAuthService(latency: Duration.zero);
      await _mount(tester, auth);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Email and password'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Create an email account'));
      await tester.pumpAndSettle();
      expect(find.text('Confirm password'), findsOneWidget);
      await tester.enterText(find.byType(TextField).first, 'invalid');
      await tester.ensureVisible(find.widgetWithText(FilledButton, 'Create account'));
      await tester.tap(find.widgetWithText(FilledButton, 'Create account'));
      await tester.pumpAndSettle();
      expect(find.text('Enter a valid email'), findsOneWidget);
      expect(tester.takeException(), isNull);
      await tester.ensureVisible(find.text('Phone number'));
      await tester.tap(find.text('Phone number'));
      await tester.pumpAndSettle();
      expect(find.text('Phone number with country code'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }
}
