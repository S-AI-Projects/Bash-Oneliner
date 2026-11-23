#!/usr/bin/env bash
set -euo pipefail

# Verify CPU count detection
if command -v nproc >/dev/null 2>&1; then
  CPUS=$(nproc)
  echo "nproc detected: $CPUS"
elif command -v sysctl >/dev/null 2>&1; then
  CPUS=$(sysctl -n hw.ncpu)
  echo "sysctl detected: $CPUS"
else
  CPUS=1
  echo "fallback: $CPUS"
fi

[ "$CPUS" -ge 1 ]
echo "PASS: check.sh verified CPU counting."
