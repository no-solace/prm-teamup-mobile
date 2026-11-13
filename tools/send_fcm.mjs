// Server-side FCM sender (runs on a trusted machine, NOT in the app).
// Usage: node tools/send_fcm.mjs <serviceAccount.json> <uid> "<title>" "<body>" [route]
// It reads the device tokens the app saved in users/{uid}/fcmTokens and calls
// FCM HTTP v1 through the Admin SDK. data.uid is required: the app drops
// messages whose data.uid is not the signed-in user.
import { readFileSync } from 'node:fs';
import { initializeApp, cert } from 'firebase-admin/app';
import { getFirestore } from 'firebase-admin/firestore';
import { getMessaging } from 'firebase-admin/messaging';

const [keyPath, uid, title, body, route] = process.argv.slice(2);
if (!keyPath || !uid || !title) {
  console.error('Usage: node tools/send_fcm.mjs <serviceAccount.json> <uid> "<title>" "<body>" [route]');
  process.exit(1);
}
initializeApp({ credential: cert(JSON.parse(readFileSync(keyPath, 'utf8'))) });

const snap = await getFirestore().collection('users').doc(uid).collection('fcmTokens').get();
const tokens = snap.docs.map((d) => d.data().token).filter(Boolean);
if (!tokens.length) { console.error('No FCM token for this uid (open the app, allow notifications).'); process.exit(2); }

const data = { uid, id: `m-${Date.now()}`, ...(route ? { route } : {}) };
const res = await getMessaging().sendEachForMulticast({
  tokens,
  notification: { title, body: body ?? '' },
  data,
});
console.log(`sent ${res.successCount}/${tokens.length}`, res.responses.map((r) => r.error?.code ?? 'ok'));
