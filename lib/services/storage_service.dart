import '../models/report.dart';

/// Owner: Cuong. Saves the PDF in Firestore (reports/{id} + files/pdf, owner
/// only, at most [maxBytes]; the Spark plan has no Cloud Storage).
abstract interface class StorageService {
  static const maxBytes = 900 * 1024;

  /// Emits [UploadProgress] events then one [UploadDone].
  Stream<UploadEvent> uploadReport({required String classId, required List<int> bytes});

  Stream<List<Report>> watchMyReports();

  /// Retrieves the mentor-owned PDF so it can be shared or printed later.
  Future<List<int>> downloadReport(Report report);
}
