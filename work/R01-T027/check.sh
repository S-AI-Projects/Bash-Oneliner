#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
INPUTRC_FILE="$SCRIPT_DIR/inputrc"
SESSION_LOG="$SCRIPT_DIR/session.log"
NOTES_FILE="$SCRIPT_DIR/NOTES.md"

echo "1. Checking required files..."
[ -f "$INPUTRC_FILE" ] || { echo "Missing inputrc"; exit 1; }
[ -f "$SESSION_LOG" ] || { echo "Missing session.log"; exit 1; }
[ -f "$NOTES_FILE" ] || { echo "Missing NOTES.md"; exit 1; }
echo "Required evidence files present."

echo "2. Verifying custom binding with bind -f in interactive bash..."
out=$(bash -i -c "bind -f '$INPUTRC_FILE' && bind -P" 2>&1 | grep "upcase-word" || true)

if ! echo "$out" | grep -q "\\C-xu"; then
  echo "Custom binding \\C-xu not found in bind -P output: $out"
  exit 1
fi
echo "Verified: upcase-word correctly mapped to \\C-xu!"

echo "3. Verifying default Readline case commands..."
def_out=$(bash -i -c "bind -P" 2>&1 || true)
echo "$def_out" | grep -q 'upcase-word.*\\eu' || { printf '%s\n' "Missing \\eu binding"; exit 1; }
echo "$def_out" | grep -q 'downcase-word.*\\el' || { printf '%s\n' "Missing \\el binding"; exit 1; }
echo "$def_out" | grep -q 'capitalize-word.*\\ec' || { printf '%s\n' "Missing \\ec binding"; exit 1; }
echo "All default case bindings verified."

echo "4. Verifying README.md updates..."
grep -F "Esc + c" "$REPO_ROOT/README.md" >/dev/null || {
  echo "Missing 'Esc + c' in README.md"
  exit 1
}
grep -F "bind -P" "$REPO_ROOT/README.md" >/dev/null || {
  echo "Missing 'bind -P' tip in README.md"
  exit 1
}
echo "README update verified!"
echo "All R01-T027 checks passed successfully!"
