# R01-T016: Move .bak files safely

## Environment

Tested on macOS 15.6 (Darwin 25.6.0, arm64) with GNU Bash 3.2.57, Bats 1.14.0, and the system BSD `find`, `xargs`, and `mv`. All reproduction files and the temporary `HOME/old` target are under `work/R01-T016/sandbox`; the reviewer's real `~/old` was not used.

## Reproducing the original commands

Created `.bak` files named `plain.bak`, `a b.bak`, and `line\nbreak.bak` (the last name contains a newline) under `sandbox/source`, plus `keep.txt`. Created the sandbox target `sandbox/home/old` and set `HOME` to `sandbox/home` before running the two README commands exactly as written.

Both commands failed at `find` with the system BSD error:

```text
find: 0: unknown primary or operator
```

The two captured errors are `sandbox/original-brace.err` and `sandbox/original-file.err`. The issue's example GNU `find` wording is `paths must precede expression: 0`; macOS reports the equivalent parse error with different wording. Since `find` produced no path list, none of the `.bak` files moved.

## Corrected result

After adding `mkdir -p ~/old` and changing `-print 0` to `-print0`, both corrected `xargs -0 -I {}` and `xargs -0 -I file` commands moved all three `.bak` files, including the space and newline names, into the temporary `sandbox/home/old`. `keep.txt` stayed in `sandbox/source`.

## Tests

`bats work/R01-T016/test.bats` runs both corrected commands with a per-test temporary `HOME`, verifies every `.bak` file moved, and confirms the non-matching file remained in place. Tests never use the reviewer's real `~/old`.
