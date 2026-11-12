"""Flow B: add a member, the 6-member cap and the blocked approval.

These tests cover the two error paths of Flow B: S13 (more than six members)
and S25 (fewer than five members).
"""

from __future__ import annotations

import pytest

from conftest import IMPORT_DEMO, run


def test_tc09_add_member_to_proposal(artemis):
    """TC-09 (Flow B, S10 → S11).

    Precondition: signed in, a pending proposal with fewer than six members.
    Expected: the Add member screen shows the Lab 2 meta line ("FinLite, 4 of
    6") and the available students. The agent reports the meta line and the
    number of selectable rows.
    """
    result = run(
        artemis,
        "In the TeamUp EXE app, signed in, open the 'Proposals' tab, tap the "
        "first proposal card, then tap 'Add member'. Wait for the add member "
        "screen. Report the meta line that shows the team name and the count "
        "of members out of six, and the number of student rows that have a "
        "checkbox.",
    )
    assert result.ok, result.error
    assert result.contains("of 6"), result.text
    assert result.number("rows") >= 1, result.text


def test_tc10_max_six_members_error(artemis):
    """TC-10 (Flow B, error path S13).

    Precondition: signed in, a pending proposal whose team already has five
    members.
    Expected: the inline error 'Max 6 members' is visible and the confirm
    button is disabled. The agent reports the error text and whether the
    button can be tapped.
    """
    result = run(
        artemis,
        "In the TeamUp EXE app, signed in, open the 'Proposals' tab and tap "
        "the first proposal card. Tap 'Add member', then tick one more "
        "student checkbox so the team would have more than six members. "
        "Report the exact error message that appears on the screen, and "
        "report whether the confirm button at the bottom is enabled or "
        "disabled.",
    )
    assert result.ok, result.error
    assert result.contains("Max 6 members"), result.text
    assert result.contains("disabled"), result.text


def test_tc11_approve_blocked_below_five_members(artemis):
    """TC-11 (Flow B, error path S25).

    Precondition: signed in, a pending proposal; a member is removed first so
    the team drops below five members.
    Expected: the inline error 'Needs at least 5 members' is visible and the
    Approve button is disabled. The agent reports the error text with the
    current member count and whether the button is enabled.
    """
    result = run(
        artemis,
        "In the TeamUp EXE app, signed in, open the 'Proposals' tab and tap "
        "the first proposal card. Tap the remove icon next to a member of the "
        "'Members' section and confirm the 'Remove' action. Wait for the "
        "screen to update. Report the exact error banner text that is visible "
        "and whether the 'Approve proposal' button is enabled or disabled.",
    )
    assert result.ok, result.error
    assert result.contains("Needs at least 5 members"), result.text
    assert result.contains("disabled"), result.text


@pytest.mark.error_path
async def test_tc06_remove_members_blocks_approve_below_five(artemis, fixture_on_device):
    """TC-06 (Flow B, error path S24 → S25) in the JSON style.

    Expected: removing two added members drops the team below five, the error
    banner shows the current count and the Approve button is disabled.
    """
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
