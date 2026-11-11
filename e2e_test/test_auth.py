"""TC-01 … TC-04 — sign-in, the three top-level tabs and sign-out.

Each test states its own precondition and starts from it, so the order of the
tests does not matter.
"""

from __future__ import annotations

from conftest import run


def test_tc01_google_signin_reaches_classes_tab(artemis):
    """TC-01 (Flow A, native interaction).

    Precondition: the app is installed and signed out.
    Expected: the Classes tab is visible and the bottom navigation bar shows
    three tabs. The agent reports the number of visible bottom tabs.
    """
    result = run(
        artemis,
        "Open the TeamUp EXE app on the device. The sign-in screen is shown "
        "with a button labelled 'Continue with Google'. Tap that button, wait "
        "for the Google account picker, and choose the test Google account "
        "that is already configured on this device. Wait for the app to load. "
        "Report the title of the screen that is visible, the number of "
        "bottom-navigation tabs that are visible, and whether the word "
        "'Classes' is visible.",
    )
    assert result.ok, result.error
    assert result.contains("Classes"), result.text
    assert result.number("tabs") == 3, result.text


def test_tc02_open_each_top_level_tab(artemis):
    """TC-02 (navigation).

    Precondition: signed in.
    Expected: the three tabs open their own screens: Classes, Proposals and
    Profile. The agent reports which tab titles it saw.
    """
    result = run(
        artemis,
        "In the TeamUp EXE app, signed in, tap the bottom navigation tab named "
        "'Proposals' and report the screen title that appears. Then tap the "
        "tab named 'Profile' and report the screen title that appears. Then "
        "tap the tab named 'Classes' and report the screen title that "
        "appears. Report the three titles separated by commas.",
    )
    assert result.ok, result.error
    assert result.contains("Proposals"), result.text
    assert result.contains("Profile"), result.text
    assert result.contains("Classes"), result.text


def test_tc03_profile_shows_firebase_demo_area(artemis):
    """TC-03 (Remote Config on screen).

    Precondition: signed in.
    Expected: the Profile screen shows the Remote Config values, including the
    parameter name `max_proposals_shown` and its numeric value. The agent
    reports the value it reads.
    """
    result = run(
        artemis,
        "In the TeamUp EXE app, signed in, open the 'Profile' tab and scroll "
        "down to the Remote Config area. Read the line that starts with "
        "'max_proposals_shown'. Report the exact number that appears after "
        "the colon, and report whether the line 'ai_matching_enabled' is also "
        "visible.",
    )
    assert result.ok, result.error
    assert result.contains("max_proposals_shown"), result.text
    assert result.number("max_proposals_shown") >= 1, result.text


def test_tc04_sign_out_returns_to_sign_in(artemis):
    """TC-04 (sign-out).

    Precondition: signed in.
    Expected: after Sign out the app shows the sign-in screen again and the
    Classes screen is no longer reachable.
    """
    result = run(
        artemis,
        "In the TeamUp EXE app, signed in, open the 'Profile' tab, scroll to "
        "the bottom and tap the 'Sign out' button. Wait for the app to "
        "settle. Report the title of the screen that is now visible and "
        "whether the text 'Continue with Google' is visible.",
    )
    assert result.ok, result.error
    assert result.contains("Continue with Google"), result.text
