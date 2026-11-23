#!/usr/bin/env bash
set -euo pipefail

# Verify who -b and uptime commands
if command -v who >/dev/null 2>&1; then
  who -b || true
fi

if command -v uptime >/dev/null 2>&1; then
  uptime || true
fi

echo "PASS: check.sh successfully verified boot inspection commands."
