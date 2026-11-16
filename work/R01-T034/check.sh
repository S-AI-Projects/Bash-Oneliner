#!/usr/bin/env bash
# Automated check for R01-T034: Test the 'Grep AND' entry
# Requirements:
# 1. Fixture has 'A then B', 'B then A', 'only A', 'only B', 'AB'.
# 2. A test proves grep 'A.*B' misses 'B then A'.
# 3. All three correct versions return exactly 'A then B', 'B then A', 'AB'.
# 4. README entry (L566) is renamed or gains the order-independent alternative.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
FIXTURE="$SCRIPT_DIR/fixture.txt"

echo "=== R01-T034 Automated Check ==="

# Check 1: Fixture content validation
echo "1. Validating fixture content..."
expected_fixture=$'A then B\nB then A\nonly A\nonly B\nAB'
actual_fixture=$(cat "$FIXTURE")
if [ "$actual_fixture" != "$expected_fixture" ]; then
  echo "FAIL: fixture.txt does not match required fixture lines." >&2
  exit 1
fi
echo "   PASS: fixture.txt contains all required test cases."

# Check 2: If bats is installed, run test.bats
if command -v bats >/dev/null 2>&1; then
  echo "2. Running test.bats with bats..."
  bats "$SCRIPT_DIR/test.bats"
  echo "   PASS: bats test.bats passed."
else
  echo "2. Running equivalent assertions natively..."
  
  # Assert grep 'A.*B' misses 'B then A'
  res=$(grep 'A.*B' "$FIXTURE")
  if grep -q "B then A" <<<"$res"; then
    echo "FAIL: grep 'A.*B' was expected to miss 'B then A'." >&2
    exit 1
  fi
  if [ "$res" != $'A then B\nAB' ]; then
    echo "FAIL: Unexpected output from grep 'A.*B': $res" >&2
    exit 1
  fi
  echo "   PASS: Proved grep 'A.*B' misses 'B then A'."

  expected_and=$'A then B\nB then A\nAB'

  # Version 1: pipe
  pipe_res=$(grep 'A' "$FIXTURE" | grep 'B')
  if [ "$pipe_res" != "$expected_and" ]; then
    echo "FAIL: piped grep did not match expected lines." >&2
    exit 1
  fi
  echo "   PASS: Version 1 (grep A | grep B) matched all 3 lines."

  # Version 2: awk
  awk_res=$(awk '/A/ && /B/' "$FIXTURE")
  if [ "$awk_res" != "$expected_and" ]; then
    echo "FAIL: awk did not match expected lines." >&2
    exit 1
  fi
  echo "   PASS: Version 2 (awk '/A/ && /B/') matched all 3 lines."

  # Version 3: lookahead (grep -P or perl)
  if grep -P "test" </dev/null >/dev/null 2>&1; then
    pcre_res=$(grep -P '^(?=.*A)(?=.*B)' "$FIXTURE")
  else
    pcre_res=$(perl -ne 'print if /^(?=.*A)(?=.*B)/' "$FIXTURE")
  fi
  if [ "$pcre_res" != "$expected_and" ]; then
    echo "FAIL: lookahead regex did not match expected lines." >&2
    exit 1
  fi
  echo "   PASS: Version 3 (lookahead regex) matched all 3 lines."
fi

# Check 3: Verify README.md has order-independent alternative
echo "3. Checking README.md entry..."
entry=$(awk '/^##### Grep AND/{on=1; next} on && /^##### /{exit} on' "$REPO_ROOT/README.md")
if [ -z "$entry" ]; then
  echo "FAIL: 'Grep AND' entry not found in README.md." >&2
  exit 1
fi

if ! grep -q "grep 'A'.*|.*grep 'B'" <<<"$entry"; then
  echo "FAIL: README.md does not include order-independent alternative 'grep '\''A'\'' file | grep '\''B'\''." >&2
  exit 1
fi

echo "   PASS: README.md entry contains order-independent alternative."

echo ""
echo "Summary: ALL CHECKS PASSED (R01-T034)."
