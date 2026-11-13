"""Pytest fixtures for the ARTEMIS end-to-end suite (Lab 3 §7).

The suite drives a real Android device through the **ARTEMIS Python SDK**
(``artemis-client``), which talks to an ARTEMIS host over HTTP. The client is
remote-only: it never imports an LLM provider or a device driver, so pytest
does not need a device to *collect* the suite.

Environment variables (never committed):
    ARTEMIS_BASE_URL     ARTEMIS host, e.g. ``http://127.0.0.1:8000``.
    ARTEMIS_TOKEN        Bearer token, if the ARTEMIS host requires one.
    ARTEMIS_DEVICE       ADB serial of the device, e.g. ``emulator-5554``.
    ARTEMIS_PROFILE      ``flash`` (regression) or ``pro`` (exploratory).
    ANDROID_SERIAL       Fallback for the ADB serial.
    ARTEMIS_TIMEOUT      Per-instruction timeout in seconds, default 1800.
    TEAMUP_APP_ID        Android application id, default com.group6.teamup_exe.

The model API key is configured on the ARTEMIS host (its ``.env``), never here.
The Google test account used for sign-in is configured on the device itself;
its credentials are NOT part of this repository.

Two observation styles are supported, because both are useful:

``run(artemis, instruction)``
    Asks the agent to report what it saw in free text and returns an
    :class:`Observed` whose ``text`` can be searched. This is what the
    exploratory session and the local test modules use.

``await artemis(instruction, keys)``
    Asks the agent to answer with one line of JSON and returns an
    :class:`Observed` whose ``values`` map is typed. The upstream suite uses
    this style because it asserts on exact numbers.

Both styles read the agent's final report back from the session steps when
the host does not return it directly; see :func:`_normalise`.
"""

from __future__ import annotations

import asyncio
import json
import os
import re
import subprocess
import time
import urllib.error
import urllib.request
from dataclasses import dataclass
from pathlib import Path
from typing import Any

import pytest

# The ARTEMIS SDK is pinned in pyproject.toml. Importing it lazily keeps the
# collection of the suite working (and `--collect-only`) on a machine where the
# SDK is not installed yet.
try:  # pragma: no cover - depends on the environment
    from artemis_client import ArtemisClient  # type: ignore
except Exception:  # pragma: no cover - the SDK is optional at collection time
    ArtemisClient = None  # type: ignore


REPO_ROOT = Path(__file__).resolve().parents[1]
#: Must match ``applicationId`` in ``android/app/build.gradle.kts``.
APP_PACKAGE = os.environ.get("TEAMUP_APP_ID", "com.group6.teamup_exe")
REPORT_DIR = REPO_ROOT / "evidence" / "artemis"
RUNS_DIR = Path(os.environ.get("TEAMUP_RUNS_DIR", Path(__file__).parent / "runs"))


@dataclass(frozen=True)
class Observed:
    """What the agent reported, normalised for assertions.

    The instruction always asks the agent to return the values it sees as
    structured output, e.g. "report the student count as the number N". This
    class turns that free text into values the test can compare.
    """

    status: str
    text: str
    error: str | None = None
    screenshot: str | None = None
    values: dict[str, Any] | None = None
    trace_id: str = ""
    seconds: float = 0.0

    @property
    def ok(self) -> bool:
        """True when the ARTEMIS task reached a successful terminal state."""
        return self.status.lower() in {"completed", "success"}

    def number(self, label: str | None = None) -> int:
        """Return the first integer in the report, optionally after ``label``."""
        pattern = rf"{label}\D{{0,20}}?(\d+)" if label else r"(\d+)"
        match = re.search(pattern, self.text, re.IGNORECASE)
        if not match:
            raise AssertionError(
                f"No number found in the agent report"
                f"{f' after {label!r}' if label else ''}:\n{self.text}"
            )
        return int(match.group(1))

    def contains(self, needle: str) -> bool:
        return needle.lower() in self.text.lower()


def parse_report(output: Any) -> dict[str, Any]:
    """Extract the JSON object the agent was asked to return."""
    if isinstance(output, dict):
        return output
    text = output if isinstance(output, str) else json.dumps(output, default=str)
    start, end = text.find("{"), text.rfind("}")
    if start == -1 or end <= start:
        raise AssertionError(f"Agent did not return a JSON object: {text!r}")
    return json.loads(text[start : end + 1])


