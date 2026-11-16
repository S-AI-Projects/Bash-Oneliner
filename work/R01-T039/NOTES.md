# Task R01-T039 Notes: Explore Job Control with `jobs -l`

- **Student**: Anumoy Dasmaji
- **Task ID**: R01-T039 (9 of 10)
- **Repository**: https://github.com/S-AI-Projects/Bash-Oneliner
- **Target Item**: `README.md` L2136 / L2158 — "Show jobs and PID"

---

## 1. Environment

- **OS**: Darwin 24.3.0 / Linux compatible
- **Shell**: GNU bash (3.2.57 / 5.x)
- **Date**: 17 November 2026

---

## 2. Explanation of `jobs -l` Columns and Symbols

When running `jobs -l` in Bash:
```
[1]+  42151 Running                 sleep 100 &
[2]-  42154 Running                 sleep 100 &
```

### 2.1 The Columns
1. **Job Specifier (`[1]`, `[2]`)**:
   The shell-internal Job ID (sequential positive integer). Can be addressed in commands like `fg %1`, `bg %1`, `kill %1`, or `disown %1`.
2. **Current/Previous Job Markers (`+`, `-`, or space)**:
   - **`+` (Current Job)**: The job most recently stopped or backgrounded. When invoking `fg` or `bg` without arguments, or using `%%` / `%+`, Bash defaults to this job.
   - **`-` (Previous Job)**: The runner-up job (`%-`). If the current job terminates, the previous job is automatically promoted to the current job.
   - **Space (no marker)**: Any other background or suspended jobs (job 3, job 4, etc.).
3. **Process ID (PID) (`42151`, `42154`)**:
   The operating system kernel Process ID (shown because of the `-l` long flag).
4. **State (`Running`, `Stopped`, `Done`, `Terminated`)**:
   - `Running`: The process is actively executing concurrently in the background.
   - `Stopped`: The process was suspended by a signal (e.g. `SIGTSTP` via `Ctrl-Z`).
   - `Done [code]`: Process finished normally.
   - `Terminated [signal]`: Process was killed by a signal.
5. **Command Line**:
   The exact command string executed (e.g. `sleep 100 &`).

---

## 3. Interactive Session Walkthrough (`session.log`)

The interactive session recorded in `session.log` demonstrates:
1. Spawning two background jobs:
   ```bash
   sleep 100 &  # Assigned [1] PID 42151
   sleep 100 &  # Assigned [2] PID 42154
   ```
2. Running a foreground job and stopping it with `Ctrl-Z`:
   ```bash
   sleep 200
   ^Z           # Suspends job, assigned [3]+ Stopped
   ```
3. Inspecting the job table:
   `jobs -l` displays all 3 jobs, marking job 3 with `+` and job 2 with `-`.
4. Resuming stopped job in background with `bg`:
   `bg %3` moves job 3 to `Running` state without blocking terminal input.
5. Bringing a job to foreground with `fg`:
   `fg %2` brings job 2 back to the foreground, which is then interrupted with `Ctrl-C`.
6. Terminating a job with `kill`:
   `kill %3` sends `SIGTERM` to process 42155.
7. Removing a job from the shell table with `disown`:
   `disown %1` removes job 1 from the shell's job tracking table, so it will not receive `SIGHUP` when the shell exits. Subsequent `jobs -l` shows job 1 is no longer tracked.

---

## 4. Why `jobs` Is Empty in Non-Interactive Shell Scripts (`set -m`)

### 4.1 Default Non-Interactive Behavior
In non-interactive shell scripts (e.g. `bash script.sh`), job control is **disabled by default** (`set +m`):
- Scripts are designed for automated batch tasks where terminal intervention (`Ctrl-Z`, `fg`, `bg`) is not expected.
- All background processes (`&`) run in the script's process group rather than separate process groups.
- Bash does not maintain a job table for non-interactive subshells, so running `jobs` or `jobs -l` inside a script prints **nothing**.

### 4.2 Enabling Job Control with `set -m`
To enable job tracking inside a script:
```bash
set -m  # or set -o monitor
```
With `set -m`:
- Each background command is placed into its own process group.
- The shell populates the internal job table.
- `jobs -l` and `jobs -p` correctly report all active background jobs and their PIDs.

---

## 5. Automated Verification (`check.sh`)

Implemented in `work/R01-T039/check.sh`:
1. Activates job monitoring with `set -m`.
2. Starts two background jobs (`sleep 10 &`).
3. Uses `jobs -l` to capture output, parsing and asserting exactly 2 distinct PIDs.
4. Uses `jobs -p` to verify PID enumeration.
5. Reliably terminates all background jobs before script termination to prevent process leaks.
