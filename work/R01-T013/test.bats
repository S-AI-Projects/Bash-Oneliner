#!/usr/bin/env bats

setup() {
  sandbox="$BATS_TEST_DIRNAME/sandbox"
  mkdir -p "$sandbox"
  file="$sandbox/test-$BATS_TEST_NUMBER.txt"
  printf 'before\n' > "$file"
}

teardown() {
  rm -f "$file"
}

@test "noclobber blocks > and preserves the existing file" {
  run bash -c 'set -o noclobber; printf "after\\n" > "$1"' _ "$file"
  [ "$status" -ne 0 ]
  [ "$(cat "$file")" = "before" ]
}

@test ">| deliberately overwrites with noclobber enabled" {
  run bash -c 'set -o noclobber; printf "after\\n" >| "$1"' _ "$file"
  [ "$status" -eq 0 ]
  [ "$(cat "$file")" = "after" ]
}

@test ">> appends with noclobber enabled" {
  run bash -c 'set -o noclobber; printf "after\\n" >> "$1"' _ "$file"
  [ "$status" -eq 0 ]
  [ "$(cat "$file")" = $'before\nafter' ]
}

@test "tee -a appends" {
  printf 'after\n' | tee -a "$file" >/dev/null
  [ "$(cat "$file")" = $'before\nafter' ]
}
