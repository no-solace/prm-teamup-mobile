import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/class_room.dart';
import '../../models/report.dart';
import '../../providers/service_providers.dart';
import '../../services/report_service.dart';
import '../../services/storage_service.dart';
import '../instrumentation.dart';

final reportClassesProvider = StreamProvider.autoDispose<List<ClassRoom>>(
  (ref) => ref.watch(classServiceProvider).watchMyClasses(),
);

final mentorReportsProvider = StreamProvider.autoDispose<List<Report>>(
  (ref) => ref.watch(storageServiceProvider).watchMyReports(),
);

class ReportDemoActions {
  const ReportDemoActions(this._reports, this._storage, this._ref);

  final ReportService _reports;
  final StorageService _storage;
  final Ref _ref;

  Future<BuiltReport> buildPdf(String classId) =>
      _reports.buildClassTeamsPdf(classId);

  /// Uploads the PDF and reports the export to Analytics. A failed upload is a
  /// real error path: the mentor sees the message and Crashlytics records one
  /// non-fatal report.
  Stream<UploadEvent> upload(
    String classId,
    List<int> bytes, {
    required int teamCount,
  }) async* {
    Report? uploaded;
    try {
      await for (final event in _storage.uploadReport(
        classId: classId,
        bytes: bytes,
      )) {
        if (event is UploadDone) uploaded = event.report;
        yield event;
      }
    } catch (error, stack) {
      await _ref.trackNonFatal(error, stack, reason: 'report_upload_failed');
      rethrow;
    }
    if (uploaded != null) {
      // docs/analytics-plan.md: report_export links the export to the class
      // size, so we can compare "matched" against "exported".
      await _ref.trackAnalytics(
        (analytics) => analytics.logReportExport(
          teamCount: teamCount,
          fileSizeKb: uploaded!.sizeKb,
        ),
      );
    }
  }

  Future<List<int>> download(Report report) => _storage.downloadReport(report);
}

final reportDemoActionsProvider = Provider.autoDispose<ReportDemoActions>(
  (ref) => ReportDemoActions(
    ref.watch(reportServiceProvider),
    ref.watch(storageServiceProvider),
    ref,
  ),
);
