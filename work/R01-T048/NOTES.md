# R01-T048: Property tests for `shuf -n`

## Environment
- OS: Ubuntu 24.04.5 LTS
- Shell: GNU Bash 5.2.21
- GNU coreutils: 9.4
- Bats: 1.14.0

## Fixtures
- `unique-1000.txt`: 1,000 distinct lines.
- `unique-50.txt`: 50 distinct lines.
- `duplicates-1000.txt`: 1,000 lines, with each of 500 values appearing twice.

## Properties tested
1. `shuf -n 100` returns exactly 100 lines when the input has at least 100 lines.
2. When the input has fewer than 100 lines, `shuf -n 100` returns all available lines.
3. Every output line is present in the input.
4. With unique input, the default `shuf -n` output contains no repeated lines.
5. `shuf -n 2000 -r` can produce repeated lines when sampling from only 50 unique lines.
6. Reusing the same `--random-source` file produces identical output.

## Results
- All 5 Bats tests passed.
- The complete test suite was run 20 consecutive times.
- All 20 runs passed with zero failures.

## README change
Added the `shuf -n 100 -r filename` example and a comment explaining that the default behavior does not repeat lines.
