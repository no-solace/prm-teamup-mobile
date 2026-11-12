"""Lab 2 Flow A: import a class (S22, S23), then AI matching and approval (S8, S9, S10, S12, S14)."""

import pytest

from conftest import IMPORT_DEMO


@pytest.mark.analytics
async def test_tc04_import_csv_shows_counts(artemis, fixture_on_device, analytics_log):
    got = await artemis(
        "Make sure you are signed in. On the Classes tab tap 'Import class list', tap 'Choose CSV' "
        "and pick 'lab3-demo.csv' from Downloads. Report preview_button (the exact label of the "
        "import button). Tap it. On the Import result screen report imported, in_a_group and "
        "available (the three numbers shown).",
        ["preview_button", "imported", "in_a_group", "available"],
    )
    assert got.values["preview_button"] == "Import 12 students"
    assert (got.values["imported"], got.values["in_a_group"], got.values["available"]) == (12, 9, 3)
    assert "class_import" in analytics_log.events(), analytics_log.raw()[-2000:]


@pytest.mark.analytics
async def test_tc05_match_with_ai_then_approve(artemis, fixture_on_device, analytics_log):
    # Compare counts before/after instead of absolute values: proposals left by other
    # classes of the test account must not break this test.
    got = await artemis(
        IMPORT_DEMO
        + "Tap 'Match with AI' and wait up to 30 seconds; the Proposals tab opens. Report "
        "group2_before (how many proposal cards are named 'Group 2'). Open one card named "
        "'Group 2' and report member_count (the number of members after the additions). Scroll "
        "down, tap 'Approve proposal' and tap 'Confirm'. Report approved_message (the exact "
        "snackbar text shown). Go back to the Proposals tab and report group2_after (how many "
        "cards are named 'Group 2' now).",
        ["group2_before", "member_count", "approved_message", "group2_after"],
    )
    assert got.values["group2_before"] >= 1
    assert got.values["member_count"] == 6
    assert got.values["approved_message"] == "Team approved"
    assert got.values["group2_after"] == got.values["group2_before"] - 1
    events = analytics_log.events()
    assert {"ai_match_start", "ai_match_result", "proposal_approve"} <= events, analytics_log.raw()[-2000:]
