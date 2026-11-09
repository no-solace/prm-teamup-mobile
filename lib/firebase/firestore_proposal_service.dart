import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/data_validation.dart';
import '../models/major.dart';
import '../models/proposal.dart';
import '../models/student.dart';
import '../models/team.dart';
import '../services/app_error.dart';
import '../services/proposal_service.dart';
import 'firestore_class_service.dart';

/// Proposal drafts never change the roster. Approval and its short undo are
/// transactions, so concurrent mentors cannot assign the same student twice.
class FirestoreProposalService implements ProposalService {
  FirestoreProposalService({FirebaseFirestore? db, FirebaseAuth? auth})
    : _db = db ?? FirebaseFirestore.instance,
      _auth = auth ?? FirebaseAuth.instance;

  final FirebaseFirestore _db;
  final FirebaseAuth _auth;

  String _uid() =>
      _auth.currentUser?.uid ??
      (throw const PermissionDeniedError('Sign in to access proposals'));

  CollectionReference<Map<String, dynamic>> get _classes =>
      _db.collection('classes');

  DocumentReference<Map<String, dynamic>> _class(String classId) {
    if (!DataValidation.isId(classId)) {
      throw const ValidationError('Invalid class ID');
    }
    return _classes.doc(classId);
  }

  CollectionReference<Map<String, dynamic>> _collection(String classId) =>
      _class(classId).collection('proposals');

  Future<void> _ownsClass(String classId, String uid) async {
    final snapshot = await _class(classId).get();
    if (!snapshot.exists || snapshot.data()?['mentorUid'] != uid) {
      throw const PermissionDeniedError('Class is unavailable');
    }
  }

  Proposal _parse(DocumentSnapshot<Map<String, dynamic>> doc) {
    if (!doc.exists) throw const NotFoundError('Proposal not found');
    return Proposal.fromMap(doc.id, doc.data()!);
  }

  Stream<T> _session<T>(Stream<T> Function(String) open) =>
      switchDataStream(_auth.authStateChanges(), (user) {
        if (user == null) {
          return Stream<T>.error(
            const PermissionDeniedError('Sign in to access proposals'),
          );
        }
        return open(user.uid);
      }).transform(
        StreamTransformer<T, T>.fromHandlers(
          handleError: (error, stack, sink) =>
              sink.addError(_error(error), stack),
        ),
      );

  @override
  Stream<List<Proposal>> watchPending(String classId) => _session(
    (uid) =>
        _collection(classId)
            .where('status', isEqualTo: ProposalStatus.pending.name)
            .snapshots()
            .map(
              (snapshot) => [
                for (final doc in snapshot.docs)
                  if (doc.data()['mentorUid'] == uid) _parse(doc),
              ]..sort((a, b) => a.teamName.compareTo(b.teamName)),
            ),
  );

  @override
  Stream<List<Proposal>> watchAllPending() => _session(
    (uid) => _db
        .collectionGroup('proposals')
        .where('mentorUid', isEqualTo: uid)
        .where('status', isEqualTo: ProposalStatus.pending.name)
        .snapshots()
        .map(
          (snapshot) =>
              [for (final doc in snapshot.docs) _parse(doc)]
                ..sort((a, b) => a.teamName.compareTo(b.teamName)),
        ),
  );

  /// A proposal URL carries only its ID. Resolve it inside owned classes,
  /// avoiding a broad collection-group read that would require another index.
  Future<DocumentReference<Map<String, dynamic>>> _locate(
    String uid,
    String proposalId,
  ) async {
    if (!DataValidation.isId(proposalId)) {
      throw const ValidationError('Invalid proposal ID');
    }
    final classes = await _classes.where('mentorUid', isEqualTo: uid).get();
    final results = await Future.wait([
      for (final room in classes.docs)
        _collection(room.id).doc(proposalId).get(),
    ]);
    final matches = results.where((doc) => doc.exists).toList();
    if (matches.isEmpty) throw const NotFoundError('Proposal not found');
    if (matches.length > 1) {
      throw const ValidationError('Duplicate proposal ID in owned classes');
    }
    return matches.single.reference;
  }

  @override
  Stream<Proposal> watchProposal(String proposalId) => _session(
    (uid) =>
        Stream.fromFuture(_locate(uid, proposalId))
            .asyncExpand((reference) => reference.snapshots().map(_parse)),
  );

  @override
  Future<void> savePending(List<Proposal> proposals) async {
    if (proposals.isEmpty) return;
    try {
      final uid = _uid();
      final classId = proposals.first.classId;
      if (proposals.any(
        (p) =>
            p.classId != classId ||
            p.status != ProposalStatus.pending ||
            !DataValidation.isId(p.id),
      )) {
        throw const ValidationError('Invalid matching proposals');
      }
      await _ownsClass(classId, uid);
      final existing = await _collection(classId).get();
      final known = {for (final d in existing.docs) d.id: d.data()};
      final batch = _db.batch();
      for (final proposal in proposals) {
        final previous = known[proposal.id];
        // Re-running matching must not overwrite a mentor's draft edits.
        if (previous != null) continue;
        batch.set(_collection(classId).doc(proposal.id), proposal.toMap(uid));
      }
      if (_uid() != uid) throw const PermissionDeniedError('Account changed');
      await batch.commit();
    } catch (error) {
      throw _error(error);
    }
  }

