#!/usr/bin/env bash

PID_MAX=$(cat /proc/sys/kernel/pid_max)
THREADS_MAX=$(cat /proc/sys/kernel/threads-max)
USER_LIMIT=$(ulimit -u)

if [[ -r /sys/fs/cgroup/pids.max ]]; then
    CGROUP_LIMIT=$(cat /sys/fs/cgroup/pids.max)
elif [[ -r /sys/fs/cgroup/pids/pids.max ]]; then
    CGROUP_LIMIT=$(cat /sys/fs/cgroup/pids/pids.max)
else
    CGROUP_LIMIT="unavailable"
fi

printf '%-22s %s\n' "LIMIT" "VALUE"
printf '%-22s %s\n' "pid_max" "$PID_MAX"
printf '%-22s %s\n' "threads-max" "$THREADS_MAX"
printf '%-22s %s\n' "ulimit -u" "$USER_LIMIT"
printf '%-22s %s\n' "cgroup pids.max" "$CGROUP_LIMIT"
