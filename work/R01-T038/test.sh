#!/usr/bin/env bash
# Automated test script for R01-T038: Test sed '$d' on Linux and macOS
# Compares sed '$d' output across 4 tricky fixtures against expected files.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"
FIXTURES_DIR="$SCRIPT_DIR/fixtures"

echo "=== R01-T038 sed '\$d' Test Suite ==="
echo "Operating System: $(uname -s) $(uname -r)"
echo "Sed version / info:"
sed --version 2>&1 | head -n 1 || which sed

fail=0

# Test all 4 fixtures
fixtures=("normal" "single" "empty" "no_trailing_newline")

for name in "${fixtures[@]}"; do
  input_file="$FIXTURES_DIR/$name.txt"
  expected_file="$FIXTURES_DIR/$name.expected"
  
  if [ ! -f "$input_file" ] || [ ! -f "$expected_file" ]; then
    echo "FAIL: Missing fixture files for '$name'" >&2
    fail=1
    continue
  fi

  output=$(sed '$d' "$input_file")
  expected=$(cat "$expected_file")

  if diff -u <(sed '$d' "$input_file") "$expected_file"; then
    echo "PASS: fixture '$name'"
  else
    echo "FAIL: fixture '$name' output did not match expected" >&2
    fail=1
  fi
done

# Also test the awk alternative: awk 'NR>1{print prev} {prev=$0}'
echo "Testing awk alternative on standard fixtures..."
for name in "normal" "single" "empty"; do
  input_file="$FIXTURES_DIR/$name.txt"
  expected_file="$FIXTURES_DIR/$name.expected"
  if diff -u <(awk 'NR>1{print prev} {prev=$0}' "$input_file") "$expected_file"; then
    echo "PASS (awk): fixture '$name'"
  else
    echo "FAIL (awk): fixture '$name' output did not match expected" >&2
    fail=1
  fi
done

# Check README.md entry
echo "Checking README.md entry..."
entry=$(awk '/^##### Delete\/remove last line/{on=1; next} on && /^##### /{exit} on' "$REPO_ROOT/README.md")
if [ -z "$entry" ]; then
  echo "FAIL: 'Delete/remove last line' entry not found in README.md" >&2
  fail=1
else
  if ! grep -q "awk 'NR>1{print prev} {prev=\$0}'" <<<"$entry"; then
    echo "FAIL: README.md does not contain the awk alternative" >&2
    fail=1
  fi
  if ! grep -qi "GNU" <<<"$entry" || ! grep -qi "BSD" <<<"$entry"; then
    echo "FAIL: README.md does not mention GNU and BSD compatibility" >&2
    fail=1
  fi
  echo "PASS: README.md entry verified."
fi

if [ "$fail" -eq 0 ]; then
  echo ""
  echo "Summary: ALL TESTS PASSED (R01-T038)."
  exit 0
else
  echo ""
  echo "Summary: SOME TESTS FAILED (R01-T038)."
  exit 1
fi
