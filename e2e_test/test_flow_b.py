"""TC-09 … TC-11 — Flow B: add a member, the 6-member cap and the blocked approval.

These tests cover the two error paths of Flow B: S13 (more than six members)
and S25 (fewer than five members).
"""

from __future__ import annotations

from conftest import run


def test_tc09_add_member_to_proposal(artemis):
    """TC-09 (Flow B, S10 → S11).

    Precondition: signed in, a pending proposal with fewer than six members.
    Expected: the Add member screen shows the places counter and the
    available students. The agent reports the counter and the number of
    selectable rows.
    """
    result = run(
        artemis,
        "In the TeamUp EXE app, signed in, open the 'Proposals' tab, tap the "
        "first proposal card, then tap 'Add member'. Wait for the add member "
        "screen. Report the text of the line that says how many places are "
        "selected, and the number of student rows that have a checkbox.",
    )
    assert result.ok, result.error
    assert result.contains("places selected"), result.text
    assert result.number("rows") >= 1, result.text


def test_tc10_max_six_members_error(artemis):
    """TC-10 (Flow B, error path S13).

    Precondition: signed in, a pending proposal whose team already has six
    members, or a proposal that is filled to six in this test.
    Expected: the inline error 'Max 6 members' is visible and the confirm
    button is disabled. The agent reports the error text and whether the
    button can be tapped.
    """
    result = run(
        artemis,
        "In the TeamUp EXE app, signed in, open the 'Proposals' tab and tap "
        "the first proposal card. Tap 'Add member', then tick student "
        "checkboxes until the counter says the team has six members. Report "
        "the exact error message that appears on the screen, and report "
        "whether the 'Add' button at the bottom is enabled or disabled.",
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
