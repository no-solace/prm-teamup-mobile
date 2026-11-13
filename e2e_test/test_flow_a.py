"""Flow A: import a class, run the AI matching, open and approve a proposal.

The class used by these tests is the CSV fixture committed at
``tools/fixtures/lab3-demo.csv`` (12 students, 1 class, 2 groups).

Two flavours of the same journey live here:

* the free-text tests (TC-05 … TC-08) ask the agent to describe what it saw
  and search the report;
* the JSON tests (TC-04, TC-05 upstream) ask for named keys and compare
  exact numbers.
"""

from __future__ import annotations

import pytest

from conftest import IMPORT_DEMO, run


@pytest.mark.analytics
async def test_tc04_import_csv_shows_counts(artemis, fixture_on_device, analytics_log):
    """TC-04 (Flow A, S22 → S23).

    Expected: the import preview names the file and the five detected
    columns, the result screen shows the three counts (imported, in a group,
    available) and the class is opened.
    """
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
    """TC-05 (Flow A, primary action: S3 → S8 → S9 → S12 → S14).

    Expected: the matching lands on the Proposals tab, a proposal card shows
    the members after the additions, and approving it shows the confirmation.
    """
    # Compare counts before/after instead of absolute values: proposals left
    # by other classes of the test account must not break this test.
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


def test_tc05_import_class_list(artemis):
    """TC-05 (Flow A, S22 → S23) in the free-text style.

    Precondition: signed in, no class imported yet (or the demo class
    imported in an earlier session).
    Expected: the import screen shows the chosen file name, the five detected
    columns and a button that says how many students will be imported. The
    agent reports the file name and the number of students.
    """
    result = run(
        artemis,
        "In the TeamUp EXE app, signed in, on the 'Classes' tab, tap the "
        "'Import class list' button. On the import screen, tap 'Choose CSV' "
        "and pick the file named 'lab3-demo.csv' from the device's file "
        "picker. Wait for the preview. Report the file name shown, the number "
        "of columns marked as detected, and the number of students that the "
        "import button says it will import.",
    )
    assert result.ok, result.error
    assert result.contains("lab3-demo.csv"), result.text
    assert result.number("columns") == 5, result.text
    assert result.number("students") == 12, result.text


def test_tc06_import_result_shows_counts(artemis):
    """TC-06 (Flow A, S23).

    Precondition: the demo CSV has just been imported.
    Expected: the result screen shows three numbers — imported, in a group and
    available — and a button that opens the class. The agent reports the
    three numbers.
    """
    result = run(
        artemis,
        "In the TeamUp EXE app, signed in, on the 'Classes' tab, tap "
        "'Import class list', choose the file 'lab3-demo.csv' and then tap "
        "the button that starts with 'Import'. Wait for the import result "
        "screen. Report the number shown next to 'imported', the number shown "
        "next to 'in a group' and the number shown next to 'available'.",
    )
    assert result.ok, result.error
    assert result.number("imported") == 12, result.text
    assert result.number("in a group") == 9, result.text
    assert result.number("available") == 3, result.text


def test_tc07_match_with_ai_creates_proposals(artemis):
    """TC-07 (Flow A, primary action: S3 → S8 → S9).

    Precondition: signed in, the demo class is imported and has students
    without a team.
    Expected: running the matching lands on the Proposals tab and at least
    one proposal card is visible. The agent reports the number of proposal
    cards and the first team name.
    """
    result = run(
        artemis,
        "In the TeamUp EXE app, signed in, open the 'Classes' tab, open the "
        "class named 'EXE101 Demo', and tap the 'Match with AI' button. Wait "
        "until the matching finishes and the app shows the 'Proposals' tab. "
        "Report how many proposal cards are visible and the name of the first "
        "team shown on the first card.",
    )
    assert result.ok, result.error
    assert result.number("cards") >= 1, result.text
    assert result.contains("Proposals"), result.text


def test_tc08_open_proposal_detail_shows_majors(artemis):
    """TC-08 (Flow A/B, detail screen S10).

    Precondition: signed in, at least one pending proposal.
    Expected: the proposal detail screen shows the major slots, the fit chip
    ('Strong fit' or 'Good fit') and the 'Why this team?' section. The agent
    reports the fit label and the number of major slots.
    """
    result = run(
        artemis,
        "In the TeamUp EXE app, signed in, open the 'Proposals' tab and tap "
        "the first proposal card. Wait for the proposal detail screen. Report "
        "the fit label that is visible ('Strong fit' or 'Good fit'), the "
        "number of major slots shown in the major slot row, and whether the "
        "heading 'Why this team?' is visible.",
    )
    assert result.ok, result.error
    assert (
        result.contains("Strong fit") or result.contains("Good fit")
    ), result.text
    assert result.number("slots") >= 1, result.text
    assert result.contains("Why this team?"), result.text
