import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:teamup_exe/firebase/activity_messages.dart';
import 'package:teamup_exe/models/app_user.dart';

void main() {
  const mentor = AppUser(uid: 'm1', displayName: 'Lan', role: UserRole.mentor);
  const leader = AppUser(
    uid: 's1',
    displayName: 'An',
    role: UserRole.leader,
    classId: 'c',
    teamId: 't',
    mentorUid: 'm1',
  );
  final at = DateTime(2026, 11, 12, 9);
  Map<String, dynamic> topic(String status, {int revisions = 0}) => {
    'teamName': 'Tutor Match',
    'title': 'Campus tutor finder',
    'status': status,
    'revisionCount': revisions,
    'submittedAt': at,
    if (status != 'pending') 'reviewedAt': at,
    if (status != 'pending') 'mentorFeedback': 'Narrow the scope',
  };
  Map<String, dynamic> booking(String status) => {
    'slotId': 's',
    'mentorUid': 'm1',
    'classId': 'c',
    'teamId': 't',
    'teamName': 'Tutor Match',
    'purpose': 'topic_review',
    'status': status,
    'startTime': at,
    'endTime': at.add(const Duration(minutes: 30)),
    'requestedBy': 's1',
    'createdAt': at,
  };

  test('topics: mentor hears (re)submissions, students hear decisions', () {
    final m = topicMessage(mentor, 'c_t', topic('pending'))!;
    expect(m.data['uid'], 'm1');
    expect(m.data['route'], '/topics/c_t');
    expect(m.notification!.title, 'New topic to review');
    expect(topicMessage(mentor, 'c_t', topic('pending', revisions: 1))!.notification!.title,
        'Topic resubmitted');
    expect(topicMessage(mentor, 'c_t', topic('approved')), isNull);
    expect(topicMessage(leader, 'c_t', topic('pending')), isNull);
    final s = topicMessage(leader, 'c_t', topic('revision_requested'))!;
    expect(s.data['uid'], 's1');
    expect(s.notification!.title, 'Your topic needs revision');
    expect(s.notification!.body, 'Narrow the scope');
  });

  test('bookings: mentor hears requests, students hear confirmations, both hear cancels', () {
    expect(bookingMessage(mentor, 'b1', booking('requested'))!.notification!.title,
        'New meeting request');
    expect(bookingMessage(mentor, 'b1', booking('confirmed')), isNull);
    expect(bookingMessage(leader, 'b1', booking('requested')), isNull);
    expect(bookingMessage(leader, 'b1', booking('confirmed'))!.data['route'], '/schedule/b1');
    expect(bookingMessage(leader, 'b1', booking('cancelled'))!.notification!.title,
        'Meeting cancelled');
    // Malformed data throws here; changesOf skips such documents.
    expect(() => bookingMessage(mentor, 'b1', {'status': 'requested'}), throwsFormatException);
  });

  test('first snapshot is silent, later ones announce, own writes and bad docs are skipped', () async {
    final snapshots = StreamController<List<Doc>>();
    final out = <Map<String, dynamic>>[];
    final sub = changesOf(snapshots.stream, (id, d) => bookingMessage(mentor, id, d))
        .listen((m) => out.add(m.data));
    snapshots.add([(id: 'b1', data: booking('requested'), local: false)]);
    await pumpEventQueue();
    snapshots.add([
      (id: 'b2', data: booking('requested'), local: false),
      (id: 'b3', data: booking('cancelled'), local: true),
      (id: 'b4', data: {'status': 'requested'}, local: false),
    ]);
    await pumpEventQueue();
    expect(out.map((d) => (d['id'], d['silent'])).toList(), [
      ('booking:b1:requested', '1'),
      ('booking:b2:requested', null),
    ]);
    await snapshots.close();
    await sub.cancel();
  });

  // An account switch cancels this stream and waits; it must not hang until
  // another snapshot arrives (an async* generator would).
  test('cancel while waiting for snapshots completes at once', () async {
    final snapshots = StreamController<List<Doc>>();
    final sub = changesOf(snapshots.stream, (_, _) => null).listen((_) {});
    snapshots.add([]);
    await pumpEventQueue();
    await sub.cancel().timeout(const Duration(seconds: 2));
  });
}