  Future<List<Student>> _students(
    Transaction tx,
    String classId,
    List<String> ids,
  ) async {
    final result = <Student>[];
    for (final id in ids) {
      if (!DataValidation.isId(id)) {
        throw const ValidationError('Invalid student ID');
      }
      final snapshot = await tx.get(
        _class(classId).collection('students').doc(id),
      );
      if (!snapshot.exists) {
        throw const NotFoundError('Student missing from class');
      }
      result.add(Student.fromMap(id, classId, snapshot.data()!));
    }
    return result;
  }

  Future<Team> _team(Transaction tx, Proposal proposal) async {
    final snapshot = await tx.get(
      _class(proposal.classId).collection('teams').doc(proposal.teamId),
    );
    if (!snapshot.exists) throw const NotFoundError('Team no longer exists');
    return Team.fromMap(proposal.teamId, proposal.classId, snapshot.data()!);
  }

  void _checkRoster(
    Proposal proposal,
    Team team,
    List<Student> current,
    List<Student> added,
  ) {
    if (team.memberIds.length != proposal.currentMemberIds.length ||
        !team.memberIds.asMap().entries.every(
          (e) =>
              e.value == proposal.currentMemberIds[e.key] &&
              team.majors[e.key] == proposal.currentMajors[e.key],
        )) {
      throw const ValidationError('Team changed. Run matching again');
    }
    if (current.asMap().entries.any(
          (e) =>
              e.value.teamId != team.id ||
              e.value.major != proposal.currentMajors[e.key],
        ) ||
        added.any((s) => s.teamId != null) ||
        added.asMap().entries.any(
          (e) => e.value.major != proposal.addMajors[e.key],
        )) {
      throw const ValidationError(
        'Student assignment changed. Refresh proposal',
      );
    }
  }

  @override
  Future<Proposal> updateMembers(
    String proposalId, {
    required List<String> addStudentIds,
    required List<String> currentMemberIds,
  }) async {
    try {
      final uid = _uid();
      final reference = await _locate(uid, proposalId);
      return await _db.runTransaction((tx) async {
        final snapshot = await tx.get(reference);
        final proposal = _parse(snapshot);
        if (proposal.status != ProposalStatus.pending) {
          throw const ValidationError('Only pending proposals can be edited');
        }
        if (addStudentIds.toSet().length != addStudentIds.length ||
            currentMemberIds.toSet().length != currentMemberIds.length ||
            addStudentIds
                .toSet()
                .intersection(currentMemberIds.toSet())
                .isNotEmpty ||
            addStudentIds.length + currentMemberIds.length >
                TeamRules.maxMembers) {
          throw const ValidationError('Team allows at most 6 distinct members');
        }
        final team = await _team(tx, proposal);
        if (currentMemberIds.join('|') != team.memberIds.join('|')) {
          throw const ValidationError(
            'Existing team members cannot be removed from draft',
          );
        }
        final students = await _students(tx, proposal.classId, addStudentIds);
        if (students.any((s) => s.hasTeam)) {
          throw const ValidationError(
            'One or more students already have a team',
          );
        }
        final updatedMap = {
          ...proposal.toMap(uid),
          'currentMemberIds': team.memberIds,
          'currentMajors': [for (final major in team.majors) major.code],
          'addStudentIds': addStudentIds,
          'addMajors': [for (final student in students) student.major.code],
        };
        final updated = Proposal.fromMap(proposalId, updatedMap);
        tx.update(reference, updatedMap);
        return updated;
      });
    } catch (error) {
      throw _error(error);
    }
  }

  @override
  Future<void> approve(String proposalId) async {
    try {
      final uid = _uid();
      final reference = await _locate(uid, proposalId);
      await _db.runTransaction((tx) async {
        final proposal = _parse(await tx.get(reference));
        if (proposal.status != ProposalStatus.pending) {
          throw const ValidationError('This proposal has already been handled');
        }
        if (!proposal.canApprove) {
          throw const ValidationError('Team requires 5–6 members');
        }
        final team = await _team(tx, proposal);
        final current = await _students(
          tx,
          proposal.classId,
          proposal.currentMemberIds,
        );
        final added = await _students(
          tx,
          proposal.classId,
          proposal.addStudentIds,
        );
        _checkRoster(proposal, team, current, added);
        tx.update(_class(proposal.classId).collection('teams').doc(team.id), {
          'memberIds': [...team.memberIds, ...proposal.addStudentIds],
          'majors': [
            for (final major in team.majors) major.code,
            for (final major in proposal.addMajors) major.code,
          ],
          'rosterChangeProposalId': proposalId,
        });
        for (final student in added) {
          tx.update(
            _class(proposal.classId).collection('students').doc(student.mssv),
            {'teamId': team.id},
          );
        }
        tx.update(reference, {
          'status': 'approved',
          'approvedAt': FieldValue.serverTimestamp(),
        });
      });
    } catch (error) {
      throw _error(error);
    }
  }

