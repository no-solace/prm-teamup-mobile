import 'dart:async';

import '../../models/app_user.dart';
import '../../models/meeting.dart';
import '../../models/project_topic.dart';
import '../app_error.dart';
import '../booking_service.dart';
import '../meeting_service.dart';
import '../topic_service.dart';
import 'sample_data.dart';

/// Re-emits [read] after every change (same pattern as FakeProposalService).
class _Live {
  final _changes = StreamController<void>.broadcast();
  void changed() => _changes.add(null);
  Stream<T> watch<T>(T Function() read) async* {
    yield read();
    await for (final _ in _changes.stream) {
      yield read();
    }
  }
}

class FakeTopicService implements TopicService {
  final _live = _Live();
  final Map<String, ProjectTopic> _topics = {};
  final Map<String, List<int>> _outlines = {};

  @override
  Future<List<int>> downloadOutline(String topicId) async =>
      _outlines[topicId] ?? (throw const NotFoundError('The outline file is missing'));

  @override
  Stream<List<ProjectTopic>> watchMentorTopics() =>
      _live.watch(() => _topics.values.toList());

  @override
  Stream<ProjectTopic?> watchTopic(String topicId) => _live.watch(() => _topics[topicId]);

  @override
  Future<void> submit(
    AppUser leader, {
    required String title,
    required String description,
    required String techStack,
    TopicAttachment? attachment,
    required int maxRevisions,
  }) async {
    final id = leader.topicId;
    if (!leader.isLeader || id == null) {
      throw const PermissionDeniedError('Only the team leader can submit a topic');
    }
    if (title.trim().isEmpty || description.trim().isEmpty || techStack.trim().isEmpty) {
      throw const ValidationError('Fill in title, summary and tech stack');
    }
    if (attachment != null &&
        (attachment.bytes.isEmpty || attachment.bytes.length > TopicAttachment.maxBytes)) {
      throw const ValidationError('Outline must be between 1 byte and 900 KB');
    }
    final old = _topics[id];
    if (old?.status == TopicStatus.approved) {
      throw const ValidationError('An approved topic can no longer be changed');
    }
    final resubmit = old != null && old.status != TopicStatus.pending;
    if (resubmit && old.revisionCount >= maxRevisions) {
      throw ValidationError('Revision limit reached ($maxRevisions). Contact your mentor.');
    }
    _topics[id] = ProjectTopic(
      id: id,
      classId: leader.classId!,
      teamId: leader.teamId!,
      teamName: 'Tutor Match',
      mentorUid: leader.mentorUid ?? SampleData.mentorUid,
      title: title.trim(),
      description: description.trim(),
      techStack: techStack.trim(),
      status: TopicStatus.pending,
      revisionCount: (old?.revisionCount ?? 0) + (resubmit ? 1 : 0),
      submittedAt: DateTime.now(),
      attachmentName: attachment?.fileName ?? old?.attachmentName,
    );
    if (attachment != null) _outlines[id] = List.of(attachment.bytes);
    _live.changed();
  }

  @override
  Future<void> review(String topicId, TopicStatus decision, String feedback) async {
    final t = _topics[topicId] ?? (throw const NotFoundError('Topic not found'));
    if (t.status != TopicStatus.pending) {
      throw const ValidationError('This topic has already been reviewed');
    }
    if (decision == TopicStatus.pending ||
        (decision != TopicStatus.approved && feedback.trim().isEmpty)) {
      throw const ValidationError('Add feedback so the team knows what to change');
    }
    _topics[topicId] = ProjectTopic(
      id: t.id,
      classId: t.classId,
      teamId: t.teamId,
      teamName: t.teamName,
      mentorUid: t.mentorUid,
      title: t.title,
      description: t.description,
      techStack: t.techStack,
      status: decision,
      revisionCount: t.revisionCount,
      submittedAt: t.submittedAt,
      attachmentName: t.attachmentName,
      mentorFeedback: feedback.trim().isEmpty ? null : feedback.trim(),
    );
    _live.changed();
  }
}

