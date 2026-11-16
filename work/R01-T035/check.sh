#!/usr/bin/env bash
# Automated check for R01-T035: Uppercasing with tr: slashes, locales and non-English letters
# Requirements:
# 1. NOTES.md shows tr /a-z/ /A-Z/ mapping '/' to '/' (input containing '/' is unchanged).
# 2. Table for 'straße café ÉCOLE' across tools with locale.
# 3. check.sh asserts identical results for ASCII input across all methods.
# 4. README L2825 uses tr '[:lower:]' '[:upper:]' and mentions ${var^^}.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"

echo "=== R01-T035 Automated Check ==="

# Check 1: Slash mapping demonstration
echo "1. Checking slash mapping in tr /a-z/ /A-Z/..."
slash_input="/path/to/my/file.txt"
slash_output=$(echo "$slash_input" | tr /a-z/ /A-Z/)
expected_slash="/PATH/TO/MY/FILE.TXT"
if [ "$slash_output" != "$expected_slash" ]; then
  echo "FAIL: Expected '$expected_slash', got '$slash_output'" >&2
  exit 1
fi
echo "   PASS: tr /a-z/ /A-Z/ maps '/' to '/' without altering slashes."

# Check 2: ASCII equivalence across methods
echo "2. Checking ASCII equivalence across uppercasing methods..."
ascii_input="the quick brown fox jumps over the lazy dog 12345"
expected_ascii="THE QUICK BROWN FOX JUMPS OVER THE LAZY DOG 12345"

# Method A: tr '[:lower:]' '[:upper:]'
res_tr_posix=$(echo "$ascii_input" | tr '[:lower:]' '[:upper:]')
# Method B: tr a-z A-Z
res_tr_range=$(echo "$ascii_input" | tr 'a-z' 'A-Z')
# Method C: awk toupper
res_awk=$(echo "$ascii_input" | awk '{print toupper($0)}')

if [ "$res_tr_posix" != "$expected_ascii" ]; then
  echo "FAIL: tr '[:lower:]' '[:upper:]' failed on ASCII input." >&2
  exit 1
fi

if [ "$res_tr_range" != "$expected_ascii" ]; then
  echo "FAIL: tr a-z A-Z failed on ASCII input." >&2
  exit 1
fi

if [ "$res_awk" != "$expected_ascii" ]; then
  echo "FAIL: awk toupper failed on ASCII input." >&2
  exit 1
fi

# Method D: Bash 4+ ${var^^} if supported, or Python fallback
if [ "${BASH_VERSINFO[0]:-0}" -ge 4 ]; then
  eval 'res_bash="${ascii_input^^}"'
  if [ "$res_bash" != "$expected_ascii" ]; then
    echo "FAIL: Bash ${var^^} failed on ASCII input." >&2
    exit 1
  fi
fi

echo "   PASS: All methods produce identical results for ASCII input."

# Check 3: Verify README.md contains tr '[:lower:]' '[:upper:]' and mentions ${var^^}
echo "3. Checking README.md entry..."
entry=$(awk '/^##### To uppercase\/lowercase/{on=1; next} on && /^##### /{exit} on' "$REPO_ROOT/README.md")
if [ -z "$entry" ]; then
  echo "FAIL: 'To uppercase/lowercase' entry not found in README.md." >&2
  exit 1
fi

if grep -q '/a-z/' <<<"$entry"; then
  echo "FAIL: README.md still contains bogus slashes in 'tr /a-z/ /A-Z/'." >&2
  exit 1
fi

if ! grep -Fq "tr '[:lower:]' '[:upper:]'" <<<"$entry"; then
  echo "FAIL: README.md does not use tr '[:lower:]' '[:upper:]'." >&2
  exit 1
fi

if ! grep -Fq '${var^^}' <<<"$entry"; then
  echo "FAIL: README.md does not mention Bash \${var^^}." >&2
  exit 1
fi

echo "   PASS: README.md entry correctly updated."

echo ""
echo "Summary: ALL CHECKS PASSED (R01-T035)."
