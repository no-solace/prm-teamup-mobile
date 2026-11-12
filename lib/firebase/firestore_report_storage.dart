import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/report.dart';
import '../services/app_error.dart';
import '../services/storage_service.dart';
import 'firestore_class_service.dart';

/// Reports in Firestore: metadata in reports/{id}, bytes in reports/{id}/files/pdf.
/// ponytail: one document per file caps PDFs at ~900 KB; chunk or move to a
/// bucket if reports ever grow past that.
class FirestoreReportStorage implements StorageService {
  FirestoreReportStorage({FirebaseFirestore? firestore, FirebaseAuth? auth})
    : _firestore = firestore ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String _uid() =>
      _auth.currentUser?.uid ??
      (throw const PermissionDeniedError('Sign in to export reports'));

  DocumentReference<Map<String, dynamic>> _file(String reportId) =>
      _firestore.collection('reports').doc(reportId).collection('files').doc('pdf');

  @override
  Stream<UploadEvent> uploadReport({
    required String classId,
    required List<int> bytes,
  }) async* {
    final uid = _uid();
    if (bytes.isEmpty || bytes.length > StorageService.maxBytes) {
      throw const ValidationError('PDF must be between 1 byte and 900 KB');
    }
    final classDoc = await _firestore.collection('classes').doc(classId).get();
    if (classDoc.data()?['mentorUid'] != uid) {
      throw const PermissionDeniedError('Class is unavailable');
    }
    yield const UploadProgress(0);
    final reportDoc = _firestore.collection('reports').doc();
    final sizeKb = (bytes.length / 1024).ceil();
    // One commit: metadata never exists without its file (finding F5).
    await (_firestore.batch()
          ..set(reportDoc, {
            'ownerUid': uid,
            'classId': classId,
            'sizeKb': sizeKb,
            'createdAt': FieldValue.serverTimestamp(),
          })
          ..set(_file(reportDoc.id), {'bytes': Blob(Uint8List.fromList(bytes))}))
        .commit();
    yield const UploadProgress(1);
    yield UploadDone(
      Report(
        id: reportDoc.id,
        ownerUid: uid,
        classId: classId,
        sizeKb: sizeKb,
        createdAt: DateTime.now(),
      ),
    );
  }

  @override
  Stream<List<Report>> watchMyReports() =>
      switchDataStream(_auth.authStateChanges(), (user) {
        if (user == null) {
          return Stream<List<Report>>.error(
            const PermissionDeniedError('Sign in to view reports'),
          );
        }
        return _firestore
            .collection('reports')
            .where('ownerUid', isEqualTo: user.uid)
            .snapshots()
            .map((snapshot) {
              final reports = [
                for (final doc in snapshot.docs)
                  Report(
                    id: doc.id,
                    ownerUid: doc.data()['ownerUid'] as String,
                    classId: doc.data()['classId'] as String,
                    sizeKb: doc.data()['sizeKb'] as int,
                    createdAt:
                        (doc.data()['createdAt'] as Timestamp?)?.toDate() ??
                        DateTime.now(),
                  ),
              ];
              reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));
              return reports;
            });
      });

  @override
  Future<List<int>> downloadReport(Report report) async {
    final uid = _uid();
    if (report.ownerUid != uid) {
      throw const PermissionDeniedError('Report does not belong to this mentor');
    }
    final bytes = (await _file(report.id).get()).data()?['bytes'];
    if (bytes is! Blob) throw const NotFoundError('Report file is unavailable');
    if (_uid() != uid) throw const PermissionDeniedError('Account changed');
    return bytes.bytes;
  }
}
