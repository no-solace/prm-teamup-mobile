"""Profile / Firebase demo area: Remote Config, PDF export + upload, notifications, offline error."""

import os

import pytest

from conftest import IMPORT_DEMO, adb

# Remote Config before/after evidence: run once with the defaults, change the values in the
# Firebase console, run again with the new expectations (no rebuild in between).
EXPECT_AI_ENABLED = os.environ.get("EXPECT_RC_AI_ENABLED", "true").lower() == "true"
EXPECT_MAX_PROPOSALS = int(os.environ.get("EXPECT_RC_MAX_PROPOSALS", "3"))


async def test_tc10_remote_config_values_change_the_app(artemis, fixture_on_device):
    got = await artemis(
        IMPORT_DEMO
        + "On the class screen report match_button_visible (true if a 'Match with AI' button is "
        "visible). Then open the Profile tab, scroll to the 'Firebase demo' area and report "
        "ai_matching_enabled and max_proposals_shown exactly as printed there.",
        ["match_button_visible", "ai_matching_enabled", "max_proposals_shown"],
    )
    assert got.values["ai_matching_enabled"] in (EXPECT_AI_ENABLED, str(EXPECT_AI_ENABLED).lower())
    assert int(got.values["max_proposals_shown"]) == EXPECT_MAX_PROPOSALS
    # Behaviour, not just a printed value: the flag hides or shows the button.
    assert got.values["match_button_visible"] is EXPECT_AI_ENABLED


@pytest.mark.analytics
async def test_tc11_export_pdf_and_upload(artemis, fixture_on_device, analytics_log):
    got = await artemis(
        IMPORT_DEMO
        + "Open the Profile tab and scroll to the 'Firebase demo' area. Tap 'Select class' and "
        "choose 'EXE101 Demo'. Tap 'Generate and upload PDF'. While uploading report "
        "saw_progress (true if a percentage such as '40% uploaded' appeared). When it finishes "
        "report status_text (the exact status message shown, which starts with 'Uploaded') and "
        "saved_reports_visible (true if the 'Saved reports' list shows at least one item).",
        ["saw_progress", "status_text", "saved_reports_visible"],
    )
    assert got.values["saw_progress"] is True
    assert str(got.values["status_text"]).startswith("Uploaded")
    assert got.values["saved_reports_visible"] is True
    assert "report_export" in analytics_log.events(), analytics_log.raw()[-2000:]


@pytest.mark.native
async def test_tc12_notification_permission_dialog(artemis):
    # Android 13+: reset the permission so the system dialog appears again.
    adb("shell", "pm", "revoke", os.environ.get("TEAMUP_APP_ID", "com.group6.teamup_exe"),
        "android.permission.POST_NOTIFICATIONS", check=False)
    got = await artemis(
        "Make sure you are signed in. Open the Profile tab, open 'Notifications', tap "
        "'Enable / check notifications'. If the Android permission dialog appears, tap 'Allow'. "
        "Report dialog_appeared (true if the system permission dialog was shown) and "
        "permission_text (the exact permission status sentence shown in the app afterwards).",
        ["dialog_appeared", "permission_text"],
    )
    assert got.values["dialog_appeared"] is True
    assert "allow" in str(got.values["permission_text"]).lower()


@pytest.mark.error_path
async def test_tc13_offline_matching_shows_error_with_retry(artemis, fixture_on_device):
    # Import first (needs network), then cut the network before matching.
    adb("shell", "cmd", "connectivity", "airplane-mode", "disable", check=False)
    try:
        got = await artemis(
            IMPORT_DEMO
            + "Now turn on Airplane mode from the quick settings panel. Return to the app, tap "
            "'Match with AI' and wait up to 40 seconds. Report error_visible (true if an error "
            "message is shown instead of proposals) and retry_label (the exact label of the "
            "retry button, or null). Turn Airplane mode off again and tap the retry button; "
            "report recovered (true if proposals or the 'No match found' screen appears).",
            ["error_visible", "retry_label", "recovered"],
        )
    finally:
        adb("shell", "cmd", "connectivity", "airplane-mode", "disable", check=False)
    assert got.values["error_visible"] is True
    assert got.values["retry_label"] == "Try again"
    assert got.values["recovered"] is True
