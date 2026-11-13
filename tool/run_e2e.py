"""Local helper for the ARTEMIS end-to-end suite (Lab 3 §7).

Wraps the environment the suite needs so the tests can be started with a
single command on a machine that has the ARTEMIS host and an Android device
(or emulator) attached.

Usage (PowerShell):

    .\\tool\\run_e2e.ps1                 # whole regression suite
    .\\tool\\run_e2e.ps1 -TestPath e2e_test/test_auth.py
    .\\tool\\run_e2e.ps1 -Mark "not exploratory"

The script does NOT invent credentials: it reads them from the environment and
fails with a clear message when something is missing.
"""

from __future__ import annotations

import os
import shutil
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parents[1]
PACKAGE = "com.group6.teamup_exe"


def _fail(message: str) -> None:
    print()
    print(f"[FAIL] {message}")
    print()
    raise SystemExit(1)


def _run(cmd: list[str], **kwargs) -> subprocess.CompletedProcess:
    return subprocess.run(cmd, capture_output=True, text=True, **kwargs)


def _adb() -> str:
    exe = shutil.which("adb")
    if exe:
        return exe
    android_home = os.environ.get("ANDROID_HOME") or os.environ.get("ANDROID_SDK_ROOT")
    if android_home:
        candidate = Path(android_home) / "platform-tools" / "adb.exe"
        if candidate.exists():
            return str(candidate)
    _fail("adb was not found on PATH. Install the Android SDK platform-tools.")


def main() -> int:
    base_url = os.environ.get("ARTEMIS_BASE_URL", "http://127.0.0.1:8000")
    profile = os.environ.get("ARTEMIS_PROFILE", "flash")
    timeout = os.environ.get("ARTEMIS_TIMEOUT", "1800")
    device = os.environ.get("ARTEMIS_DEVICE") or os.environ.get("ANDROID_SERIAL") or ""

    # 1. the ARTEMIS host must answer.
    import urllib.error
    import urllib.request

    try:
        with urllib.request.urlopen(f"{base_url}/api/status", timeout=10) as response:
            if response.status != 200:
                _fail(f"ARTEMIS host at {base_url} returned {response.status}.")
        print(f"[OK]   ARTEMIS host reachable at {base_url}")
    except (urllib.error.URLError, TimeoutError) as error:
        _fail(
            f"ARTEMIS host is not reachable at {base_url} ({error}). "
            "Start it with:  uv run python -m artemis ui --port 8000 --no-open"
        )

    # 2. a device must be attached.
    adb = _adb()
    if not device:
        listing = _run([adb, "devices"]).stdout
        attached = [line.split()[0] for line in listing.splitlines() if line.endswith("\tdevice")]
        if not attached:
            _fail(
                "No Android device attached. Start an emulator or connect a phone, "
                "then re-run with ARTEMIS_DEVICE=<serial>."
            )
        device = attached[0]
    print(f"[OK]   Device serial: {device}")

    # 3. the API key.
    if not os.environ.get("ARTEMIS_API_KEY"):
        _fail("ARTEMIS_API_KEY is not set. Export the multimodal model key before running the suite.")
    print("[OK]   ARTEMIS_API_KEY present")

    # 4. the app under test must be installed.
    packages = _run([adb, "-s", device, "shell", "pm", "list", "packages"]).stdout
    if PACKAGE not in packages:
        _fail(
            f"The app ({PACKAGE}) is not installed on {device}. "
            "Run:  flutter build apk --release && adb install -r <apk>"
        )
    print(f"[OK]   App {PACKAGE} installed")

    # 5. run pytest.
    os.environ.update(
        ARTEMIS_DEVICE=device,
        ARTEMIS_BASE_URL=base_url,
        ARTEMIS_PROFILE=profile,
        ARTEMIS_TIMEOUT=timeout,
    )
    print()
    print(f"Running: python -m pytest {sys.argv[1:]}")
    print()
    code = subprocess.call([sys.executable, "-m", "pytest", *sys.argv[1:]], cwd=REPO_ROOT)
    print()
    print("[DONE] The ARTEMIS regression suite passed." if code == 0 else f"[DONE] Failures (exit {code}).")
    return code


if __name__ == "__main__":
    raise SystemExit(main())
