#!/usr/bin/env bash
set -euo pipefail

# Test $_ in non-interactive script
echo "test_target_arg" > /dev/null
ARG="$_"
if [ "$ARG" != "test_target_arg" ]; then
  echo "FAILED: \$_ mismatch, got $ARG"
  exit 1
fi

echo "PASS: check.sh verified \$_ inside script execution."
