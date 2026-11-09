import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamup_exe/app.dart';
import 'package:teamup_exe/models/proposal.dart';
import 'package:teamup_exe/models/student.dart';
import 'package:teamup_exe/models/team.dart';
import 'package:teamup_exe/providers/fake_overrides.dart';
import 'package:teamup_exe/providers/service_providers.dart';
import 'package:teamup_exe/router/app_router.dart';
import 'package:teamup_exe/router/routes.dart';
import 'package:teamup_exe/services/config_service.dart';
import 'package:teamup_exe/services/fakes/fake_class_service.dart';
import 'package:teamup_exe/services/fakes/fake_infra_services.dart';
import 'package:teamup_exe/services/fakes/fake_matching_service.dart';
import 'package:teamup_exe/viewmodels/classes/import_class_view_model.dart';
import 'package:teamup_exe/widgets/stat_triple.dart';

class _NeverMatcher extends FakeMatchingService {
  @override
  Future<List<Proposal>> propose({
    required String classId,
    required List<Student> students,
    required List<Team> teams,
  }) => Completer<List<Proposal>>().future;
}

Future<ProviderContainer> _app(
  WidgetTester tester, {
  double width = 360,
  FakeConfigService? config,
  bool pendingMatch = false,
}) async {
  tester.view.physicalSize = Size(width, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        ...fakeOverrides(
          classService: FakeClassService(latency: Duration.zero),
        ).where(
          (override) =>
              !(config != null && override.origin == configServiceProvider) &&
              !(pendingMatch && override.origin == matchingServiceProvider),
        ),
        classCsvPickerProvider.overrideWithValue(
          () async => PickedClassCsv(
            name: 'class_A.csv',
            bytes: utf8.encode(
              'MSSV,full name,class,group,major\n190412,Mai Pham,Class A,,MKT',
            ),
          ),
        ),
        if (config != null) configServiceProvider.overrideWithValue(config),
        if (pendingMatch)
          matchingServiceProvider.overrideWithValue(_NeverMatcher()),
      ],
      child: const TeamUpApp(),
    ),
  );
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(TeamUpApp)));
}

void main() {
  testWidgets('S2 → S3 → S4 → S7 and selectable student result', (
    tester,
  ) async {
    final container = await _app(tester);
    expect(find.text('My classes'), findsOneWidget);
    expect(find.text('Import class list'), findsOneWidget);
    await tester.tap(find.text('Class A'));
    await tester.pumpAndSettle();
    expect(find.byType(NavigationBar), findsNothing);
    expect(find.text('Automated grouping'), findsOneWidget);
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.text('Students without team'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilterChip, 'AI'));
    await tester.pumpAndSettle();
    expect(find.text('Lan Vo'), findsOneWidget);
    expect(find.text('Minh Anh'), findsNothing);
    await tester.tap(find.widgetWithText(FilterChip, 'All'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Minh Anh'));
    await tester.pumpAndSettle();
    expect(find.text('Student info'), findsOneWidget);
    expect(find.text('190401'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();
    final result = container
        .read(appRouterProvider)
        .push<String>(Routes.student('class-a', '190401', selectionMode: true));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Add to team'));
    await tester.pumpAndSettle();
    expect(await result, '190401');
    expect(find.text('No team'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('S22 chooses CSV, imports, S23 opens actual class; 412dp', (
    tester,
  ) async {
    await _app(tester, width: 412);
    await tester.tap(find.text('Import class list'));
    await tester.pumpAndSettle();
    final disabled = tester.widget<FilledButton>(
      find.widgetWithText(FilledButton, 'Import students'),
    );
    expect(disabled.onPressed, isNull);
    await tester.tap(find.text('Choose CSV'));
    await tester.pumpAndSettle();
    expect(find.text('class_A.csv'), findsOneWidget);
    expect(find.text('Detected'), findsNWidgets(5));
    await tester.tap(find.text('Import 42 students'));
    await tester.pumpAndSettle();
    expect(find.text('Import result'), findsOneWidget);
    for (final count in ['42', '30', '12']) {
      expect(
        find.descendant(of: find.byType(StatTriple), matching: find.text(count)),
        findsOneWidget,
      );
    }
    await tester.tap(find.text('Open Class A'));
    await tester.pumpAndSettle();
    expect(find.text('Class A'), findsOneWidget);
    expect(find.text('Automated grouping'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('S8 timeout displays S18, retry resumes, Cancel returns to S3', (
    tester,
  ) async {
    await _app(tester, pendingMatch: true);
    await tester.tap(find.text('Class A'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Match with AI'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('AI matching'), findsOneWidget);
    await tester.pump(const Duration(seconds: 30));
    await tester.pumpAndSettle();
    expect(find.text("You're offline"), findsOneWidget);
    await tester.tap(find.text('Try again'));
    await tester.pump();
    expect(find.text('AI matching'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Automated grouping'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'S3 follows ConfigService updates, empty class disables matching',
    (tester) async {
      final config = FakeConfigService();
      final container = await _app(tester, config: config);
      container.read(appRouterProvider).go(Routes.classDetail('class-a'));
      await tester.pumpAndSettle();
      expect(find.text('Match with AI'), findsOneWidget);
      config.set(
        const AppConfig(aiMatchingEnabled: false, maxProposalsShown: 3),
      );
      await tester.pumpAndSettle();
      expect(find.text('Match with AI'), findsNothing);
      config.set(AppConfig.defaults);
      container.read(appRouterProvider).go(Routes.classDetail('class-b'));
      await tester.pumpAndSettle();
      final button = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Match with AI'),
      );
      expect(button.onPressed, isNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('S3/S7 remain scrollable at 360dp with enlarged text', (
    tester,
  ) async {
    final container = await _app(tester);
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    container.read(appRouterProvider).go(Routes.classDetail('class-a'));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    container.read(appRouterProvider).go(Routes.student('class-a', '190401'));
    await tester.pumpAndSettle();
    expect(find.text('Add to team'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('S22 exposes accessible 48dp actions and missing-file guidance', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    final container = await _app(tester);
    container.read(appRouterProvider).go(Routes.importClass);
    await tester.pumpAndSettle();
    expect(find.text('Import class list'), findsOneWidget);
    expect(
      find.bySemanticsLabel(RegExp('Choose a CSV class list')),
      findsOneWidget,
    );
    expect(
      find.bySemanticsLabel(
        'Import unavailable: choose a valid CSV with all five columns',
      ),
      findsOneWidget,
    );
    final choose = find.widgetWithText(FilledButton, 'Choose CSV');
    expect(tester.getSize(choose).height, greaterThanOrEqualTo(48));
    expect(
      tester.getSize(find.byType(BackButton)).height,
      greaterThanOrEqualTo(48),
    );
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });
}
