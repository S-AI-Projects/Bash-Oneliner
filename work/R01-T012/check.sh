#!/usr/bin/env bash
set -euo pipefail

# Feed commands to an interactive, clean Bash so history expansion is enabled.
output=$(printf '%s\n' \
  'echo aaa aaa' \
  '^aaa^bbb' \
  'echo aaa aaa' \
  '!!:gs/aaa/bbb/' \
  'exit' | bash --norc -i 2>&1 || true)

grep -Fqx 'bbb aaa' <<< "$output" || {
  printf 'FAIL: first-only output was not found\n%s\n' "$output" >&2
  exit 1
}
grep -Fqx 'bbb bbb' <<< "$output" || {
  printf 'FAIL: global output was not found\n%s\n' "$output" >&2
  exit 1
}
printf 'PASS: caret substitution changes the first occurrence; :gs changes all occurrences.\n'
