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

[CmdletBinding()]
param(
    [string]$TestPath = "e2e_test",
    [string]$Device = $env:ARTEMIS_DEVICE,
    [string]$BaseUrl = "http://127.0.0.1:8000",
    [string]$Profile = "flash",
    [int]$Timeout = 1800,
    [string]$Mark = "",
    [switch]$CollectOnly
)

$ErrorActionPreference = "Stop"

function Fail($message) {
    Write-Host ""
    Write-Host "[FAIL] $message" -ForegroundColor Red
    Write-Host ""
    exit 1
}

# --- 1. the ARTEMIS host must answer -----------------------------------------
try {
    $status = Invoke-WebRequest -Uri "$BaseUrl/api/status" -TimeoutSec 10 -UseBasicParsing
    if ($status.StatusCode -ne 200) { Fail "ARTEMIS host at $BaseUrl returned $($status.StatusCode)." }
    Write-Host "[OK]   ARTEMIS host reachable at $BaseUrl" -ForegroundColor Green
} catch {
    Fail "ARTEMIS host is not reachable at $BaseUrl. Start it with:  uv run python -m artemis ui --port 8000 --no-open"
}

# --- 2. a device must be attached --------------------------------------------
if (-not $Device) {
    $attached = (& adb devices 2>$null) | Select-String "device$"
    if (-not $attached) {
        Fail "No Android device attached. Start an emulator or connect a phone, then re-run with -Device <serial>."
    }
    $Device = (($attached -split "\s+")[0]).Trim()
}
Write-Host "[OK]   Device serial: $Device" -ForegroundColor Green

# --- 3. the API key -----------------------------------------------------------
if (-not $env:ARTEMIS_API_KEY) {
    Fail "ARTEMIS_API_KEY is not set. Export the multimodal model key before running the suite."
}
Write-Host "[OK]   ARTEMIS_API_KEY present" -ForegroundColor Green

# --- 4. the app under test must be installed ---------------------------------
$package = "com.group6.teamup_exe"
$installed = (& adb -s $Device shell pm list packages 2>$null) | Select-String $package
if (-not $installed) {
    Fail "The app ($package) is not installed on $Device. Run:  flutter build apk --release && adb install -r <apk>"
}
Write-Host "[OK]   App $package installed" -ForegroundColor Green

# --- 5. run pytest -----------------------------------------------------------
$env:ARTEMIS_DEVICE = $Device
$env:ARTEMIS_BASE_URL = $BaseUrl
$env:ARTEMIS_PROFILE = $Profile
$env:ARTEMIS_TIMEOUT = "$Timeout"

$pytestArgs = @($TestPath, "-ra", "--strict-markers")
if ($Mark) { $pytestArgs += @("-m", $Mark) }
if ($CollectOnly) { $pytestArgs += "--collect-only" }

Write-Host ""
Write-Host "Running: python -m pytest $($pytestArgs -join ' ')" -ForegroundColor Cyan
Write-Host ""

& python -m pytest @pytestArgs
$code = $LASTEXITCODE

Write-Host ""
if ($code -eq 0) {
    Write-Host "[DONE] The ARTEMIS regression suite passed." -ForegroundColor Green
} else {
    Write-Host "[DONE] The suite reported failures (pytest exit code $code)." -ForegroundColor Yellow
}
exit $code
