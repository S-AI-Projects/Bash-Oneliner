#!/usr/bin/env bats

setup() {
  DIR="$(cd "$BATS_TEST_DIRNAME" && pwd -P)"
  SANDBOX="$DIR/sandbox"
  SAFE_RM="$DIR/safe_rm.sh"
}

@test "sandbox removed" {
  # Ensure sandbox exists with files
  mkdir -p "$SANDBOX"
  touch "$SANDBOX/test_file.txt"
  [ -d "$SANDBOX" ]

  run "$SAFE_RM" "$SANDBOX"
  [ "$status" -eq 0 ]
  [ ! -e "$SANDBOX" ]
}

@test "safe_rm.sh / exits non-zero without deleting anything" {
  run "$SAFE_RM" "/"
  [ "$status" -ne 0 ]
  [ -d "/" ]
}

@test "safe_rm.sh ~ exits non-zero without deleting anything" {
  run "$SAFE_RM" "$HOME"
  [ "$status" -ne 0 ]
  [ -d "$HOME" ]
}

@test "safe_rm.sh ../.. exits non-zero without deleting anything" {
  run "$SAFE_RM" "$BATS_TEST_DIRNAME/../.."
  [ "$status" -ne 0 ]
  [ -d "$BATS_TEST_DIRNAME/../.." ]
}