  @override
  Future<void> undoApprove(String proposalId) async {
    try {
      final uid = _uid();
      final reference = await _locate(uid, proposalId);
      await _db.runTransaction((tx) async {
        final snapshot = await tx.get(reference);
        final proposal = _parse(snapshot);
        final approvedAt = snapshot.data()?['approvedAt'];
        if (proposal.status != ProposalStatus.approved ||
            approvedAt is! Timestamp ||
            DateTime.now().difference(approvedAt.toDate()) >
                const Duration(seconds: 5)) {
          throw const ValidationError('Undo period has expired');
        }
        final team = await _team(tx, proposal);
        final expected = [
          ...proposal.currentMemberIds,
          ...proposal.addStudentIds,
        ];
        if (team.memberIds.join('|') != expected.join('|') ||
            team.majors.map((m) => m.code).join('|') !=
                [
                  ...proposal.currentMajors,
                  ...proposal.addMajors,
                ].map((m) => m.code).join('|')) {
          throw const ValidationError('Team changed since approval');
        }
        final added = await _students(
          tx,
          proposal.classId,
          proposal.addStudentIds,
        );
        if (added.any((student) => student.teamId != team.id)) {
          throw const ValidationError(
            'Student assignments changed since approval',
          );
        }
        tx.update(_class(proposal.classId).collection('teams').doc(team.id), {
          'memberIds': proposal.currentMemberIds,
          'majors': [for (final major in proposal.currentMajors) major.code],
          'rosterChangeProposalId': null,
        });
        for (final student in added) {
          tx.update(
            _class(proposal.classId).collection('students').doc(student.mssv),
            {'teamId': null},
          );
        }
        tx.update(reference, {
          'status': 'pending',
          'approvedAt': FieldValue.delete(),
        });
      });
    } catch (error) {
      throw _error(error);
    }
  }

  @override
  Future<void> discard(String proposalId) async {
    try {
      final uid = _uid();
      final reference = await _locate(uid, proposalId);
      await _db.runTransaction((tx) async {
        final p = _parse(await tx.get(reference));
        if (p.status != ProposalStatus.pending) {
          throw const ValidationError(
            'Only pending proposals can be discarded',
          );
        }
        tx.update(reference, {'status': 'discarded'});
      });
    } catch (error) {
      throw _error(error);
    }
  }

  @override
  Future<Proposal> createManual({
    required String classId,
    required String teamId,
    required List<String> addStudentIds,
  }) async {
    try {
      final uid = _uid();
      await _ownsClass(classId, uid);
      if (!DataValidation.isId(teamId) ||
          addStudentIds.isEmpty ||
          addStudentIds.length != addStudentIds.toSet().length) {
        throw const ValidationError('Select at least one available student');
      }
      final reference = _collection(classId).doc();
      return await _db.runTransaction((tx) async {
        final snapshot = await tx.get(
          _class(classId).collection('teams').doc(teamId),
        );
        if (!snapshot.exists) throw const NotFoundError('Team not found');
        final team = Team.fromMap(teamId, classId, snapshot.data()!);
        if (team.size + addStudentIds.length > TeamRules.maxMembers) {
          throw const ValidationError('Team would exceed 6 members');
        }
        final students = await _students(tx, classId, addStudentIds);
        if (students.any((s) => s.hasTeam || team.memberIds.contains(s.mssv))) {
          throw const ValidationError('Student is already assigned');
        }
        final majors = [...team.majors, ...students.map((s) => s.major)];
        final proposal = Proposal(
          id: reference.id,
          classId: classId,
          teamId: teamId,
          teamName: team.name,
          currentMemberIds: team.memberIds,
          currentMajors: team.majors,
          addStudentIds: addStudentIds,
          addMajors: [for (final student in students) student.major],
          fit: majors.toSet().length >= TeamRules.targetMajors
              ? ProposalFit.strong
              : ProposalFit.good,
          reasons: const ['Members selected by mentor'],
          source: ProposalSource.manual,
        );
        tx.set(reference, proposal.toMap(uid));
        return proposal;
      });
    } catch (error) {
      throw _error(error);
    }
  }

  AppError _error(Object error) {
    if (error is AppError) return error;
    if (error is FormatException || error is TypeError) {
      return const ValidationError('Stored proposal data is invalid');
    }
    if (error is FirebaseException) {
      return switch (error.code) {
        'permission-denied' ||
        'unauthenticated' => const PermissionDeniedError(),
        'unavailable' => const NetworkError(),
        'deadline-exceeded' => const TimeoutAppError(),
        'not-found' => const NotFoundError(),
        'aborted' => const ValidationError(
          'Data changed. Refresh and try again',
        ),
        _ => UnknownError('Could not save proposal', error),
      };
    }
    return UnknownError('Could not save proposal', error);
  }
}
