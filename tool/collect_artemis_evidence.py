"""Collect ARTEMIS evidence (screenshots + step log) into ``evidence/artemis``.

The ARTEMIS daemon exposes every session it ran, the steps of each session
and the screenshots it captured. This script copies that material into the
repository so the Lab 3 evidence folder is filled with material that was
actually produced by a run - not by hand.

Usage:

    python tool/collect_artemis_evidence.py
    python tool/collect_artemis_evidence.py --session <session-id>
    python tool/collect_artemis_evidence.py --base-url http://127.0.0.1:8000

The script is read-only with respect to the ARTEMIS host: it only issues GET
requests.
"""

from __future__ import annotations

import argparse
import json
import sys
import urllib.error
import urllib.request
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
EVIDENCE_ROOT = REPO_ROOT / "evidence" / "artemis"


def _get(url: str, timeout: float = 30.0) -> bytes:
    with urllib.request.urlopen(url, timeout=timeout) as response:
        return response.read()


def _get_json(url: str, timeout: float = 30.0):
    return json.loads(_get(url, timeout).decode("utf-8"))


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--base-url", default="http://127.0.0.1:8000")
    parser.add_argument("--session", default="", help="collect only this session id")
    parser.add_argument("--limit", type=int, default=0, help="max sessions (0 = all)")
    args = parser.parse_args()

    base = args.base_url.rstrip("/")
    try:
        sessions = _get_json(f"{base}/api/sessions")
    except (urllib.error.URLError, TimeoutError) as error:
        print(f"[FAIL] ARTEMIS host is not reachable at {base}: {error}")
        print("       Start it with:  uv run python -m artemis ui --port 8000 --no-open")
        return 1

    if args.session:
        sessions = [s for s in sessions if s.get("session_id") == args.session]
    if args.limit:
        sessions = sessions[: args.limit]

    if not sessions:
        print("[WARN] No ARTEMIS session found. Run the suite first:  tool\\run_e2e.ps1")
        return 1

    EVIDENCE_ROOT.mkdir(parents=True, exist_ok=True)
    total_images = 0

    for session in sessions:
        session_id = session.get("session_id")
        if not session_id:
            continue
        goal = (session.get("initial_goal") or "").strip()
        status = session.get("status")
        folder = EVIDENCE_ROOT / session_id
        folder.mkdir(parents=True, exist_ok=True)

        (folder / "session.json").write_text(
            json.dumps(session, indent=2, ensure_ascii=False), encoding="utf-8"
        )

        try:
            steps = _get_json(f"{base}/api/sessions/{session_id}/steps")
        except (urllib.error.URLError, TimeoutError, ValueError):
            steps = []

        report: list[str] = [
            f"# ARTEMIS session {session_id}",
            "",
            f"- **Goal**: {goal}",
            f"- **Status**: {status}",
            f"- **Steps**: {len(steps)}",
            "",
        ]
        images_dir = folder / "screenshots"
        images_dir.mkdir(exist_ok=True)

        for step in steps:
            number = step.get("step_number")
            summary = (step.get("summary") or "").strip()
            action = step.get("action_taken")
            report.append(f"## Step {number}")
            report.append("")
            if summary:
                report.append(summary)
                report.append("")
            if isinstance(action, dict):
                report.append("```json")
                report.append(json.dumps(action, indent=2, ensure_ascii=False)[:2000])
                report.append("```")
                report.append("")

            for key, label in (("pre_image_name", "before"), ("post_image_name", "after")):
                image_name = step.get(key)
                if not image_name:
                    continue
                try:
                    data = _get(f"{base}/api/images/{image_name}")
                except (urllib.error.URLError, TimeoutError):
                    continue
                target = images_dir / f"step-{number:02d}-{label}.jpg"
                target.write_bytes(data)
                total_images += 1
                report.append(f"![{label}](screenshots/{target.name})")
                report.append("")

        (folder / "report.md").write_text("\n".join(report), encoding="utf-8")
        print(f"[OK]   {session_id}: {len(steps)} step(s), status={status}")

    print()
    print(f"[DONE] Evidence written to {EVIDENCE_ROOT} ({total_images} screenshots).")
    return 0


if __name__ == "__main__":
    sys.exit(main())
