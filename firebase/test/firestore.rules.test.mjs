import { readFileSync } from 'node:fs';
import { after, before, beforeEach, test } from 'node:test';
import assert from 'node:assert/strict';
import { initializeTestEnvironment, assertFails, assertSucceeds } from '@firebase/rules-unit-testing';
import { Bytes, collection, collectionGroup, deleteDoc, deleteField, doc, getDoc, getDocs,
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
test('reports restricted by owner/class/range/immutable timestamp; PDF bytes owner-only', async () => {
  const alice = db();
  const ref = doc(alice, 'reports/r');
  const report = { ownerUid: 'alice', classId: 'a', sizeKb: 20, createdAt: serverTimestamp() };
  const pdf = (n) => ({ bytes: Bytes.fromUint8Array(new Uint8Array(n).fill(37)) });
  const batch = writeBatch(alice);
  batch.set(ref, report);
  batch.set(doc(alice, 'reports/r/files/pdf'), pdf(1024));
  await assertSucceeds(batch.commit());
  await assertSucceeds(getDoc(doc(db(), 'reports/r/files/pdf')));
  await assertFails(getDoc(doc(db('bob'), 'reports/r')));
  await assertFails(getDoc(doc(db('bob'), 'reports/r/files/pdf')));
  await assertFails(setDoc(doc(db(), 'reports/r/files/pdf'), pdf(921601)));
  await assertFails(setDoc(doc(db(), 'reports/r/files/other'), pdf(10)));
  await assertFails(setDoc(doc(db('bob'), 'reports/r/files/pdf'), pdf(10)));
  for (const patch of [{ ownerUid: 'bob' }, { sizeKb: -1 }, { sizeKb: 901 },
    { storagePath: 'reports/alice/r.pdf' }, { createdAt: Timestamp.fromMillis(0) }]) {
    await assertFails(updateDoc(ref, patch));
  }
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

// ---- Flow D/E/F: student roles, topics, slots, bookings, minutes ----
const studentUser = (role, teamId = '1', studentId = 'S1') => ({ displayName: role, role,
  lastSignInAt: Timestamp.now(), classId: 'a', teamId, studentId, mentorUid: 'alice' });
const seedStudents = () => env.withSecurityRulesDisabled(async (context) => {
  const admin = context.firestore();
  await setDoc(doc(admin, 'classes/a/students/S1'), { ...student, teamId: '1' });
  await setDoc(doc(admin, 'classes/a/students/S2'), { ...student, teamId: '2' });
  await setDoc(doc(admin, 'classes/a/teams/2'), { name: 'Group 2', memberIds: ['S2'], majors: ['SE'] });
  await setDoc(doc(admin, 'users/lead'), studentUser('leader'));
  await setDoc(doc(admin, 'users/mem'), studentUser('member'));
  await setDoc(doc(admin, 'users/lead2'), studentUser('leader', '2', 'S2'));
});
const topic = (over = {}) => ({ classId: 'a', teamId: '1', teamName: 'Group 1', mentorUid: 'alice',
  leaderUid: 'lead', title: 'Tutor app', description: 'Idea', techStack: 'Flutter',
  status: 'pending', revisionCount: 0, submittedAt: serverTimestamp(), ...over });
const in1h = () => Timestamp.fromMillis(Date.now() + 3600e3);
const in90m = () => Timestamp.fromMillis(Date.now() + 5400e3);

test('student onboarding only links an MSSV that is in that team', async () => {
  await seedStudents();
  const fresh = (uid, over) => setDoc(doc(db(uid), `users/${uid}`), {
    ...studentUser('leader'), lastSignInAt: serverTimestamp(), ...over });
  await assertSucceeds(getDoc(doc(db('fresh'), 'classes/a/students/S1')));
  await assertSucceeds(fresh('fresh'));
  await assertFails(fresh('wrongteam', { teamId: '2' }));
  await assertFails(fresh('wrongmentor', { mentorUid: 'bob' }));
  await assertFails(fresh('mentorstudent', { role: 'mentor' }));
  // A profiled student cannot read the roster or change links.
  await assertFails(getDoc(doc(db('lead'), 'classes/a/students/S2')));
  await assertFails(updateDoc(doc(db('lead'), 'users/lead'), { teamId: '2', lastSignInAt: serverTimestamp() }));
  await assertSucceeds(getDocs(query(collection(db('lead'), 'classes/a/students'), where('teamId', '==', '1'))));
  await assertSucceeds(getDoc(doc(db('mem'), 'classes/a/teams/1')));
  await assertFails(getDoc(doc(db('mem'), 'classes/a/teams/2')));
});

test('topics: leader submits own team only; member and other teams cannot; only mentor decides', async () => {
  await seedStudents();
  await assertSucceeds(getDoc(doc(db('lead'), 'topics/a_1'))); // not created yet
  await assertFails(setDoc(doc(db('mem'), 'topics/a_1'), topic({ leaderUid: 'mem' })));
  await assertFails(setDoc(doc(db('lead2'), 'topics/a_1'), topic({ leaderUid: 'lead2' })));
  await assertFails(setDoc(doc(db('lead'), 'topics/a_1'), topic({ status: 'approved' })));
  await assertSucceeds(setDoc(doc(db('lead'), 'topics/a_1'), topic()));
  await assertFails(getDoc(doc(db('lead2'), 'topics/a_1')));
  await assertFails(updateDoc(doc(db('lead'), 'topics/a_1'), { status: 'approved' }));
  await assertFails(updateDoc(doc(db('bob'), 'topics/a_1'), { status: 'approved', reviewedAt: serverTimestamp() }));
  await assertFails(updateDoc(doc(db(), 'topics/a_1'), { status: 'rejected', reviewedAt: serverTimestamp() }));
  await assertSucceeds(updateDoc(doc(db(), 'topics/a_1'), {
    status: 'revision_requested', mentorFeedback: 'Narrow the scope', reviewedAt: serverTimestamp() }));
  // Resubmission must count one revision and clear the feedback.
  await assertFails(updateDoc(doc(db('lead'), 'topics/a_1'), {
    title: 'v2', status: 'pending', submittedAt: serverTimestamp(), mentorFeedback: deleteField() }));
  await assertSucceeds(updateDoc(doc(db('lead'), 'topics/a_1'), { title: 'v2', status: 'pending',
    submittedAt: serverTimestamp(), revisionCount: 1, mentorFeedback: deleteField() }));
  await assertSucceeds(updateDoc(doc(db(), 'topics/a_1'), { status: 'approved', reviewedAt: serverTimestamp() }));
  await assertFails(updateDoc(doc(db('lead'), 'topics/a_1'), {
    title: 'v3', status: 'pending', submittedAt: serverTimestamp(), revisionCount: 2 }));
});

test('topic outline file: leader writes before approval; team and mentor read; others cannot', async () => {
  await seedStudents();
  const outline = (uid) => doc(db(uid), 'topics/a_1/files/outline');
  const file = (n, contentType = 'application/pdf') =>
    ({ contentType, bytes: Bytes.fromUint8Array(new Uint8Array(n).fill(1)) });
  // First submission: the file goes in before the topic exists.
  await assertSucceeds(setDoc(outline('lead'), file(2048)));
  await assertFails(setDoc(outline('mem'), file(10)));
  await assertFails(setDoc(doc(db('lead2'), 'topics/a_1/files/outline'), file(10)));
  await assertFails(setDoc(outline('lead'), file(921601)));
  await assertFails(setDoc(outline('lead'), file(10, 'text/html')));
  await assertFails(setDoc(doc(db('lead'), 'topics/a_1/files/other'), file(10)));
  await assertSucceeds(setDoc(doc(db('lead'), 'topics/a_1'), topic({ attachmentName: 'outline.pdf' })));
  await assertSucceeds(getDoc(outline('mem')));
  await assertSucceeds(getDoc(outline()));
  await assertFails(getDoc(outline('lead2')));
  await assertFails(getDoc(outline('bob')));
  await assertSucceeds(updateDoc(doc(db(), 'topics/a_1'), { status: 'approved', reviewedAt: serverTimestamp() }));
  await assertFails(setDoc(outline('lead'), file(10)));
});

test('slots and bookings: atomic booking, no double booking, cancel frees the slot', async () => {
  await seedStudents();
  const slotRef = (c) => doc(c, 'mentors/alice/slots/s1');
  await assertFails(setDoc(slotRef(db('lead')), { startTime: in1h(), endTime: in90m(), status: 'available', bookingId: null }));
  await assertSucceeds(setDoc(slotRef(db()), { startTime: in1h(), endTime: in90m(), status: 'available', bookingId: null }));
  await assertSucceeds(getDocs(collection(db('mem'), 'mentors/alice/slots')));
  await assertFails(getDocs(collection(db('bob'), 'mentors/alice/slots')));
  // withSecurityRulesDisabled does not return the callback's value.
  let slot;
  await env.withSecurityRulesDisabled(async (c) => { slot = (await getDoc(slotRef(c.firestore()))).data(); });
  const book = (uid, id) => {
    const c = db(uid);
    const batch = writeBatch(c);
    batch.update(slotRef(c), { status: 'booked', bookingId: id });
    batch.set(doc(c, `bookings/${id}`), { slotId: 's1', mentorUid: 'alice', classId: 'a',
      teamId: uid === 'lead2' ? '2' : '1', teamName: uid === 'lead2' ? 'Group 2' : 'Group 1',
      purpose: 'topic_review', status: 'requested', startTime: slot.startTime, endTime: slot.endTime,
      requestedBy: uid, createdAt: serverTimestamp() });
    return batch.commit();
  };
  await assertFails(book('mem', 'b0'));
  await assertSucceeds(book('lead', 'b1'));
  await assertFails(book('lead2', 'b2'));
  await assertFails(getDoc(doc(db('lead2'), 'bookings/b1')));
  await assertFails(updateDoc(doc(db(), 'bookings/b1'), { status: 'confirmed', meetUrl: 'https://evil.com/x' }));
  await assertSucceeds(updateDoc(doc(db(), 'bookings/b1'), { status: 'confirmed', meetUrl: 'https://meet.google.com/abc-defg-hij' }));
  // Cancelling without freeing the slot is denied; together it succeeds.
  await assertFails(updateDoc(doc(db('lead'), 'bookings/b1'), { status: 'cancelled' }));
  const c = db('lead');
  const batch = writeBatch(c);
  batch.update(doc(c, 'bookings/b1'), { status: 'cancelled' });
  batch.update(slotRef(c), { status: 'available', bookingId: null });
  await assertSucceeds(batch.commit());
  await assertSucceeds(book('lead2', 'b2'));
});

test('minutes: both sides draft, only mentor signs, signed minutes are frozen', async () => {
  await seedStudents();
  await env.withSecurityRulesDisabled(async (context) => setDoc(doc(context.firestore(), 'bookings/b1'), {
    slotId: 's1', mentorUid: 'alice', classId: 'a', teamId: '1', teamName: 'Group 1',
    purpose: 'sprint_review', status: 'confirmed', startTime: Timestamp.fromMillis(0),
    endTime: Timestamp.fromMillis(1800e3), requestedBy: 'lead', createdAt: Timestamp.now(),
    meetUrl: 'https://meet.google.com/abc-defg-hij' }));
  const ref = (uid) => doc(db(uid), 'minutes/b1');
  await assertSucceeds(getDoc(ref('mem')));
  await assertFails(getDoc(ref('lead2')));
  await assertSucceeds(setDoc(ref('mem'), { bookingId: 'b1', mentorUid: 'alice', classId: 'a', teamId: '1',
    teamName: 'Group 1', meetingDate: Timestamp.fromMillis(0), summary: 'Sprint 1 done',
    actionItems: [{ task: 'Login', assignee: 'An', deadline: '2026-12-01' }], mentorRating: null,
    isSignedByMentor: false, createdBy: 'mem', updatedAt: serverTimestamp() }));
  await assertSucceeds(updateDoc(ref('lead'), { summary: 'Edited', updatedAt: serverTimestamp() }));
  await assertFails(updateDoc(ref('lead'), { isSignedByMentor: true, mentorRating: 5, updatedAt: serverTimestamp() }));
  await assertFails(updateDoc(ref(), { isSignedByMentor: true, mentorRating: 6, updatedAt: serverTimestamp() }));
  await assertSucceeds(updateDoc(ref(), { isSignedByMentor: true, mentorRating: 4, updatedAt: serverTimestamp() }));
  await assertFails(updateDoc(ref('lead'), { summary: 'After sign', updatedAt: serverTimestamp() }));
  // The PDF is built on the device; nothing may be attached after signing.
  await assertFails(updateDoc(ref('lead'), { pdfStoragePath: 'minutes/b1/minutes.pdf' }));
});

// Review finding F3: importClass writes the class, every student and every team in one batch.
const importBatch = (client, id, students, groups) => {
  const batch = writeBatch(client);
  batch.set(doc(client, `classes/${id}`), room());
  const majors = ['SE', 'AI', 'MKT', 'GD'];
  const rows = Array.from({ length: students }, (_, i) => ({
    id: `M${String(i + 1).padStart(6, '0')}`, major: majors[i % 4] }));
  groups.forEach((size, g) => {
    const members = rows.splice(0, size);
    batch.set(doc(client, `classes/${id}/teams/${g + 1}`), {
      name: `Group ${g + 1}`, memberIds: members.map((m) => m.id), majors: members.map((m) => m.major) });
    for (const m of members) {
      batch.set(doc(client, `classes/${id}/students/${m.id}`), { ...student, major: m.major, teamId: String(g + 1) });
    }
  });
  for (const m of rows) batch.set(doc(client, `classes/${id}/students/${m.id}`), { ...student, major: m.major, teamId: null });
  return batch.commit();
};

test('import of the 12-student demo class commits in one batch', async () => {
  await assertSucceeds(importBatch(db(), 'demo12', 12, [6, 3]));
});
test('import of a 42-student class (6 groups of 5, 12 free) commits in one batch', async () => {
  await assertSucceeds(importBatch(db(), 'full42', 42, [5, 5, 5, 5, 5, 5]));
});
