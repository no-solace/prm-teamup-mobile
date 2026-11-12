import { readFileSync } from 'node:fs';
import { after, before, beforeEach, test } from 'node:test';
import assert from 'node:assert/strict';
import { initializeTestEnvironment, assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { collection, collectionGroup, deleteDoc, deleteField, doc, getDoc, getDocs,
  query, runTransaction, serverTimestamp, setDoc, Timestamp, updateDoc, where, writeBatch } from 'firebase/firestore';

const projectId = 'demo-teamup-data';
let env;
const room = (owner = 'alice') => ({ name: 'EXE101', mentorUid: owner, createdAt: serverTimestamp() });
const student = { fullName: 'Student A', major: 'SE', teamId: null };
const team = { name: 'Group 1', memberIds: ['S1'], majors: ['SE'] };
const pending = () => ({ classId: 'a', mentorUid: 'alice', teamId: '1', teamName: 'Group 1',
  currentMemberIds: ['S1', 'S2', 'S3'], currentMajors: ['SE', 'SE', 'AI'],
  addStudentIds: ['S4', 'S5'], addMajors: ['MKT', 'GD'], fit: 'strong',
  reasons: ['Team reaches four majors'], status: 'pending', source: 'ai' });
const assertDeniedByRule = async (operation) => {
  const error = await assertFails(operation);
  assert.doesNotMatch(error.message, /maximum of 1000 expressions/i);
};
const db = (uid = 'alice') => env.authenticatedContext(uid).firestore();
const seedProposalRoster = () => env.withSecurityRulesDisabled(async (context) => {
  const admin = context.firestore();
  const batch = writeBatch(admin);
  batch.set(doc(admin, 'classes/a/teams/1'), {
    name: 'Group 1', memberIds: ['S1', 'S2', 'S3'], majors: ['SE', 'SE', 'AI'],
  });
  for (const id of ['S1', 'S2', 'S3']) {
    batch.set(doc(admin, `classes/a/students/${id}`), { ...student, teamId: '1', major: id === 'S3' ? 'AI' : 'SE' });
  }
  for (const [id, major] of [['S4', 'MKT'], ['S5', 'GD']]) {
    batch.set(doc(admin, `classes/a/students/${id}`), { ...student, major });
  }
  await batch.commit();
});

before(async () => {
  env = await initializeTestEnvironment({ projectId, firestore: {
    rules: readFileSync(new URL('../firestore.rules', import.meta.url), 'utf8'),
  } });
});
after(async () => { await env?.cleanup(); });
beforeEach(async () => {
  await env.clearFirestore();
  await env.withSecurityRulesDisabled(async (context) => {
    const admin = context.firestore();
    await Promise.all(['alice', 'bob'].map((uid) => setDoc(doc(admin, 'users', uid),
      { displayName: uid, role: 'mentor', lastSignInAt: Timestamp.now() })));
    await setDoc(doc(admin, 'users/viewer'), { displayName: 'viewer', role: 'viewer', lastSignInAt: Timestamp.now() });
    await setDoc(doc(admin, 'classes/a'), room());
    await setDoc(doc(admin, 'classes/a/students/S1'), student);
    await setDoc(doc(admin, 'classes/a/teams/1'), team);
  });
});

test('signed-out get/list/write all denied', async () => {
  const guest = env.unauthenticatedContext().firestore();
  await assertFails(getDoc(doc(guest, 'classes/a')));
  await assertFails(getDocs(collection(guest, 'classes')));
  await assertFails(setDoc(doc(guest, 'classes/new'), room()));
});
test('mentor gets own class and correctly scoped query; unfiltered list denied', async () => {
  await assertSucceeds(getDoc(doc(db(), 'classes/a')));
  const own = await assertSucceeds(getDocs(query(collection(db(), 'classes'), where('mentorUid', '==', 'alice'))));
  assert.equal(own.size, 1);
  await assertFails(getDocs(collection(db(), 'classes')));
});
test('other mentor cannot get/update/delete class or students/teams', async () => {
  for (const path of ['classes/a', 'classes/a/students/S1', 'classes/a/teams/1']) {
    await assertFails(getDoc(doc(db('bob'), path)));
    await assertFails(updateDoc(doc(db('bob'), path), { name: 'Hacked' }));
    await assertFails(deleteDoc(doc(db('bob'), path)));
  }
  await assertFails(setDoc(doc(db('bob'), 'classes/a/students/S2'), student));
});
test('non-mentor cannot create own class or promote assigned role', async () => {
  await assertFails(setDoc(doc(db('viewer'), 'classes/v'), room('viewer')));
  await assertFails(updateDoc(doc(db('viewer'), 'users/viewer'), { role: 'mentor', lastSignInAt: serverTimestamp() }));
  await assertFails(deleteDoc(doc(db('viewer'), 'users/viewer')));
});
test('baseline mentor signup works but admin role and cross-user writes fail', async () => {
  await assertSucceeds(setDoc(doc(db('new'), 'users/new'), {
    displayName: 'New mentor', role: 'mentor', lastSignInAt: serverTimestamp(),
  }));
  await assertFails(setDoc(doc(db('evil'), 'users/evil'), {
    displayName: 'Evil', role: 'admin', lastSignInAt: serverTimestamp(),
  }));
  await assertFails(updateDoc(doc(db(), 'users/alice'), { role: 'admin', lastSignInAt: serverTimestamp() }));
  await assertFails(getDoc(doc(db('bob'), 'users/alice')));
  await assertFails(setDoc(doc(db('bob'), 'users/alice'), {
    displayName: 'Hacked', role: 'mentor', lastSignInAt: serverTimestamp(),
  }));
});
test('atomic parent + students + team import allowed with getAfter', async () => {
  const client = db();
  const batch = writeBatch(client);
  batch.set(doc(client, 'classes/new'), room());
  batch.set(doc(client, 'classes/new/students/S1'), { ...student, teamId: '1' });
  batch.set(doc(client, 'classes/new/teams/1'), team);
  await assertSucceeds(batch.commit());
  await assertSucceeds(getDocs(collection(client, 'classes/new/students')));
});
test('failed import leaves no partial class', async () => {
  const client = db();
  const batch = writeBatch(client);
  batch.set(doc(client, 'classes/new'), room());
  batch.set(doc(client, 'classes/new/students/S1'), { ...student, major: 'UNKNOWN' });
  await assertFails(batch.commit());
  await env.withSecurityRulesDisabled(async (context) => {
    assert.equal((await getDoc(doc(context.firestore(), 'classes/new'))).exists(), false);
  });
});
test('ownership, createdAt, missing fields, schema pollution and oversized update denied', async () => {
  await assertFails(setDoc(doc(db(), 'classes/spoof'), room('bob')));
  for (const patch of [{ mentorUid: 'bob' }, { createdAt: Timestamp.fromMillis(0) },
    { name: deleteField() }, { extraData: true }, { name: 'x'.repeat(121) }, { name: 5 }]) {
    await assertFails(updateDoc(doc(db(), 'classes/a'), patch));
  }
  await assertFails(setDoc(doc(db(), 'classes/backdated'), { ...room(), createdAt: Timestamp.fromMillis(0) }));
  await assertSucceeds(updateDoc(doc(db(), 'classes/a'), { name: 'Renamed' }));
});
test('student validators run on create and update; orphan denied', async () => {
  await assertSucceeds(setDoc(doc(db(), 'classes/a/students/S2'), { ...student, major: 'GD' }));
  for (const patch of [{ major: 'BAD' }, { teamId: '../escape' }, { fullName: '' },
    { fullName: 'x'.repeat(121) }, { fullName: deleteField() }, { extra: 'field' }]) {
    await assertFails(updateDoc(doc(db(), 'classes/a/students/S1'), patch));
  }
  await assertFails(setDoc(doc(db(), 'classes/missing/students/S2'), student));
});
test('team sizes 0..6 and parallel arrays checked, including deep types/duplicates', async () => {
  const client = db();
  for (const n of [0, 4, 5, 6]) {
    const teamId = `size-${n}`;
    const ref = doc(client, `classes/a/teams/${teamId}`);
    const ids = Array.from({ length: n }, (_, i) => `S${n}-${i + 1}`);
    const batch = writeBatch(client);
    // Team and student documents must reference each other in the same commit.
    for (const id of ids) {
      batch.set(doc(client, `classes/a/students/${id}`), { ...student, teamId });
    }
    batch.set(ref, { name: 'Team', memberIds: ids, majors: Array(n).fill('SE') });
    await assertSucceeds(batch.commit());
  }
  let invalidIndex = 0;
  for (const invalid of [
    { ...team, memberIds: Array(7).fill('S1'), majors: Array(7).fill('SE') },
    { ...team, memberIds: ['S1', 'S1'], majors: ['SE', 'SE'] },
    { ...team, memberIds: [123] }, { ...team, majors: ['BAD'] },
    { ...team, majors: [] }, { ...team, memberIds: ['bad/path'] },
    { ...team, majors: ['GD'] },
  ]) {
    await assertFails(setDoc(doc(client, `classes/a/teams/invalid-${invalidIndex++}`), invalid));
  }
});
test('proposal ownership and pending collection-group query', async () => {
  await assertSucceeds(setDoc(doc(db(), 'classes/a/proposals/p'), pending()));
  await assertSucceeds(getDocs(query(collectionGroup(db(), 'proposals'),
    where('mentorUid', '==', 'alice'), where('status', '==', 'pending'))));
  await assertFails(getDocs(collectionGroup(db(), 'proposals')));
  await assertFails(getDoc(doc(db('bob'), 'classes/a/proposals/p')));
  await assertFails(setDoc(doc(db(), 'classes/a/proposals/spoof'), { ...pending(), mentorUid: 'bob' }));
});

test('pending proposal edits validate mutable fields without evaluation overflow', async () => {
  const ref = doc(db(), 'classes/a/proposals/p');
  await assertSucceeds(setDoc(ref, pending()));
  await assertSucceeds(updateDoc(ref, { fit: 'good', reasons: ['Reviewed'] }));
  await assertDeniedByRule(updateDoc(ref, { fit: 'unknown' }));
  await assertDeniedByRule(updateDoc(ref, {
    addStudentIds: ['S4', 'S4'], addMajors: ['MKT', 'GD'],
  }));
  await assertDeniedByRule(updateDoc(ref, { teamName: 'x'.repeat(121) }));
  await assertDeniedByRule(updateDoc(ref, { classId: 'other' }));
});
test('approve requires atomic roster updates, undo reverts roster; discarded stays discarded', async () => {
  await seedProposalRoster();
  const client = db();
  const ref = doc(client, 'classes/a/proposals/p');
  const teamRef = doc(client, 'classes/a/teams/1');
  await assertSucceeds(setDoc(ref, pending()));
  await assertDeniedByRule(updateDoc(ref, { status: 'approved', addStudentIds: [], addMajors: [] }));
  await assertDeniedByRule(updateDoc(ref, { source: 'manual' }));
  await assertDeniedByRule(updateDoc(ref, { status: 'approved' }));
  await assertDeniedByRule(updateDoc(ref, { status: 'approved', approvedAt: serverTimestamp() }));

  const incomplete = writeBatch(client);
  incomplete.update(teamRef, { memberIds: ['S1', 'S2', 'S3', 'S4', 'S5'], majors: ['SE', 'SE', 'AI', 'MKT', 'GD'], rosterChangeProposalId: 'p' });
  incomplete.update(ref, { status: 'approved', approvedAt: serverTimestamp() });
  await assertDeniedByRule(incomplete.commit());

  const approved = writeBatch(client);
  approved.update(teamRef, { memberIds: ['S1', 'S2', 'S3', 'S4', 'S5'], majors: ['SE', 'SE', 'AI', 'MKT', 'GD'], rosterChangeProposalId: 'p' });
  for (const id of ['S4', 'S5']) approved.update(doc(client, `classes/a/students/${id}`), { teamId: '1' });
  approved.update(ref, { status: 'approved', approvedAt: serverTimestamp() });
  await assertSucceeds(approved.commit());
  assert.equal((await getDoc(doc(client, 'classes/a/students/S4'))).data().teamId, '1');
  await assertDeniedByRule(updateDoc(ref, { status: 'pending', approvedAt: deleteField() }));

  const undone = writeBatch(client);
  undone.update(teamRef, { memberIds: ['S1', 'S2', 'S3'], majors: ['SE', 'SE', 'AI'], rosterChangeProposalId: null });
  for (const id of ['S4', 'S5']) undone.update(doc(client, `classes/a/students/${id}`), { teamId: null });
  undone.update(ref, { status: 'pending', approvedAt: deleteField() });
  await assertSucceeds(undone.commit());
  assert.equal((await getDoc(doc(client, 'classes/a/students/S5'))).data().teamId, null);
  await assertSucceeds(updateDoc(ref, { status: 'discarded' }));
  await assertDeniedByRule(updateDoc(ref, { status: 'pending' }));
});

test('matching replaces an AI draft atomically and can reuse a superseded ID', async () => {
  const client = db();
  const draft = doc(client, 'classes/a/proposals/p');
  const replacement = doc(client, 'classes/a/proposals/replacement');
  const manual = doc(client, 'classes/a/proposals/manual');
  const guard = doc(client, 'classes/a/matching/state');
  await assertSucceeds(getDoc(guard));
  await assertFails(getDoc(doc(db('bob'), guard.path)));
  await assertFails(setDoc(doc(db('bob'), guard.path), { updatedAt: serverTimestamp() }));
  await assertFails(setDoc(guard, { updatedAt: Timestamp.now(), extra: true }));
  await assertSucceeds(setDoc(draft, pending()));
  await assertSucceeds(setDoc(manual, { ...pending(), source: 'manual' }));
  await assertDeniedByRule(updateDoc(manual, { status: 'superseded' }));
  await assertDeniedByRule(updateDoc(draft, { status: 'superseded', teamId: '2' }));

  await assertSucceeds(runTransaction(client, async (tx) => {
    assert.equal((await tx.get(guard)).exists(), false);
    assert.equal((await tx.get(draft)).data().status, 'pending');
    assert.equal((await tx.get(replacement)).exists(), false);
    tx.update(draft, { status: 'superseded' });
    tx.set(replacement, pending());
    tx.set(guard, { updatedAt: serverTimestamp() });
  }));
  const open = await assertSucceeds(getDocs(query(collection(client, 'classes/a/proposals'),
    where('status', '==', 'pending'))));
  assert.deepEqual(open.docs.map((entry) => entry.id).sort(), ['manual', 'replacement']);
  await assertDeniedByRule(updateDoc(draft, { status: 'pending', teamId: '2' }));
  await assertDeniedByRule(updateDoc(draft, { status: 'pending', addStudentIds: ['S1', 'S4'] }));
  const restore = writeBatch(client);
  restore.set(draft, pending());
  restore.update(replacement, { status: 'superseded' });
  restore.set(guard, { updatedAt: serverTimestamp() });
  await assertSucceeds(restore.commit());
});

test('a replacement can fill place six after a previous approval', async () => {
  await seedProposalRoster();
  const client = db();
  const teamRef = doc(client, 'classes/a/teams/1');
  const first = doc(client, 'classes/a/proposals/first');
  const next = doc(client, 'classes/a/proposals/next');
  const sixth = doc(client, 'classes/a/students/S6');
  const five = ['S1', 'S2', 'S3', 'S4', 'S5'];
  const fiveMajors = ['SE', 'SE', 'AI', 'MKT', 'GD'];
  await assertSucceeds(setDoc(sixth, student));
  await assertSucceeds(setDoc(first, pending()));
  const approveFirst = writeBatch(client);
  approveFirst.update(teamRef, { memberIds: five, majors: fiveMajors, rosterChangeProposalId: first.id });
  for (const id of ['S4', 'S5']) approveFirst.update(doc(client, `classes/a/students/${id}`), { teamId: '1' });
  approveFirst.update(first, { status: 'approved', approvedAt: serverTimestamp() });
  await assertSucceeds(approveFirst.commit());

  await assertSucceeds(setDoc(next, {
    ...pending(), currentMemberIds: five, currentMajors: fiveMajors,
    addStudentIds: ['S6'], addMajors: ['SE'],
  }));
  const approveNext = writeBatch(client);
  approveNext.update(teamRef, {
    memberIds: [...five, 'S6'], majors: [...fiveMajors, 'SE'], rosterChangeProposalId: next.id,
  });
  approveNext.update(sixth, { teamId: '1' });
  approveNext.update(next, { status: 'approved', approvedAt: serverTimestamp() });
  await assertSucceeds(approveNext.commit());
  const undoNext = writeBatch(client);
  undoNext.update(teamRef, { memberIds: five, majors: fiveMajors, rosterChangeProposalId: null });
  undoNext.update(sixth, { teamId: null });
  undoNext.update(next, { status: 'pending', approvedAt: deleteField() });
  await assertSucceeds(undoNext.commit());
  assert.equal((await getDoc(first)).data().status, 'approved');
  assert.deepEqual((await getDoc(teamRef)).data().memberIds, five);
});

test('approval rejects a partially updated roster and changing an assigned major', async () => {
  await seedProposalRoster();
  const client = db();
  const proposalRef = doc(client, 'classes/a/proposals/p');
  const teamRef = doc(client, 'classes/a/teams/1');
  await assertSucceeds(setDoc(proposalRef, pending()));

  const partial = writeBatch(client);
  partial.update(teamRef, {
    memberIds: ['S1', 'S2', 'S3', 'S4', 'S5'],
    majors: ['SE', 'SE', 'AI', 'MKT', 'GD'],
    rosterChangeProposalId: 'p',
  });
  partial.update(doc(client, 'classes/a/students/S4'), { teamId: '1' });
  partial.update(proposalRef, { status: 'approved', approvedAt: serverTimestamp() });
  await assertDeniedByRule(partial.commit());

  await assertFails(updateDoc(doc(client, 'classes/a/students/S1'), { major: 'GD' }));
  await assertFails(deleteDoc(teamRef));
  await assertFails(updateDoc(doc(client, 'classes/a/students/S4'), { teamId: '1' }));
});

test('approval supports six added students with all student updates in one commit', async () => {
  const client = db();
  const teamRef = doc(client, 'classes/a/teams/1');
  const proposalRef = doc(client, 'classes/a/proposals/all-six');
  const studentIds = ['S1', 'S2', 'S3', 'S4', 'S5', 'S6'];
  const studentMajors = ['SE', 'AI', 'MKT', 'GD', 'SE', 'AI'];
  await env.withSecurityRulesDisabled(async (context) => {
    const admin = context.firestore();
    const seed = writeBatch(admin);
    seed.set(doc(admin, 'classes/a/teams/1'), { name: 'Group 1', memberIds: [], majors: [] });
    for (let i = 0; i < studentIds.length; i++) {
      seed.set(doc(admin, `classes/a/students/${studentIds[i]}`), {
        ...student, major: studentMajors[i],
      });
    }
    await seed.commit();
  });
  await assertSucceeds(setDoc(proposalRef, {
    ...pending(), teamId: '1', currentMemberIds: [], currentMajors: [],
    addStudentIds: studentIds, addMajors: studentMajors,
  }));
  const approved = writeBatch(client);
  approved.update(teamRef, {
    memberIds: studentIds, majors: studentMajors, rosterChangeProposalId: 'all-six',
  });
  for (const id of studentIds) {
    approved.update(doc(client, `classes/a/students/${id}`), { teamId: '1' });
  }
  approved.update(proposalRef, { status: 'approved', approvedAt: serverTimestamp() });
  await assertSucceeds(approved.commit());
});

test('another mentor cannot approve a proposal for an unowned class', async () => {
  await seedProposalRoster();
  await assertSucceeds(setDoc(doc(db(), 'classes/a/proposals/p'), pending()));
  const other = db('bob');
  const batch = writeBatch(other);
  batch.update(doc(other, 'classes/a/teams/1'), {
    memberIds: ['S1', 'S2', 'S3', 'S4', 'S5'],
    majors: ['SE', 'SE', 'AI', 'MKT', 'GD'],
    rosterChangeProposalId: 'p',
  });
  for (const id of ['S4', 'S5']) {
    batch.update(doc(other, `classes/a/students/${id}`), { teamId: '1' });
  }
  batch.update(doc(other, 'classes/a/proposals/p'), {
    status: 'approved', approvedAt: serverTimestamp(),
  });
  await assertDeniedByRule(batch.commit());
});

test('undo after five seconds is rejected atomically', async () => {
  await seedProposalRoster();
  await env.withSecurityRulesDisabled(async (context) => {
    const admin = context.firestore();
    const batch = writeBatch(admin);
    batch.update(doc(admin, 'classes/a/teams/1'), {
      memberIds: ['S1', 'S2', 'S3', 'S4', 'S5'],
      majors: ['SE', 'SE', 'AI', 'MKT', 'GD'],
      rosterChangeProposalId: 'p',
    });
    for (const id of ['S4', 'S5']) {
      batch.update(doc(admin, `classes/a/students/${id}`), { teamId: '1' });
    }
    batch.set(doc(admin, 'classes/a/proposals/p'), {
      ...pending(), status: 'approved',
      approvedAt: Timestamp.fromMillis(Date.now() - 20_000),
    });
    await batch.commit();
  });
  const client = db();
  const batch = writeBatch(client);
  batch.update(doc(client, 'classes/a/teams/1'), {
    memberIds: ['S1', 'S2', 'S3'],
    majors: ['SE', 'SE', 'AI'],
    rosterChangeProposalId: null,
  });
  for (const id of ['S4', 'S5']) {
    batch.update(doc(client, `classes/a/students/${id}`), { teamId: null });
  }
  batch.update(doc(client, 'classes/a/proposals/p'), {
    status: 'pending', approvedAt: deleteField(),
  });
  await assertDeniedByRule(batch.commit());
  assert.equal((await getDoc(doc(client, 'classes/a/proposals/p'))).data().status, 'approved');
  assert.equal((await getDoc(doc(client, 'classes/a/students/S4'))).data().teamId, '1');
});

test('a student assigned to one team cannot join a second team', async () => {
  await seedProposalRoster();
  await assertDeniedByRule(setDoc(doc(db(), 'classes/a/teams/2'), {
    name: 'Another team', memberIds: ['S1'], majors: ['SE'],
  }));
  await assertDeniedByRule(updateDoc(doc(db(), 'classes/a/students/S1'), { teamId: '2' }));
});

test('FCM token register/refresh/delete restricted to owner mentor and valid schema', async () => {
  const client = db();
  const ref = doc(client, 'users/alice/fcmTokens/aBc_12==');
  await assertSucceeds(setDoc(ref, { token: 'abc:123', platform: 'android', updatedAt: serverTimestamp() }));
  await assertSucceeds(updateDoc(ref, { updatedAt: serverTimestamp() }));
  await assertFails(setDoc(doc(db('bob'), 'users/alice/fcmTokens/hij'), {
    token: 'stolen', platform: 'android', updatedAt: serverTimestamp(),
  }));
  await assertFails(setDoc(doc(client, 'users/alice/fcmTokens/wrong'), {
    token: 'abc', platform: 'ios', updatedAt: serverTimestamp(),
  }));
  await assertFails(updateDoc(ref, { extra: true, updatedAt: serverTimestamp() }));
  await assertSucceeds(deleteDoc(ref));
});
test('reports restricted by owner/class/path/range/immutable timestamp', async () => {
  const ref = doc(db(), 'reports/r');
  const report = { ownerUid: 'alice', classId: 'a', storagePath: 'reports/alice/r.pdf',
    downloadUrl: 'https://example.test/r.pdf', sizeKb: 20, createdAt: serverTimestamp() };
  await assertSucceeds(setDoc(ref, report));
  await assertFails(getDoc(doc(db('bob'), 'reports/r')));
  for (const patch of [{ ownerUid: 'bob' }, { storagePath: 'reports/bob/r.pdf' },
    { sizeKb: -1 }, { sizeKb: 10241 }, { downloadUrl: 'javascript:bad' },
    { createdAt: Timestamp.fromMillis(0) }]) await assertFails(updateDoc(ref, patch));
});
test('notifications private; updates may only mark read; parent role required', async () => {
  const ref = doc(db(), 'users/alice/notifications/n');
  await assertSucceeds(setDoc(ref, { title: 'TeamUp', body: 'Demo', receivedAt: Timestamp.now(), route: '/proposals', read: false }));
  await assertSucceeds(updateDoc(ref, { read: true }));
  await assertFails(updateDoc(ref, { title: 'Changed' }));
  await assertFails(getDoc(doc(db('bob'), 'users/alice/notifications/n')));
  await assertFails(setDoc(doc(db('orphan'), 'users/orphan/notifications/n'), {
    title: 'TeamUp', body: '', receivedAt: Timestamp.now(), read: false,
  }));
});