class FakeBookingService implements BookingService {
  FakeBookingService() {
    final start = DateTime.now().add(const Duration(days: 1));
    for (var i = 0; i < 3; i++) {
      final at = DateTime(start.year, start.month, start.day, 9 + i * 2);
      _slots.add(MentorSlot(
        id: 'slot-$i',
        mentorUid: SampleData.mentorUid,
        startTime: at,
        endTime: at.add(const Duration(minutes: 30)),
      ));
    }
  }

  final _live = _Live();
  final List<MentorSlot> _slots = [];
  final List<MeetingBooking> _bookings = [];
  var _seq = 0;

  @override
  Stream<List<MentorSlot>> watchSlots(String mentorUid) => _live.watch(
    () => _slots.where((s) => s.mentorUid == mentorUid).toList()
      ..sort((a, b) => a.startTime.compareTo(b.startTime)),
  );

  @override
  Future<void> addSlot(DateTime start, Duration duration) async {
    if (start.isBefore(DateTime.now())) throw const ValidationError('Pick a time in the future');
    final end = start.add(duration);
    if (_slots.any((s) => s.startTime.isBefore(end) && s.endTime.isAfter(start))) {
      throw const ValidationError('This time overlaps one of your slots');
    }
    _slots.add(MentorSlot(
      id: 'slot-new-${_seq++}',
      mentorUid: SampleData.mentorUid,
      startTime: start,
      endTime: start.add(duration),
    ));
    _live.changed();
  }

  @override
  Future<void> deleteSlot(String slotId) async {
    final slot = _slots.firstWhere((s) => s.id == slotId);
    if (!slot.isAvailable) {
      throw const ValidationError('Decline the booking before removing this slot');
    }
    _slots.remove(slot);
    _live.changed();
  }

  @override
  Stream<List<MeetingBooking>> watchMentorBookings() => _live.watch(() => List.of(_bookings));

  @override
  Stream<List<MeetingBooking>> watchTeamBookings(AppUser student) => _live.watch(
    () => _bookings
        .where((b) => b.classId == student.classId && b.teamId == student.teamId)
        .toList(),
  );

  @override
  Stream<MeetingBooking> watchBooking(String bookingId) => _live.watch(
    () => _bookings.firstWhere(
      (b) => b.id == bookingId,
      orElse: () => throw const NotFoundError('Meeting not found'),
    ),
  );

  @override
  Future<void> book(AppUser leader, MentorSlot slot, MeetingPurpose purpose) async {
    if (!leader.isLeader) throw const PermissionDeniedError('Only the team leader can book');
    final i = _slots.indexWhere((s) => s.id == slot.id);
    if (i < 0 || !_slots[i].isAvailable) {
      throw const ValidationError('This slot was just taken. Pick another one');
    }
    final id = 'booking-${_seq++}';
    _slots[i] = MentorSlot(
      id: slot.id,
      mentorUid: slot.mentorUid,
      startTime: slot.startTime,
      endTime: slot.endTime,
      bookingId: id,
    );
    _bookings.add(MeetingBooking(
      id: id,
      slotId: slot.id,
      mentorUid: slot.mentorUid,
      classId: leader.classId!,
      teamId: leader.teamId!,
      teamName: 'Tutor Match',
      purpose: purpose,
      status: BookingStatus.requested,
      startTime: slot.startTime,
      endTime: slot.endTime,
    ));
    _live.changed();
  }

