import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/project_topic.dart';
import '../../router/routes.dart';
import '../../theme/app_spacing.dart';
import '../../viewmodels/auth/session_view_model.dart';
import '../../viewmodels/topics/topic_view_model.dart';
import '../../widgets/action_feedback.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/status_view.dart';

StatusTone topicTone(TopicStatus s) => switch (s) {
  TopicStatus.pending => StatusTone.waiting,
  TopicStatus.approved => StatusTone.good,
  TopicStatus.rejected => StatusTone.bad,
  TopicStatus.revisionRequested => StatusTone.bad,
};

/// Flow D tab. Mentor: review queue. Student: their team's topic.
class TopicsScreen extends ConsumerWidget {
  const TopicsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final student = ref.watch(sessionProvider).value?.isStudent ?? false;
    return Scaffold(
      appBar: AppBar(title: Text(student ? 'Our topic' : 'Topic reviews')),
      body: student ? const _StudentTopic() : const _ReviewQueue(),
    );
  }
}

class _ReviewQueue extends ConsumerWidget {
  const _ReviewQueue();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final topics = ref.watch(mentorTopicsProvider);
    final text = Theme.of(context).textTheme;
    return topics.when(
      loading: () => const LoadingView(),
      error: (e, _) => StatusView.error(
        message: errorText(e),
        onRetry: () => ref.invalidate(mentorTopicsProvider),
      ),
      data: (items) => items.isEmpty
          ? const StatusView(
              icon: Icons.lightbulb_outline,
              title: 'No topics yet',
              message: 'Team leaders submit their project topics here for your review.',
            )
          : ListView.builder(
              padding: kScreenPadding,
              itemCount: items.length,
              itemBuilder: (context, i) {
                final t = items[i];
                return AppCard(
                  onTap: () => context.push(Routes.topic(t.id)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(child: Text(t.title, style: text.titleMedium)),
                          StatusChip(label: t.status.label, tone: topicTone(t.status)),
                        ],
                      ),
                      const SizedBox(height: kSpaceXs),
                      Text('${t.teamName} · submitted ${shortDateTime(t.submittedAt)}'),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

class _StudentTopic extends ConsumerWidget {
  const _StudentTopic();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider).value;
    final leader = user?.isLeader ?? false;
    final maxRevisions = ref.watch(topicMaxRevisionsProvider);
    final topic = ref.watch(myTopicProvider);
    final text = Theme.of(context).textTheme;
    return topic.when(
      loading: () => const LoadingView(),
      error: (e, _) => StatusView.error(
        message: errorText(e),
        onRetry: () => ref.invalidate(myTopicProvider),
      ),
      data: (t) {
        if (t == null) {
          return StatusView(
            icon: Icons.lightbulb_outline,
            title: 'No topic submitted',
            message: leader
                ? 'Submit your project idea for your mentor to review.'
                : 'Your team leader submits the topic.',
            actionLabel: leader ? 'Submit topic' : null,
            onAction: leader ? () => context.push(Routes.topicSubmit) : null,
          );
        }
        final resubmitsLeft = maxRevisions - t.revisionCount;
        return ListView(
          padding: kScreenPadding,
          children: [
            Row(
              children: [
                Expanded(child: Text(t.title, style: text.headlineSmall)),
                StatusChip(label: t.status.label, tone: topicTone(t.status)),
              ],
            ),
            const SizedBox(height: kSpaceSm),
            Text('Submitted ${shortDateTime(t.submittedAt)} · revision ${t.revisionCount}/$maxRevisions'),
            if (t.mentorFeedback != null) ...[
              const SizedBox(height: kSpaceMd),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Mentor feedback', style: text.titleSmall),
                    const SizedBox(height: kSpaceXs),
                    Text(t.mentorFeedback!),
                  ],
                ),
              ),
            ],
            const SizedBox(height: kSpaceMd),
            TopicBody(topic: t),
            const SizedBox(height: kSpaceLg),
            if (leader && t.editable)
              AppButton(
                label: t.status == TopicStatus.pending
                    ? 'Edit topic'
                    : 'Resubmit ($resubmitsLeft left)',
                onPressed: (t.status == TopicStatus.pending || resubmitsLeft > 0)
                    ? () => context.push(Routes.topicSubmit)
                    : null,
              ),
          ],
        );
      },
    );
  }
}

/// Topic content shared by the student view and the mentor review.
class TopicBody extends StatelessWidget {
  const TopicBody({super.key, required this.topic});

  final ProjectTopic topic;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Summary', style: text.titleSmall),
        const SizedBox(height: kSpaceXs),
        Text(topic.description),
        const SizedBox(height: kSpaceMd),
        Text('Tech stack', style: text.titleSmall),
        const SizedBox(height: kSpaceXs),
        Text(topic.techStack),
        if (topic.attachmentUrl != null) ...[
          const SizedBox(height: kSpaceMd),
          AppButton(
            label: topic.attachmentName ?? 'Open outline',
            icon: Icons.attach_file,
            variant: AppButtonVariant.tonal,
            onPressed: () => openLink(context, topic.attachmentUrl!),
          ),
        ],
      ],
    );
  }
}
