"""Lab 2 Flow B error path: removing members drops a team below 5 (S24, S25)."""

import pytest

from conftest import IMPORT_DEMO


@pytest.mark.error_path
async def test_tc06_remove_members_blocks_approve_below_five(artemis, fixture_on_device):
    got = await artemis(
        IMPORT_DEMO
        + "Tap 'Match with AI' and wait. Open one proposal named 'Group 2'. Remove two of the "
        "added members: tap the remove button of one added member, tap 'Remove' in the 'Remove "
        "member?' dialog, and repeat once more. Report banner_text (the exact error banner text "
        "shown, or null) and approve_enabled (true if the 'Approve proposal' button can be "
        "tapped). Do not approve. Finally scroll down, tap 'Discard proposal' and tap 'Confirm' "
        "so this test leaves no pending proposal behind.",
        ["banner_text", "approve_enabled"],
    )
    assert got.values["banner_text"] == "Needs at least 5 members (now 4)"
    assert got.values["approve_enabled"] is False
