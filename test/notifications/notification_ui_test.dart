import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamup_exe/providers/fake_overrides.dart';
import 'package:teamup_exe/screens/notifications/config_demo_panel.dart';
import 'package:teamup_exe/screens/notifications/inbox_screen.dart';
import 'package:teamup_exe/services/config_service.dart';
import 'package:teamup_exe/services/fakes/fake_infra_services.dart';
import 'package:teamup_exe/services/notification_service.dart';
import 'package:teamup_exe/theme/app_theme.dart';

void main() {
  for (final width in [360.0, 412.0]) {
    testWidgets('inbox read/unread and permission denied at width $width', (
      tester,
    ) async {
      tester.view.physicalSize = Size(width, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      final notifications = FakeNotificationService(
        permission: NotificationPermission.denied,
      );
      addTearDown(notifications.dispose);
      await tester.pumpWidget(
        ProviderScope(
          overrides: fakeOverrides(notificationService: notifications),
          child: MaterialApp(theme: buildAppTheme(), home: const InboxScreen()),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.textContaining('1 unread'), findsOneWidget);
      expect(find.textContaining('Not allowed.'), findsOneWidget);
      await tester.tap(find.byTooltip('Mark all read'));
      await tester.pumpAndSettle();
      expect(find.textContaining('0 unread'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'two Remote Config values change actual demo actions and real service list',
    (tester) async {
      final config = FakeConfigService();
      await tester.pumpWidget(
        ProviderScope(
          overrides: fakeOverrides(configService: config),
          child: MaterialApp(
            theme: buildAppTheme(),
            home: const Scaffold(
              body: SingleChildScrollView(child: ConfigDemoPanel()),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Match with AI'), findsOneWidget);
      final original = find.byType(ListTile).evaluate().length;
      expect(original, 3);
      config.set(
        const AppConfig(aiMatchingEnabled: false, maxProposalsShown: 1),
      );
      await tester.pumpAndSettle();
      expect(find.text('Match with AI'), findsNothing);
      expect(
        find.text('AI matching is disabled by Remote Config.'),
        findsOneWidget,
      );
      expect(find.byType(ListTile), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
