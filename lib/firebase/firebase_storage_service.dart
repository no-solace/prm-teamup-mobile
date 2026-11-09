import 'dart:async';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

import '../models/report.dart';
import '../services/app_error.dart';
import '../services/storage_service.dart';
import 'firestore_class_service.dart';

class FirebaseStorageService implements StorageService {
  FirebaseStorageService({
    FirebaseStorage? storage,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _storage = storage ?? FirebaseStorage.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  final FirebaseStorage _storage;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  String _uid() =>
      _auth.currentUser?.uid ??
      (throw const PermissionDeniedError('Sign in to export reports'));

  @override
  Stream<UploadEvent> uploadReport({
    required String classId,
    required List<int> bytes,
  }) async* {
    final uid = _uid();
    if (bytes.isEmpty || bytes.length > 5 * 1024 * 1024) {
      throw const ValidationError('PDF must be between 1 byte and 5 MB');
    }
    final classDoc = await _firestore.collection('classes').doc(classId).get();
    if (classDoc.data()?['mentorUid'] != uid) {
      throw const PermissionDeniedError('Class is unavailable');
    }
    final reportDoc = _firestore.collection('reports').doc();
    final path = 'reports/$uid/${reportDoc.id}.pdf';
    final file = _storage.ref().child(path);
    final upload = file.putData(
      Uint8List.fromList(bytes),
      SettableMetadata(contentType: 'application/pdf'),
    );
    await for (final snapshot in upload.snapshotEvents) {
      if (snapshot.totalBytes > 0) {
        yield UploadProgress(snapshot.bytesTransferred / snapshot.totalBytes);
      }
    }
    await upload;
    if (_uid() != uid) {
      throw const PermissionDeniedError('Account changed during upload');
    }
    final url = await file.getDownloadURL();
    final sizeKb = (bytes.length / 1024).ceil();
    try {
      await reportDoc.set({
        'ownerUid': uid,
        'classId': classId,
        'storagePath': path,
        'downloadUrl': url,
        'sizeKb': sizeKb,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      try {
        await file.delete();
      } catch (_) {
        // Cleanup is best-effort if the user has signed out.
      }
      rethrow;
    }
    yield UploadDone(
      Report(
        id: reportDoc.id,
        ownerUid: uid,
        classId: classId,
        storagePath: path,
        downloadUrl: url,
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
                    storagePath: doc.data()['storagePath'] as String,
                    downloadUrl: doc.data()['downloadUrl'] as String,
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
    if (report.ownerUid != uid ||
        !report.storagePath.startsWith('reports/$uid/')) {
      throw const PermissionDeniedError(
        'Report does not belong to this mentor',
      );
    }
    final bytes = await _storage
        .ref()
        .child(report.storagePath)
        .getData(5 * 1024 * 1024);
    if (bytes == null) throw const NotFoundError('Report file is unavailable');
    if (_uid() != uid) throw const PermissionDeniedError('Account changed');
    return bytes;
  }
}
