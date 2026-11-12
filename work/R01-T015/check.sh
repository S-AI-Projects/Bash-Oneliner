#!/usr/bin/env bash
set -euo pipefail

output=$(HISTFILE=/dev/null bash --noprofile --norc -i 2>/dev/null <<'BASH'
history -c
echo number-check
!1
history -c
echo relative-check
echo later
!-2
history -c
echo double-check
!!
history -c
echo prefix-check
!echo
history -c
echo substring-check
!?substring?
history -c
echo alpha beta
echo !^
history -c
echo alpha beta
echo !$
history -c
echo alpha beta
echo !*
history -c
echo print-only-target
!!:p
echo after-print-only
exit
BASH
)

expect_count() {
  local text=$1 expected=$2 actual
  actual=$(printf '%s\n' "$output" | grep -Fxc -- "$text" || true)
  if [[ $actual -ne $expected ]]; then
    printf 'FAIL: expected %q %s time(s), found %s\n--- output ---\n%s\n' \
      "$text" "$expected" "$actual" "$output" >&2
    exit 1
  fi
}

expect_count number-check 2
expect_count relative-check 2
expect_count double-check 2
expect_count prefix-check 2
expect_count substring-check 2
expect_count 'alpha beta' 4
expect_count alpha 1
expect_count beta 1
expect_count print-only-target 1
expect_count after-print-only 1
printf 'PASS: Bash history event/word designators and :p behavior verified.\n'
