#!/usr/bin/env bats

setup() {
  script="$BATS_TEST_DIRNAME/length.sh"
}

@test "Hindi text counts locale characters under C.UTF-8" {
  run env LC_ALL=C.UTF-8 "$script" 'नमस्ते'
  [ "$status" -eq 0 ]
  [ "$output" = $'characters=6\nbytes=18' ]
}

@test "Hindi text counts bytes as characters under C" {
  run env LC_ALL=C "$script" 'नमस्ते'
  [ "$status" -eq 0 ]
  [ "$output" = $'characters=18\nbytes=18' ]
}

@test "ASCII and empty values report character and byte counts" {
  run env LC_ALL=C.UTF-8 "$script" hello
  [ "$status" -eq 0 ]
  [ "$output" = $'characters=5\nbytes=5' ]

  run env LC_ALL=C.UTF-8 "$script" ''
  [ "$status" -eq 0 ]
  [ "$output" = $'characters=0\nbytes=0' ]
}

@test "requires exactly one argument" {
  run "$script"
  [ "$status" -eq 2 ]
  [[ "$output" == *"Usage:"* ]]
}

@test "set -u reports an unset variable as unbound" {
  if output=$(bash -uc 'unset foo; printf "%s" "${#foo}"' 2>&1); then
    exit_code=0
  else
    exit_code=$?
  fi
  [ "$exit_code" -eq 127 ]
  [[ "$output" == *"unbound variable"* ]]
}