#: Substrings that identify a provider quota / rate-limit failure in the
#: telemetry the ARTEMIS host records for a session.
_QUOTA_MARKERS = (
    "RESOURCE_EXHAUSTED",
    "429 Too Many Requests",
    "quota exceeded",
    "generate_content_free_tier_requests",
)


def _session_hit_quota(session_id: str) -> str:
    """Return the quota message if the session died on a rate limit.

    The ARTEMIS daemon retries a rate-limited LLM call for minutes before it
    gives up, so a run that is out of quota burns the whole timeout per test
    and then reports a bare ``failed``. Reading the recorded telemetry turns
    that into an explicit, actionable message.
    """
    steps = _fetch_session_steps(session_id)
    blob = json.dumps(steps, ensure_ascii=False)
    for marker in _QUOTA_MARKERS:
        if marker.lower() in blob.lower():
            return marker
    return ""


def _fetch_session_steps(session_id: str) -> list[dict]:
    """Return the recorded steps of an ARTEMIS session.

    The ARTEMIS daemon stores the final report of a Flash run as a step whose
    ``action_taken`` is ``report_task_status``. The remote client only
    receives the session metadata, so the steps are read back from the host.

    The host marks a session completed before it saves the last step, so a read
    right after the run can miss the report. Retry briefly until the
    ``report_task_status`` step shows up.
    """
    base = os.environ.get("ARTEMIS_BASE_URL", "http://127.0.0.1:8000").rstrip("/")
    url = f"{base}/api/sessions/{session_id}/steps"
    steps: list[dict] = []
    for attempt in range(10):
        if attempt:
            time.sleep(1.5)
        try:
            with urllib.request.urlopen(url, timeout=30) as response:
                payload = json.loads(response.read().decode("utf-8"))
        except (urllib.error.URLError, TimeoutError, ValueError):
            continue
        steps = payload if isinstance(payload, list) else []
        if any(
            (step.get("action_taken") or {}).get("action") == "report_task_status"
            for step in steps
        ):
            break
    return steps


def _extract_final_report(steps: list[dict]) -> str:
    """Pull the agent's final explanation out of the recorded steps."""
    for step in reversed(steps):
        action = step.get("action_taken")
        if not isinstance(action, dict):
            continue
        if action.get("action") != "report_task_status":
            continue
        args = action.get("args")
        if not isinstance(args, dict):
            continue
        explanation = args.get("explanation") or args.get("report") or args.get("summary")
        if isinstance(explanation, str) and explanation.strip():
            return explanation
    return ""


def _normalise(result) -> Observed:
    """Turn an ARTEMIS ``TaskResult`` into an :class:`Observed`.

    ``TaskResult.output`` may be a string or a structured payload, so every
    scalar is stringified before the text is searched. When the host does not
    return the report directly, it is read back from the session steps.
    """
    status = str(getattr(result, "status", "") or "")
    output = getattr(result, "output", None)
    if output is None:
        text = ""
    elif isinstance(output, str):
        text = output
    elif isinstance(output, dict):
        text = " ".join(
            f"{key}: {value}" for key, value in output.items() if not isinstance(value, dict)
        )
    else:
        text = str(output)
    error = getattr(result, "error", None)
    screenshot = (getattr(result, "raw", {}) or {}).get("screenshot")
    trace_id = str(getattr(result, "trace_id", "") or getattr(result, "session_id", "") or "")

    if not text.strip():
        session_id = (getattr(result, "raw", {}) or {}).get("session_id") or getattr(
            result, "session_id", None
        )
        if session_id:
            text = _extract_final_report(_fetch_session_steps(session_id))

    return Observed(status=status, text=text, error=error, screenshot=screenshot, trace_id=trace_id)


def _skip_if_out_of_quota(result) -> None:
    """Skip the test when the ARTEMIS host ran out of model quota.

    The cause is an account limit, not a defect in the app, and the suite
    would otherwise spend the whole timeout on every remaining test.
    """
    session_id = (getattr(result, "raw", {}) or {}).get("session_id") or getattr(
        result, "session_id", None
    )
    if session_id and _session_hit_quota(session_id):
        pytest.skip(
            "The ARTEMIS host is out of model quota "
            f"({_QUOTA_MARKERS[0]}). The free tier allows a limited number "
            "of requests per day and resets at 00:00 UTC. Re-run after the "
            "reset, or use a key with a higher quota."
        )


