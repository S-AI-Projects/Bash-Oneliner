# R01-T013: Prevent accidental file overwrites

## Environment

Tested on macOS 15.6 (Darwin 25.6.0, arm64) with GNU Bash 3.2.57 and Bats 1.14.0. The Bats tests passed locally. The issue specifies Ubuntu 22.04/24.04; I could not run the Linux check because the Docker daemon is not running on this machine.

## Destructive replacement demonstration

All file operations below were run in `work/R01-T013/sandbox`.

1. Created `notes.txt` with three lines. `wc -l notes.txt` reported `3`.
2. Ran `cat >notes.txt` and supplied one replacement line. `wc -l notes.txt` reported `1`: the original three lines were lost.
3. Restored three lines, then ran `tee notes.txt` with one replacement line on standard input. `wc -l notes.txt` reported `1`: `tee` also replaced the old contents.

## Noclobber, override, and append

With `set -o noclobber` enabled, `cat >notes.txt` failed with status 1 and left the existing file unchanged. Bash printed:

```text
bash: notes.txt: cannot overwrite existing file
```

`cat >|notes.txt` deliberately replaced the existing file despite `noclobber`. `cat >>notes.txt` appended a line, and `tee -a notes.txt` appended another line. `tee notes.txt` still replaced the file when `noclobber` was enabled, because the overwrite is performed by the `tee` program rather than Bash's `>` redirection.

## Tests

`bats work/R01-T013/test.bats` passed all four checks: `>` is blocked without changing the file, `>|` is allowed, `>>` is allowed, and `tee -a` appends. The test fixtures are kept under `work/R01-T013/sandbox`.
