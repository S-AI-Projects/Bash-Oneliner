#!/usr/bin/env bats

@test "pipefail detects a failed command in a pipeline" {
  run bash -c 'set -o pipefail; false | tee "$1"' _ "$BATS_TEST_TMPDIR/out.txt"
  [ "$status" -eq 1 ]
}

@test "pipefail detects when tee cannot write" {
  mkdir "$BATS_TEST_TMPDIR/readonly"
  chmod 500 "$BATS_TEST_TMPDIR/readonly"

  run bash -c 'set -o pipefail; echo hi | tee "$1/out.txt"' _ "$BATS_TEST_TMPDIR/readonly"

  chmod 700 "$BATS_TEST_TMPDIR/readonly"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Permission denied"* ]]
}