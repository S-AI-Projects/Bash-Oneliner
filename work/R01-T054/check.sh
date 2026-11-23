#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

FIXTURE_DIR="$DIR/sandbox_tree"
rm -rf "$FIXTURE_DIR"
mkdir -p "$FIXTURE_DIR/a/b" "$FIXTURE_DIR/.hidden_dir"
touch "$FIXTURE_DIR/visible1.txt" "$FIXTURE_DIR/a/b/visible2.txt" "$FIXTURE_DIR/.hidden_file" "$FIXTURE_DIR/.hidden_dir/inner.txt"

# Test standard find vs skip-hidden find
ALL_COUNT=$(find "$FIXTURE_DIR" -type f | wc -l | tr -d ' ')
SKIP_COUNT=$(find "$FIXTURE_DIR" -type f -not -path '*/.*' | wc -l | tr -d ' ')

if [ "$ALL_COUNT" -ne 4 ]; then
  echo "FAILED: Expected 4 total files, got $ALL_COUNT"
  exit 1
fi

if [ "$SKIP_COUNT" -ne 2 ]; then
  echo "FAILED: Expected 2 non-hidden files, got $SKIP_COUNT"
  exit 1
fi

rm -rf "$FIXTURE_DIR"
echo "PASS: check.sh verified skip-hidden find behavior."
