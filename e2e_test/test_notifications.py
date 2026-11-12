"""Opening a push notification from the notification shade (native interaction).

This test needs a human to send the message, because the Firebase console is the sender:
  1. Run the test with TEAMUP_PUSH_READY=1.
  2. When the app is in the background, send a test message from Firebase console →
     Messaging → "Send test message" with the device FCM token shown in Profile → Notifications,
     and the data field `route` = `/proposals`.
Without TEAMUP_PUSH_READY the test is skipped and reported as such in docs/test-plan.md.
"""

import os

import pytest


@pytest.mark.native
@pytest.mark.skipif(not os.environ.get("TEAMUP_PUSH_READY"), reason="needs a console-sent push message")
async def test_tc14_push_notification_opens_proposals(artemis):
    got = await artemis(
        "Make sure you are signed in, then press the Home button so the app is in the background. "
        "Wait up to 90 seconds for a notification to appear in the notification shade, open the "
        "shade, and tap the TeamUp notification. Report opened_title (the title of the screen "
        "that opens) and notification_listed (true if Profile → Notifications lists a "
        "notification afterwards).",
        ["opened_title", "notification_listed"],
    )
    assert got.values["opened_title"] == "Proposals"
    assert got.values["notification_listed"] is True
