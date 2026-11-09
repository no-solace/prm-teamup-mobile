import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:teamup_exe/models/class_room.dart';
import 'package:teamup_exe/models/major.dart';
import 'package:teamup_exe/models/proposal.dart';
import 'package:teamup_exe/models/student.dart';
import 'package:teamup_exe/models/team.dart';
import 'package:teamup_exe/providers/fake_overrides.dart';
import 'package:teamup_exe/providers/service_providers.dart';
import 'package:teamup_exe/services/app_error.dart';
import 'package:teamup_exe/services/class_service.dart';
import 'package:teamup_exe/services/fakes/fake_class_service.dart';
import 'package:teamup_exe/services/fakes/fake_matching_service.dart';
import 'package:teamup_exe/services/fakes/fake_proposal_service.dart';
import 'package:teamup_exe/services/fakes/sample_data.dart';
import 'package:teamup_exe/viewmodels/classes/class_detail_view_model.dart';
import 'package:teamup_exe/viewmodels/classes/import_class_view_model.dart';
import 'package:teamup_exe/viewmodels/classes/matching_view_model.dart';
import 'package:teamup_exe/viewmodels/classes/no_team_view_model.dart';
import 'package:teamup_exe/viewmodels/classes/student_detail_view_model.dart';
import 'package:teamup_exe/viewmodels/view_state.dart';

class _Classes extends FakeClassService {
  _Classes() : super(latency: Duration.zero);
  bool offline = false;
  bool missingColumn = false;
  int writes = 0;
  Completer<ImportResult>? pendingWrite;

  @override
  Stream<ClassRoom> watchClass(String classId) =>
      offline ? Stream.error(const NetworkError()) : super.watchClass(classId);

  @override
  Future<ImportPreview> parseImportFile({
    required String fileName,
    required List<int> bytes,
  }) async {
    final preview = await super.parseImportFile(
      fileName: fileName,
      bytes: bytes,
    );
    return ImportPreview(
      fileName: preview.fileName,
      className: preview.className,
      rowCount: preview.rowCount,
      students: preview.students,
      detectedColumns: {...preview.detectedColumns, 'Major': !missingColumn},
    );
  }

  @override
  Future<ImportResult> importClass(ImportPreview preview) {
    writes++;
    if (offline) throw const NetworkError();
    return pendingWrite?.future ?? super.importClass(preview);
  }
}

class _PendingMatcher extends FakeMatchingService {
  final calls = <Completer<List<Proposal>>>[];

  @override
  Future<List<Proposal>> propose({
    required String classId,
    required List<Student> students,
    required List<Team> teams,
  }) {
    final result = Completer<List<Proposal>>();
    calls.add(result);
    return result.future;
  }
}

class _Proposals extends FakeProposalService {
  _Proposals() : super(empty: true);
  final saved = <List<Proposal>>[];
  @override
  Future<void> savePending(List<Proposal> proposals) async =>
      saved.add(proposals);
}

ProviderContainer _container({_Classes? classes}) {
  final container = ProviderContainer(
    overrides: fakeOverrides(classService: classes ?? _Classes()),
  );
  addTearDown(container.dispose);
  return container;
}

List<Proposal> _sampleProposals() {
  final students = SampleData.students();
  return SampleData.proposals(students, SampleData.teams(students));
}

Future<void> _waitForMatcherCalls(
  WidgetTester tester,
  _PendingMatcher matcher,
  int count,
) async {
  for (var attempt = 0; attempt < 20 && matcher.calls.length < count; attempt++) {
    await tester.pump(const Duration(milliseconds: 1));
  }
  expect(matcher.calls, hasLength(count));
}

