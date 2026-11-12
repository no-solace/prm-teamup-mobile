"""Fixtures for the ARTEMIS suite.

Nothing secret lives in this repository. Configure through environment variables:

    ARTEMIS_BASE_URL     ARTEMIS host, default http://127.0.0.1:8000
    ARTEMIS_TOKEN        optional host token
    ARTEMIS_DEVICE       adb serial (see `adb devices`), optional if one device
    ARTEMIS_PROFILE      flash (default, regression) or pro (exploratory only)
    TEAMUP_RUNS_DIR      where to write one JSON line per run, default e2e_test/runs
    TEAMUP_APP_ID        Android application id, default com.group6.teamup_exe

The model API key is configured on the ARTEMIS host (its .env), never here.
The Google test account must be a dedicated account that is already added to the
emulator/device. Do not use a personal account.
"""

from __future__ import annotations

import json
import os
import re
import subprocess
import time
from dataclasses import dataclass
from pathlib import Path
from typing import Any

import pytest
from artemis_client import ArtemisClient

APP_ID = os.environ.get("TEAMUP_APP_ID", "com.group6.teamup_exe")
RUNS_DIR = Path(os.environ.get("TEAMUP_RUNS_DIR", Path(__file__).parent / "runs"))

# Every instruction starts from the same known state so tests do not depend on
# each other's order (Lab 3 section 7).
PREAMBLE = (
    f"The TeamUp EXE app (package {APP_ID}) is installed. Force-stop it and open it fresh. "
)

# Appended to every instruction: the agent returns what it sees, and the test
# compares those values with the expected ones instead of trusting "SUCCESS".
REPORT_RULE = (
    " When finished, answer with ONE line of JSON and nothing else, using exactly the keys "
    "requested above. Report only values you actually saw on screen; use null if not visible."
)


@dataclass
class Observed:
    """What the agent reported, plus the run metadata used as evidence."""

    values: dict[str, Any]
    trace_id: str
    seconds: float
    status: str


def parse_report(output: Any) -> dict[str, Any]:
    """Extract the JSON object the agent was asked to return."""
    if isinstance(output, dict):
        return output
    text = output if isinstance(output, str) else json.dumps(output, default=str)
    start, end = text.find("{"), text.rfind("}")
    if start == -1 or end <= start:
        raise AssertionError(f"Agent did not return a JSON object: {text!r}")
    return json.loads(text[start : end + 1])


@pytest.fixture(scope="session")
def client() -> ArtemisClient:
    kwargs: dict[str, Any] = {
        "device_serial": os.environ.get("ARTEMIS_DEVICE"),
        "default_profile": os.environ.get("ARTEMIS_PROFILE", "flash"),
    }
    if token := os.environ.get("ARTEMIS_TOKEN"):
        kwargs["token"] = token
    return ArtemisClient(os.environ.get("ARTEMIS_BASE_URL", "http://127.0.0.1:8000"), **kwargs)


@pytest.fixture
def artemis(client: ArtemisClient, request: pytest.FixtureRequest):
    """Returns `run(goal, expected_keys)` that executes one instruction and logs the run."""

    async def run(goal: str, expected_keys: list[str] | None = None, **kwargs: Any) -> Observed:
        keys = expected_keys or []
        shape = "{" + ", ".join(f'"{k}": ...' for k in keys) + "}"
        full_goal = PREAMBLE + goal + REPORT_RULE
        started = time.monotonic()
        result = await client.run(
            full_goal,
            expected_output=f"One line of JSON shaped like {shape}",
            enable_outputter=True,
            **kwargs,
        )
        seconds = time.monotonic() - started
        RUNS_DIR.mkdir(parents=True, exist_ok=True)
        with (RUNS_DIR / "runs.jsonl").open("a", encoding="utf-8") as log:
            log.write(
                json.dumps(
                    {
                        "test": request.node.name,
                        "status": result.status,
                        "trace_id": result.trace_id,
                        "seconds": round(seconds, 1),
                        "error": result.error,
                        "output": result.output,
                    },
                    default=str,
                )
                + "\n"
            )
        assert result.succeeded, f"{result.status}: {result.error} (trace {result.trace_id})"
        values = parse_report(result.output) if keys else {}
        missing = [k for k in keys if k not in values]
        assert not missing, f"Agent omitted {missing}; got {values} (trace {result.trace_id})"
        return Observed(values, result.trace_id, seconds, result.status)

    return run


# ---------------------------------------------------------------- adb helpers
def adb(*args: str, check: bool = True) -> str:
    """Run an adb command against the selected device and return stdout."""
    cmd = ["adb"]
    if serial := os.environ.get("ARTEMIS_DEVICE"):
        cmd += ["-s", serial]
    proc = subprocess.run(cmd + list(args), capture_output=True, text=True, encoding="utf-8")
    if check and proc.returncode != 0:
        raise RuntimeError(f"adb {' '.join(args)} failed: {proc.stderr.strip()}")
    return proc.stdout


@pytest.fixture
def analytics_log():
    """Logcat capture for tests marked `analytics`.

    Verbose Analytics logging makes the SDK print `Logging event ... name=<event>` lines.
    Call `analytics_log.events()` after the run to get the names that were logged.
    """
    adb("shell", "setprop", "log.tag.FA", "VERBOSE")
    adb("shell", "setprop", "log.tag.FA-SVC", "VERBOSE")
    adb("logcat", "-c")

    class _Log:
        @staticmethod
        def raw() -> str:
            return adb("logcat", "-d", "-s", "FA", "FA-SVC")

        @staticmethod
        def events() -> set[str]:
            return set(re.findall(r"name=([a-z_]+)", _Log.raw()))

    return _Log()


@pytest.fixture
def fixture_on_device() -> str:
    """Pushes the demo CSV to the device Download folder; returns its file name."""
    local = Path(__file__).resolve().parent.parent / "tool" / "fixtures" / "lab3-demo.csv"
    adb("push", str(local), "/sdcard/Download/lab3-demo.csv")
    return "lab3-demo.csv"


# Reusable instruction fragment: import the demo class so a test never relies on data
# left behind by another test (every import creates a brand-new class).
IMPORT_DEMO = (
    "Make sure you are signed in (use Continue with Google and the test account if asked). "
    "On the Classes tab tap 'Import class list', tap 'Choose CSV', pick 'lab3-demo.csv' from "
    "Downloads, tap 'Import 12 students', then tap 'Open EXE101 Demo' on the Import result screen. "
    "You are now on the class screen of the class you just imported. "
)
