"""TC-05 … TC-08 — Flow A: import a class, run the matching, open a proposal.

The class used by these tests is the CSV fixture committed at
``tool/fixtures/lab3-demo.csv`` (12 students, 1 class, 2 groups).
"""

from __future__ import annotations

from conftest import run


def test_tc05_import_class_list(artemis):
    """TC-05 (Flow A, S22 → S23).

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
