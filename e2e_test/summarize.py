"""Build the results table (test, runs, pass rate, average time) from JUnit XML files.

Usage:  uv run python summarize.py runs/run1.xml runs/run2.xml runs/run3.xml
A test that does not pass in every run is flagged FLAKY and must be explained in docs/test-plan.md.
"""

from __future__ import annotations

import sys
import xml.etree.ElementTree as ET
from collections import defaultdict


def main(paths: list[str]) -> int:
    stats: dict[str, dict[str, float]] = defaultdict(
        lambda: {"runs": 0, "passed": 0, "skipped": 0, "seconds": 0.0}
    )
    for path in paths:
        for case in ET.parse(path).getroot().iter("testcase"):
            row = stats[case.get("name", "?")]
            if case.find("skipped") is not None:
                row["skipped"] += 1
                continue
            row["runs"] += 1
            row["seconds"] += float(case.get("time", 0))
            if case.find("failure") is None and case.find("error") is None:
                row["passed"] += 1
    print("| Test | Runs | Passed | Pass rate | Avg time (s) | Verdict |")
    print("|---|---|---|---|---|---|")
    for name, row in sorted(stats.items()):
        runs, passed = int(row["runs"]), int(row["passed"])
        if runs == 0:
            print(f"| {name} | 0 | 0 | n/a | n/a | SKIPPED |")
            continue
        verdict = "OK" if passed == runs else ("FAILED" if passed == 0 else "FLAKY")
        print(
            f"| {name} | {runs} | {passed} | {passed / runs:.0%} | {row['seconds'] / runs:.0f} | {verdict} |"
        )
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
