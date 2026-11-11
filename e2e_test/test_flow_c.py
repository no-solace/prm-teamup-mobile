"""TC-12 … TC-14 — Flow C: manual grouping, the no-result state and the discard dialog.

Flow C is the alternative path of the product: when the matching finds
nothing, the mentor groups the students by hand.
"""

from __future__ import annotations

from conftest import run


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
