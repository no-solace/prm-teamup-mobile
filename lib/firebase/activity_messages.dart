import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../models/app_user.dart';
import '../models/meeting.dart';
import 'firestore_class_service.dart' show switchDataStream;
import 'firestore_codec.dart';

/// Flow D/E notifications without a server (the Spark plan has no Cloud
/// Functions to send FCM). The app watches the topics and bookings the user
/// can read and turns each change into the same message a push would carry,
/// so FcmNotificationService saves it to the inbox and shows it on the device.
///
/// ponytail: delivered only while the app runs (foreground or alive in the
/// background). Killed-app delivery needs a sender with FCM credentials
/// (Cloud Functions on Blaze, or a free Worker); the message format is the same.
Stream<RemoteMessage> activityMessages(
  Stream<AppUser?> users, {
  FirebaseFirestore? firestore,
}) {
  final db = firestore ?? FirebaseFirestore.instance;
  String key(AppUser? u) => '${u?.uid}|${u?.role}|${u?.classId}|${u?.teamId}';
  return switchDataStream(_distinctBy(users, key), (AppUser? me) {
    if (me == null || me.role == null) return const Stream<RemoteMessage>.empty();
    final topicId = me.topicId;
    // Students may only get their own topic by ID (no query in the rules).
    final topics = me.isMentor
        ? db.collection('topics').where('mentorUid', isEqualTo: me.uid).snapshots().map(_docs)
        : topicId == null
        ? null
        : db.collection('topics').doc(topicId).snapshots().map(
            (d) => [if (d.exists) (id: d.id, data: plainData(d)!, local: d.metadata.hasPendingWrites)],
          );
    final bookings = me.isMentor
        ? db.collection('bookings').where('mentorUid', isEqualTo: me.uid).snapshots()
        : db
              .collection('bookings')
              .where('classId', isEqualTo: me.classId)
              .where('teamId', isEqualTo: me.teamId)
              .snapshots();
    return _merge([
      if (topics != null) changesOf(topics, (id, d) => topicMessage(me, id, d)),
      changesOf(bookings.map(_docs), (id, d) => bookingMessage(me, id, d)),
    ]);
  });
}

typedef Doc = ({String id, Map<String, dynamic> data, bool local});

List<Doc> _docs(QuerySnapshot<Map<String, dynamic>> s) => [
  for (final d in s.docs)
    (id: d.id, data: plainData(d)!, local: d.metadata.hasPendingWrites),
];

/// The first snapshot fills the inbox silently (no banner flood on start);
/// later snapshots announce new events. This device's own writes are skipped.
/// Not async*: a generator only notices cancel at its next yield, which would
/// block switchDataStream on an account switch until another snapshot came.
Stream<RemoteMessage> changesOf(
  Stream<List<Doc>> snapshots,
  RemoteMessage? Function(String id, Map<String, dynamic> data) toMessage,
) {
  var first = true;
  // Rules or a missing index must not break the push pipeline.
  return snapshots.handleError((Object _) {}).expand((docs) {
    final silent = first;
    first = false;
    return [
      for (final doc in docs)
        if (!doc.local)
          if (_safe(() => toMessage(doc.id, doc.data)) case final message?)
            silent
                ? RemoteMessage(
                    data: {...message.data, 'silent': '1'},
                    notification: message.notification,
                    sentTime: message.sentTime,
                  )
                : message,
    ];
  });
}

RemoteMessage? _safe(RemoteMessage? Function() build) {
  try {
    return build();
  } catch (_) {
    return null; // Malformed document: skip it, never break the stream.
  }
}

RemoteMessage _message(
  AppUser me, {
  required String id,
  required String title,
  required String body,
  required String route,
  required DateTime at,
}) => RemoteMessage(
  data: {'uid': me.uid, 'id': id, 'route': route, 'title': title, 'body': body},
  notification: RemoteNotification(title: title, body: body),
  sentTime: at,
);

const _topicLabel = {
  'approved': 'approved',
  'rejected': 'rejected',
  'revision_requested': 'needs revision',
};

/// Mentor: a (re)submitted topic. Students: the mentor's decision.
RemoteMessage? topicMessage(AppUser me, String id, Map<String, dynamic> d) {
  final status = d['status'];
  if (me.isMentor) {
    if (status != 'pending') return null;
    final at = d['submittedAt'] as DateTime;
    return _message(
      me,
      id: 'topic:$id:${at.millisecondsSinceEpoch}',
      title: (d['revisionCount'] as int? ?? 0) > 0 ? 'Topic resubmitted' : 'New topic to review',
      body: '${d['teamName']}: ${d['title']}',
      route: '/topics/$id',
      at: at,
    );
  }
  final label = _topicLabel[status];
  final at = d['reviewedAt'];
  if (label == null || at is! DateTime) return null;
  return _message(
    me,
    id: 'topic:$id:$status:${at.millisecondsSinceEpoch}',
    title: 'Your topic $label',
    body: d['mentorFeedback'] as String? ?? d['title'] as String,
    route: '/topics',
    at: at,
  );
}

/// Mentor: new and cancelled requests. Students: confirmed and cancelled.
RemoteMessage? bookingMessage(AppUser me, String id, Map<String, dynamic> d) {
  final b = MeetingBooking.fromMap(id, d);
  final title = switch ((me.isMentor, b.status)) {
    (true, BookingStatus.requested) => 'New meeting request',
    (false, BookingStatus.confirmed) => 'Meeting confirmed',
    (_, BookingStatus.cancelled) => 'Meeting cancelled',
    _ => null,
  };
  if (title == null) return null;
  final s = b.startTime;
  String two(int n) => n.toString().padLeft(2, '0');
  return _message(
    me,
    id: 'booking:$id:${b.status.name}',
    title: title,
    body: '${b.teamName}: ${b.purpose.label} · ${two(s.day)}/${two(s.month)} ${two(s.hour)}:${two(s.minute)}',
    route: '/schedule/$id',
    at: b.status == BookingStatus.requested && d['createdAt'] is DateTime
        ? d['createdAt'] as DateTime
        : DateTime.now(),
  );
}

Stream<T> _distinctBy<T>(Stream<T> source, String Function(T) key) {
  String? last;
  var seen = false;
  return source.where((value) {
    final k = key(value);
    if (seen && k == last) return false;
    seen = true;
    last = k;
    return true;
  });
}

Stream<T> _merge<T>(List<Stream<T>> streams) {
  final subs = <StreamSubscription<T>>[];
  late final StreamController<T> out;
  var open = streams.length;
  out = StreamController<T>(
    onListen: () {
      if (open == 0) unawaited(out.close());
      for (final s in streams) {
        subs.add(s.listen(out.add, onError: out.addError, onDone: () {
          if (--open == 0) unawaited(out.close());
        }));
      }
    },
    onPause: () {
      for (final s in subs) {
        s.pause();
      }
    },
    onResume: () {
      for (final s in subs) {
        s.resume();
      }
    },
    onCancel: () => Future.wait(subs.map((s) => s.cancel())),
  );
  return out.stream;
}

/// Pushes and app-generated activity messages through one pipeline.
Stream<RemoteMessage> mergeMessages(List<Stream<RemoteMessage>> streams) => _merge(streams);