  void _set(String id, BookingStatus to, Set<BookingStatus> from, {String? meetUrl}) {
    final i = _bookings.indexWhere((b) => b.id == id);
    if (i < 0) throw const NotFoundError('Meeting not found');
    final b = _bookings[i];
    if (!from.contains(b.status)) {
      throw ValidationError('A ${b.status.name} meeting cannot become ${to.name}');
    }
    _bookings[i] = MeetingBooking(
      id: b.id,
      slotId: b.slotId,
      mentorUid: b.mentorUid,
      classId: b.classId,
      teamId: b.teamId,
      teamName: b.teamName,
      purpose: b.purpose,
      status: to,
      startTime: b.startTime,
      endTime: b.endTime,
      meetUrl: meetUrl ?? b.meetUrl,
    );
    if (to == BookingStatus.cancelled) {
      final s = _slots.indexWhere((s) => s.id == b.slotId);
      if (s >= 0) {
        final slot = _slots[s];
        _slots[s] = MentorSlot(
          id: slot.id,
          mentorUid: slot.mentorUid,
          startTime: slot.startTime,
          endTime: slot.endTime,
        );
      }
    }
    _live.changed();
  }

  @override
  Future<void> confirm(String bookingId, String meetUrl) async {
    if (!MeetingBooking.meetUrlPattern.hasMatch(meetUrl.trim())) {
      throw const ValidationError('Paste a Google Meet link like https://meet.google.com/abc-defg-hij');
    }
    _set(bookingId, BookingStatus.confirmed, {BookingStatus.requested}, meetUrl: meetUrl.trim());
  }

  @override
  Future<void> cancel(String bookingId) async => _set(
    bookingId,
    BookingStatus.cancelled,
    {BookingStatus.requested, BookingStatus.confirmed},
  );

  @override
  Future<void> complete(String bookingId) async =>
      _set(bookingId, BookingStatus.completed, {BookingStatus.confirmed});
}

class FakeMeetingService implements MeetingService {
  final _live = _Live();
  final Map<String, MeetingMinutes> _minutes = {};

  @override
  Stream<MeetingMinutes?> watchMinutes(String bookingId) =>
      _live.watch(() => _minutes[bookingId]);

  MeetingMinutes _copy(MeetingMinutes m, {String? summary, List<ActionItem>? items,
      int? rating, bool? signed}) => MeetingMinutes(
    id: m.id,
    mentorUid: m.mentorUid,
    classId: m.classId,
    teamId: m.teamId,
    teamName: m.teamName,
    meetingDate: m.meetingDate,
    summary: summary ?? m.summary,
    actionItems: items ?? m.actionItems,
    mentorRating: rating ?? m.mentorRating,
    isSignedByMentor: signed ?? m.isSignedByMentor,
  );

  @override
  Future<void> saveMinutes(
    MeetingBooking booking, {
    required String summary,
    required List<ActionItem> actionItems,
  }) async {
    if (summary.trim().isEmpty) throw const ValidationError('Summary is required');
    if (!actionItems.every((i) => i.isComplete)) {
      throw const ValidationError('Each action item needs a task, an assignee and a deadline');
    }
    if (!booking.canHaveMinutes) {
      throw const ValidationError('Minutes are written after a confirmed meeting');
    }
    final old = _minutes[booking.id];
    if (old?.isSignedByMentor == true) {
      throw const ValidationError('Signed minutes can no longer be edited');
    }
    _minutes[booking.id] = old == null
        ? MeetingMinutes(
            id: booking.id,
            mentorUid: booking.mentorUid,
            classId: booking.classId,
            teamId: booking.teamId,
            teamName: booking.teamName,
            meetingDate: booking.startTime,
            summary: summary.trim(),
            actionItems: actionItems,
          )
        : _copy(old, summary: summary.trim(), items: actionItems);
    _live.changed();
  }

  @override
  Future<void> sign(String minutesId, int rating) async {
    final m = _minutes[minutesId] ?? (throw const NotFoundError('Minutes not found'));
    if (rating < 1 || rating > 5) throw const ValidationError('Rate progress from 1 to 5 stars');
    _minutes[minutesId] = _copy(m, rating: rating, signed: true);
    _live.changed();
  }

  @override
  Future<List<int>> exportPdf(MeetingMinutes minutes) async {
    if (!minutes.isSignedByMentor) {
      throw const ValidationError('Export after the mentor signs the minutes');
    }
    return '%PDF-1.4 fake minutes ${minutes.id}'.codeUnits;
  }
}
