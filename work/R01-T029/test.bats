setup() {
  DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
  REPO_ROOT="$(cd "$DIR/../.." && pwd)"
  FIXTURE="$DIR/fixture"
  COUNT_SH="$DIR/count_files.sh"
}

@test "count_files.sh passes shellcheck" {
  run shellcheck "$COUNT_SH"
  [ "$status" -eq 0 ]
}

@test "fixture directory contains expected test files" {
  [ -f "$FIXTURE/two_lines.txt" ]
  [ -f "$FIXTURE/five_lines.txt" ]
  [ -f "$FIXTURE/zero_lines.txt" ]
  [ -f "$FIXTURE/my notes.txt" ]
  [ -d "$FIXTURE/subdir" ]

  [ $(wc -l < "$FIXTURE/two_lines.txt" | tr -d ' ') -eq 2 ]
  [ $(wc -l < "$FIXTURE/five_lines.txt" | tr -d ' ') -eq 5 ]
  [ $(wc -l < "$FIXTURE/zero_lines.txt" | tr -d ' ') -eq 0 ]
}

@test "README command prints line counts per file and fails on spaces" {
  cd "$FIXTURE"
  run bash -c "ls | xargs -n1 wc -l"
  # Fails due to missing 'my' and 'notes.txt' files and directory error
  [ "$status" -ne 0 ]
  # Verifies errors for 'my' and 'notes.txt'
  echo "$output" | grep -q "my:.*No such file or directory"
  echo "$output" | grep -q "notes.txt:.*No such file or directory"
  # Verifies line counts are printed
  echo "$output" | grep -q "5 five_lines.txt"
  echo "$output" | grep -q "2 two_lines.txt"
}

@test "count_files.sh returns 4 for the fixture" {
  run "$COUNT_SH" "$FIXTURE"
  [ "$status" -eq 0 ]
  [ "$output" = "4" ]
}

@test "README heading renamed and correct count files entry added" {
  run grep -F "##### Count lines in each file" "$REPO_ROOT/README.md"
  [ "$status" -eq 0 ]
  run grep -F "find . -maxdepth 1 -type f | wc -l" "$REPO_ROOT/README.md"
  [ "$status" -eq 0 ]
}