def _log_run(test: str, result, values: dict[str, Any] | None = None) -> None:
    """Append one JSON line per run so the suite leaves an audit trail."""
    RUNS_DIR.mkdir(parents=True, exist_ok=True)
    with (RUNS_DIR / "runs.jsonl").open("a", encoding="utf-8") as log:
        log.write(
            json.dumps(
                {
                    "test": test,
                    "status": getattr(result, "status", ""),
                    "trace_id": getattr(result, "trace_id", ""),
                    "error": getattr(result, "error", None),
                    "output": values,
                },
                default=str,
            )
            + "\n"
        )


class ArtemisRunner:
    """The object the ``artemis`` fixture hands to a test.

    It supports both calling styles used in this repository:

    * ``await artemis(goal, ["key", ...])`` — the agent answers with one line
      of JSON and the runner parses it into ``Observed.values``.
    * ``run(artemis, goal)`` (module-level helper) — the agent answers in free
      text and the caller searches ``Observed.text``.

    Both styles read the agent's final report back from the session steps when
    the host does not return it directly, and both skip the test when the host
    ran out of model quota.
    """

    def __init__(self, client: ArtemisClient, test_name: str = "") -> None:
        self._client = client
        self._test_name = test_name

    async def run(self, goal: str, expected_keys: list[str] | None = None, **kwargs: Any) -> Observed:
        """Run one instruction and return the normalised observation."""
        keys = expected_keys or []
        shape = "{" + ", ".join(f'"{k}": ...' for k in keys) + "}"
        full_goal = PREAMBLE + goal + REPORT_RULE
        result = await self._client.run(
            full_goal,
            expected_output=f"One line of JSON shaped like {shape}",
            enable_outputter=True,
            locked_app_package=APP_PACKAGE,
            timeout=float(os.environ.get("ARTEMIS_TIMEOUT", "1800")),
            **kwargs,
        )
        observed = _normalise(result)
        if not observed.ok:
            _skip_if_out_of_quota(result)
        values: dict[str, Any] = {}
        if keys:
            try:
                values = parse_report(observed.text)
            except (AssertionError, json.JSONDecodeError):
                # The host did not return the JSON line; the raw report is
                # still available so the assertion message shows what the
                # agent actually said.
                values = {}
            missing = [k for k in keys if k not in values]
            if missing:
                raise AssertionError(
                    f"Agent omitted {missing}; got {values or observed.text} "
                    f"(trace {observed.trace_id})"
                )
        _log_run(self._test_name, result, values)
        return Observed(
            status=observed.status,
            text=observed.text,
            error=observed.error,
            screenshot=observed.screenshot,
            values=values,
            trace_id=observed.trace_id,
        )

    async def __call__(self, goal: str, expected_keys: list[str] | None = None, **kwargs: Any) -> Observed:
        """``await artemis(goal, keys)`` is the same as ``artemis.run(...)``."""
        return await self.run(goal, expected_keys, **kwargs)


def run(artemis, instruction: str) -> Observed:
    """Send one instruction and return the normalised observation.

    ``ArtemisClient.run`` is a coroutine, so it is driven with
    ``asyncio.run``. The ARTEMIS host is a long-lived daemon; the client keeps
    no connection state between calls, so one event loop per instruction is
    safe.
    """
    if isinstance(artemis, ArtemisRunner):
        return asyncio.run(artemis.run(instruction))
    result = asyncio.run(
        artemis.run(
            instruction,
            locked_app_package=APP_PACKAGE,
            timeout=float(os.environ.get("ARTEMIS_TIMEOUT", "1800")),
        )
    )
    observed = _normalise(result)
    if not observed.ok:
        _skip_if_out_of_quota(result)
    return observed


@pytest.fixture(scope="session")
def device_serial() -> str:
    serial = os.environ.get("ARTEMIS_DEVICE") or os.environ.get("ANDROID_SERIAL")
    if not serial:
        pytest.skip("Set ARTEMIS_DEVICE (or ANDROID_SERIAL) to the device serial")
    return serial


