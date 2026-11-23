# Task R01-T053: CPU Counting and Cgroup Boundary Comparison

## Comparison of CPU Count Tools

| Tool / Source | Scope / Semantics | Cgroup / Affinity Aware? | Platform |
| --- | --- | --- | --- |
| `/proc/cpuinfo` | Physical/virtual processors configured on host | No (shows entire host hardware) | Linux only |
| `lscpu` | Comprehensive CPU architecture details from `/sys/devices/system/cpu` | No (hardware topology) | Linux only |
| `nproc --all` | Total installed processing units | No | GNU coreutils |
| `nproc` | Processing units available to the current process | **Yes** (bounded by cgroups & taskset) | GNU coreutils |
| `sysctl -n hw.ncpu` | Total CPUs | No | macOS / BSD |

## Syscall & Trace Inspection
Running `strace lscpu` shows that `lscpu` inspects:
- `/sys/devices/system/cpu/online`
- `/sys/devices/system/cpu/possible`
- `/proc/cpuinfo`
- `/sys/devices/system/cpu/cpu*/topology/`

## Cgroup & Affinity Differences
When running inside containers (Docker/Kubernetes) or systemd slices with `cpu.max` set, `/proc/cpuinfo` still lists all host cores (e.g. 128 cores), while `nproc` correctly reflects quota allocations or CPU affinity sets.
