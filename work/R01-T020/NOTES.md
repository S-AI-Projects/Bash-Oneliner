# R01-T020: Let CI catch the wrong `expr` examples

## Checker behavior

`claims.sh` extracts the block beneath `##### Simple math with expr`. For every command line with an inline `#` result comment, it runs the command in Bash, compares stdout with the first value in the comment, and prints `OK` or `MISMATCH`. It exits nonzero if any claim differs.

## Baseline before the README fix

Run from the repository root with `bash work/R01-T020/claims.sh`. The original entry reported:

```text
MISMATCH | command: expr 10+20 | expected: 30 | actual: 10+20
MISMATCH | command: expr 10\*20 | expected: 600 | actual: 10*20
OK | command: expr 30 \> 20 | expected: 1 | actual: 1
2 expr claim(s) mismatched
```

## Why shell metacharacters are escaped

In `expr 10 \* 20`, the backslash prevents Bash from treating `*` as a filename glob; it leaves a literal multiplication operator for `expr`. In `expr 30 \> 20`, the backslash prevents Bash from treating `>` as output redirection; `expr` receives it as its greater-than operator. The backslashes are shell quoting and do not reach `expr`.

The original multiplication comment said `600`, but `10 * 20` is `200`. Once the spacing was corrected, the checker caught this incorrect claimed result too, so the README comment is corrected to `#200` for the check to pass.

## After the README fix

```text
OK | command: expr 10 + 20 | expected: 30 | actual: 30
OK | command: expr 10 \* 20 | expected: 200 | actual: 200
OK | command: expr 30 \> 20 | expected: 1 | actual: 1
```

## Environment

CI runs the checker on Ubuntu 24.04 with Bash. The local checker is run in the task worktree and the repository's existing Bats tests are run separately.
