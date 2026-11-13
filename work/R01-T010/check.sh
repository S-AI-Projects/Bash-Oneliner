#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"
FIXTURE="$DIR/fixture.txt"

if [ ! -f "$FIXTURE" ]; then
  echo "ERROR: Fixture file not found: $FIXTURE"
  exit 1
fi

echo "=== R01-T010 Equivalency Check ==="

TMP_DIR="$(mktemp -d)"
trap 'rm -rf "$TMP_DIR"' EXIT

AWK_OUT="$TMP_DIR/awk.out"
GREP_OUT="$TMP_DIR/grep.out"
SED_OUT="$TMP_DIR/sed.out"
PLAIN_GREP_OUT="$TMP_DIR/plain_grep.out"

# 1. Execute awk version
awk '$1 ~ /^Linux/' "$FIXTURE" > "$AWK_OUT"

# 2. Execute fixed grep version
grep -E '^[[:space:]]*Linux' "$FIXTURE" > "$GREP_OUT"

# 3. Execute sed version
sed -n '/^[[:space:]]*Linux/p' "$FIXTURE" > "$SED_OUT"

# 4. Execute un-indented plain grep to demonstrate difference
grep '^Linux' "$FIXTURE" > "$PLAIN_GREP_OUT" || true

# Assert plain grep differs from awk
if cmp -s "$AWK_OUT" "$PLAIN_GREP_OUT"; then
  echo "ERROR: Plain grep '^Linux' should differ on indented lines!"
  exit 1
fi
echo "  ✓ Confirmed plain grep '^Linux' misses indented lines"

# Assert diff of awk vs fixed grep is empty
DIFF_GREP="$(diff -u "$AWK_OUT" "$GREP_OUT")"
if [ -n "$DIFF_GREP" ]; then
  echo "ERROR: diff of awk vs fixed grep is not empty:"
  echo "$DIFF_GREP"
  exit 1
fi
echo "  ✓ awk vs fixed grep diff is empty (identical)"

# Assert diff of awk vs sed is empty
DIFF_SED="$(diff -u "$AWK_OUT" "$SED_OUT")"
if [ -n "$DIFF_SED" ]; then
  echo "ERROR: diff of awk vs sed is not empty:"
  echo "$DIFF_SED"
  exit 1
fi
echo "  ✓ awk vs sed diff is empty (identical)"

echo "=== All commands match on fixture.txt ==="
