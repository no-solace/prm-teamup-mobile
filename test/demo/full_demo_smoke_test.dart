import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamup_exe/app.dart';
import 'package:teamup_exe/providers/fake_overrides.dart';
import 'package:teamup_exe/providers/service_providers.dart';
import 'package:teamup_exe/router/app_router.dart';
import 'package:teamup_exe/router/routes.dart';
import 'package:teamup_exe/services/class_service.dart';
import 'package:teamup_exe/services/csv_class_importer.dart';
import 'package:teamup_exe/services/fakes/fake_auth_service.dart';
import 'package:teamup_exe/services/fakes/fake_class_service.dart';
import 'package:teamup_exe/services/fakes/fake_infra_services.dart';
import 'package:teamup_exe/services/fakes/fake_matching_service.dart';
import 'package:teamup_exe/viewmodels/classes/import_class_view_model.dart';

class _CsvDemoClasses extends FakeClassService {
  _CsvDemoClasses() : super(latency: Duration.zero);

  @override
  Future<ImportPreview> parseImportFile({
    required String fileName,
    required List<int> bytes,
  }) async => const CsvClassImporter().parse(fileName: fileName, bytes: bytes);
}

void main() {
  testWidgets('demo: sign in, import, match, approve, and export a valid PDF', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(412, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final auth = FakeAuthService(latency: Duration.zero);
    final classes = _CsvDemoClasses();
    final storage = FakeStorageService();
    final fixture = File('tool/fixtures/lab3-demo.csv').readAsBytesSync();
    List<int>? sharedPdf;
    String? sharedFilename;
    const printingChannel = MethodChannel('net.nfet.printing');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(printingChannel, (call) async {
          if (call.method != 'sharePdf') return null;
          final arguments = call.arguments as Map<Object?, Object?>;
          sharedPdf = (arguments['doc'] as Uint8List).toList();
          sharedFilename = arguments['name'] as String;
          return 1;
        });
    addTearDown(() {
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(printingChannel, null);
    });
    final container = ProviderContainer(
      overrides: [
        ...fakeOverrides(
          signedIn: false,
          authService: auth,
          classService: classes,
        ).where(
          (override) =>
              override.origin != matchingServiceProvider &&
              override.origin != storageServiceProvider,
        ),
        matchingServiceProvider.overrideWithValue(
          FakeMatchingService(latency: Duration.zero),
        ),
        storageServiceProvider.overrideWithValue(storage),
        classCsvPickerProvider.overrideWithValue(
          () async => PickedClassCsv(name: 'lab3-demo.csv', bytes: fixture),
        ),
      ],
    );
    addTearDown(() async {
      container.dispose();
      await auth.dispose();
    });

    await tester.pumpWidget(
      UncontrolledProviderScope(container: container, child: const TeamUpApp()),
    );
    await tester.pumpAndSettle();
    expect(find.text('Continue with Google'), findsOneWidget);

    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();
    expect(find.text('My classes'), findsOneWidget);
    expect(find.text('Class A'), findsOneWidget);

    await tester.tap(find.text('Import class list'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Choose CSV'));
    await tester.pumpAndSettle();
    expect(find.text('lab3-demo.csv'), findsOneWidget);
    await tester.tap(find.text('Import 12 students'));
    await tester.pumpAndSettle();
    expect(find.text('Import result'), findsOneWidget);
    final classId = container.read(importClassViewModelProvider).result!.classId;
    await tester.tap(find.text('Open EXE101 Demo'));
    await tester.pumpAndSettle();
    expect(find.text('Automated grouping'), findsOneWidget);

    expect(classes.studentsFor(classId), hasLength(12));
    expect(classes.studentsFor(classId).where((student) => !student.hasTeam), hasLength(3));
    expect(classes.teamsFor(classId).singleWhere((team) => team.id == '2').size, 3);

    await tester.tap(find.text('Match with AI'));
    for (var i = 0;
        i < 20 &&
            container.read(appRouterProvider).routeInformationProvider.value.uri.path !=
                Routes.proposals;
        i++) {
      await tester.pump(const Duration(milliseconds: 250));
    }
    await tester.pumpAndSettle();
    expect(
      container.read(appRouterProvider).routeInformationProvider.value.uri.path,
      Routes.proposals,
    );
    await tester.tap(find.text('Group 2'));
    await tester.pumpAndSettle();
    expect(find.text('Proposal detail'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Approve proposal'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Approve proposal'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Confirm'));
    await tester.pumpAndSettle();
    expect(classes.teamsFor(classId).singleWhere((team) => team.id == '2').size, 6);
    expect(classes.studentsFor(classId).where((student) => !student.hasTeam), isEmpty);

    container.read(appRouterProvider).go(Routes.profile);
    await tester.pumpAndSettle();
    expect(
      container.read(appRouterProvider).routeInformationProvider.value.uri.path,
      Routes.profile,
    );
    await tester.ensureVisible(find.text('Select class'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Select class'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('EXE101 Demo').last);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Generate and upload PDF'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Generate and upload PDF'));
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();

    final pendingReports = storage.watchMyReports().first;
    await tester.pump();
    final reports = await pendingReports;
    expect(reports, hasLength(1));
    expect(reports.single.classId, classId);
    final pdf = await storage.downloadReport(reports.single);
    expect(pdf, isNotEmpty);
    expect(String.fromCharCodes(pdf.take(5)), '%PDF-');
    expect(sharedPdf, orderedEquals(pdf));
    expect(sharedFilename, 'teamup_$classId.pdf');
    expect(find.text('Saved reports'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
