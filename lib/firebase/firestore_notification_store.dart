import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/app_notification.dart';
import '../services/notification_store.dart';

class FirestoreNotificationStore implements NotificationStore {
  FirestoreNotificationStore({FirebaseFirestore? firestore})
    : _db = firestore ?? FirebaseFirestore.instance;
  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> _inbox(String uid) =>
      _db.collection('users').doc(uid).collection('notifications');

  @override
  Stream<List<AppNotification>> watch(String uid) => _inbox(uid)
      .orderBy('receivedAt', descending: true)
      .limit(100)
      .snapshots()
      .map(
        (snapshot) => snapshot.docs
            .map((doc) {
              final data = doc.data();
              return AppNotification(
                id: doc.id,
                title: data['title'] is String
                    ? data['title'] as String
                    : 'TeamUp EXE',
                body: data['body'] is String ? data['body'] as String : '',
                route:
                    NotificationRoutes.isAllowed(
                      data['route'] is String ? data['route'] as String : null,
                    )
                    ? data['route'] as String
                    : null,
                receivedAt: data['receivedAt'] is Timestamp
                    ? (data['receivedAt'] as Timestamp).toDate()
                    : DateTime.fromMillisecondsSinceEpoch(0),
                read: data['read'] == true,
              );
            })
            .toList(growable: false),
      );

  @override
  Future<void> save(String uid, AppNotification notification) async {
    // Transaction preserves an existing read flag when the same FCM ID is
    // delivered again (receive + tap). Existing notifications are immutable
    // apart from read status, as required by Firestore rules.
    final doc = _inbox(uid).doc(notification.id);
    await _db.runTransaction((transaction) async {
      final existing = await transaction.get(doc);
      if (existing.exists) {
        if (notification.read && existing.data()?['read'] != true) {
          transaction.update(doc, {'read': true});
        }
        return;
      }
      transaction.set(doc, {
        'title': notification.title,
        'body': notification.body,
        'route': notification.route,
        'receivedAt': Timestamp.fromDate(notification.receivedAt),
        'read': notification.read,
      });
    });
  }

  @override
  Future<void> markRead(String uid, String id) =>
      _inbox(uid).doc(id).update({'read': true});

  // Encoding avoids slash-containing tokens becoming nested document paths.
  DocumentReference<Map<String, dynamic>> _token(String uid, String token) =>
      _db
          .collection('users')
          .doc(uid)
          .collection('fcmTokens')
          .doc(base64Url.encode(utf8.encode(token)));

  @override
  Future<void> saveToken(String uid, String token) => _token(uid, token).set({
    'token': token,
    'platform': 'android',
    'updatedAt': FieldValue.serverTimestamp(),
  });

  @override
  Future<void> removeToken(String uid, String token) =>
      _token(uid, token).delete();
}