@pytest.fixture(scope="session")
def profile() -> str:
    """``flash`` for regression, ``pro`` for the exploratory session."""
    value = os.environ.get("ARTEMIS_PROFILE", "flash").strip().lower()
    if value not in {"flash", "pro"}:
        pytest.fail(f"ARTEMIS_PROFILE must be 'flash' or 'pro'; got {value!r}")
    return value


@pytest.fixture(scope="session")
def client(device_serial: str, profile: str) -> ArtemisClient:
    """A session-wide ARTEMIS client bound to the device and the profile."""
    if ArtemisClient is None:  # pragma: no cover - depends on the environment
        pytest.skip("The ARTEMIS SDK is not installed (pip install -e '.[artemis]')")
    REPORT_DIR.mkdir(parents=True, exist_ok=True)
    return ArtemisClient(
        base_url=os.environ.get("ARTEMIS_BASE_URL", "http://127.0.0.1:8000"),
        token=os.environ.get("ARTEMIS_TOKEN"),
        device_serial=device_serial,
        default_profile=profile,
    )


#: Every instruction starts from the same known state so tests do not depend
#: on each other's order (Lab 3 section 7).
PREAMBLE = (
    f"The TeamUp EXE app (package {APP_PACKAGE}) is installed. Force-stop it and open it fresh. "
)

#: Appended to every instruction: the agent returns what it sees, and the test
#: compares those values with the expected ones instead of trusting "SUCCESS".
REPORT_RULE = (
    " When finished, answer with ONE line of JSON and nothing else, using exactly the keys "
    "requested above. Report only values you actually saw on screen; use null if not visible."
)


@pytest.fixture
def artemis(client: ArtemisClient, request: pytest.FixtureRequest) -> ArtemisRunner:
    """The runner a test uses to drive one instruction at a time."""
    return ArtemisRunner(client, request.node.name)


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
    local = REPO_ROOT / "tool" / "fixtures" / "lab3-demo.csv"
    adb("push", str(local), "/sdcard/Download/lab3-demo.csv")
    return "lab3-demo.csv"


#: Reusable instruction fragment: import the demo class so a test never relies
#: on data left behind by another test (every import creates a brand-new class).
IMPORT_DEMO = (
    "Make sure you are signed in (use Continue with Google and the test account if asked). "
    "On the Classes tab tap 'Import class list', tap 'Choose CSV', pick 'lab3-demo.csv' from "
    "Downloads, tap 'Import 12 students', then tap 'Open EXE101 Demo' on the Import result screen. "
    "You are now on the class screen of the class you just imported. "
)


def install_app(apk: Path | None = None) -> str:
    """Install (or reinstall) the app under test on the connected device."""
    apk = apk or (REPO_ROOT / "build" / "app" / "outputs" / "flutter-apk" / "app-release.apk")
    if not apk.exists():
        pytest.skip(f"APK not found at {apk}; run `flutter build apk` first")
    subprocess.run(["adb", "install", "-r", str(apk)], check=True)
    return APP_PACKAGE


def clear_app_state(serial: str) -> None:
    """Reset the app so a test starts from a known state."""
    subprocess.run(
        ["adb", "-s", serial, "shell", "pm", "clear", APP_PACKAGE], check=False
    )


def launch_app(serial: str) -> None:
    subprocess.run(
        [
            "adb", "-s", serial, "shell", "monkey", "-p", APP_PACKAGE,
            "-c", "android.intent.category.LAUNCHER", "1",
        ],
        check=False,
    )


def read_logcat(serial: str, since: str = "-1") -> str:
    """Return the device log, used to check Analytics events."""
    out = subprocess.run(
        ["adb", "-s", serial, "logcat", "-d", "-t", since],
        capture_output=True,
        text=True,
        check=False,
    )
    return out.stdout


__all__ = [
    "APP_PACKAGE",
    "IMPORT_DEMO",
    "Observed",
    "REPORT_DIR",
    "REPO_ROOT",
    "adb",
    "clear_app_state",
    "install_app",
    "launch_app",
    "parse_report",
    "read_logcat",
    "run",
]
