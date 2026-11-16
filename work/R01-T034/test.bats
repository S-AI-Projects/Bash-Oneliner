#!/usr/bin/env bats
# Tests for R01-T034: Test the 'Grep AND' entry

setup() {
  SCRIPT_DIR="$(cd -- "$(dirname -- "$BATS_TEST_FILENAME")" && pwd)"
  FIXTURE="$SCRIPT_DIR/fixture.txt"
}

@test "README command 'grep A.*B' matches in order but misses 'B then A'" {
  run grep 'A.*B' "$FIXTURE"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "A then B" ]
  [ "${lines[1]}" = "AB" ]
  [ "${#lines[@]}" -eq 2 ]

  # Explicit assertion: 'B then A' is missing
  for line in "${lines[@]}"; do
    [ "$line" != "B then A" ]
  done
}

@test "Correct version 1 (piped grep) matches 'A then B', 'B then A' and 'AB'" {
  run bash -c "grep 'A' '$FIXTURE' | grep 'B'"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "A then B" ]
  [ "${lines[1]}" = "B then A" ]
  [ "${lines[2]}" = "AB" ]
  [ "${#lines[@]}" -eq 3 ]
}

@test "Correct version 2 (awk) matches 'A then B', 'B then A' and 'AB'" {
  run awk '/A/ && /B/' "$FIXTURE"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "A then B" ]
  [ "${lines[1]}" = "B then A" ]
  [ "${lines[2]}" = "AB" ]
  [ "${#lines[@]}" -eq 3 ]
}

@test "Correct version 3 (grep -P lookahead) matches 'A then B', 'B then A' and 'AB'" {
  if ! grep -P "test" </dev/null >/dev/null 2>&1; then
    skip "grep -P (PCRE) not supported on this platform"
  fi

  run grep -P '^(?=.*A)(?=.*B)' "$FIXTURE"
  [ "$status" -eq 0 ]
  [ "${lines[0]}" = "A then B" ]
  [ "${lines[1]}" = "B then A" ]
  [ "${lines[2]}" = "AB" ]
  [ "${#lines[@]}" -eq 3 ]
}
