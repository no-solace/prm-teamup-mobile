import 'dart:async';

import '../../models/app_notification.dart';
import '../../models/report.dart';
import '../analytics_service.dart';
import '../config_service.dart';
import '../crash_service.dart';
import '../notification_service.dart';
import '../notification_store.dart';
import '../storage_service.dart';
import 'sample_data.dart';

/// Records events in memory so tests can assert on them.
class FakeAnalyticsService implements AnalyticsService {
  final List<String> events = [];

  Future<void> _log(
    String name, [
    Map<String, Object?> params = const {},
  ]) async => events.add('$name $params');

  @override
  Future<void> setUser(String? uid) =>
      _log(uid == null ? 'clear_user_id' : 'set_user_id');
  @override
  Future<void> logLogin({String method = 'google'}) =>
      _log('login', {'method': method});
  @override
  Future<void> logLogout() => _log('logout');
  @override
  Future<void> logClassImport({
    required int rowCount,
    required int availableCount,
  }) => _log('class_import', {
    'row_count': rowCount,
    'available_count': availableCount,
  });
  @override
  Future<void> logViewItem({
    required String itemCategory,
    required String itemId,
  }) => _log('view_item', {'item_category': itemCategory, 'item_id': itemId});
  @override
  Future<void> logAiMatchStart({
    required int studentCount,
    required int teamCount,
  }) => _log('ai_match_start', {
    'student_count': studentCount,
    'team_count': teamCount,
  });
  @override
  Future<void> logAiMatchResult({
    required int proposalCount,
    required bool noMatch,
    required int durationMs,
  }) => _log('ai_match_result', {
    'proposal_count': proposalCount,
    'no_match': noMatch,
    'duration_ms': durationMs,
  });
  @override
  Future<void> logProposalApprove({
    required int memberCount,
    required int majorCount,
    required String source,
    required bool edited,
  }) => _log('proposal_approve', {
    'member_count': memberCount,
    'major_count': majorCount,
    'source': source,
    'edited': edited,
  });
  @override
  Future<void> logProposalDiscard({required String source}) =>
      _log('proposal_discard', {'source': source});
  @override
  Future<void> logMemberChangeBlocked({required String reason}) =>
      _log('member_change_blocked', {'reason': reason});
  @override
  Future<void> logReportExport({
    required int teamCount,
    required int fileSizeKb,
  }) => _log('report_export', {
    'team_count': teamCount,
    'file_size_kb': fileSizeKb,
  });
}

class FakeCrashService implements CrashService {
  final List<String> nonFatals = [];

  @override
  Future<void> setUser({required String uid, required String role}) async {}
  @override
  Future<void> setClass(String? classId) async {}
  @override
  Future<void> recordNonFatal(
    Object error,
    StackTrace? stack, {
    required String reason,
  }) async => nonFatals.add('$reason: $error');
  @override
  void testCrash() => throw StateError('Test crash (fake)');
}

class FakeConfigService implements ConfigService {
  FakeConfigService([this._config = AppConfig.defaults]);

  AppConfig _config;
  final _controller = StreamController<AppConfig>.broadcast();

  /// Lets tests and the gallery flip values.
  void set(AppConfig config) {
    _config = config;
    _controller.add(config);
  }

  @override
  AppConfig get current => _config;
  @override
  Stream<AppConfig> watch() async* {
    yield _config;
    yield* _controller.stream;
  }

  @override
  Future<void> refresh() async {}
  @override
  String get lastFetchStatus => 'fake';
}

class FakeNotificationService implements NotificationService {
  FakeNotificationService({this.permission = NotificationPermission.granted});
  NotificationPermission permission;
  final _taps = StreamController<String>.broadcast();
  final _changes = StreamController<List<AppNotification>>.broadcast();
  final List<AppNotification> _inbox = [
    AppNotification(
      id: 'n-1',
      title: 'AI proposals ready',
      body: 'Class A: 3 teams to review',
      receivedAt: DateTime(2026, 11, 5, 9, 30),
      route: '/proposals',
    ),
  ];

  @override
  Future<NotificationPermission> requestPermission() async => permission;
  @override
  Future<NotificationPermission> currentPermission() async => permission;
  @override
  Future<String?> getToken() async =>
      permission == NotificationPermission.granted ? 'fake-fcm-token' : null;
  @override
  Future<void> start() async {}
  @override
  Stream<String> get tappedRoutes => _taps.stream;
  @override
  Stream<List<AppNotification>> watchInbox() async* {
    yield List.unmodifiable(_inbox);
    yield* _changes.stream;
  }

  @override
  Future<void> markRead(String id) async {
    final index = _inbox.indexWhere((n) => n.id == id);
    if (index < 0) return;
    _inbox[index] = _inbox[index].copyWith(read: true);
    _changes.add(List.unmodifiable(_inbox));
  }

  void receive(AppNotification item, {bool tapped = false}) {
    final index = _inbox.indexWhere((n) => n.id == item.id);
    final next = item.copyWith(
      read: tapped || (index >= 0 && _inbox[index].read),
    );
    if (index >= 0) {
      _inbox[index] = next;
    } else {
      _inbox.insert(0, next);
    }
    _changes.add(List.unmodifiable(_inbox));
    if (tapped && NotificationRoutes.isAllowed(item.route)) {
      _taps.add(item.route!);
    }
  }

  @override
  Stream<String?> get issues => Stream.value(null);
  @override
  Future<void> unregisterToken() async {}
  @override
  Future<void> dispose() async {
    await _taps.close();
    await _changes.close();
  }
}

class FakeStorageService implements StorageService {
  final List<Report> _reports = [];
  final Map<String, List<int>> _files = {};
  final _changes = StreamController<List<Report>>.broadcast();

  @override
  Stream<UploadEvent> uploadReport({
    required String classId,
    required List<int> bytes,
  }) async* {
    for (var i = 1; i <= 5; i++) {
      await Future<void>.delayed(const Duration(milliseconds: 200));
      yield UploadProgress(i / 5);
    }
    final report = Report(
      id: 'r-${_reports.length + 1}',
      ownerUid: SampleData.mentorUid,
      classId: classId,
      storagePath:
          'reports/${SampleData.mentorUid}/r-${_reports.length + 1}.pdf',
      downloadUrl: 'https://example.com/class-a.pdf',
      sizeKb: (bytes.length / 1024).ceil(),
      createdAt: DateTime.now(),
    );
    _files[report.id] = List.of(bytes);
    _reports.insert(0, report);
    _changes.add(List.unmodifiable(_reports));
    yield UploadDone(report);
  }

  @override
  Stream<List<Report>> watchMyReports() async* {
    yield List.unmodifiable(_reports);
    yield* _changes.stream;
  }

  @override
  Future<List<int>> downloadReport(Report report) async =>
      _files[report.id] ?? (throw StateError('Report is missing'));
}
