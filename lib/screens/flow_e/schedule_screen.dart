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
import '../../widgets/status_chip.dart';
import '../../widgets/status_view.dart';

StatusTone bookingTone(BookingStatus s) => switch (s) {
  BookingStatus.requested => StatusTone.waiting,
  BookingStatus.confirmed => StatusTone.good,
  BookingStatus.cancelled => StatusTone.bad,
  BookingStatus.completed => StatusTone.neutral,
};

/// Flow E + F tab. Mentor: requests, meetings and availability.
/// Student: the team's meetings and booking.
class ScheduleScreen extends ConsumerWidget {
  const ScheduleScreen({super.key});

  Future<void> _addSlot(BuildContext context, WidgetRef ref) async {
    final now = DateTime.now();
    final day = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 60)),
    );
    if (day == null || !context.mounted) return;
    final time = await showTimePicker(context: context, initialTime: const TimeOfDay(hour: 9, minute: 0));
    if (time == null || !context.mounted) return;
    await runWithFeedback(
      context,
      () => ref
          .read(scheduleActionProvider.notifier)
          .addSlot(DateTime(day.year, day.month, day.day, time.hour, time.minute)),
      success: 'Slot opened',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(sessionProvider).value;
    final mentor = user?.isMentor ?? false;
    final bookings = ref.watch(bookingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      floatingActionButton: mentor
          ? FloatingActionButton.extended(
              onPressed: () => _addSlot(context, ref),
              icon: const Icon(Icons.add),
              label: const Text('Open slot'),
            )
          : null,
      body: bookings.when(
        loading: () => const LoadingView(),
        error: (e, _) => StatusView.error(
          message: errorText(e),
          onRetry: () => ref.invalidate(bookingsProvider),
        ),
        data: (items) {
          final requests = items.where((b) => b.status == BookingStatus.requested).toList();
          final upcoming = items.where((b) => b.status == BookingStatus.confirmed).toList();
          final history = items.where((b) => !b.isOpen).toList().reversed.toList();
          return ListView(
            padding: kScreenPadding,
            children: [
              if (user?.isLeader ?? false) ...[
                AppButton(
                  label: 'Book a meeting',
                  icon: Icons.event_available,
                  onPressed: () => context.push(Routes.bookSlot),
                ),
                const SizedBox(height: kSpaceMd),
              ],
              _Section(
                title: mentor ? 'Requests' : 'Waiting for mentor',
                empty: 'Nothing waiting',
                children: [for (final b in requests) _BookingCard(booking: b, mentor: mentor)],
              ),
              _Section(
                title: 'Upcoming meetings',
                empty: 'No confirmed meetings',
                children: [for (final b in upcoming) _BookingCard(booking: b, mentor: mentor)],
              ),
              if (mentor) const _MySlots(),
              if (history.isNotEmpty)
                _Section(
                  title: 'History',
                  empty: '',
                  children: [for (final b in history) _BookingCard(booking: b, mentor: mentor)],
                ),
              const SizedBox(height: kSpaceXl * 2),
            ],
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.empty, required this.children});

  final String title;
  final String empty;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: kSpaceMd),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: kSpaceSm),
        if (children.isEmpty)
          Text(empty, style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant))
        else
          ...children,
      ],
    ),
  );
}

class _BookingCard extends ConsumerWidget {
  const _BookingCard({required this.booking, required this.mentor});

  final MeetingBooking booking;
  final bool mentor;

  Future<void> _confirm(BuildContext context, WidgetRef ref) async {
    final url = await askMeetLink(context);
    if (url == null || !context.mounted) return;
    await runWithFeedback(
      context,
      () => ref.read(scheduleActionProvider.notifier).confirm(booking.id, url),
      success: 'Meeting confirmed',
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final b = booking;
    final busy = ref.watch(scheduleActionProvider);
    final text = Theme.of(context).textTheme;
    return AppCard(
      onTap: () => context.push(Routes.meeting(b.id)),
      semanticsLabel: '${b.teamName} ${b.purpose.label} ${b.status.label}',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Text(mentor ? b.teamName : b.purpose.label, style: text.titleMedium)),
              StatusChip(label: b.status.label, tone: bookingTone(b.status)),
            ],
          ),
          const SizedBox(height: kSpaceXs),
          Text('${shortDateTime(b.startTime)}${mentor ? ' · ${b.purpose.label}' : ''}'),
          if (mentor && b.status == BookingStatus.requested) ...[
            const SizedBox(height: kSpaceSm),
            Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: 'Decline',
                    variant: AppButtonVariant.text,
                    onPressed: busy
                        ? null
                        : () => runWithFeedback(
                            context,
                            () => ref.read(scheduleActionProvider.notifier).cancel(b.id),
                            success: 'Request declined',
                          ),
                  ),
                ),
                const SizedBox(width: kSpaceSm),
                Expanded(
                  child: AppButton(
                    label: 'Confirm',
                    onPressed: busy ? null : () => _confirm(context, ref),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _MySlots extends ConsumerWidget {
  const _MySlots();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final slots = ref.watch(slotsProvider);
    return _Section(
      title: 'My open slots',
      empty: slots.isLoading
          ? 'Loading...'
          : slots.hasError
          ? errorText(slots.error!)
          : 'No open slots. Tap "Open slot" to add one.',
      children: [
        for (final s in slots.value ?? const <MentorSlot>[])
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(s.isAvailable ? Icons.event_available : Icons.event_busy),
            title: Text(shortDateTime(s.startTime)),
            subtitle: Text(s.isAvailable ? 'Available' : 'Booked'),
            trailing: s.isAvailable
                ? IconButton(
                    tooltip: 'Remove slot',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => runWithFeedback(
                      context,
                      () => ref.read(scheduleActionProvider.notifier).deleteSlot(s.id),
                      success: 'Slot removed',
                    ),
                  )
                : null,
          ),
      ],
    );
  }
}

/// Asks the mentor for the Google Meet link of the meeting.
Future<String?> askMeetLink(BuildContext context) =>
    showDialog<String>(context: context, builder: (_) => const _MeetLinkDialog());

/// Owns its controller so it is disposed after the close animation,
/// not while the field is still on screen.
class _MeetLinkDialog extends StatefulWidget {
  const _MeetLinkDialog();

  @override
  State<_MeetLinkDialog> createState() => _MeetLinkDialogState();
}

class _MeetLinkDialogState extends State<_MeetLinkDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AlertDialog(
    title: const Text('Google Meet link'),
    content: TextField(
      controller: _controller,
      autofocus: true,
      keyboardType: TextInputType.url,
      decoration: const InputDecoration(hintText: 'https://meet.google.com/abc-defg-hij'),
    ),
    actions: [
      TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
      FilledButton(
        onPressed: () => Navigator.of(context).pop(_controller.text),
        child: const Text('Confirm'),
      ),
    ],
  );
}
