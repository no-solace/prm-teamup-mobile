import '../models/app_user.dart';
import '../models/meeting.dart';

/// Flow E. Mentor availability slots and team bookings.
abstract interface class BookingService {
  /// Slots of [mentorUid] from now on, sorted by start time.
  Stream<List<MentorSlot>> watchSlots(String mentorUid);

  /// Mentor only. Throws [ValidationError] for a past start.
  Future<void> addSlot(DateTime start, Duration duration);

  /// Mentor only; a booked slot must be declined first.
  Future<void> deleteSlot(String slotId);

  /// Bookings addressed to the signed-in mentor, soonest first.
  Stream<List<MeetingBooking>> watchMentorBookings();

  /// Bookings of the student's own team, soonest first.
  Stream<List<MeetingBooking>> watchTeamBookings(AppUser student);

  Stream<MeetingBooking> watchBooking(String bookingId);

  /// Leader only. Atomic: fails with [ValidationError] if the slot was
  /// taken in the meantime.
  Future<void> book(AppUser leader, MentorSlot slot, MeetingPurpose purpose);

  /// Mentor accepts and attaches the Google Meet link.
  Future<void> confirm(String bookingId, String meetUrl);

  /// Mentor declines or the team cancels; frees the slot.
  Future<void> cancel(String bookingId);

  /// Mentor marks a confirmed meeting as held.
  Future<void> complete(String bookingId);
}
