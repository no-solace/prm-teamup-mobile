import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/meeting.dart';
import '../../theme/app_spacing.dart';
import '../../viewmodels/schedule/schedule_view_model.dart';
import '../../widgets/action_feedback.dart';
import '../../widgets/app_button.dart';
import '../../widgets/status_view.dart';

/// Flow E, leader: pick a free slot of the team's mentor and a purpose.
class BookSlotScreen extends ConsumerStatefulWidget {
  const BookSlotScreen({super.key});

  @override
  ConsumerState<BookSlotScreen> createState() => _BookSlotScreenState();
}

class _BookSlotScreenState extends ConsumerState<BookSlotScreen> {
  MentorSlot? _slot;
  MeetingPurpose _purpose = MeetingPurpose.topicReview;

  Future<void> _book() async {
    final slot = _slot;
    if (slot == null) {
      showMessage(context, 'Pick a time slot');
      return;
    }
    final ok = await runWithFeedback(
      context,
      () => ref.read(scheduleActionProvider.notifier).book(slot, _purpose),
      success: 'Request sent to your mentor',
    );
    if (ok && mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final slots = ref.watch(slotsProvider);
    final busy = ref.watch(scheduleActionProvider);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Book a meeting')),
      body: slots.when(
        loading: () => const LoadingView(),
        error: (e, _) => StatusView.error(
          message: errorText(e),
          onRetry: () => ref.invalidate(slotsProvider),
        ),
        data: (all) {
          final free = all.where((s) => s.isAvailable).toList();
          // A slot taken by another team disappears from the list.
          if (_slot != null && !free.any((s) => s.id == _slot!.id)) _slot = null;
          if (free.isEmpty) {
            return const StatusView(
              icon: Icons.event_busy,
              title: 'No free slots',
              message: 'Your mentor has not opened any time yet. Check back later.',
            );
          }
          return ListView(
            padding: kScreenPadding,
            children: [
              Text('Purpose', style: text.titleMedium),
              const SizedBox(height: kSpaceSm),
              DropdownButtonFormField<MeetingPurpose>(
                initialValue: _purpose,
                decoration: const InputDecoration(border: OutlineInputBorder()),
                items: [
                  for (final p in MeetingPurpose.values)
                    DropdownMenuItem(value: p, child: Text(p.label)),
                ],
                onChanged: (p) => setState(() => _purpose = p ?? _purpose),
              ),
              const SizedBox(height: kSpaceLg),
              Text('Free slots', style: text.titleMedium),
              RadioGroup<String>(
                groupValue: _slot?.id,
                onChanged: (id) => setState(() => _slot = free.firstWhere((s) => s.id == id)),
                child: Column(
                  children: [
                    for (final s in free)
                      RadioListTile<String>(
                        value: s.id,
                        contentPadding: EdgeInsets.zero,
                        title: Text(shortDateTime(s.startTime)),
                        subtitle: Text('${s.endTime.difference(s.startTime).inMinutes} minutes'),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: kSpaceLg),
              AppButton(label: 'Send request', loading: busy, onPressed: _book),
            ],
          );
        },
      ),
    );
  }
}
