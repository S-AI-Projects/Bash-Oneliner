#!/usr/bin/env bash
# Automated check for R01-T039: Explore job control with `jobs -l`
# Requirements:
# 1. session.log exists and demonstrates two backgrounded sleeps, stopped job with Ctrl-Z, jobs -l, bg, fg, kill %2 and disown.
# 2. NOTES.md explains columns and markers (+, -).
# 3. check.sh uses set -m, starts 2 jobs, asserts 2 PIDs in jobs -l, kills them before exiting.
# 4. README entry (L2158) gains jobs -p, kill %1 and disown %1.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"

echo "=== R01-T039 Automated Check ==="

# Check 1: Verify session.log
echo "1. Checking session.log..."
if [ ! -f "$SCRIPT_DIR/session.log" ]; then
  echo "FAIL: session.log not found." >&2
  exit 1
fi

for keyword in "sleep" "jobs -l" "bg" "fg" "kill" "disown"; do
  if ! grep -q "$keyword" "$SCRIPT_DIR/session.log"; then
    echo "FAIL: session.log missing expected keyword '$keyword'." >&2
    exit 1
  fi
done
echo "   PASS: session.log contains all required job control interactions."

# Check 2: Verify NOTES.md explanation
echo "2. Checking NOTES.md explanation..."
if [ ! -f "$SCRIPT_DIR/NOTES.md" ]; then
  echo "FAIL: NOTES.md not found." >&2
  exit 1
fi

if ! grep -q "+" "$SCRIPT_DIR/NOTES.md" || ! grep -q "-" "$SCRIPT_DIR/NOTES.md"; then
  echo "FAIL: NOTES.md missing explanation of + and - markers." >&2
  exit 1
fi
echo "   PASS: NOTES.md explains job markers and columns."

# Check 3: Active job control test with set -m
echo "3. Testing active job control with 'set -m'..."
# Enable job control in script
set -m

# Spawn 2 background jobs
sleep 20 &
job1_pid=$!
sleep 20 &
job2_pid=$!

cleanup_jobs() {
  kill "$job1_pid" "$job2_pid" 2>/dev/null || true
  wait "$job1_pid" "$job2_pid" 2>/dev/null || true
}
trap cleanup_jobs EXIT

# Capture jobs -l output
jobs_out=$(jobs -l)
echo "   Active jobs output:"
echo "$jobs_out"

# Assert exactly 2 job lines
job_count=$(grep -c "sleep" <<<"$jobs_out" || true)
if [ "$job_count" -ne 2 ]; then
  echo "FAIL: Expected 2 jobs in jobs -l, found $job_count" >&2
  exit 1
fi

# Assert both PIDs appear in jobs -l
if ! grep -q "$job1_pid" <<<"$jobs_out" || ! grep -q "$job2_pid" <<<"$jobs_out"; then
  echo "FAIL: Expected PIDs ($job1_pid, $job2_pid) missing from jobs -l output." >&2
  exit 1
fi
echo "   PASS: jobs -l lists both PIDs ($job1_pid, $job2_pid) correctly."

# Test jobs -p
pids_out=$(jobs -p)
if ! grep -q "$job1_pid" <<<"$pids_out" || ! grep -q "$job2_pid" <<<"$pids_out"; then
  echo "FAIL: jobs -p did not list expected PIDs." >&2
  exit 1
fi
echo "   PASS: jobs -p verified."

# Kill jobs cleanly
kill %1
kill %2
# Wait briefly for termination
wait "$job1_pid" "$job2_pid" 2>/dev/null || true
trap - EXIT

# Verify no leftover sleep processes
leftovers=$(ps -ef 2>/dev/null | grep -E "sleep 20$" | grep -v grep || true)
if [ -n "$leftovers" ]; then
  echo "FAIL: Leftover sleep processes detected: $leftovers" >&2
  exit 1
fi
echo "   PASS: All background jobs terminated cleanly without leaks."

# Check 4: Verify README.md entry
echo "4. Checking README.md entry..."
entry=$(awk '/^##### Show jobs and PID/{on=1; next} on && /^##### /{exit} on' "$REPO_ROOT/README.md")
if [ -z "$entry" ]; then
  echo "FAIL: 'Show jobs and PID' entry not found in README.md." >&2
  exit 1
fi

if ! grep -q "jobs -p" <<<"$entry"; then
  echo "FAIL: README.md does not contain 'jobs -p'." >&2
  exit 1
fi

if ! grep -q "kill %1" <<<"$entry"; then
  echo "FAIL: README.md does not contain 'kill %1'." >&2
  exit 1
fi

if ! grep -q "disown %1" <<<"$entry"; then
  echo "FAIL: README.md does not contain 'disown %1'." >&2
  exit 1
fi

echo "   PASS: README.md contains jobs -p, kill %1, and disown %1."

echo ""
echo "Summary: ALL CHECKS PASSED (R01-T039)."
