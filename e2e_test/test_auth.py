"""Authentication: Google account picker (native), sign-out, invalid e-mail error path."""

import pytest


@pytest.mark.native
@pytest.mark.analytics
async def test_tc01_google_sign_in_account_picker(artemis, analytics_log):
    got = await artemis(
        "The user is signed out, so the Sign in screen is shown. Tap 'Continue with Google'. "
        "In the Android account picker choose the test account. Wait for the app to load. "
        "Report: signed_in (true if the 'My classes' screen is visible), "
        "tabs (the labels of the bottom navigation bar, in order).",
        ["signed_in", "tabs"],
    )
    assert got.values["signed_in"] is True
    assert [t.lower() for t in got.values["tabs"]] == ["classes", "proposals", "profile"]
    assert "login" in analytics_log.events(), analytics_log.raw()[-2000:]


async def test_tc02_sign_out_returns_to_sign_in(artemis):
    got = await artemis(
        "Make sure you are signed in. Open the Profile tab, scroll down and tap 'Sign out'. "
        "Report: sign_in_visible (true if 'Continue with Google' is visible), "
        "classes_tab_visible (true if a bottom bar with 'Classes' is still visible). "
        "Then force-stop and reopen the app and report relaunch_sign_in_visible "
        "(true if 'Continue with Google' is visible again).",
        ["sign_in_visible", "classes_tab_visible", "relaunch_sign_in_visible"],
    )
    assert got.values["sign_in_visible"] is True
    assert got.values["classes_tab_visible"] is False
    assert got.values["relaunch_sign_in_visible"] is True


@pytest.mark.error_path
async def test_tc03_invalid_email_shows_error(artemis):
    got = await artemis(
        "Sign out first if you are signed in, so the Sign in screen is shown. Tap 'Email and "
        "password', type 'abc' in the Email field and 'Passw0rd!' in the Password field, then tap "
        "the sign-in button. Report: error_text (the exact error message shown, or null), "
        "reached_classes (true if the 'My classes' screen appeared).",
        ["error_text", "reached_classes"],
    )
    assert got.values["error_text"] == "Enter a valid email"
    assert got.values["reached_classes"] is False
