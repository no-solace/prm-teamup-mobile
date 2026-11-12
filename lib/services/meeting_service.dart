import '../models/meeting.dart';

/// Flow F. Minutes of a held meeting (minutes/{bookingId}).
abstract interface class MeetingService {
  Stream<MeetingMinutes?> watchMinutes(String bookingId);

  /// Creates or edits the minutes until the mentor signs them.
  Future<void> saveMinutes(
    MeetingBooking booking, {
    required String summary,
    required List<ActionItem> actionItems,
  });

  /// Mentor rates progress (1..5) and signs; the minutes become read-only.
  Future<void> sign(String minutesId, int rating);

  /// Builds the PDF, uploads it to Storage and returns its download URL.
  Future<String> exportPdf(MeetingMinutes minutes);
}
