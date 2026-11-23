# Task R01-T060: Portable 'N days ago' Across Linux (GNU) and macOS (BSD)

## Background & Differences
- **GNU date**: Uses `-d` (e.g. `date -d "N days ago" +"%F"`).
- **BSD / macOS date**: Uses `-v` (e.g. `date -v-Nd +"%F"`). The `-d` flag on BSD sets daylight saving time.

## Detection Strategy
Run `date --version >/dev/null 2>&1`. GNU Coreutils `date` exits 0 on `--version`, while BSD date exits with error code 1.

## Timezone & DST Edge Cases
When performing date arithmetic across Daylight Saving Time transitions (e.g. 23-hour or 25-hour days), hour-based offsets like `-24 hours` can result in the same calendar day or skip a day. Using calendar day modifiers (`-v-Nd` and `N days ago`) operates strictly on calendar days, avoiding DST drift.

## Cross-Platform CI Matrix
Sample GitHub Actions workflow specification for testing on both `ubuntu-latest` and `macos-latest` runners is documented in `ci-workflow.yml`.
