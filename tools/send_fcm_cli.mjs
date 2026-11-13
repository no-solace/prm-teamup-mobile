// Same job as send_fcm.mjs but authenticates with the token of the logged-in
// Firebase CLI user (no service-account file). Server-side/trusted machine only.
// Usage: node tools/send_fcm_cli.mjs <uid> "<title>" "<body>" [route]
import { readFileSync } from 'node:fs';
import { homedir } from 'node:os';
import { execSync } from 'node:child_process';

const [uid, title, body = '', route] = process.argv.slice(2);
if (!uid || !title) { console.error('Usage: node tools/send_fcm_cli.mjs <uid> "<title>" "<body>" [route]'); process.exit(1); }
const PROJECT = 'prm-lab3-cc39e';
try { execSync('npx --yes firebase-tools@14.27.0 projects:list', { stdio: 'ignore' }); } catch {} // refreshes the token
const cfg = JSON.parse(readFileSync(`${homedir()}/.config/configstore/firebase-tools.json`, 'utf8'));
const auth = { Authorization: `Bearer ${cfg.tokens.access_token}`, 'Content-Type': 'application/json' };

const list = await (await fetch(`https://firestore.googleapis.com/v1/projects/${PROJECT}/databases/(default)/documents/users/${uid}/fcmTokens`, { headers: auth })).json();
const tokens = (list.documents ?? []).map((d) => d.fields?.token?.stringValue).filter(Boolean);
if (!tokens.length) { console.error('No FCM token for this uid: open the app, sign in, Allow notifications.'); process.exit(2); }

for (const token of tokens) {
  const res = await fetch(`https://fcm.googleapis.com/v1/projects/${PROJECT}/messages:send`, {
    method: 'POST', headers: auth,
    body: JSON.stringify({ message: { token, notification: { title, body },
      data: { uid, id: `m-${Date.now()}`, ...(route ? { route } : {}) } } }),
  });
  console.log(res.status, (await res.text()).slice(0, 160));
}
