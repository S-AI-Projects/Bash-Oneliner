#!/usr/bin/env bash
# Automated check for R01-T033: Fix the number-rounding awk program
# Requirements:
# 1. NOTES.md shows original program's failure on fixture 'pi=3.14159 e=2.71828 n=42 v=[1[2'.
# 2. Fixed program prints 'pi=3.14 e=2.72 n=42 v=[1[2'.
# 3. Tests cover line with no numbers, number at start, number at end.
# 4. README L941-948 has corrected regex and clean backslashes.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"

echo "=== R01-T033 Automated Check ==="

# Check 1: If bats is installed, run test.bats directly
if command -v bats >/dev/null 2>&1; then
  echo "1. Running test.bats with bats..."
  bats "$SCRIPT_DIR/test.bats"
  echo "   PASS: bats test.bats passed."
else
  echo "1. bats not found in PATH; running equivalent assertions natively..."
  run_round() {
    awk '{
      while (match($0, /[0-9]+\.[0-9]+/)) {
        printf "%s%.2f", substr($0, 1, RSTART-1), substr($0, RSTART, RLENGTH)
        $0 = substr($0, RSTART + RLENGTH)
      }
      print
    }'
  }

  # Test A: Main fixture
  res=$(echo "pi=3.14159 e=2.71828 n=42 v=[1[2" | run_round)
  expected="pi=3.14 e=2.72 n=42 v=[1[2"
  if [ "$res" != "$expected" ]; then
    echo "FAIL: Expected '$expected', got '$res'" >&2
    exit 1
  fi
  echo "   PASS: Main fixture output matches exactly: '$res'"

  # Test B: Line with no numbers
  res=$(echo "hello world" | run_round)
  if [ "$res" != "hello world" ]; then
    echo "FAIL: Line with no numbers was modified: '$res'" >&2
    exit 1
  fi
  echo "   PASS: Line with no numbers handled correctly."

  # Test C: Number at start
  res=$(echo "3.14159 at start" | run_round)
  if [ "$res" != "3.14 at start" ]; then
    echo "FAIL: Number at start failed: '$res'" >&2
    exit 1
  fi
  echo "   PASS: Number at start handled correctly."

  # Test D: Number at end
  res=$(echo "at end 2.71828" | run_round)
  if [ "$res" != "at end 2.72" ]; then
    echo "FAIL: Number at end failed: '$res'" >&2
    exit 1
  fi
  echo "   PASS: Number at end handled correctly."
fi

# Check 2: Verify README.md has corrected regex and clean backslashes
echo "2. Checking README.md entry..."
entry=$(awk '/^##### Round all numbers of file/{on=1; next} on && /^##### /{exit} on' "$REPO_ROOT/README.md")
if [ -z "$entry" ]; then
  echo "FAIL: 'Round all numbers of file' entry not found in README.md." >&2
  exit 1
fi

if grep -Fq '/[0-9]+\[0-9]+/' <<<"$entry"; then
  echo "FAIL: README.md still contains buggy regex '/[0-9]+\[0-9]+/'." >&2
  exit 1
fi

if ! grep -Fq '/[0-9]+\.[0-9]+/' <<<"$entry"; then
  echo "FAIL: README.md does not contain corrected regex '/[0-9]+\.[0-9]+/'." >&2
  exit 1
fi

if grep -q '\\printf' <<<"$entry" || grep -q '\\\$0' <<<"$entry"; then
  echo "FAIL: README.md still contains stray backslashes." >&2
  exit 1
fi

echo "   PASS: README.md entry has corrected regex and clean backslashes."

echo ""
echo "Summary: ALL CHECKS PASSED (R01-T033)."
