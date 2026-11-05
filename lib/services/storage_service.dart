import '../models/report.dart';

/// Owner: Cuong. Uploads to Storage `reports/{uid}/...` (only the owner may
/// read or write, see firebase/storage.rules) and saves metadata.
abstract interface class StorageService {
  /// Emits [UploadProgress] events then one [UploadDone].
  Stream<UploadEvent> uploadReport({required String classId, required List<int> bytes});

  Stream<List<Report>> watchMyReports();
}
