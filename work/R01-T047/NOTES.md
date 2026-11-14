# R01-T047: Process Limits

## Environment
- OS: Ubuntu 24.04.5 LTS (GitHub Codespaces)
- Shell: Bash
- cgroup version: cgroup v2

## Observed limits

| Limit | Value |
|---|---:|
| pid_max (/proc) | 4194304 |
| pid_max (sysctl) | 4194304 |
| threads-max | 63482 |
| ulimit -u | unlimited |
| cgroup pids.max | 9522 |
| cgroup pids.current | 100 |

## Which limit applies first?

The cgroup pids.max limit of 9,522 is the lowest finite task limit
among the values checked. It is lower than threads-max (63,482).
ulimit -u is unlimited, so it imposes no finite per-user limit here.

pid_max (4,194,304) controls the maximum PID number available for
allocation; it is not the cgroup's task-count limit.

The current cgroup is /init, with 100 tasks in use out of 9,522.
A tighter parent cgroup limit could also apply.

## Verification

Run ./work/R01-T047/limits.sh and ./work/R01-T047/check.sh.
The check verifies that sysctl and /proc pid_max match and that
the report contains all four limits.
