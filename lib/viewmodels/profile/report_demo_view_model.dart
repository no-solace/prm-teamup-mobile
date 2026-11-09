import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/class_room.dart';
import '../../models/report.dart';
import '../../providers/service_providers.dart';
import '../../services/report_service.dart';
import '../../services/storage_service.dart';

final reportClassesProvider = StreamProvider.autoDispose<List<ClassRoom>>(
  (ref) => ref.watch(classServiceProvider).watchMyClasses(),
);

final mentorReportsProvider = StreamProvider.autoDispose<List<Report>>(
  (ref) => ref.watch(storageServiceProvider).watchMyReports(),
);

class ReportDemoActions {
  const ReportDemoActions(this._reports, this._storage);

  final ReportService _reports;
  final StorageService _storage;

  Future<List<int>> buildPdf(String classId) => _reports.buildClassTeamsPdf(classId);

  Stream<UploadEvent> upload(String classId, List<int> bytes) =>
      _storage.uploadReport(classId: classId, bytes: bytes);

  Future<List<int>> download(Report report) => _storage.downloadReport(report);
}

final reportDemoActionsProvider = Provider.autoDispose<ReportDemoActions>(
  (ref) => ReportDemoActions(
    ref.watch(reportServiceProvider),
    ref.watch(storageServiceProvider),
  ),
);
