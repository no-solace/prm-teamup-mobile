import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import '../models/meeting.dart';
import '../services/app_error.dart';
import '../services/booking_service.dart';
import 'firestore_codec.dart';

/// mentors/{uid}/slots/{slotId} + bookings/{bookingId}. Slot and booking
/// always change together in one transaction (rules check both sides).
class FirestoreBookingService implements BookingService {
  FirestoreBookingService({FirebaseFirestore? db, FirebaseAuth? auth})
    : _db = db ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> _slots(String mentorUid) =>
      _db.collection('mentors').doc(mentorUid).collection('slots');
  CollectionReference<Map<String, dynamic>> get _bookings => _db.collection('bookings');

  List<MeetingBooking> _bookingList(QuerySnapshot<Map<String, dynamic>> s) =>
      [for (final d in s.docs) MeetingBooking.fromMap(d.id, plainData(d)!)]
        ..sort((a, b) => a.startTime.compareTo(b.startTime));

  @override
  Stream<List<MentorSlot>> watchSlots(String mentorUid) => appErrors(
    _slots(mentorUid)
        .where('startTime', isGreaterThanOrEqualTo: Timestamp.now())
        .snapshots()
        .map(
          (s) => [for (final d in s.docs) MentorSlot.fromMap(d.id, mentorUid, plainData(d)!)]
            ..sort((a, b) => a.startTime.compareTo(b.startTime)),
        ),
    'schedule',
  );

  @override
  Future<void> addSlot(DateTime start, Duration duration) => guardWrite('schedule', () async {
    if (start.isBefore(DateTime.now())) {
      throw const ValidationError('Pick a time in the future');
    }
    if (duration.inMinutes < 15 || duration.inMinutes > 120) {
      throw const ValidationError('A slot lasts 15 to 120 minutes');
    }
    final end = start.add(duration);
    // ponytail: read-then-write, two devices adding at once can still overlap.
    final earlier = await _slots(currentUid(_auth))
        .where('startTime', isLessThan: Timestamp.fromDate(end))
        .get();
    if (earlier.docs.any((d) => (d.data()['endTime'] as Timestamp).toDate().isAfter(start))) {
      throw const ValidationError('This time overlaps one of your slots');
    }
    await _slots(currentUid(_auth)).add({
      'startTime': Timestamp.fromDate(start),
      'endTime': Timestamp.fromDate(end),
      'status': 'available',
      'bookingId': null,
    });
  });

  @override
  Future<void> deleteSlot(String slotId) => guardWrite('schedule', () async {
    final ref = _slots(currentUid(_auth)).doc(slotId);
    if ((await ref.get()).data()?['status'] != 'available') {
      throw const ValidationError('Decline the booking before removing this slot');
    }
    await ref.delete();
  });

  @override
  Stream<List<MeetingBooking>> watchMentorBookings() => appErrors(
    _bookings.where('mentorUid', isEqualTo: currentUid(_auth)).snapshots().map(_bookingList),
    'schedule',
  );

  @override
  Stream<List<MeetingBooking>> watchTeamBookings(AppUser student) => appErrors(
    _bookings
        .where('classId', isEqualTo: student.classId)
        .where('teamId', isEqualTo: student.teamId)
        .snapshots()
        .map(_bookingList),
    'schedule',
  );

  @override
  Stream<MeetingBooking> watchBooking(String bookingId) => appErrors(
    _bookings.doc(bookingId).snapshots().map((d) {
      if (!d.exists) throw const NotFoundError('Meeting not found');
      return MeetingBooking.fromMap(d.id, plainData(d)!);
    }),
    'schedule',
  );

  @override
  Future<void> book(AppUser leader, MentorSlot slot, MeetingPurpose purpose) =>
      guardWrite('schedule', () async {
        if (!leader.isLeader || leader.mentorUid != slot.mentorUid) {
          throw const PermissionDeniedError('Only the team leader can book');
        }
        final team = await _db
            .collection('classes')
            .doc(leader.classId)
            .collection('teams')
            .doc(leader.teamId)
            .get();
        final teamName = team.data()?['name'];
        if (teamName is! String) throw const NotFoundError('Team not found');
        final slotRef = _slots(slot.mentorUid).doc(slot.id);
        final bookingRef = _bookings.doc();
        await _db.runTransaction((tx) async {
          final current = await tx.get(slotRef);
          if (current.data()?['status'] != 'available') {
            throw const ValidationError('This slot was just taken. Pick another one');
          }
          tx.update(slotRef, {'status': 'booked', 'bookingId': bookingRef.id});
          tx.set(bookingRef, {
            'slotId': slot.id,
            'mentorUid': slot.mentorUid,
            'classId': leader.classId,
            'teamId': leader.teamId,
            'teamName': teamName,
            'purpose': purpose.code,
            'status': 'requested',
            'startTime': current.data()!['startTime'],
            'endTime': current.data()!['endTime'],
            'requestedBy': leader.uid,
            'createdAt': FieldValue.serverTimestamp(),
          });
        });
      });

  Future<void> _setStatus(
    String bookingId,
    String status, {
    Map<String, dynamic> extra = const {},
    bool freeSlot = false,
  }) => guardWrite('schedule', () async {
    final ref = _bookings.doc(bookingId);
    await _db.runTransaction((tx) async {
      final booking = (await tx.get(ref)).data();
      if (booking == null) throw const NotFoundError('Meeting not found');
      final from = booking['status'];
      final allowed = switch (status) {
        'confirmed' => from == 'requested',
        'cancelled' => from == 'requested' || from == 'confirmed',
        'completed' => from == 'confirmed',
        _ => false,
      };
      if (!allowed) throw ValidationError('A $from meeting cannot become $status');
      if (freeSlot) {
        final slotRef = _slots(booking['mentorUid'] as String).doc(booking['slotId'] as String);
        tx.update(slotRef, {'status': 'available', 'bookingId': null});
      }
      tx.update(ref, {'status': status, ...extra});
    });
  });

  @override
  Future<void> confirm(String bookingId, String meetUrl) {
    final url = meetUrl.trim();
    if (!MeetingBooking.meetUrlPattern.hasMatch(url)) {
      return Future.error(
        const ValidationError('Paste a Google Meet link like https://meet.google.com/abc-defg-hij'),
      );
    }
    return _setStatus(bookingId, 'confirmed', extra: {'meetUrl': url});
  }

  @override
  Future<void> cancel(String bookingId) => _setStatus(bookingId, 'cancelled', freeSlot: true);

  @override
  Future<void> complete(String bookingId) => _setStatus(bookingId, 'completed');
}
