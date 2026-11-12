import 'data_validation.dart';

/// Flow E. mentors/{mentorUid}/slots/{slotId}.
class MentorSlot {
  const MentorSlot({
    required this.id,
    required this.mentorUid,
    required this.startTime,
    required this.endTime,
    this.bookingId,
  });

  final String id;
  final String mentorUid;
  final DateTime startTime;
  final DateTime endTime;

  /// Set while a booking holds the slot (status booked).
  final String? bookingId;

  bool get isAvailable => bookingId == null;

  factory MentorSlot.fromMap(String id, String mentorUid, Map<String, dynamic> d) {
    final status = d['status'];
    if (status != 'available' && status != 'booked') {
      throw const FormatException('Invalid slot status');
    }
    final bookingId = DataValidation.optionalText(d, 'bookingId', max: 64);
    if ((status == 'booked') != (bookingId != null)) {
      throw const FormatException('Slot status and booking disagree');
    }
    return MentorSlot(
      id: DataValidation.id(id),
      mentorUid: mentorUid,
      startTime: DataValidation.time(d['startTime']),
      endTime: DataValidation.time(d['endTime']),
      bookingId: bookingId,
    );
  }
}

enum MeetingPurpose {
  topicReview('topic_review', 'Topic review'),
  sprintReview('sprint_review', 'Sprint review'),
  techGuidance('tech_guidance', 'Technical guidance');

  const MeetingPurpose(this.code, this.label);
  final String code;
  final String label;

  static MeetingPurpose fromCode(Object? code) => values.firstWhere(
    (p) => p.code == code,
    orElse: () => throw const FormatException('Invalid purpose'),
  );
}

enum BookingStatus {
  requested('Requested'),
  confirmed('Confirmed'),
  cancelled('Cancelled'),
  completed('Completed');

  const BookingStatus(this.label);
  final String label;

  static BookingStatus fromCode(Object? code) => values.firstWhere(
    (s) => s.name == code,
    orElse: () => throw const FormatException('Invalid booking status'),
  );
}

/// Flow E + F. bookings/{id}. A confirmed booking with a meetUrl is the
/// meeting itself (no separate meetings collection).
class MeetingBooking {
  const MeetingBooking({
    required this.id,
    required this.slotId,
    required this.mentorUid,
    required this.classId,
    required this.teamId,
    required this.teamName,
    required this.purpose,
    required this.status,
    required this.startTime,
    required this.endTime,
    this.meetUrl,
  });

  final String id;
  final String slotId;
  final String mentorUid;
  final String classId;
  final String teamId;
  final String teamName;
  final MeetingPurpose purpose;
  final BookingStatus status;
  final DateTime startTime;
  final DateTime endTime;
  final String? meetUrl;

  bool get isOpen =>
      status == BookingStatus.requested || status == BookingStatus.confirmed;

  /// Minutes are written after a confirmed or completed meeting.
  bool get canHaveMinutes =>
      status == BookingStatus.confirmed || status == BookingStatus.completed;

  factory MeetingBooking.fromMap(String id, Map<String, dynamic> d) =>
      MeetingBooking(
        id: DataValidation.id(id),
        slotId: DataValidation.id(DataValidation.text(d, 'slotId', max: 64)),
        mentorUid: DataValidation.text(d, 'mentorUid', max: 128),
        classId: DataValidation.id(DataValidation.text(d, 'classId', max: 64)),
        teamId: DataValidation.id(DataValidation.text(d, 'teamId', max: 64)),
        teamName: DataValidation.text(d, 'teamName'),
        purpose: MeetingPurpose.fromCode(d['purpose']),
        status: BookingStatus.fromCode(d['status']),
        startTime: DataValidation.time(d['startTime']),
        endTime: DataValidation.time(d['endTime']),
        meetUrl: DataValidation.optionalText(d, 'meetUrl', max: 256),
      );

  /// Only Google Meet links are accepted (also enforced by the rules).
  static final meetUrlPattern = RegExp(
    r'^https://meet\.google\.com/[a-z]{3}-[a-z]{4}-[a-z]{3}$',
  );
}

class ActionItem {
  const ActionItem({required this.task, required this.assignee, required this.deadline});

  final String task;
  final String assignee;

  /// yyyy-MM-dd, kept as text so the list stays a plain map array.
  final String deadline;

  factory ActionItem.fromMap(Object? raw) {
    if (raw is! Map) throw const FormatException('Invalid action item');
    final d = Map<String, dynamic>.from(raw);
    return ActionItem(
      task: DataValidation.text(d, 'task', max: 300),
      assignee: DataValidation.text(d, 'assignee', max: 120),
      deadline: DataValidation.text(d, 'deadline', max: 10),
    );
  }

  /// Task, assignee and a yyyy-MM-dd deadline are all required.
  bool get isComplete =>
      task.trim().isNotEmpty &&
      assignee.trim().isNotEmpty &&
      RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(deadline);

  Map<String, dynamic> toMap() => {'task': task, 'assignee': assignee, 'deadline': deadline};
}

/// Flow F. minutes/{bookingId}: one record per meeting.
class MeetingMinutes {
  const MeetingMinutes({
    required this.id,
    required this.mentorUid,
    required this.classId,
    required this.teamId,
    required this.teamName,
    required this.meetingDate,
    required this.summary,
    required this.actionItems,
    this.mentorRating,
    this.isSignedByMentor = false,
    this.pdfDownloadUrl,
  });

  static const maxActionItems = 20;

  /// Same as the booking ID.
  final String id;
  final String mentorUid;
  final String classId;
  final String teamId;
  final String teamName;
  final DateTime meetingDate;
  final String summary;
  final List<ActionItem> actionItems;

  /// 1..5, set by the mentor when signing.
  final int? mentorRating;
  final bool isSignedByMentor;
  final String? pdfDownloadUrl;

  factory MeetingMinutes.fromMap(String id, Map<String, dynamic> d) {
    final items = d['actionItems'];
    final rating = d['mentorRating'];
    if (items is! List || items.length > maxActionItems) {
      throw const FormatException('Invalid action items');
    }
    if (rating != null && (rating is! int || rating < 1 || rating > 5)) {
      throw const FormatException('Invalid rating');
    }
    return MeetingMinutes(
      id: DataValidation.id(id),
      mentorUid: DataValidation.text(d, 'mentorUid', max: 128),
      classId: DataValidation.id(DataValidation.text(d, 'classId', max: 64)),
      teamId: DataValidation.id(DataValidation.text(d, 'teamId', max: 64)),
      teamName: DataValidation.text(d, 'teamName'),
      meetingDate: DataValidation.time(d['meetingDate']),
      summary: DataValidation.text(d, 'summary', max: 4000),
      actionItems: List.unmodifiable(items.map(ActionItem.fromMap)),
      mentorRating: rating as int?,
      isSignedByMentor: d['isSignedByMentor'] == true,
      pdfDownloadUrl: DataValidation.optionalText(d, 'pdfDownloadUrl', max: 2048),
    );
  }
}
