import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/meeting.dart';
import '../../router/routes.dart';
import '../../theme/app_spacing.dart';
import '../../viewmodels/auth/session_view_model.dart';
import '../../viewmodels/schedule/schedule_view_model.dart';
import '../../widgets/action_feedback.dart';
import '../../widgets/app_button.dart';
import '../../widgets/app_card.dart';
import '../../widgets/confirm_dialog.dart';
import '../../widgets/status_chip.dart';
import '../../widgets/status_view.dart';
import '../flow_e/schedule_screen.dart';

/// Flow E + F: one meeting, its Google Meet link and its minutes.
class MeetingScreen extends ConsumerWidget {
  const MeetingScreen({super.key, required this.bookingId});

  final String bookingId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booking = ref.watch(bookingProvider(bookingId));
    final user = ref.watch(sessionProvider).value;
    final mentor = user?.isMentor ?? false;
    final busy = ref.watch(scheduleActionProvider);
    final actions = ref.read(scheduleActionProvider.notifier);
    final text = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Meeting')),
      body: booking.when(
        loading: () => const LoadingView(),
        error: (e, _) => StatusView.error(
          message: errorText(e),
          onRetry: () => ref.invalidate(bookingProvider(bookingId)),
        ),
        data: (b) => ListView(
          padding: kScreenPadding,
          children: [
            Row(
              children: [
                Expanded(child: Text(b.teamName, style: text.headlineSmall)),
                StatusChip(label: b.status.label, tone: bookingTone(b.status)),
              ],
            ),
            const SizedBox(height: kSpaceSm),
            Text('${b.purpose.label} · ${shortDateTime(b.startTime)} – '
                '${b.endTime.hour.toString().padLeft(2, '0')}:${b.endTime.minute.toString().padLeft(2, '0')}'),
            const SizedBox(height: kSpaceLg),
            if (b.status == BookingStatus.confirmed && b.meetUrl != null) ...[
              AppButton(
                label: 'Join Google Meet',
                icon: Icons.videocam_outlined,
                onPressed: () => openLink(context, b.meetUrl!),
              ),
              const SizedBox(height: kSpaceSm),
            ],
            if (b.status == BookingStatus.requested)
              Text(mentor ? 'Confirm this request from the Schedule tab.' : 'Waiting for your mentor to confirm.'),
            if (mentor && b.status == BookingStatus.confirmed)
              AppButton(
                label: 'Mark as held',
                variant: AppButtonVariant.tonal,
                onPressed: busy
                    ? null
                    : () => runWithFeedback(context, () => actions.complete(b.id), success: 'Meeting completed'),
              ),
            if (b.isOpen && (mentor || (user?.isLeader ?? false))) ...[
              const SizedBox(height: kSpaceSm),
              AppButton(
                label: 'Cancel meeting',
                variant: AppButtonVariant.text,
                onPressed: busy
                    ? null
                    : () async {
                        final yes = await showConfirmDialog(
                          context,
                          title: 'Cancel this meeting?',
                          message: 'The time slot becomes free again.',
                          confirmLabel: 'Cancel meeting',
                          cancelLabel: 'Keep',
                          destructive: true,
                        );
                        if (yes && context.mounted) {
                          await runWithFeedback(context, () => actions.cancel(b.id), success: 'Meeting cancelled');
                        }
                      },
              ),
            ],
            if (b.canHaveMinutes) ...[
              const Divider(height: kSpaceXl),
              _Minutes(booking: b, mentor: mentor),
            ],
          ],
        ),
      ),
    );
  }
}

class _Minutes extends ConsumerStatefulWidget {
  const _Minutes({required this.booking, required this.mentor});

  final MeetingBooking booking;
  final bool mentor;

  @override
  ConsumerState<_Minutes> createState() => _MinutesState();
}

class _MinutesState extends ConsumerState<_Minutes> {
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    final minutes = ref.watch(minutesProvider(widget.booking.id));
    final busy = ref.watch(scheduleActionProvider);
    final actions = ref.read(scheduleActionProvider.notifier);
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    void edit() => context.push(Routes.minutesForm(widget.booking.id));

    return minutes.when(
      loading: () => const LoadingView(),
      error: (e, _) => Text(errorText(e)),
      data: (m) {
        if (m == null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Minutes', style: text.titleMedium),
              const SizedBox(height: kSpaceSm),
              const Text('No minutes yet. Summarize the meeting and list the action items.'),
              const SizedBox(height: kSpaceSm),
              AppButton(label: 'Write minutes', icon: Icons.edit_note, onPressed: edit),
            ],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(child: Text('Minutes', style: text.titleMedium)),
                StatusChip(
                  label: m.isSignedByMentor ? 'Signed · ${m.mentorRating}/5' : 'Draft',
                  tone: m.isSignedByMentor ? StatusTone.good : StatusTone.waiting,
                ),
              ],
            ),
            const SizedBox(height: kSpaceSm),
            Text(m.summary),
            const SizedBox(height: kSpaceMd),
            Text('Action items', style: text.titleSmall),
            if (m.actionItems.isEmpty) const Text('None'),
            for (final item in m.actionItems)
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.task),
                    Text('${item.assignee} · due ${item.deadline}',
                        style: text.bodySmall?.copyWith(color: scheme.onSurfaceVariant)),
                  ],
                ),
              ),
            const SizedBox(height: kSpaceMd),
            if (!m.isSignedByMentor) ...[
              AppButton(label: 'Edit minutes', variant: AppButtonVariant.tonal, onPressed: edit),
              if (widget.mentor) ...[
                const SizedBox(height: kSpaceMd),
                Text('Progress rating', style: text.titleSmall),
                Row(
                  children: [
                    for (var i = 1; i <= 5; i++)
                      IconButton(
                        tooltip: '$i star${i == 1 ? '' : 's'}',
                        icon: Icon(i <= _rating ? Icons.star : Icons.star_border, color: scheme.primary),
                        onPressed: () => setState(() => _rating = i),
                      ),
                  ],
                ),
                if (_rating == 0) const Text('Tap a star to rate progress, then sign.'),
                AppButton(
                  label: 'Sign minutes',
                  loading: busy,
                  onPressed: _rating == 0
                      ? null
                      : () => runWithFeedback(context, () => actions.sign(m.id, _rating), success: 'Minutes signed'),
                ),
              ] else
                const Text('Waiting for the mentor to rate and sign.'),
            ] else ...[
              AppButton(
                label: 'Export PDF',
                icon: Icons.picture_as_pdf_outlined,
                loading: busy,
                onPressed: () => runWithFeedback(context, () => actions.exportPdf(m)),
              ),
            ],
          ],
        );
      },
    );
  }
}
