# R01-T009: Exploring Bash History with `fc`

## Overview

Bash provides two primary builtins for interacting with command history: `history` and `fc` ("fix command"). While `history` is primarily used to display or manipulate the history list, `fc` provides listing, editing, and immediate re-execution capabilities.

This lab investigates:
1. Why `fc -l -5` does not list itself while `history | tail -n 5` does.
2. Why `fc` and history expansion are inactive in shell scripts by default.
3. How `fc -s` and `fc -s old=new` allow rapid re-execution and pattern replacement.

---

## 1. Why `fc -l -5` Does Not List Itself vs. `history | tail -n 5`

### Observed Behavior
When running six commands (`cmd1` through `cmd6`):
- `history | tail -n 5` outputs the last 5 entries, with the 5th entry being the `history | tail -n 5` pipeline command itself:
  ```text
  12  echo cmd3
  13  echo cmd4
  14  echo cmd5
  15  echo cmd6
  16  history | tail -n 5
  ```
- `fc -l -5` outputs the last 5 commands *prior* to `fc`, completely omitting the `fc` invocation:
  ```text
  2   echo cmd2
  3   echo cmd3
  4   echo cmd4
  5   echo cmd5
  6   echo cmd6
  ```

### Explanation and `man bash` Citation
From `man bash` under `fc`:
> **`fc [-e ename] [-nlr] [first] [last]`**
> **`fc -s [pat=rep] [cmd]`**
> *"Fix Command. In the first form, a range of commands from first to last is selected from the history list. First and last may be specified as a string (to locate the last command beginning with that string) or as a number (an index into the history list, where a negative number is used as an offset from the current command number). If last is not specified it is set to the current command for listing (so that ``fc -l -10'' prints the last 10 commands) and to first otherwise."*

In interactive Bash:
- When a user enters any standard command (including `history | tail -n 5`), Bash appends the command line to the history list before executing it. When `history` executes, its own pipeline is already the newest item in the history list.
- However, `fc` is specifically defined in POSIX and Bash as a history repair utility. To allow fixing or reviewing past commands without polluting the listing with the lookup command itself, Bash excludes the active `fc` command from the listing range. The offset `-5` therefore counts back across the 5 commands preceding `fc`.

---

## 2. History in Non-Interactive Shells and Scripts

### Observed Behavior
Running `fc -l -5` inside a shell script or non-interactive subshell:
```bash
bash -c 'echo "one"; echo "two"; fc -l -5'
```
produces no history output.

### Explanation and `man bash` Citation
From `man bash` under `set` (`-o option-name`):
> `history`: *"Enable command history, as described above under HISTORY. This option is on by default in interactive shells."*

From `man bash` under `HISTORY`:
> *"Non-interactive shells do not perform history expansion by default."*

When executing a script (`#!/usr/bin/env bash`) or `bash -c '...'`:
- Bash initializes as a **non-interactive shell**.
- The `history` shell option is turned off by default (`set +o history`).
- No commands executed within the script are recorded to the history list, leaving the history buffer empty.
- To enable command history inside a script, the script must explicitly set:
  ```bash
  set -o history
  ```

---

## 3. History Re-Execution: `fc -s` and `fc -s old=new`

From `man bash`:
> *"In the second form, command is re-executed after each instance of pat is replaced by rep. A useful alias to use with this is ``r="fc -s"'', so that typing ``r cc'' runs the last command beginning with ``cc'' and typing ``r'' re-executes the last command."*

### Examples
1. **Re-run the previous command**:
   ```bash
   $ echo "build target"
   build target
   $ fc -s
   echo "build target"
   build target
   ```
2. **Re-run previous command with substitution**:
   ```bash
   $ echo "deploy to staging"
   deploy to staging
   $ fc -s staging=production
   echo "deploy to production"
   deploy to production
   ```
3. **List specific ranges with `fc -l -5 -1`**:
   `first = -5` and `last = -1` explicitly selects the slice starting 5 entries back and ending at the immediately preceding entry `-1`.

---

## 4. Verification

The automated test script [`work/R01-T009/check.sh`](check.sh) validates:
1. Interactive session output with isolated `HISTFILE` created via `mktemp`.
2. Exact listing of prior commands and exclusion of `fc -l -5`.
3. Range listing via `fc -l -5 -1`.
4. Re-execution and string substitution with `fc -s old=new`.
5. Non-interactive `set -o history` status (`off` by default).
6. Preserved integrity of the user's `~/.bash_history` (SHA-256 hash verified before and after).

Recorded interactive session transcript: [`work/R01-T009/session.log`](session.log).
