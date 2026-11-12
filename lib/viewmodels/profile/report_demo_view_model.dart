import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/class_room.dart';
import '../../models/report.dart';
import '../../providers/service_providers.dart';
import '../../services/analytics_service.dart';
import '../../services/app_error.dart';
import '../../services/class_service.dart';
import '../../services/crash_service.dart';
import '../../services/report_service.dart';
import '../../services/storage_service.dart';
import '../telemetry.dart';

final reportClassesProvider = StreamProvider.autoDispose<List<ClassRoom>>(
  (ref) => ref.watch(classServiceProvider).watchMyClasses(),
);

final mentorReportsProvider = StreamProvider.autoDispose<List<Report>>(
  (ref) => ref.watch(storageServiceProvider).watchMyReports(),
);

class ReportDemoActions {
  const ReportDemoActions(
    this._reports,
    this._storage,
    this._classes,
    this._analytics,
    this._crash,
  );

  final ReportService _reports;
  final StorageService _storage;
  final ClassService _classes;
  final AnalyticsService _analytics;
  final CrashService _crash;

  /// report_export after a successful upload (best effort).
  Future<void> logExported(String classId, Report saved) =>
      bestEffort(() async {
        final teams = await _classes.watchTeams(classId).first;
        await _analytics.logReportExport(
          teamCount: teams.length,
          fileSizeKb: saved.sizeKb,
        );
      });

  /// Handled non-fatal error from the export/upload/share path.
  Future<void> reportFailure(Object error, StackTrace stack, String reason) {
    if (error is ValidationError || error is CancelledError) {
      return Future.value();
    }
    return bestEffort(
      () => _crash.recordNonFatal(error, stack, reason: reason),
    );
  }

  Future<List<int>> buildPdf(String classId) =>
      _reports.buildClassTeamsPdf(classId);

  Stream<UploadEvent> upload(String classId, List<int> bytes) =>
      _storage.uploadReport(classId: classId, bytes: bytes);

  Future<List<int>> download(Report report) => _storage.downloadReport(report);
}

final reportDemoActionsProvider = Provider.autoDispose<ReportDemoActions>(
  (ref) => ReportDemoActions(
    ref.watch(reportServiceProvider),
    ref.watch(storageServiceProvider),
    ref.watch(classServiceProvider),
    ref.watch(analyticsServiceProvider),
    ref.watch(crashServiceProvider),
  ),
);
