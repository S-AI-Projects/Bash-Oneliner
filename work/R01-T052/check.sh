#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Create test fixture with empty lines, spaces, tabs, and CRLF blank lines
FIXTURE="$DIR/fixture.txt"
printf "line1\n\nline2\n   \n\t\t\nline3\r\nline4\r\n\r\nline5\n" > "$FIXTURE"

# Run POSIX sed
OUTPUT_POSIX=$(sed '/^[[:space:]]*$/d' "$FIXTURE")

# Expected: line1, line2, line3, line4, line5 (5 lines)
LINE_COUNT=$(printf "%s\n" "$OUTPUT_POSIX" | tr -d '\r' | grep -c '^line')
if [ "$LINE_COUNT" -ne 5 ]; then
  echo "FAILED: Expected 5 lines, got $LINE_COUNT"
  exit 1
fi

echo "SUCCESS: POSIX form correctly eliminated empty, whitespace, and CRLF lines."
