import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../models/meeting.dart';
import '../services/app_error.dart';
import '../services/meeting_service.dart';
import 'firestore_codec.dart';

/// minutes/{bookingId}; signed PDF in Storage minutes/{bookingId}/minutes.pdf.
class FirestoreMeetingService implements MeetingService {
  FirestoreMeetingService({
    FirebaseFirestore? db,
    FirebaseAuth? auth,
    FirebaseStorage? storage,
  }) : _db = db ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance,
       _storage = storage ?? FirebaseStorage.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;
  final FirebaseStorage _storage;

  DocumentReference<Map<String, dynamic>> _ref(String id) =>
      _db.collection('minutes').doc(id);

  @override
  Stream<MeetingMinutes?> watchMinutes(String bookingId) => appErrors(
    _ref(bookingId).snapshots().map(
      (d) => d.exists ? MeetingMinutes.fromMap(d.id, plainData(d)!) : null,
    ),
    'minutes',
  );

  @override
  Future<void> saveMinutes(
    MeetingBooking booking, {
    required String summary,
    required List<ActionItem> actionItems,
  }) => guardWrite('minutes', () async {
    final text = summary.trim();
    if (text.isEmpty || text.length > 4000) {
      throw const ValidationError('Summary is required (max 4000 characters)');
    }
    if (actionItems.length > MeetingMinutes.maxActionItems) {
      throw const ValidationError('At most 20 action items');
    }
    if (!actionItems.every((i) => i.isComplete)) {
      throw const ValidationError('Each action item needs a task, an assignee and a deadline');
    }
    if (!booking.canHaveMinutes) {
      throw const ValidationError('Minutes are written after a confirmed meeting');
    }
    final ref = _ref(booking.id);
    final uid = currentUid(_auth);
    final items = [for (final i in actionItems) i.toMap()];
    await _db.runTransaction((tx) async {
      final existing = (await tx.get(ref)).data();
      if (existing?['isSignedByMentor'] == true) {
        throw const ValidationError('Signed minutes can no longer be edited');
      }
      if (existing == null) {
        tx.set(ref, {
          'bookingId': booking.id,
          'mentorUid': booking.mentorUid,
          'classId': booking.classId,
          'teamId': booking.teamId,
          'teamName': booking.teamName,
          'meetingDate': Timestamp.fromDate(booking.startTime),
          'summary': text,
          'actionItems': items,
          'mentorRating': null,
          'isSignedByMentor': false,
          'createdBy': uid,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      } else {
        tx.update(ref, {
          'summary': text,
          'actionItems': items,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
    });
  });

  @override
  Future<void> sign(String minutesId, int rating) => guardWrite('minutes', () async {
    if (rating < 1 || rating > 5) throw const ValidationError('Rate progress from 1 to 5 stars');
    await _ref(minutesId).update({
      'mentorRating': rating,
      'isSignedByMentor': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  });

  @override
  Future<String> exportPdf(MeetingMinutes minutes) => guardWrite('minutes', () async {
    if (!minutes.isSignedByMentor) {
      throw const ValidationError('Export after the mentor signs the minutes');
    }
    final bytes = await buildMinutesPdf(minutes);
    final path = 'minutes/${minutes.id}/minutes.pdf';
    final file = _storage.ref(path);
    await file.putData(bytes, SettableMetadata(contentType: 'application/pdf'));
    final url = await file.getDownloadURL();
    await _ref(minutes.id).update({'pdfStoragePath': path, 'pdfDownloadUrl': url});
    return url;
  });
}

/// Vietnamese-capable PDF (same bundled font as the roster report).
Future<Uint8List> buildMinutesPdf(MeetingMinutes m) async {
  final regular = pw.Font.ttf(await rootBundle.load('assets/fonts/BeVietnamPro-Regular.ttf'));
  final bold = pw.Font.ttf(await rootBundle.load('assets/fonts/BeVietnamPro-Bold.ttf'));
  String day(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
  final pdf = pw.Document()
    ..addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        theme: pw.ThemeData.withFont(base: regular, bold: bold),
        build: (_) => [
          pw.Text('BIÊN BẢN HỌP', style: pw.TextStyle(font: bold, fontSize: 18)),
          pw.SizedBox(height: 8),
          pw.Text('Nhóm: ${m.teamName}'),
          pw.Text('Ngày họp: ${day(m.meetingDate)}'),
          pw.SizedBox(height: 16),
          pw.Header(level: 1, text: 'Tóm tắt'),
          pw.Text(m.summary),
          pw.SizedBox(height: 16),
          pw.Header(level: 1, text: 'Đầu việc'),
          if (m.actionItems.isEmpty) pw.Text('Không có đầu việc.'),
          if (m.actionItems.isNotEmpty)
            pw.TableHelper.fromTextArray(
              headers: const ['STT', 'Công việc', 'Phụ trách', 'Hạn'],
              data: [
                for (var i = 0; i < m.actionItems.length; i++)
                  [
                    '${i + 1}',
                    m.actionItems[i].task,
                    m.actionItems[i].assignee,
                    m.actionItems[i].deadline,
                  ],
              ],
            ),
          pw.SizedBox(height: 16),
          pw.Text('Đánh giá tiến độ của mentor: ${m.mentorRating ?? '-'}/5'),
          pw.Text(m.isSignedByMentor ? 'Mentor đã ký duyệt.' : 'Chưa ký duyệt.'),
        ],
      ),
    );
  return pdf.save();
}
