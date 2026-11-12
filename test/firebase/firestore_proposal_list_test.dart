// Firebase's sealed reference interfaces are mocked here to verify service calls.
// ignore_for_file: subtype_of_sealed_class

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:teamup_exe/firebase/firestore_proposal_service.dart';
import 'package:teamup_exe/services/fakes/sample_data.dart';

class _Db extends Mock implements FirebaseFirestore {}

class _Auth extends Mock implements FirebaseAuth {}

class _User extends Mock implements User {}

class _Query extends Mock implements Query<Map<String, dynamic>> {}

class _QuerySnapshot extends Mock
    implements QuerySnapshot<Map<String, dynamic>> {}

class _Doc extends Mock implements QueryDocumentSnapshot<Map<String, dynamic>> {}

_Doc _doc(String id, Map<String, dynamic> data) {
  final doc = _Doc();
  when(() => doc.id).thenReturn(id);
  when(() => doc.exists).thenReturn(true);
  when(() => doc.data()).thenReturn(data);
  return doc;
}

/// Review finding F8: one malformed proposal must not fail the whole list.
void main() {
  test('watchAllPending skips a malformed document and keeps the rest', () async {
    final db = _Db();
    final auth = _Auth();
    final user = _User();
    final query = _Query();
    final snapshot = _QuerySnapshot();
    final students = SampleData.students();
    final good = SampleData.proposals(students, SampleData.teams(students)).first;

    when(() => user.uid).thenReturn('mentor');
    when(() => auth.currentUser).thenReturn(user);
    when(() => auth.authStateChanges()).thenAnswer((_) => Stream.value(user));
    when(() => db.collectionGroup('proposals')).thenReturn(query);
    when(
      () => query.where(any(), isEqualTo: any(named: 'isEqualTo')),
    ).thenReturn(query);
    when(() => query.snapshots()).thenAnswer((_) => Stream.value(snapshot));
    // Build the docs first: mocktail forbids stubbing inside a stub response.
    final docs = [
      _doc(good.id, good.toMap('mentor')),
      _doc('broken-field', {'mentorUid': 'mentor', 'status': 'pending'}),
      _doc('broken-major', {
        ...good.toMap('mentor'),
        'currentMajors': ['XX'],
      }),
    ];
    when(() => snapshot.docs).thenReturn(docs);

    final service = FirestoreProposalService(db: db, auth: auth);
    final list = await service.watchAllPending().first;

    expect(list.map((p) => p.id), [good.id]);
  });
}
