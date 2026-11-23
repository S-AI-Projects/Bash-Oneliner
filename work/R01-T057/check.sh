#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Verify comm columns and options
COMMON=$(comm -12 "$DIR/rosterA.txt" "$DIR/rosterB.txt")
EXP_COMMON=$'Charlie
David'
if [ "$COMMON" != "$EXP_COMMON" ]; then
  echo "FAILED: comm -12 mismatch"
  exit 1
fi

ONLY_A=$(comm -23 "$DIR/rosterA.txt" "$DIR/rosterB.txt")
EXP_ONLY_A=$'Alice
Eve'
if [ "$ONLY_A" != "$EXP_ONLY_A" ]; then
  echo "FAILED: comm -23 mismatch"
  exit 1
fi

ONLY_B=$(comm -13 "$DIR/rosterA.txt" "$DIR/rosterB.txt")
EXP_ONLY_B=$'Bob
Frank'
if [ "$ONLY_B" != "$EXP_ONLY_B" ]; then
  echo "FAILED: comm -13 mismatch"
  exit 1
fi

echo "PASS: check.sh verified comm reference outputs."
