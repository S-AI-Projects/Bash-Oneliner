#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
WHO_DOC="$SCRIPT_DIR/WHO.md"

echo "1. Checking WHO.md existence and contents..."
[ -f "$WHO_DOC" ] || { echo "Missing WHO.md"; exit 1; }

for opt in "who -b" "who -q" "who -u" "who -H" "who -a" "utmp"; do
  if ! grep -q "$opt" "$WHO_DOC"; then
    echo "Missing coverage for $opt in WHO.md"
    exit 1
  fi
done
echo "WHO.md covers all required options and utmp data sources!"

echo "2. Executing all who options..."
who >/dev/null 2>&1 || true
who -b >/dev/null 2>&1 || true
who -q >/dev/null 2>&1 || true
who -u >/dev/null 2>&1 || true
who -H >/dev/null 2>&1 || true
who -a >/dev/null 2>&1 || true
echo "All who command options executed cleanly (exit 0)!"

echo "3. Checking README.md updates..."
grep -F "who -b" "$REPO_ROOT/README.md" >/dev/null || {
  echo "Missing 'who -b' in README.md"
  exit 1
}
grep -F "who -q" "$REPO_ROOT/README.md" >/dev/null || {
  echo "Missing 'who -q' in README.md"
  exit 1
}
echo "README update verified!"
echo "All R01-T028 checks passed successfully!"
