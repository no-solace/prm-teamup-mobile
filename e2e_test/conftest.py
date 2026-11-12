"""Pytest fixtures for the ARTEMIS end-to-end suite (Lab 3 §7).

The suite drives a real Android device through the **ARTEMIS Python SDK**
(``artemis-client``), which talks to an ARTEMIS host over HTTP. The client is
remote-only: it never imports ADB, an LLM provider or a device driver, so
pytest does not need a device to *collect* the suite.

Environment variables (never committed):
    ARTEMIS_API_KEY      API key of the multimodal model (Gemini / Claude / GPT-4o).
    ARTEMIS_DEVICE       ADB serial of the device, e.g. ``emulator-5554``.
    ARTEMIS_PROFILE      ``flash`` (regression) or ``pro`` (exploratory).
    ARTEMIS_BASE_URL     ARTEMIS host, e.g. ``http://127.0.0.1:8000``.
    ARTEMIS_TOKEN        Bearer token, if the ARTEMIS host requires one.
    ANDROID_SERIAL       Fallback for the ADB serial.

The Google test account used for sign-in is configured on the device itself;
its credentials are NOT part of this repository.
"""

from __future__ import annotations

import asyncio
import os
import re
import subprocess
from dataclasses import dataclass
from pathlib import Path

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
APP_PACKAGE = "com.group6.teamup_exe"
REPORT_DIR = REPO_ROOT / "evidence" / "artemis"


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
def api_key() -> str:
    key = os.environ.get("ARTEMIS_API_KEY")
    if not key:
        pytest.skip("Set ARTEMIS_API_KEY to the multimodal model API key")
    return key


@pytest.fixture(scope="session")
def artemis(device_serial: str, profile: str, api_key: str):
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


def _normalise(result) -> Observed:
    """Turn an ARTEMIS ``TaskResult`` into an :class:`Observed`.

    ``TaskResult.output`` may be a string or a structured payload, so every
    scalar is stringified before the text is searched.
    """
    status = str(getattr(result, "status", "") or "")
    output = getattr(result, "output", None)
    if output is None:
        text = ""
    elif isinstance(output, str):
        text = output
    else:
        text = " ".join(
            f"{key}: {value}" for key, value in output.items() if not isinstance(value, dict)
        )
    error = getattr(result, "error", None)
    screenshot = (getattr(result, "raw", {}) or {}).get("screenshot")
    return Observed(status=status, text=text, error=error, screenshot=screenshot)


def run(artemis, instruction: str) -> Observed:
    """Send one instruction and return the normalised observation.

    ``ArtemisClient.run`` is a coroutine, so it is driven with
    ``asyncio.run``. The ARTEMIS host is a long-lived daemon; the client keeps
    no connection state between calls, so one event loop per instruction is
    safe.
    """
    result = asyncio.run(
        artemis.run(
            instruction,
            locked_app_package=APP_PACKAGE,
            timeout=float(os.environ.get("ARTEMIS_TIMEOUT", "1800")),
        )
    )
    return _normalise(result)


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
    "Observed",
    "REPORT_DIR",
    "REPO_ROOT",
    "clear_app_state",
    "install_app",
    "launch_app",
    "read_logcat",
    "run",
]
