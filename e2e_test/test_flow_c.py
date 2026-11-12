"""Lab 2 Flow C: discard an AI proposal and fall back to manual matching (S17, S5, S16, S21)."""

import pytest

from conftest import IMPORT_DEMO


@pytest.mark.error_path
async def test_tc07_discard_then_manual_add_search_empty(artemis, fixture_on_device):
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
