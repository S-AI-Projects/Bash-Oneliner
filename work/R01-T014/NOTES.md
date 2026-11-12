# R01-T014: Characters and bytes in `${#foo}`

## Environment

Tested on macOS 15.6 (Darwin 25.6.0, arm64) with GNU Bash 3.2.57, Bats 1.14.0, and ShellCheck 0.11.0. The machine provides both `C.UTF-8` and `C`. The issue recommends Ubuntu 22.04/24.04; a Linux run was not available because the Docker daemon is not running.

## Locale results

Byte counts below come from `printf '%s' "$foo" | wc -c`. Bash `${#foo}` counts characters according to the active locale. Under `C.UTF-8`, the Hindi string has six encoded characters (code points) and 18 UTF-8 bytes. Under `C`, Bash treats each byte as a character, so the count is 18.

| Value | Locale | `${#foo}` | `wc -c` bytes |
|---|---|---:|---:|
| `hello` | `C.UTF-8` | 5 | 5 |
| `hello` | `C` | 5 | 5 |
| `नमस्ते` | `C.UTF-8` | 6 | 18 |
| `नमस्ते` | `C` | 18 | 18 |
| empty string | `C.UTF-8` | 0 | 0 |
| empty string | `C` | 0 | 0 |
| unset `foo` (without `set -u`) | `C.UTF-8` | 0 | 0 |
| unset `foo` (without `set -u`) | `C` | 0 | 0 |

## Arrays

For `arr=(a bb ccc)`, `${#arr}` is `1` (the first element's length), `${#arr[@]}` is `3` (the number of elements), and `${#arr[2]}` is `3` (the third element's length).

## Unset variable with nounset

With `set -u`, expanding `${#foo}` after `unset foo` exits with status 127 and prints:

```text
bash: foo: unbound variable
```

## Script and tests

`length.sh` prints the locale-sensitive character count and the byte count for one argument. `test.bats` checks the Hindi string under both locales, ASCII and empty input, argument validation, and the unset-variable error. `shellcheck work/R01-T014/length.sh` and `bats work/R01-T014/test.bats` are the required checks.
