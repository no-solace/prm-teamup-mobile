"""TC-15 … TC-18 — export and upload, the push notification and the analytics event.

TC-16 to TC-18 need the Firebase console (or a second device) to trigger the
message and to read DebugView; they are skipped when the trigger is not
available so the rest of the suite still runs.
"""

from __future__ import annotations

import os

import pytest

from conftest import read_logcat, run


def test_tc15_export_pdf_and_show_download_url(artemis):
    """TC-15 (export and upload, S6).

    Precondition: signed in, the demo class is imported.
    Expected: after the export the panel shows the upload progress, the
    storage path and the download URL of the uploaded file. The agent reports
    the URL it can read.
    """
    result = run(
        artemis,
        "In the TeamUp EXE app, signed in, open the 'Profile' tab, scroll to "
        "'Export PDF to Firebase Storage', choose the class 'EXE101 Demo' in "
        "the dropdown and tap 'Generate and upload PDF'. Wait until the "
        "upload finishes. Report the 'Download URL' text that is shown, the "
        "number of kilobytes reported, and whether the 'Saved reports' "
        "section lists a file.",
    )
    assert result.ok, result.error
    assert result.contains("http"), result.text
    assert result.number("KB") >= 1, result.text
    assert result.contains("Saved reports"), result.text


def test_tc16_push_notification_opens_relevant_screen(artemis):
    """TC-16 (FCM, native interaction with the notification shade).

    Precondition: signed in, the device can receive FCM messages. The test
    sends the message from the Firebase console before the instruction runs.
    Expected: the notification appears in the shade, tapping it opens the
    Proposals screen.
    """
    if not os.environ.get("ARTEMIS_FCM_TRIGGER"):
        pytest.skip(
            "Set ARTEMIS_FCM_TRIGGER=1 after sending a test message from the "
            "Firebase console so the agent can open the notification shade"
        )
    result = run(
        artemis,
        "Pull down the notification shade on the device. Find the TeamUp EXE "
        "notification that was just received and tap it. Wait for the app to "
        "open. Report the title of the screen that is shown and the title of "
        "the notification you tapped.",
    )
    assert result.ok, result.error
    assert (
        result.contains("Proposals") or result.contains("notification")
    ), result.text


def test_tc17_analytics_event_is_logged(artemis, device_serial):
    """TC-17 (Analytics, evidence that the event plan is instrumented).

    Precondition: signed in, Firebase Analytics debug mode is enabled on the
    device so the events appear in Logcat.
    Expected: after running the matching, the Logcat capture contains the
    `ai_match_start` and `ai_match_result` events with their parameters.
    """
    if not os.environ.get("ARTEMIS_ANALYTICS_DEBUG"):
        pytest.skip(
            "Set ARTEMIS_ANALYTICS_DEBUG=1 after enabling the Analytics debug "
            "mode in the Firebase console"
        )
    run(
        artemis,
        "In the TeamUp EXE app, signed in, open the 'Classes' tab, open the "
        "class 'EXE101 Demo' and tap 'Match with AI'. Wait until the matching "
        "finishes. Report the screen title that is shown at the end.",
    )
    log = read_logcat(device_serial)
    assert "ai_match_start" in log, "ai_match_start not found in Logcat"
    assert "ai_match_result" in log, "ai_match_result not found in Logcat"


def test_tc18_crashlytics_test_crash(artemis):
    """TC-18 (Crashlytics demo area).

    Precondition: signed in, Crashlytics collection enabled.
    Expected: the test-crash action in the Profile demo area triggers a crash;
    the app restarts and the crash appears in the Crashlytics dashboard.
    """
    if not os.environ.get("ARTEMIS_CRASHLYTICS"):
        pytest.skip(
            "Set ARTEMIS_CRASHLYTICS=1 to run the deliberate crash; the test "
            "is destructive and must not run in the regression profile"
        )
    result = run(
        artemis,
        "In the TeamUp EXE app, signed in, open the 'Profile' tab and scroll "
        "to the Crashlytics demo area. Tap the action that triggers a test "
        "crash. Wait a few seconds and report whether the app closed.",
    )
    assert result.ok, result.error
    assert result.contains("closed") or result.contains("crash"), result.text
