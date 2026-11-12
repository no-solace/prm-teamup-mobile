import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/meeting.dart';
import '../../theme/app_spacing.dart';
import '../../viewmodels/schedule/schedule_view_model.dart';
import '../../widgets/action_feedback.dart';
import '../../widgets/app_button.dart';
import '../../widgets/status_view.dart';

/// Flow F: write or edit the minutes (summary + action item checklist).
class MinutesFormScreen extends ConsumerStatefulWidget {
  const MinutesFormScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  ConsumerState<MinutesFormScreen> createState() => _MinutesFormScreenState();
}

class _Row {
  _Row([ActionItem? item])
    : task = TextEditingController(text: item?.task),
      assignee = TextEditingController(text: item?.assignee),
      deadline = item?.deadline ?? '';

  final TextEditingController task;
  final TextEditingController assignee;
  String deadline;

  void dispose() {
    task.dispose();
    assignee.dispose();
  }
}

class _MinutesFormScreenState extends ConsumerState<MinutesFormScreen> {
  final _summary = TextEditingController();
  final List<_Row> _rows = [];
  final List<_Row> _removed = [];
  bool _prefilled = false;

  @override
  void dispose() {
    _summary.dispose();
    for (final r in [..._rows, ..._removed]) {
      r.dispose();
    }
    super.dispose();
  }

  Future<void> _pickDeadline(_Row row) async {
    final now = DateTime.now();
    final day = await showDatePicker(
      context: context,
      firstDate: now.subtract(const Duration(days: 30)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (day == null) return;
    setState(() => row.deadline =
        '${day.year}-${day.month.toString().padLeft(2, '0')}-${day.day.toString().padLeft(2, '0')}');
  }

  Future<void> _save(MeetingBooking booking) async {
    final items = [
      for (final r in _rows)
        if (r.task.text.trim().isNotEmpty || r.assignee.text.trim().isNotEmpty)
          ActionItem(task: r.task.text.trim(), assignee: r.assignee.text.trim(), deadline: r.deadline),
    ];
    if (!items.every((i) => i.isComplete)) {
      showMessage(context, 'Each action item needs a task, an assignee and a deadline');
      return;
    }
    final ok = await runWithFeedback(
      context,
      () => ref.read(scheduleActionProvider.notifier).saveMinutes(booking, _summary.text, items),
      success: 'Minutes saved',
    );
    if (ok && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final booking = ref.watch(bookingProvider(widget.bookingId));
    final minutes = ref.watch(minutesProvider(widget.bookingId));
    final busy = ref.watch(scheduleActionProvider);
    if (!_prefilled && minutes.hasValue) {
      _prefilled = true;
      final m = minutes.value;
      _summary.text = m?.summary ?? '';
      _rows.addAll([for (final i in m?.actionItems ?? const <ActionItem>[]) _Row(i)]);
      if (_rows.isEmpty) _rows.add(_Row());
    }
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Meeting minutes')),
      body: booking.when(
        loading: () => const LoadingView(),
        error: (e, _) => StatusView.error(message: errorText(e)),
        data: (b) => !_prefilled
            ? const LoadingView()
            : ListView(
                padding: kScreenPadding,
                children: [
                  TextField(
                    controller: _summary,
                    maxLength: 4000,
                    minLines: 4,
                    maxLines: 10,
                    decoration: const InputDecoration(
                      labelText: 'Summary',
                      hintText: 'What was discussed and decided',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: kSpaceMd),
                  Text('Action items', style: text.titleMedium),
                  for (final r in _rows)
                    Padding(
                      padding: const EdgeInsets.only(top: kSpaceSm),
                      child: Column(
                        children: [
                          TextField(
                            controller: r.task,
                            decoration: const InputDecoration(labelText: 'Task', border: OutlineInputBorder()),
                          ),
                          const SizedBox(height: kSpaceXs),
                          Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: r.assignee,
                                  decoration: const InputDecoration(
                                    labelText: 'Assignee',
                                    border: OutlineInputBorder(),
                                  ),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () => _pickDeadline(r),
                                icon: const Icon(Icons.event),
                                label: Text(r.deadline.isEmpty ? 'Deadline' : r.deadline),
                              ),
                              IconButton(
                                tooltip: 'Remove item',
                                icon: const Icon(Icons.close),
                                // Disposed with the screen; the field may
                                // still be mounted during this frame.
                                onPressed: () => setState(() {
                                  _rows.remove(r);
                                  _removed.add(r);
                                }),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: kSpaceSm),
                  if (_rows.length < MeetingMinutes.maxActionItems)
                    AppButton(
                      label: 'Add action item',
                      icon: Icons.add,
                      variant: AppButtonVariant.text,
                      onPressed: () => setState(() => _rows.add(_Row())),
                    ),
                  const SizedBox(height: kSpaceLg),
                  AppButton(label: 'Save minutes', loading: busy, onPressed: () => _save(b)),
                ],
              ),
      ),
    );
  }
}
