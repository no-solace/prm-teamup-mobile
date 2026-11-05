/// Metadata of an uploaded PDF report (reports/{id}); the file lives at
/// Storage `reports/{ownerUid}/...`.
class Report {
  const Report({
    required this.id,
    required this.ownerUid,
    required this.classId,
    required this.storagePath,
    required this.downloadUrl,
    required this.sizeKb,
    required this.createdAt,
  });

  final String id;
  final String ownerUid;
  final String classId;
  final String storagePath;
  final String downloadUrl;
  final int sizeKb;
  final DateTime createdAt;
}

/// Upload progress shown on the Firebase demo area (0.0 .. 1.0).
sealed class UploadEvent {
  const UploadEvent();
}

class UploadProgress extends UploadEvent {
  const UploadProgress(this.fraction);
  final double fraction;
}

class UploadDone extends UploadEvent {
  const UploadDone(this.report);
  final Report report;
}
