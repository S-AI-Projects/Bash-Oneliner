#!/usr/bin/env bash
set -euo pipefail

PROC_PID_MAX=$(cat /proc/sys/kernel/pid_max)
SYSCTL_PID_MAX=$(sysctl -n kernel.pid_max)

if [[ "$PROC_PID_MAX" != "$SYSCTL_PID_MAX" ]]; then
    echo "FAIL: sysctl and /proc pid_max values differ"
    exit 1
fi

OUTPUT=$(./work/R01-T047/limits.sh)

for limit in "pid_max" "threads-max" "ulimit -u" "cgroup pids.max"; do
    if ! grep -Fq "$limit" <<< "$OUTPUT"; then
        echo "FAIL: missing $limit in limits.sh output"
        exit 1
    fi
done

echo "PASS: sysctl and /proc pid_max values match"
echo "PASS: all four limits are reported"
