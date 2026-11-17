#!/usr/bin/env bash
set -euo pipefail

# Ensure GNU tools if available, fallback to system
if [ -d "/opt/homebrew/opt/grep/libexec/gnubin" ]; then
  export PATH="/opt/homebrew/opt/grep/libexec/gnubin:$PATH"
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
TREE="$SCRIPT_DIR/tree"

echo "Checking fixture tree..."
test -f "$TREE/file1.txt" || { echo "Missing file1.txt"; exit 1; }
test -d "$TREE/subdir" || { echo "Missing subdir"; exit 1; }
test -f "$TREE/subdir/nested.txt" || { echo "Missing nested.txt"; exit 1; }

echo "Running GNU grep with -d skip..."
grep_out="$(grep -d skip 'bbo' "$TREE"/* 2>&1 | sort)"

echo "Running portable find version..."
find_out="$(find "$TREE" -maxdepth 1 -type f -exec grep -H 'bbo' {} + 2>&1 | sort)"

echo "Comparing outputs..."
diff_out="$(diff -u <(echo "$grep_out") <(echo "$find_out") || true)"

if [ -n "$diff_out" ]; then
  echo "Diff between grep -d skip and find version is not empty:"
  echo "$diff_out"
  exit 1
fi
echo "Diff is empty - outputs match!"

echo "Verifying sub-directory file does not appear in either output..."
if echo "$grep_out" | grep -q "nested.txt"; then
  echo "Error: nested.txt appeared in grep -d skip output"
  exit 1
fi

if echo "$find_out" | grep -q "nested.txt"; then
  echo "Error: nested.txt appeared in find version output"
  exit 1
fi
echo "Sub-directory file correctly excluded from both!"

echo "Verifying README update..."
grep -F "find" "$REPO_ROOT/README.md" | grep -q "maxdepth 1" || {
  echo "Error: README missing portable find alternative"
  exit 1
}
echo "README update verified!"
echo "All R01-T022 checks passed successfully!"
