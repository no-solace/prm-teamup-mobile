import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/class_room.dart';
import '../../models/report.dart';
import '../../providers/service_providers.dart';
import '../../services/app_error.dart';
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

  /// The PDF and the number of teams it prints (CR-01: the Analytics event
  /// must carry a real number, not a placeholder).
  Future<BuiltReport> buildPdf(String classId) =>
      _reports.buildClassTeamsPdf(classId);

  /// Uploads the PDF. A failed upload is a real error path: the mentor sees
  /// the message and Crashlytics records one non-fatal report.
  ///
  /// The `report_export` Analytics event is logged once, by [logExported],
  /// after the panel has confirmed the upload finished.
  Stream<UploadEvent> upload(String classId, List<int> bytes) async* {
    try {
      await for (final event in _storage.uploadReport(
        classId: classId,
        bytes: bytes,
      )) {
        yield event;
      }
    } catch (error, stack) {
      await _ref.trackNonFatal(error, stack, reason: 'report_upload_failed');
      rethrow;
    }
  }

  /// report_export after a successful upload (best effort).
  ///
  /// `teamCount` comes from the PDF builder, so the number matches the teams
  /// printed in the file (CR-05) instead of being counted a second time.
  Future<void> logExported(
    String classId,
    Report saved, {
    required int teamCount,
  }) async {
    await _ref.trackAnalytics(
      (analytics) => analytics.logReportExport(
        teamCount: teamCount,
        fileSizeKb: saved.sizeKb,
      ),
    );
  }

  /// Handled non-fatal error from the export/upload/share path.
  ///
  /// Mistakes the user can fix themselves (validation) and cancellations are
  /// not defects, so they never reach Crashlytics.
  Future<void> reportFailure(Object error, StackTrace stack, String reason) async {
    if (error is ValidationError || error is CancelledError) {
      return;
    }
    await _ref.trackNonFatal(error, stack, reason: reason);
  }

  Future<List<int>> download(Report report) => _storage.downloadReport(report);
}

/// Not auto-disposed: the actions are used from a widget callback, and a
/// disposed `Ref` could no longer read the Analytics/Crashlytics services to
/// log the export.
final reportDemoActionsProvider = Provider<ReportDemoActions>(
  (ref) => ReportDemoActions(
    ref.watch(reportServiceProvider),
    ref.watch(storageServiceProvider),
    ref,
  ),
);
