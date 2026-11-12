"""Flow C: manual grouping, the no-result state and the discard dialog.

Flow C is the alternative path of the product: when the matching finds
nothing, the mentor groups the students by hand.
"""

from __future__ import annotations

import pytest

from conftest import IMPORT_DEMO, run


def test_tc12_need_members_shows_major_gaps(artemis):
    """TC-12 (Flow C, S5).

    Precondition: signed in, the demo class is imported and has a team with
    fewer than six members.
    Expected: the 'Teams needing members' screen lists at least one team with
    its member count and the line 'Needs ... to reach 5'. The agent reports
    the number of team cards and the member count of the first one.
    """
    result = run(
        artemis,
        "In the TeamUp EXE app, signed in, open the 'Classes' tab, open the "
        "class 'EXE101 Demo' and tap the row that leads to the teams needing "
        "members. Wait for that screen. Report the number of team cards "
        "visible, the member count written on the first card, and whether a "
        "line starting with 'Needs' is visible on the first card.",
    )
    assert result.ok, result.error
    assert result.number("cards") >= 1, result.text
    assert result.contains("Needs"), result.text


def test_tc13_add_student_no_results(artemis):
    """TC-13 (Flow C, error path S21).

    Precondition: signed in, the add-student screen is open.
    Expected: searching for a name that does not exist shows the empty state
    'No student results' and no student rows. The agent reports the empty
    message and the number of rows.
    """
    result = run(
        artemis,
        "In the TeamUp EXE app, signed in, open the 'Classes' tab, open the "
        "class 'EXE101 Demo', open the teams needing members screen and tap "
        "the first team card to reach the add student screen. Type 'ZZZNOONE' "
        "into the search field and wait for the list to refresh. Report the "
        "empty-state message that is visible and the number of student rows "
        "visible.",
    )
    assert result.ok, result.error
    assert result.contains("No student"), result.text
    assert result.number("rows") == 0, result.text


def test_tc14_discard_dialog(artemis):
    """TC-14 (Flow C, S17).

    Precondition: signed in, a pending proposal.
    Expected: the discard confirmation dialog asks 'Discard proposal?' and
    offers a destructive 'Discard' action and a 'Cancel' action. The agent
    reports both labels and then cancels, so the proposal stays pending.
    """
    result = run(
        artemis,
        "In the TeamUp EXE app, signed in, open the 'Proposals' tab and tap "
        "the first proposal card. Tap 'Discard proposal'. Wait for the "
        "dialog. Report the dialog title, the label of the red button and the "
        "label of the other button. Then tap 'Cancel' so nothing is "
        "discarded.",
    )
    assert result.ok, result.error
    assert result.contains("Discard proposal?"), result.text
    assert result.contains("Discard"), result.text
    assert result.contains("Cancel"), result.text


@pytest.mark.error_path
async def test_tc07_discard_then_manual_add_search_empty(artemis, fixture_on_device):
    """TC-07 (Flow C, S17 → S5 → S16 → S21) in the JSON style.

    Expected: discarding the AI proposal frees the card, and the manual
    search shows the empty state.
    """
    got = await artemis(
        IMPORT_DEMO
        + "Tap 'Match with AI' and wait; the Proposals tab opens. Report group2_before (how many "
        "cards are named 'Group 2'). Open one 'Group 2' card, scroll down, tap 'Discard proposal' "
        "and tap 'Confirm'. Go to the Proposals tab and report group2_after. Then open Classes, "
        "open the class 'EXE101 Demo' you imported most recently, open the list of teams needing "
        "members, choose 'Add student' for Group 2 and type 'ZZZ' in the search field. Report "
        "empty_title (the exact empty-state title shown, or null).",
        ["group2_before", "group2_after", "empty_title"],
    )
    assert got.values["group2_after"] == got.values["group2_before"] - 1
    assert got.values["empty_title"] == "No student results"
