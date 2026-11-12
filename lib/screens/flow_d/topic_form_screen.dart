import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../services/topic_service.dart';
import '../../theme/app_spacing.dart';
import '../../viewmodels/topics/topic_view_model.dart';
import '../../widgets/action_feedback.dart';
import '../../widgets/app_button.dart';

/// Flow D, leader: submit, edit or resubmit the team topic.
class TopicFormScreen extends ConsumerStatefulWidget {
  const TopicFormScreen({super.key});

  @override
  ConsumerState<TopicFormScreen> createState() => _TopicFormScreenState();
}

class _TopicFormScreenState extends ConsumerState<TopicFormScreen> {
  final _title = TextEditingController();
  final _summary = TextEditingController();
  final _stack = TextEditingController();
  TopicAttachment? _file;
  bool _prefilled = false;

  @override
  void dispose() {
    _title.dispose();
    _summary.dispose();
    _stack.dispose();
    super.dispose();
  }

  Future<void> _pick() async {
    try {
      final file = await ref.read(topicFilePickerProvider)();
      if (file != null) setState(() => _file = file);
    } catch (_) {
      if (mounted) showMessage(context, 'Could not read that file');
    }
  }

  Future<void> _submit() async {
    final ok = await runWithFeedback(
      context,
      () => ref.read(topicActionProvider.notifier).submit(
        title: _title.text,
        description: _summary.text,
        techStack: _stack.text,
        attachment: _file,
      ),
      success: 'Topic sent to your mentor',
    );
    if (ok && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final existing = ref.watch(myTopicProvider).value;
    if (!_prefilled && existing != null) {
      _prefilled = true;
      _title.text = existing.title;
      _summary.text = existing.description;
      _stack.text = existing.techStack;
    }
    final busy = ref.watch(topicActionProvider);
    InputDecoration field(String label, [String? hint]) =>
        InputDecoration(labelText: label, hintText: hint, border: const OutlineInputBorder());
    return Scaffold(
      appBar: AppBar(title: Text(existing == null ? 'Submit topic' : 'Update topic')),
      body: ListView(
        padding: kScreenPadding,
        children: [
          TextField(controller: _title, maxLength: 200, decoration: field('Title')),
          const SizedBox(height: kSpaceSm),
          TextField(
            controller: _summary,
            maxLength: 4000,
            minLines: 4,
            maxLines: 10,
            decoration: field('Idea summary', 'Problem, users, main features'),
          ),
          const SizedBox(height: kSpaceSm),
          TextField(
            controller: _stack,
            maxLength: 300,
            decoration: field('Tech stack', 'Flutter, Firebase, ...'),
          ),
          const SizedBox(height: kSpaceSm),
          AppButton(
            label: _file?.fileName ?? existing?.attachmentName ?? 'Attach outline (PDF/DOCX, max 900 KB)',
            icon: Icons.attach_file,
            variant: AppButtonVariant.tonal,
            onPressed: busy ? null : _pick,
          ),
          const SizedBox(height: kSpaceLg),
          AppButton(label: 'Send to mentor', loading: busy, onPressed: _submit),
        ],
      ),
    );
  }
}
