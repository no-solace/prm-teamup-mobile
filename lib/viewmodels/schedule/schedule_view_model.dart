import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/meeting.dart';
import '../../providers/service_providers.dart';
import '../../services/app_error.dart';
import '../auth/session_view_model.dart';
import '../view_state.dart';

/// Mentor: requests to them. Student: their team's bookings (Flow E).
final bookingsProvider = StreamProvider.autoDispose<List<MeetingBooking>>((ref) {
  final user = ref.watch(sessionProvider).value;
  final service = ref.watch(bookingServiceProvider);
  if (user == null) return Stream.error(const PermissionDeniedError('Sign in first'));
  return user.isMentor ? service.watchMentorBookings() : service.watchTeamBookings(user);
});

/// Upcoming slots of the mentor (own, or the team's mentor for students).
final slotsProvider = StreamProvider.autoDispose<List<MentorSlot>>((ref) {
  final user = ref.watch(sessionProvider).value;
  final mentorUid = user == null ? null : (user.isMentor ? user.uid : user.mentorUid);
  if (mentorUid == null) return Stream.error(const PermissionDeniedError('No mentor linked'));
  return ref.watch(bookingServiceProvider).watchSlots(mentorUid);
});

final bookingProvider = StreamProvider.autoDispose.family<MeetingBooking, String>(
  (ref, id) => ref.watch(bookingServiceProvider).watchBooking(id),
);

final minutesProvider = StreamProvider.autoDispose.family<MeetingMinutes?, String>(
  (ref, bookingId) => ref.watch(meetingServiceProvider).watchMinutes(bookingId),
);

/// Busy flag for Flow E/F writes; errors are rethrown as [AppError].
class ScheduleActionViewModel extends Notifier<bool> {
  @override
  bool build() => false;

  Future<T> _run<T>(Future<T> Function() body) async {
    if (state) throw const ValidationError('Another action is in progress');
    state = true;
    try {
      return await body();
    } catch (e) {
      throw toAppError(e);
    } finally {
      state = false;
    }
  }

  Future<void> addSlot(DateTime start) => _run(() {
    final minutes = ref.read(configServiceProvider).current.defaultMeetingDurationMinutes;
    return ref.read(bookingServiceProvider).addSlot(start, Duration(minutes: minutes));
  });

  Future<void> deleteSlot(String slotId) =>
      _run(() => ref.read(bookingServiceProvider).deleteSlot(slotId));

  Future<void> book(MentorSlot slot, MeetingPurpose purpose) => _run(() {
    final user = ref.read(sessionProvider).value;
    if (user == null) throw const PermissionDeniedError('Sign in first');
    return ref.read(bookingServiceProvider).book(user, slot, purpose);
  });

  Future<void> confirm(String bookingId, String meetUrl) =>
      _run(() => ref.read(bookingServiceProvider).confirm(bookingId, meetUrl));

  Future<void> cancel(String bookingId) =>
      _run(() => ref.read(bookingServiceProvider).cancel(bookingId));

  Future<void> complete(String bookingId) =>
      _run(() => ref.read(bookingServiceProvider).complete(bookingId));

  Future<void> saveMinutes(
    MeetingBooking booking,
    String summary,
    List<ActionItem> items,
  ) => _run(
    () => ref
        .read(meetingServiceProvider)
        .saveMinutes(booking, summary: summary, actionItems: items),
  );

  Future<void> sign(String minutesId, int rating) =>
      _run(() => ref.read(meetingServiceProvider).sign(minutesId, rating));

  Future<String> exportPdf(MeetingMinutes minutes) =>
      _run(() => ref.read(meetingServiceProvider).exportPdf(minutes));
}

final scheduleActionProvider = NotifierProvider<ScheduleActionViewModel, bool>(
  ScheduleActionViewModel.new,
);
