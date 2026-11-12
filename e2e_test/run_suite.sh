#!/usr/bin/env bash
# Runs the whole ARTEMIS suite 3 times (Lab 3 section 7) and prints the pass-rate table.
#
# Prerequisites (see docs/test-plan.md section 6):
#   - ARTEMIS host running (uv run artemis ...) with a model API key in ITS .env
#   - one Android device/emulator attached, TeamUp installed (flutter run / flutter install)
#   - dedicated Google test account added to the device
#   - export ARTEMIS_DEVICE=<adb serial>   (optional if only one device)
set -euo pipefail
cd "$(dirname "$0")"
mkdir -p runs
rm -f runs/run*.xml runs/runs.jsonl
for i in 1 2 3; do
  uv run pytest -v --junitxml="runs/run$i.xml" || true   # keep going: failures are results
done
uv run python summarize.py runs/run1.xml runs/run2.xml runs/run3.xml | tee runs/results.md
