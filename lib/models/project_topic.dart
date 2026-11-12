import 'data_validation.dart';

enum TopicStatus {
  pending('Pending review'),
  approved('Approved'),
  rejected('Rejected'),
  revisionRequested('Revision requested');

  const TopicStatus(this.label);
  final String label;

  /// Wire value (revision_requested in Firestore).
  String get code => this == revisionRequested ? 'revision_requested' : name;

  static TopicStatus fromCode(Object? code) => values.firstWhere(
    (s) => s.code == code,
    orElse: () => throw const FormatException('Invalid topic status'),
  );
}

/// Flow D. One topic per team: topics/{classId}_{teamId}.
class ProjectTopic {
  const ProjectTopic({
    required this.id,
    required this.classId,
    required this.teamId,
    required this.teamName,
    required this.mentorUid,
    required this.title,
    required this.description,
    required this.techStack,
    required this.status,
    required this.revisionCount,
    required this.submittedAt,
    this.attachmentName,
    this.mentorFeedback,
  });

  final String id;
  final String classId;
  final String teamId;
  final String teamName;
  final String mentorUid;
  final String title;
  final String description;
  final String techStack;
  final TopicStatus status;

  /// Resubmissions so far; capped by Remote Config max_topic_revisions.
  final int revisionCount;
  final DateTime submittedAt;
  /// Set when an outline is attached (bytes in topics/{id}/files/outline).
  final String? attachmentName;
  final String? mentorFeedback;

  /// The leader may edit while waiting or after the mentor asks for changes.
  bool get editable => status != TopicStatus.approved;

  factory ProjectTopic.fromMap(String id, Map<String, dynamic> d) {
    final count = d['revisionCount'];
    if (count is! int || count < 0) throw const FormatException('Invalid revisionCount');
    return ProjectTopic(
      id: id,
      classId: DataValidation.id(DataValidation.text(d, 'classId', max: 64)),
      teamId: DataValidation.id(DataValidation.text(d, 'teamId', max: 64)),
      teamName: DataValidation.text(d, 'teamName'),
      mentorUid: DataValidation.text(d, 'mentorUid', max: 128),
      title: DataValidation.text(d, 'title', max: 200),
      description: DataValidation.text(d, 'description', max: 4000),
      techStack: DataValidation.text(d, 'techStack', max: 300),
      status: TopicStatus.fromCode(d['status']),
      revisionCount: count,
      submittedAt: DataValidation.time(d['submittedAt']),
      attachmentName: DataValidation.optionalText(d, 'attachmentName', max: 200),
      mentorFeedback: DataValidation.optionalText(d, 'mentorFeedback', max: 2000),
    );
  }
}