void main() {
  test('S3 loads class, reports offline, and retries', () async {
    final classes = _Classes()..offline = true;
    final container = _container(classes: classes);
    final provider = classDetailViewModelProvider('class-a');
    container.listen(provider, (_, _) {});
    expect(container.read(provider), isA<Loading<ClassRoom>>());
    await pumpEventQueue();
    expect(container.read(provider), isA<Failure<ClassRoom>>());
    classes.offline = false;
    container.read(provider.notifier).retry();
    await pumpEventQueue();
    expect(
      (container.read(provider) as Data<ClassRoom>).value.withoutTeamCount,
      5,
    );
  });

  test('S4 excludes assigned students, filters by major, and clears', () async {
    final container = _container();
    final provider = noTeamViewModelProvider('class-a');
    container.listen(provider, (_, _) {});
    await pumpEventQueue();
    final students = container.read(provider).visibleStudents;
    expect(students, hasLength(5));
    expect(students.every((s) => !s.hasTeam), isTrue);
    container.read(provider.notifier).selectMajor(Major.ai);
    expect(container.read(provider).visibleStudents.map((s) => s.major), [
      Major.ai,
    ]);
    container.read(provider.notifier).selectMajor(null);
    expect(container.read(provider).visibleStudents, hasLength(5));
  });

  test('S4 empty class is Empty rather than a filtered result', () async {
    final container = _container();
    final provider = noTeamViewModelProvider('class-b');
    container.listen(provider, (_, _) {});
    await pumpEventQueue();
    expect(container.read(provider).students, isA<Empty<List<Student>>>());
  });

  test('S7 resolves actual class name and handles missing student', () async {
    final container = _container();
    final provider = studentDetailViewModelProvider((
      classId: 'class-a',
      studentId: '190401',
    ));
    final missing = studentDetailViewModelProvider((
      classId: 'class-a',
      studentId: 'missing',
    ));
    container.listen(provider, (_, _) {});
    container.listen(missing, (_, _) {});
    await pumpEventQueue();
    expect(
      (container.read(provider) as Data<StudentProfile>).value.className,
      'Class A',
    );
    expect(
      (container.read(missing) as Failure<StudentProfile>).error,
      isA<NotFoundError>(),
    );
  });

  group('S22 CSV import', () {
    late ProviderContainer container;
    late _Classes classes;
    PickedClassCsv? picked;

    setUp(() {
      classes = _Classes();
      container = ProviderContainer(
        overrides: [
          ...fakeOverrides(classService: classes),
          classCsvPickerProvider.overrideWithValue(() async => picked),
        ],
      );
      container.listen(importClassViewModelProvider, (_, _) {});
      addTearDown(container.dispose);
      picked = const PickedClassCsv(name: 'class_A.csv', bytes: [1]);
    });

    test('cancel preserves a valid preview', () async {
      final model = container.read(importClassViewModelProvider.notifier);
      await model.chooseFile();
      final preview = container.read(importClassViewModelProvider).preview;
      picked = null;
      await model.chooseFile();
      expect(
        container.read(importClassViewModelProvider).preview,
        same(preview),
      );
      expect(container.read(importClassViewModelProvider).canImport, isTrue);
    });

    test('rejects xlsx, empty CSV, and missing required columns', () async {
      final model = container.read(importClassViewModelProvider.notifier);
      for (final file in [
        const PickedClassCsv(name: 'class.xlsx', bytes: [1]),
        const PickedClassCsv(name: 'class.csv', bytes: []),
      ]) {
        picked = file;
        await model.chooseFile();
        final state = container.read(importClassViewModelProvider);
        expect(state.error, isA<ValidationError>());
        expect(state.canImport, isFalse);
      }
      picked = const PickedClassCsv(name: 'class.csv', bytes: [1]);
      classes.missingColumn = true;
      await model.chooseFile();
      final state = container.read(importClassViewModelProvider);
      expect(state.preview!.detectedColumns['Major'], isFalse);
      expect(state.error, isA<ValidationError>());
      expect(state.canImport, isFalse);
      expect(await model.importClass(), isNull);
      expect(classes.writes, 0);
    });

    test(
      'write failure retains preview and retry returns S23 result',
      () async {
        final model = container.read(importClassViewModelProvider.notifier);
        await model.chooseFile();
        classes.offline = true;
        expect(await model.importClass(), isNull);
        expect(
          container.read(importClassViewModelProvider).error,
          isA<NetworkError>(),
        );
        expect(container.read(importClassViewModelProvider).canImport, isTrue);
        classes.offline = false;
        final result = await model.importClass();
        expect(result!.imported, 42);
        expect(result.available, 12);
        expect(
          container.read(importClassViewModelProvider).result,
          same(result),
        );
      },
    );

    test('double tap does not submit twice', () async {
      final model = container.read(importClassViewModelProvider.notifier);
      await model.chooseFile();
      classes.pendingWrite = Completer<ImportResult>();
      final first = model.importClass();
      expect(container.read(importClassViewModelProvider).importing, isTrue);
      expect(await model.importClass(), isNull);
      expect(classes.writes, 1);
      classes.pendingWrite!.complete(
        const ImportResult(
          classId: 'class-a',
          imported: 42,
          inAGroup: 30,
          available: 12,
        ),
      );
      await first;
    });
  });

  testWidgets('S8 saves results before Data; empty results become No match', (
    tester,
  ) async {
    final matcher = _PendingMatcher();
    final proposals = _Proposals();
    final container = ProviderContainer(
      overrides: [
        classServiceProvider.overrideWithValue(_Classes()),
        matchingServiceProvider.overrideWithValue(matcher),
        proposalServiceProvider.overrideWithValue(proposals),
      ],
    );
    addTearDown(container.dispose);
    final provider = matchingViewModelProvider('class-a');
    container.listen(provider, (_, _) {});
    await _waitForMatcherCalls(tester, matcher, 1);
    matcher.calls.single.complete(_sampleProposals());
    await tester.pump();
    expect(container.read(provider), isA<Data<List<Proposal>>>());
    expect(proposals.saved.single, hasLength(3));
    final retry = container.read(provider.notifier).start();
    await _waitForMatcherCalls(tester, matcher, 2);
    matcher.calls.last.complete([]);
    await retry;
    expect(container.read(provider), isA<Empty<List<Proposal>>>());
    expect(proposals.saved, hasLength(1));
  });

  testWidgets('S8 reaches S18 at 30 seconds, drops late results and retries', (
    tester,
  ) async {
    final matcher = _PendingMatcher();
    final proposals = _Proposals();
    final container = ProviderContainer(
      overrides: [
        classServiceProvider.overrideWithValue(_Classes()),
        matchingServiceProvider.overrideWithValue(matcher),
        proposalServiceProvider.overrideWithValue(proposals),
      ],
    );
    addTearDown(container.dispose);
    final provider = matchingViewModelProvider('class-a');
    container.listen(provider, (_, _) {});
    await _waitForMatcherCalls(tester, matcher, 1);
    await tester.pump(const Duration(seconds: 30));
    expect(
      (container.read(provider) as Failure<List<Proposal>>).error,
      isA<TimeoutAppError>(),
    );
    matcher.calls.first.complete(_sampleProposals());
    await tester.pump();
    expect(proposals.saved, isEmpty);
    final retry = container.read(provider.notifier).start();
    await _waitForMatcherCalls(tester, matcher, 2);
    matcher.calls.last.complete(_sampleProposals());
    await retry;
    expect(container.read(provider), isA<Data<List<Proposal>>>());
    expect(proposals.saved, hasLength(1));
  });

  testWidgets(
    'S8 cancellation ignores late matcher completion without saving',
    (tester) async {
      final matcher = _PendingMatcher();
      final proposals = _Proposals();
      final container = ProviderContainer(
        overrides: [
          classServiceProvider.overrideWithValue(_Classes()),
          matchingServiceProvider.overrideWithValue(matcher),
          proposalServiceProvider.overrideWithValue(proposals),
        ],
      );
      addTearDown(container.dispose);
      final provider = matchingViewModelProvider('class-a');
      container.listen(provider, (_, _) {});
      await _waitForMatcherCalls(tester, matcher, 1);
      container.read(provider.notifier).cancel();
      matcher.calls.single.complete(_sampleProposals());
      await tester.pump();
      expect(proposals.saved, isEmpty);
      expect(container.read(provider), isA<Loading<List<Proposal>>>());
    },
  );
}
