#!/usr/bin/env bash
# Layer check (D14). Run before every PR: bash tools/check_layers.sh
# Fails if UI code touches Firebase, or screens hard-code colours / sizes.
set -u
cd "$(dirname "$0")/.."
fail=0

check() { # $1 = description, $2 = regex, rest = paths
  local desc="$1" re="$2"; shift 2
  local hits
  hits=$(grep -rnE "$re" "$@" --include='*.dart' 2>/dev/null)
  if [ -n "$hits" ]; then
    echo "FAIL: $desc"; echo "$hits"; echo; fail=1
  fi
}

FIREBASE="import 'package:(firebase_[a-z_]+|cloud_firestore|google_sign_in)/|import '.*/firebase/"
check "screens/widgets import Firebase"        "$FIREBASE" lib/screens lib/widgets
check "viewmodels import Firebase"             "$FIREBASE" lib/viewmodels
check "services/models import Firebase"        "$FIREBASE" lib/services lib/models
check "services/models import Flutter UI"      "import 'package:flutter/(material|widgets|cupertino)" lib/services lib/models
check "viewmodels import screens/widgets"      "import '.*/(screens|widgets)/" lib/viewmodels
check "screens/widgets import providers"       "import '.*/providers/" lib/screens lib/widgets
check "screens hard-code a colour"             "Color\(0x" lib/screens
check "screens hard-code a font size"          "fontSize:" lib/screens
check "screens hard-code padding numbers"      "EdgeInsets\.(all|symmetric|only)\([^)]*[0-9]" lib/screens

if [ "$fail" -eq 0 ]; then echo "Layers OK"; fi
exit $fail
