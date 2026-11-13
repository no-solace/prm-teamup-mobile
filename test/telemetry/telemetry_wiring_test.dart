import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamup_exe/models/proposal.dart';
import 'package:teamup_exe/models/report.dart';
import 'package:teamup_exe/models/student.dart';
import 'package:teamup_exe/models/team.dart';
import 'package:teamup_exe/providers/fake_overrides.dart';
import 'package:teamup_exe/providers/service_providers.dart';
import 'package:teamup_exe/services/app_error.dart';
import 'package:teamup_exe/services/class_service.dart';
import 'package:teamup_exe/services/fakes/fake_class_service.dart';
import 'package:teamup_exe/services/fakes/fake_infra_services.dart';
import 'package:teamup_exe/services/fakes/fake_matching_service.dart';
import 'package:teamup_exe/services/matching_service.dart';
import 'package:teamup_exe/viewmodels/classes/class_detail_view_model.dart';
import 'package:teamup_exe/viewmodels/classes/import_class_view_model.dart';
import 'package:teamup_exe/viewmodels/classes/matching_view_model.dart';
import 'package:teamup_exe/viewmodels/classes/student_detail_view_model.dart';
import 'package:teamup_exe/viewmodels/profile/report_demo_view_model.dart';
import 'package:teamup_exe/viewmodels/proposals/proposal_view_model.dart';

class _FailingMatcher extends FakeMatchingService {
  @override
  Future<List<Proposal>> propose({
    required String classId,
    required List<Student> students,
    required List<Team> teams,
  }) => Future.error(const NetworkError());
}

class _FailingImport extends FakeClassService {
  _FailingImport() : super(latency: Duration.zero);

  @override
  Future<ImportResult> importClass(ImportPreview preview) =>
      Future.error(const NetworkError());
}

class _Crash extends FakeCrashService {
  final classes = <String?>[];

  @override
  Future<void> setClass(String? classId) async => classes.add(classId);
}

/// Everything the Lab 3 analytics plan lists must really be logged.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late FakeAnalyticsService analytics;
  late _Crash crash;

  ProviderContainer container({
    FakeClassService? classes,
    MatchingService? matcher,
  }) {
    analytics = FakeAnalyticsService();
    crash = _Crash();
    final c = ProviderContainer(
      overrides: [
        ...fakeOverrides(
          classService: classes ?? FakeClassService(latency: Duration.zero),
          analyticsService: analytics,
          crashService: crash,
          matchingService:
              matcher ?? FakeMatchingService(latency: Duration.zero),
        ),
        classCsvPickerProvider.overrideWithValue(
          () async => const PickedClassCsv(name: 'class_A.csv', bytes: [1]),
        ),
      ],
    );
    addTearDown(c.dispose);
    return c;
  }

  List<String> logged(String name) =>
      analytics.events.where((e) => e.startsWith(name)).toList();

  test('S8 logs ai_match_start and ai_match_result', () async {
    final c = container();
    final provider = matchingViewModelProvider('class-a');
    c.listen(provider, (_, _) {});
    await pumpEventQueue();
    expect(logged('ai_match_start'), hasLength(1));
    expect(logged('ai_match_start').single, contains('student_count'));
    expect(logged('ai_match_result'), hasLength(1));
    expect(logged('ai_match_result').single, contains('duration_ms'));
    expect(crash.nonFatals, isEmpty);
  });

  test('S8 failure is a handled non-fatal with a reason', () async {
    final c = container(matcher: _FailingMatcher());
    final provider = matchingViewModelProvider('class-a');
    c.listen(provider, (_, _) {});
    await pumpEventQueue();
    expect(crash.nonFatals, hasLength(1));
    expect(crash.nonFatals.single, startsWith('ai_matching_failed'));
    expect(logged('ai_match_result'), isEmpty);
  });

  test('S22 logs class_import and reports a failed write', () async {
    final ok = container();
    ok.listen(importClassViewModelProvider, (_, _) {});
    await ok.read(importClassViewModelProvider.notifier).chooseFile();
    await ok.read(importClassViewModelProvider.notifier).importClass();
    await pumpEventQueue();
    expect(logged('class_import'), hasLength(1));
    expect(logged('class_import').single, contains('available_count'));

    final bad = container(classes: _FailingImport());
    bad.listen(importClassViewModelProvider, (_, _) {});
    await bad.read(importClassViewModelProvider.notifier).chooseFile();
    await bad.read(importClassViewModelProvider.notifier).importClass();
    await pumpEventQueue();
    expect(logged('class_import'), isEmpty);
    expect(crash.nonFatals.single, startsWith('class_import_failed'));
  });

  test('view_item is logged once per class, student and proposal', () async {
    final c = container();
    final classProvider = classDetailViewModelProvider('class-a');
    c.listen(classProvider, (_, _) {});
    await pumpEventQueue();
    expect(logged('view_item'), hasLength(1));
    expect(logged('view_item').single, contains('class'));
    // The Crashlytics custom key follows the class the mentor is looking at.
    expect(crash.classes, ['class-a']);

    final students = await c
        .read(classServiceProvider)
        .watchStudents('class-a')
        .first;
    final studentProvider = studentDetailViewModelProvider((
      classId: 'class-a',
      studentId: students.first.mssv,
    ));
    c.listen(studentProvider, (_, _) {});
    await pumpEventQueue();
    expect(logged('view_item'), hasLength(2));
    expect(logged('view_item').last, contains('student'));

    final pending = await c
        .read(proposalServiceProvider)
        .watchAllPending()
        .first;
    c.listen(proposalDetailProvider(pending.first.id), (_, _) {});
    await pumpEventQueue();
    expect(logged('view_item'), hasLength(3));
    expect(logged('view_item').last, contains('proposal'));
  });

  test('report export logs report_export with team count and size', () async {
    final c = container();
    final actions = c.read(reportDemoActionsProvider);
    final built = await actions.buildPdf('class-a');
    final events = await actions.upload('class-a', built.bytes).toList();
    await actions.logExported(
      'class-a',
      (events.last as UploadDone).report,
      teamCount: built.teamCount,
    );
    expect(logged('report_export'), hasLength(1));
    expect(logged('report_export').single, contains('team_count'));
    expect(logged('report_export').single, contains('file_size_kb'));
  });

  test(
    'S25 logs member_change_blocked min_5 when an edit leaves under 5',
    () async {
      final c = container();
      final proposal =
          (await c.read(proposalServiceProvider).watchAllPending().first).first;
      // Removing every added member leaves only the current roster (under 5).
      await c.read(proposalActionProvider.notifier).updateMembers(proposal, []);
      await pumpEventQueue();
      expect(logged('member_change_blocked'), hasLength(1));
      expect(logged('member_change_blocked').single, contains('min_5'));
    },
  );

  test('user mistakes are not reported to Crashlytics', () async {
    final c = container();
    final actions = c.read(reportDemoActionsProvider);
    await actions.reportFailure(
      const ValidationError('typo'),
      StackTrace.current,
      'x',
    );
    await actions.reportFailure(
      const CancelledError(),
      StackTrace.current,
      'x',
    );
    expect(crash.nonFatals, isEmpty);
    await actions.reportFailure(
      const NetworkError(),
      StackTrace.current,
      'report_export_failed',
    );
    expect(crash.nonFatals, hasLength(1));
  });
}
