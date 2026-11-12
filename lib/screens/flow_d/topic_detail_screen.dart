import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/project_topic.dart';
import '../../theme/app_spacing.dart';
import '../../viewmodels/auth/session_view_model.dart';
import '../../viewmodels/topics/topic_view_model.dart';
import '../../widgets/action_feedback.dart';
import '../../widgets/app_button.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/status_view.dart';
import 'topics_screen.dart';

/// Flow D, mentor: read the topic, open the outline and decide.
class TopicDetailScreen extends ConsumerStatefulWidget {
  const TopicDetailScreen({super.key, required this.topicId});

  final String topicId;

  @override
  ConsumerState<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends ConsumerState<TopicDetailScreen> {
  final _feedback = TextEditingController();

  @override
  void dispose() {
    _feedback.dispose();
    super.dispose();
  }

  Future<void> _decide(TopicStatus decision) => runWithFeedback(
    context,
    () => ref
        .read(topicActionProvider.notifier)
        .review(widget.topicId, decision, _feedback.text),
    success: 'Marked as ${decision.label.toLowerCase()}',
  );

  @override
  Widget build(BuildContext context) {
    final topic = ref.watch(topicProvider(widget.topicId));
    final mentor = ref.watch(sessionProvider).value?.isMentor ?? false;
    final busy = ref.watch(topicActionProvider);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Topic')),
      body: topic.when(
        loading: () => const LoadingView(),
        error: (e, _) => StatusView.error(
          message: errorText(e),
          onRetry: () => ref.invalidate(topicProvider(widget.topicId)),
        ),
        data: (t) => t == null
            ? const StatusView(icon: Icons.search_off, title: 'Topic not found')
            : ListView(
                padding: kScreenPadding,
                children: [
                  Row(
                    children: [
                      Expanded(child: Text(t.title, style: text.headlineSmall)),
                      StatusChip(label: t.status.label, tone: topicTone(t.status)),
                    ],
                  ),
                  const SizedBox(height: kSpaceSm),
                  Text('${t.teamName} · submitted ${shortDateTime(t.submittedAt)} · revision ${t.revisionCount}'),
                  const SizedBox(height: kSpaceMd),
                  TopicBody(topic: t),
                  if (t.mentorFeedback != null && t.status != TopicStatus.pending) ...[
                    const SizedBox(height: kSpaceMd),
                    Text('Your feedback', style: text.titleSmall),
                    Text(t.mentorFeedback!),
                  ],
                  if (mentor && t.status == TopicStatus.pending) ...[
                    const SizedBox(height: kSpaceLg),
                    TextField(
                      controller: _feedback,
                      maxLength: 2000,
                      minLines: 3,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        labelText: 'Feedback',
                        hintText: 'Required for reject or revision',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: kSpaceSm),
                    AppButton(
                      label: 'Approve',
                      loading: busy,
                      onPressed: () => _decide(TopicStatus.approved),
                    ),
                    const SizedBox(height: kSpaceSm),
                    AppButton(
                      label: 'Request revision',
                      variant: AppButtonVariant.tonal,
                      onPressed: busy ? null : () => _decide(TopicStatus.revisionRequested),
                    ),
                    const SizedBox(height: kSpaceSm),
                    AppButton(
                      label: 'Reject',
                      variant: AppButtonVariant.destructive,
                      onPressed: busy ? null : () => _decide(TopicStatus.rejected),
                    ),
                  ],
                ],
              ),
      ),
    );
  }
}
