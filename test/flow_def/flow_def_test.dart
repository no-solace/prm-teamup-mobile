import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamup_exe/app.dart';
import 'package:teamup_exe/models/app_user.dart';
import 'package:teamup_exe/models/meeting.dart';
import 'package:teamup_exe/models/project_topic.dart';
import 'package:teamup_exe/providers/fake_overrides.dart';
import 'package:teamup_exe/router/app_router.dart';
import 'package:teamup_exe/router/routes.dart';
import 'package:teamup_exe/screens/flow_e/schedule_screen.dart';
import 'package:teamup_exe/services/app_error.dart';
import 'package:teamup_exe/services/fakes/fake_auth_service.dart';
import 'package:teamup_exe/services/fakes/fake_flow_def_services.dart';

void main() {
  testWidgets(
    'new account onboards as leader, gets student tabs, submits a topic, cannot open mentor pages',
    (tester) async {
      final auth = FakeAuthService(
        latency: Duration.zero,
        user: const AppUser(uid: 'new', displayName: 'An Pham', role: null),
      );
      final container = ProviderContainer(overrides: fakeOverrides(authService: auth));
      addTearDown(() async {
        container.dispose();
        await auth.dispose();
      });
      await tester.pumpWidget(
        UncontrolledProviderScope(container: container, child: const TeamUpApp()),
      );
      await tester.pumpAndSettle();
      String path() => container.read(appRouterProvider).routeInformationProvider.value.uri.path;

      expect(path(), Routes.onboarding);
      await tester.enterText(find.widgetWithText(TextField, 'Class code'), 'class-a');
      await tester.enterText(find.widgetWithText(TextField, 'Student ID (MSSV)'), '190501');
      await tester.tap(find.text('I am the team leader'));
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();

      expect(path(), Routes.classes);
      expect(find.text('Tutor Match'), findsOneWidget);
      for (final tab in ['My team', 'Topics', 'Schedule', 'Profile']) {
        expect(find.descendant(of: find.byType(NavigationBar), matching: find.text(tab)), findsOneWidget);
      }
      expect(find.text('Proposals'), findsNothing);

      await tester.tap(find.text('Topics'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Submit topic'));
      await tester.pumpAndSettle();
      await tester.enterText(find.widgetWithText(TextField, 'Title'), 'Campus tutor finder');
      await tester.enterText(find.widgetWithText(TextField, 'Idea summary'), 'Match students with tutors');
      await tester.enterText(find.widgetWithText(TextField, 'Tech stack'), 'Flutter, Firebase');
      await tester.tap(find.text('Send to mentor'));
      await tester.pumpAndSettle();
      expect(find.text('Campus tutor finder'), findsOneWidget);
      expect(find.text('Pending review'), findsOneWidget);

      for (final denied in ['/proposals', Routes.classDetail('class-a')]) {
        container.read(appRouterProvider).go(denied);
        await tester.pumpAndSettle();
        expect(path(), Routes.classes, reason: denied);
      }
    },
  );

  testWidgets('mentor keeps Proposals and gets Topics + Schedule tabs; student-only pages bounce', (tester) async {
    final container = ProviderContainer(overrides: fakeOverrides());
    addTearDown(container.dispose);
    await tester.pumpWidget(UncontrolledProviderScope(container: container, child: const TeamUpApp()));
    await tester.pumpAndSettle();
    for (final tab in ['Classes', 'Proposals', 'Topics', 'Schedule', 'Profile']) {
      expect(find.descendant(of: find.byType(NavigationBar), matching: find.text(tab)), findsOneWidget);
    }
    container.read(appRouterProvider).go(Routes.bookSlot);
    await tester.pumpAndSettle();
    expect(container.read(appRouterProvider).routeInformationProvider.value.uri.path, Routes.classes);
  });

  testWidgets('Meet link dialog closes without using a disposed controller', (tester) async {
    late BuildContext ctx;
    await tester.pumpWidget(MaterialApp(home: Builder(builder: (c) {
      ctx = c;
      return const SizedBox();
    })));
    final result = askMeetLink(ctx);
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'https://meet.google.com/abc-defg-hij');
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(await result, 'https://meet.google.com/abc-defg-hij');
  });

  test('overlapping slots and incomplete action items are rejected', () async {
    final booking = FakeBookingService();
    final start = DateTime.now().add(const Duration(days: 3));
    await booking.addSlot(start, const Duration(minutes: 30));
    await expectLater(
      booking.addSlot(start.add(const Duration(minutes: 15)), const Duration(minutes: 30)),
      throwsA(isA<ValidationError>()),
    );
    await booking.addSlot(start.add(const Duration(minutes: 30)), const Duration(minutes: 30));

    final b = MeetingBooking(
      id: 'b',
      slotId: 's',
      mentorUid: 'm',
      classId: 'c',
      teamId: 't',
      teamName: 'T',
      purpose: MeetingPurpose.values.first,
      status: BookingStatus.confirmed,
      startTime: start,
      endTime: start,
    );
    await expectLater(
      FakeMeetingService().saveMinutes(
        b,
        summary: 'ok',
        actionItems: const [ActionItem(task: 'Fix', assignee: '', deadline: '')],
      ),
      throwsA(isA<ValidationError>()),
    );
  });

  test('wire formats reject bad data', () {
    expect(MeetingBooking.meetUrlPattern.hasMatch('https://meet.google.com/abc-defg-hij'), isTrue);
    expect(MeetingBooking.meetUrlPattern.hasMatch('https://evil.com/abc-defg-hij'), isFalse);
    expect(TopicStatus.fromCode('revision_requested'), TopicStatus.revisionRequested);
    expect(() => TopicStatus.fromCode('approved_by_me'), throwsFormatException);
    expect(
      () => MentorSlot.fromMap('s1', 'm', {
        'startTime': DateTime(2026),
        'endTime': DateTime(2026),
        'status': 'booked',
        'bookingId': null,
      }),
      throwsFormatException,
    );
    expect(Routes.isAllowedDeepLink('/schedule/b-1'), isTrue);
    expect(Routes.isAllowedDeepLink('/topics/c_t'), isTrue);
  });
}
