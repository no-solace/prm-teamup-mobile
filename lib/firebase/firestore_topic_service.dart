import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';
import '../models/project_topic.dart';
import '../services/app_error.dart';
import '../services/topic_service.dart';
import 'firestore_codec.dart';

/// topics/{classId}_{teamId}; the outline bytes in topics/{id}/files/outline.
class FirestoreTopicService implements TopicService {
  FirestoreTopicService({FirebaseFirestore? db, FirebaseAuth? auth})
    : _db = db ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  CollectionReference<Map<String, dynamic>> get _topics => _db.collection('topics');
  DocumentReference<Map<String, dynamic>> _outline(String topicId) =>
      _topics.doc(topicId).collection('files').doc('outline');

  static const _contentTypes = {
    'pdf': 'application/pdf',
    'docx': 'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
  };

  @override
  Stream<List<ProjectTopic>> watchMentorTopics() => appErrors(
    _topics.where('mentorUid', isEqualTo: currentUid(_auth)).snapshots().map(
      (s) => [for (final d in s.docs) ProjectTopic.fromMap(d.id, plainData(d)!)]
        // Waiting topics first, then newest.
        ..sort((a, b) {
          final waiting = (b.status == TopicStatus.pending ? 1 : 0) -
              (a.status == TopicStatus.pending ? 1 : 0);
          return waiting != 0 ? waiting : b.submittedAt.compareTo(a.submittedAt);
        }),
    ),
    'topic',
  );

  @override
  Stream<ProjectTopic?> watchTopic(String topicId) => appErrors(
    _topics.doc(topicId).snapshots().map(
      (d) => d.exists ? ProjectTopic.fromMap(d.id, plainData(d)!) : null,
    ),
    'topic',
  );

  static String _text(String value, String label, int max) {
    final v = value.trim();
    if (v.isEmpty || v.length > max) {
      throw ValidationError('$label is required (max $max characters)');
    }
    return v;
  }

  @override
  Future<void> submit(
    AppUser leader, {
    required String title,
    required String description,
    required String techStack,
    TopicAttachment? attachment,
    required int maxRevisions,
  }) => guardWrite('topic', () async {
    final topicId = leader.topicId;
    if (!leader.isLeader || topicId == null || leader.uid != currentUid(_auth)) {
      throw const PermissionDeniedError('Only the team leader can submit a topic');
    }
    final fields = <String, dynamic>{
      'title': _text(title, 'Title', 200),
      'description': _text(description, 'Summary', 4000),
      'techStack': _text(techStack, 'Tech stack', 300),
    };
    final ref = _topics.doc(topicId);
    final existing = (await ref.get()).data();
    final status = existing?['status'];
    final revisions = existing?['revisionCount'] as int? ?? 0;
    // Editing a pending topic is free; resubmitting after a decision counts.
    final resubmit = existing != null && status != 'pending';
    if (status == 'approved') {
      throw const ValidationError('An approved topic can no longer be changed');
    }
    if (resubmit && revisions >= maxRevisions) {
      throw ValidationError('Revision limit reached ($maxRevisions). Contact your mentor.');
    }

    if (attachment != null) {
      final ext = attachment.fileName.split('.').last.toLowerCase();
      final type = _contentTypes[ext];
      if (type == null) throw const ValidationError('Attach a .pdf or .docx outline');
      if (attachment.bytes.isEmpty || attachment.bytes.length > TopicAttachment.maxBytes) {
        throw const ValidationError('Outline must be between 1 byte and 900 KB');
      }
      // Written before the topic; a failed topic write just leaves the file
      // to be replaced by the next submission.
      await _outline(topicId).set({
        'contentType': type,
        'bytes': Blob(Uint8List.fromList(attachment.bytes)),
      });
      final name = attachment.fileName.trim();
      fields['attachmentName'] = name.length > 200 ? name.substring(name.length - 200) : name;
    }

    fields['status'] = 'pending';
    fields['submittedAt'] = FieldValue.serverTimestamp();
    if (existing == null) {
      final team = await _db
          .collection('classes')
          .doc(leader.classId)
          .collection('teams')
          .doc(leader.teamId)
          .get();
      final teamName = team.data()?['name'];
      if (teamName is! String) throw const NotFoundError('Team not found');
      await ref.set({
        ...fields,
        'classId': leader.classId,
        'teamId': leader.teamId,
        'teamName': teamName,
        'mentorUid': leader.mentorUid,
        'leaderUid': leader.uid,
        'revisionCount': 0,
      });
    } else {
      await ref.update({
        ...fields,
        'revisionCount': resubmit ? revisions + 1 : revisions,
        'mentorFeedback': FieldValue.delete(),
      });
    }
  });

  @override
  Future<void> review(String topicId, TopicStatus decision, String feedback) =>
      guardWrite('topic', () async {
        if (decision == TopicStatus.pending) {
          throw const ValidationError('Choose approve, reject or request revision');
        }
        final note = feedback.trim();
        if (decision != TopicStatus.approved && note.isEmpty) {
          throw const ValidationError('Add feedback so the team knows what to change');
        }
        if (note.length > 2000) throw const ValidationError('Feedback is too long');
        await _topics.doc(topicId).update({
          'status': decision.code,
          'mentorFeedback': note.isEmpty ? FieldValue.delete() : note,
          'reviewedAt': FieldValue.serverTimestamp(),
        });
      });

  @override
  Future<List<int>> downloadOutline(String topicId) => guardWrite('topic', () async {
    final bytes = (await _outline(topicId).get()).data()?['bytes'];
    if (bytes is! Blob) throw const NotFoundError('The outline file is missing');
    return bytes.bytes;
  });
}
