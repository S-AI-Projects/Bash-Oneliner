#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

for N in 0 1 7; do
  CALC_DATE=$("$DIR/days_ago.sh" "$N")
  PY_DATE=$(python3 -c "import datetime; print((datetime.date.today() - datetime.timedelta(days=$N)).strftime('%Y-%m-%d'))")
  echo "Testing N=$N: Shell=$CALC_DATE, Python=$PY_DATE"
  if [ "$CALC_DATE" != "$PY_DATE" ]; then
    echo "FAILED: Date mismatch for N=$N"
    exit 1
  fi
done

echo "PASS: test.sh verified portable days_ago calculation against Python datetime."
