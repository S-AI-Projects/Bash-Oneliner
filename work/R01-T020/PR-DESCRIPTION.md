## Description

Adds a CI check for the `expr` examples and corrects the README examples so their output comments match what Bash and `expr` produce.

## Related Issue

Fixes: #24

## Type of Change

- [x] Tests
- [x] Documentation
- [x] CI/CD

## Changes Made

- Added `work/R01-T020/claims.sh` to extract and check each commented command under `##### Simple math with expr`.
- Added `.github/workflows/r01-t020.yml` to run the checker on relevant pushes and pull requests.
- Fixed the README examples to use spaced `expr` operands and a literal multiplication operator.
- Added `work/R01-T020/NOTES.md` with the baseline mismatches, the final results, and why `*` and `>` need shell escaping.

## Screenshots / Recordings

Not applicable.

## Testing

- Before the README fix, the checker reported mismatches for `expr 10+20` and `expr 10\\*20`; the unchanged comparison example passed.
- After the fix, `bash work/R01-T020/claims.sh` reports `OK` for all three examples.
- `git diff --check` passes.
- The repository has no existing Bats files or other project test runner.
- Live GitHub Actions runs are not yet available because the task branch could not be pushed.

## Checklist

- [x] I have tested my changes locally.
- [x] I have added or updated tests, if needed.
- [x] I have updated documentation, if needed.
- [x] I have followed the project's coding guidelines.
- [x] I have run the relevant tests and checks.
- [ ] I have addressed previous review feedback, if applicable.

## Additional Notes

The source README's multiplication comment claimed `600`, but `10 * 20` evaluates to `200`. The output comment is therefore corrected to `#200` so the new checker can pass. GitHub rejected the branch push because the saved credential is invalid; no live red/green Actions links or PR can be attached until repository access is restored.
