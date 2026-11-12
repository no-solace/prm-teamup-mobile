/// Metadata of a saved PDF report (reports/{id}); the bytes live in
/// reports/{id}/files/pdf so listing reports never downloads them.
class Report {
  const Report({
    required this.id,
    required this.ownerUid,
    required this.classId,
    required this.sizeKb,
    required this.createdAt,
  });

  final String id;
  final String ownerUid;
  final String classId;
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
