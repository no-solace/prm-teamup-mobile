"""Exploratory session (Lab 3 §7).

One unscripted session of 15–30 minutes in the ARTEMIS *pro* profile. The
exploratory agent is asked to use the app like a real mentor would and to
report what confused it. The report is written to
``evidence/artemis/exploratory/``.

Run it explicitly, it is never part of the regression run:

    ARTEMIS_PROFILE=pro pytest e2e_test/test_exploratory.py -s -m exploratory
"""

from __future__ import annotations

import os
from datetime import datetime, timezone

import pytest

from conftest import REPORT_DIR, run

EXPLORATORY_DIR = REPORT_DIR / "exploratory"

PROMPT = (
    "Explore the TeamUp EXE app on this device like a real mentor would, for "
    "about 15 minutes. The app groups students into teams of 5 to 6 people "
    "with different majors. Try to: sign in, look at your classes, import a "
    "class list if possible, run the AI matching, open a proposal, add or "
    "remove a member, approve a team, and export a PDF report from the "
    "Profile tab. You may also try to break things: tap buttons twice, open "
    "the same screen from different places, and see what happens when you go "
    "back.\n"
    "Do NOT follow a script. Report at the end:\n"
    "1. every screen you reached and what it showed,\n"
    "2. every point where you were unsure what to do or where the wording was "
    "unclear,\n"
    "3. every error message, empty state or visual defect you saw, with the "
    "exact wording,\n"
    "4. every action you wanted to do but could not,\n"
    "5. the number of proposals shown on the Proposals tab."
)


@pytest.mark.exploratory
def test_exploratory_session(artemis):
    """Unscripted exploratory run; the findings are written to evidence/."""
    if os.environ.get("ARTEMIS_PROFILE", "flash") != "pro":
        pytest.skip("The exploratory session requires ARTEMIS_PROFILE=pro")
    EXPLORATORY_DIR.mkdir(parents=True, exist_ok=True)
    result = run(artemis, PROMPT)
    stamp = datetime.now(timezone.utc).strftime("%Y%m%dT%H%M%SZ")
    report = EXPLORATORY_DIR / f"exploratory_{stamp}.md"
    report.write_text(
        "# Exploratory session report\n\n"
        f"- Run at: {stamp}\n"
        "- Profile: pro\n"
        f"- Agent status: {result.status}\n"
        f"- Screenshot: {result.screenshot or '(none)'}\n\n"
        "## Agent report\n\n"
        f"{result.text}\n",
        encoding="utf-8",
    )
    print(f"Exploratory report written to {report}")
    assert result.ok, result.error
