#!/usr/bin/env bash
set -euo pipefail

DAYS="${1:-0}"

# Detect GNU date vs BSD date
if date --version >/dev/null 2>&1; then
  # GNU date
  date -d "$DAYS days ago" +"%F"
else
  # BSD / macOS date
  date -v "-${DAYS}d" +"%F"
fi
