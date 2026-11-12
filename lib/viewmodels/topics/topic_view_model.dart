import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/project_topic.dart';
import '../../providers/service_providers.dart';
import '../../services/app_error.dart';
import '../../services/config_service.dart';
import '../../services/topic_service.dart';
import '../auth/session_view_model.dart';
import '../notifications/config_demo_view_model.dart';
import '../view_state.dart';

/// Outline picker (PDF/DOCX); replace in widget tests.
final topicFilePickerProvider = Provider<Future<TopicAttachment?> Function()>(
  (ref) => () async {
    final file = await FilePicker.pickFile(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'docx'],
    );
    if (file == null) return null;
    return TopicAttachment(fileName: file.name, bytes: await file.readAsBytes());
  },
);

/// Remote Config max_topic_revisions, live.
final topicMaxRevisionsProvider = Provider<int>(
  (ref) =>
      ref.watch(appConfigProvider).value?.maxTopicRevisions ??
      AppConfig.defaults.maxTopicRevisions,
);

/// Mentor review queue (Flow D).
final mentorTopicsProvider = StreamProvider.autoDispose<List<ProjectTopic>>((ref) {
  ref.watch(sessionProvider.select((s) => s.value?.uid));
  return ref.watch(topicServiceProvider).watchMentorTopics();
});

/// One topic (mentor detail) by ID.
final topicProvider = StreamProvider.autoDispose.family<ProjectTopic?, String>(
  (ref, id) => ref.watch(topicServiceProvider).watchTopic(id),
);

/// The signed-in student's team topic, or null before the first submission.
final myTopicProvider = StreamProvider.autoDispose<ProjectTopic?>((ref) {
  final id = ref.watch(sessionProvider.select((s) => s.value?.topicId));
  if (id == null) return Stream.error(const PermissionDeniedError('Students only'));
  return ref.watch(topicServiceProvider).watchTopic(id);
});

/// Busy flag for topic writes; errors are rethrown as [AppError].
class TopicActionViewModel extends Notifier<bool> {
  @override
  bool build() => false;

  Future<void> _run(Future<void> Function() body) async {
    if (state) throw const ValidationError('Another action is in progress');
    state = true;
    try {
      await body();
    } catch (e) {
      throw toAppError(e);
    } finally {
      state = false;
    }
  }

  Future<void> submit({
    required String title,
    required String description,
    required String techStack,
    TopicAttachment? attachment,
  }) => _run(() async {
    final user = ref.read(sessionProvider).value;
    if (user == null) throw const PermissionDeniedError('Sign in first');
    await ref.read(topicServiceProvider).submit(
      user,
      title: title,
      description: description,
      techStack: techStack,
      attachment: attachment,
      maxRevisions: ref.read(configServiceProvider).current.maxTopicRevisions,
    );
  });

  Future<void> review(String topicId, TopicStatus decision, String feedback) =>
      _run(() => ref.read(topicServiceProvider).review(topicId, decision, feedback));
}

final topicActionProvider = NotifierProvider<TopicActionViewModel, bool>(
  TopicActionViewModel.new,
);
