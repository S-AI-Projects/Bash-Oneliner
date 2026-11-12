#!/usr/bin/env bash
# probe.sh: Check if HOST:PORT is OPEN or CLOSED using nc within ~5 seconds
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <HOST> <PORT>" >&2
  exit 1
fi

host="$1"
port="$2"

# Probe target host and port in background with nc -z
( nc -z "$host" "$port" >/dev/null 2>&1 ) &
pid=$!

# Wait up to 5 seconds (50 iterations of 0.1s)
for ((i=0; i<50; i++)); do
  if ! kill -0 "$pid" 2>/dev/null; then
    if wait "$pid"; then
      echo "OPEN"
      exit 0
    else
      echo "CLOSED"
      exit 1
    fi
  fi
  sleep 0.1
done

# If still running after timeout, kill process and report closed
kill "$pid" 2>/dev/null || true
wait "$pid" 2>/dev/null || true
echo "CLOSED"
exit 1
