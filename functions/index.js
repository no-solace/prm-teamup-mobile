// Push notifications for Flow D/E (FCM). The app saves each received push to
// users/{uid}/notifications itself, so these triggers only send messages.
// Deploy (Blaze plan): firebase deploy --only functions
const { onDocumentWritten } = require('firebase-functions/v2/firestore');
const { logger } = require('firebase-functions');
const { initializeApp } = require('firebase-admin/app');
const { getFirestore } = require('firebase-admin/firestore');
const { getMessaging } = require('firebase-admin/messaging');

initializeApp();
const db = getFirestore();

const STALE_TOKEN = new Set([
  'messaging/registration-token-not-registered',
  'messaging/invalid-registration-token',
]);

/** One multicast per user: data.uid must match the signed-in account. */
async function notify(uids, { title, body, route, id }) {
  await Promise.all([...new Set(uids)].filter(Boolean).map(async (uid) => {
    const snap = await db.collection(`users/${uid}/fcmTokens`).get();
    const docs = snap.docs.filter((d) => typeof d.get('token') === 'string');
    if (docs.length === 0) return;
    const result = await getMessaging().sendEachForMulticast({
      tokens: docs.map((d) => d.get('token')),
      notification: { title, body },
      data: { uid, id: `${id}:${uid}`, route, title, body },
      android: { priority: 'high' },
    });
    await Promise.all(result.responses.map((r, i) =>
      !r.success && STALE_TOKEN.has(r.error?.code) ? docs[i].ref.delete() : null));
  }));
}

async function teamUids(classId, teamId) {
  const snap = await db.collection('users')
    .where('classId', '==', classId).where('teamId', '==', teamId).get();
  return snap.docs.map((d) => d.id);
}

const TOPIC_LABEL = {
  approved: 'approved', rejected: 'rejected', revision_requested: 'needs revision',
};
const PURPOSE_LABEL = {
  topic_review: 'Topic review', sprint_review: 'Sprint review', tech_guidance: 'Technical guidance',
};

exports.onTopicWritten = onDocumentWritten('topics/{topicId}', async (event) => {
  const before = event.data.before.data();
  const after = event.data.after.data();
  if (!after) return;
  const id = event.id;
  if (after.status === 'pending' && before?.status !== 'pending') {
    // New submission or resubmission -> mentor.
    await notify([after.mentorUid], {
      id,
      title: before ? 'Topic resubmitted' : 'New topic to review',
      body: `${after.teamName}: ${after.title}`,
      route: `/topics/${event.params.topicId}`,
    });
  } else if (before?.status === 'pending' && TOPIC_LABEL[after.status]) {
    // Mentor decision -> every student of the team.
    await notify(await teamUids(after.classId, after.teamId), {
      id,
      title: `Your topic ${TOPIC_LABEL[after.status]}`,
      body: after.mentorFeedback || after.title,
      route: '/topics',
    });
  }
});

exports.onBookingWritten = onDocumentWritten('bookings/{bookingId}', async (event) => {
  const before = event.data.before.data();
  const after = event.data.after.data();
  if (!after || before?.status === after.status) return;
  const route = `/schedule/${event.params.bookingId}`;
  const when = after.startTime.toDate().toISOString().slice(0, 16).replace('T', ' ');
  const what = `${PURPOSE_LABEL[after.purpose] ?? 'Meeting'} · ${when} UTC`;
  if (!before) {
    await notify([after.mentorUid], {
      id: event.id, title: 'New meeting request', body: `${after.teamName}: ${what}`, route,
    });
  } else if (after.status === 'confirmed' || after.status === 'cancelled') {
    const team = await teamUids(after.classId, after.teamId);
    await notify([after.mentorUid, ...team], {
      id: event.id,
      title: after.status === 'confirmed' ? 'Meeting confirmed' : 'Meeting cancelled',
      body: `${after.teamName}: ${what}`,
      route,
    });
  }
  logger.info('booking notification', { bookingId: event.params.bookingId, status: after.status });
});
