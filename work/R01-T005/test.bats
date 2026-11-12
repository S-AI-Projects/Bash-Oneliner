#!/usr/bin/env bats

setup() {
  DIR="$(cd "$BATS_TEST_DIRNAME" && pwd -P)"
  FIXTURE="$DIR/fixture.txt"
  EXPECTED="$DIR/expected.txt"
  EMPTY_FILE="$BATS_TEST_TMPDIR/empty.txt"
  touch "$EMPTY_FILE"

  NO_NEWLINE_FILE="$BATS_TEST_TMPDIR/no_newline.txt"
  printf "@S_first_line\nmiddle_@S_fragment\n@S_last_no_newline" > "$NO_NEWLINE_FILE"
}

@test "sed -n '/^@S/p' output matches expected.txt exactly" {
  run sed -n '/^@S/p' "$FIXTURE"
  [ "$status" -eq 0 ]
  expected_content="$(cat "$EXPECTED")"
  [ "$output" = "$expected_content" ]
}

@test "expected output excludes mid-line and leading-space lines" {
  run sed -n '/^@S/p' "$FIXTURE"
  [ "$status" -eq 0 ]
  # Mid-line occurrence must not be selected
  [[ "$output" != *"middle_@S_fragment"* ]]
  # Leading-space line must not be selected
  [[ "$output" != *" @S_with_leading_space"* ]]
}

@test "sed -n '/^@S/p' and grep '^@S' give identical output on fixture" {
  sed_out="$(sed -n '/^@S/p' "$FIXTURE")"
  grep_out="$(grep '^@S' "$FIXTURE")"
  [ "$sed_out" = "$grep_out" ]
}

@test "empty-file test passes (no output, exit 0)" {
  run sed -n '/^@S/p' "$EMPTY_FILE"
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "file without trailing newline preserves all lines starting with @S" {
  sed_out="$(sed -n '/^@S/p' "$NO_NEWLINE_FILE")"
  grep_out="$(grep '^@S' "$NO_NEWLINE_FILE")"
  [ "$sed_out" = "$grep_out" ]
  [[ "$sed_out" == *"@S_first_line"* ]]
  [[ "$sed_out" == *"@S_last_no_newline"* ]]
  [[ "$sed_out" != *"middle_@S_fragment"* ]]
}
