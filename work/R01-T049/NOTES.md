# R01-T049 — Read Options and Prompt Exercise

## Environment
- OS: Linux 6.8.0-1070-azure x86_64 (GitHub Codespaces)
- Shell: GNU Bash 5.2.21

## Files
- `READ_PROMPT.md`: explanations and demos of `-r`, `-s`, `-p`, `-n1`, `$'…'`, and `-t 5`.
- `ask_yn.sh`: yes/no prompt with a five-second timeout.
- `check.sh`: automated prompt tests.

## Manual test
Ran `ask_yn.sh`, entered `y`, and checked the exit status with `echo $?`. Result: 0.

## Automated tests
Ran:
    bash -n work/R01-T049/ask_yn.sh work/R01-T049/check.sh
    bash work/R01-T049/check.sh work/R01-T049/ask_yn.sh

Results:
- y returns 0: PASS
- n returns 1: PASS
- Enter (newline) returns 1: PASS
- x followed by y returns 0: PASS
- Five-second timeout returns 1: PASS

Final result: 5 passed, 0 failed.

## Stdin behaviour
Tests supply input through pipes rather than an interactive terminal. The prompt from `read -p` is not displayed when stdin is not a terminal, and `-s` cannot suppress echo for piped input. The timeout test checks the case where no input arrives.

## Repository checks
- Bash syntax checks passed for both scripts.
- `git diff --check` passed.
- No repository-level test runner or test suite was present in this checkout.
