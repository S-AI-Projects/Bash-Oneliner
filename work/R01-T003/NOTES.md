# Task R01-T003: Use `yes | rm -r` Safely in a Sandbox

## Overview
This document explores the mechanics of piping `yes` into `rm -r`, demonstrates how interactive prompts for write-protected files are answered automatically, explains why `rm -rf` is fundamentally different from `yes | rm -r`, and implements a sandbox guard script (`safe_rm.sh`) verified by Bats tests.

---

## 1. Sandbox Creation & File Listing

The sandbox was initialized using `work/R01-T003/create_sandbox.sh`, generating exactly 20 files, with 5 files set to mode `444` (`chmod 444`):

```bash
$ ls -l work/R01-T003/sandbox
total 160
-r--r--r--  1 aanyaahuja  staff  26 Nov 10 20:14 file_01.txt
-r--r--r--  1 aanyaahuja  staff  26 Nov 10 20:14 file_02.txt
-r--r--r--  1 aanyaahuja  staff  26 Nov 10 20:14 file_03.txt
-r--r--r--  1 aanyaahuja  staff  26 Nov 10 20:14 file_04.txt
-r--r--r--  1 aanyaahuja  staff  26 Nov 10 20:14 file_05.txt
-rw-r--r--  1 aanyaahuja  staff  26 Nov 10 20:14 file_06.txt
-rw-r--r--  1 aanyaahuja  staff  26 Nov 10 20:14 file_07.txt
-rw-r--r--  1 aanyaahuja  staff  26 Nov 10 20:14 file_08.txt
-rw-r--r--  1 aanyaahuja  staff  26 Nov 10 20:14 file_09.txt
-rw-r--r--  1 aanyaahuja  staff  26 Nov 10 20:14 file_10.txt
-rw-r--r--  1 aanyaahuja  staff  26 Nov 10 20:14 file_11.txt
-rw-r--r--  1 aanyaahuja  staff  26 Nov 10 20:14 file_12.txt
-rw-r--r--  1 aanyaahuja  staff  26 Nov 10 20:14 file_13.txt
-rw-r--r--  1 aanyaahuja  staff  26 Nov 10 20:14 file_14.txt
-rw-r--r--  1 aanyaahuja  staff  26 Nov 10 20:14 file_15.txt
-rw-r--r--  1 aanyaahuja  staff  26 Nov 10 20:14 file_16.txt
-rw-r--r--  1 aanyaahuja  staff  26 Nov 10 20:14 file_17.txt
-rw-r--r--  1 aanyaahuja  staff  26 Nov 10 20:14 file_18.txt
-rw-r--r--  1 aanyaahuja  staff  26 Nov 10 20:14 file_19.txt
-rw-r--r--  1 aanyaahuja  staff  26 Nov 10 20:14 file_20.txt
```

Notice `file_01.txt` through `file_05.txt` display mode `r--r--r--` (mode 444).

---

## 2. Interactive Behavior: `rm -r` vs `yes | rm -r`

### Attempting plain `rm -r` (answering `n`):
When `rm -r` encounters a write-protected (read-only) file without `-f`, it prompts the user for confirmation on standard input:
```bash
$ rm -r sandbox
rm: remove write-protected regular file 'sandbox/file_01.txt'? n
$ ls -ld sandbox
drwxr-xr-x  22 aanyaahuja  staff  704 Nov 10 20:14 sandbox
```
Because the prompt is answered with `n`, the file is not deleted and the directory remains intact.

### Running `yes | rm -r sandbox`:
Piping `yes` continuously supplies `y\n` to standard input:
```bash
$ yes | rm -r sandbox
$ ls -ld sandbox
ls: sandbox: No such file or directory
```
`rm` reads `y` from stdin for every write-protected confirmation prompt, automatically deleting all files and removing the directory.

---

## 3. Difference Between `yes n` and `rm -rf`

### What `yes n` does:
`yes n` continuously outputs the character `n` followed by a newline (`n\n`). When piped to an interactive command such as `rm -ri` or `rm -r`:
```bash
yes n | rm -ri directory
```
Every prompt requesting deletion confirmation receives `n`. The command safely runs through all entries without deleting any of them.

### Why `rm -rf` is not the same thing:
1. **Bypassing stdin**: `rm -rf` uses the `-f` (`--force`) flag, which instructs `rm` to never prompt and to ignore non-existent files. It does not read standard input at all.
2. **Permission handling**: `rm -rf` unlinks files directly via system calls (as long as the containing directory has write permissions), completely skipping the write-protection interactive check.
3. **Piping `yes | rm -r` vs `rm -rf`**:
   - `yes | rm -r` still relies on `rm` prompting on stdin and `yes` supplying answers. If stdin is disconnected or buffered unexpectedly, behavior can differ.
   - `rm -rf` is an internal flag in `rm` itself that bypasses prompt logic entirely.

---

## 4. Sandbox Guard: `safe_rm.sh`

`work/R01-T003/safe_rm.sh` guarantees that `yes | rm -r` can only ever delete paths located inside `work/R01-T003/sandbox`:

```bash
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
mkdir -p "$script_dir/sandbox"
sandbox_root="$(realpath "$script_dir/sandbox")"
target_resolved="$(realpath "$target")"

# Refuse any path outside the sandbox root
if [ "$target_resolved" != "$sandbox_root" ] && [[ "$target_resolved" != "$sandbox_root"/* ]]; then
  echo "Error: Refused. Target '$target_resolved' is not under sandbox '$sandbox_root'." >&2
  exit 1
fi

set +o pipefail
yes | rm -r -- "$target_resolved"
```

- **ShellCheck Verification**:
  ```bash
  $ shellcheck work/R01-T003/safe_rm.sh
  # (Clean: Exits 0 with no warnings)
  ```

---

## 5. Bats Test Results (`safe_rm.bats`)

The test suite in `work/R01-T003/safe_rm.bats` validates safe execution and failure guards across 4 distinct test cases:

```bash
$ bats work/R01-T003/safe_rm.bats
1..4
ok 1 sandbox removed
ok 2 safe_rm.sh / exits non-zero without deleting anything
ok 3 safe_rm.sh ~ exits non-zero without deleting anything
ok 4 safe_rm.sh ../.. exits non-zero without deleting anything
```
