import '../models/app_user.dart';
import '../models/project_topic.dart';

/// A picked outline file (PDF or DOCX). Stored in Firestore, so at most
/// [maxBytes] (one document is limited to 1 MiB).
class TopicAttachment {
  const TopicAttachment({required this.fileName, required this.bytes});
  final String fileName;
  final List<int> bytes;

  static const maxBytes = 900 * 1024;
}

/// Flow D. Leaders submit their team's topic; the mentor reviews it.
abstract interface class TopicService {
  /// Every topic sent to the signed-in mentor (review queue), newest first.
  Stream<List<ProjectTopic>> watchMentorTopics();

  /// The student's team topic, or null before the first submission.
  Stream<ProjectTopic?> watchTopic(String topicId);

  /// Creates or resubmits [leader]'s team topic. Throws [ValidationError]
  /// once [maxRevisions] resubmissions are used or after approval.
  Future<void> submit(
    AppUser leader, {
    required String title,
    required String description,
    required String techStack,
    TopicAttachment? attachment,
    required int maxRevisions,
  });

  /// Mentor decision; [feedback] is required unless approving.
  Future<void> review(String topicId, TopicStatus decision, String feedback);

  /// Bytes of the attached outline (see ProjectTopic.attachmentName).
  Future<List<int>> downloadOutline(String topicId);
}
