setup() {
  DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
  REPO_ROOT="$(cd "$DIR/../.." && pwd)"
  FETCH_SH="$DIR/fetch.sh"
  TEST_DIR="$(mktemp -d "$BATS_TMPDIR/fetch_test.XXXXXX")"
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "fetch.sh passes shellcheck" {
  run shellcheck "$FETCH_SH"
  [ "$status" -eq 0 ]
}

@test "good URL creates a non-empty file and exits 0" {
  good_url="https://raw.githubusercontent.com/onceupon/Bash-Oneliner/master/LICENSE"
  out_file="$TEST_DIR/license.txt"

  run "$FETCH_SH" "$good_url" "$out_file"
  [ "$status" -eq 0 ]
  [ -f "$out_file" ]
  [ -s "$out_file" ]
}

@test "bad URL exits non-zero and leaves no output file" {
  bad_url="https://raw.githubusercontent.com/onceupon/Bash-Oneliner/master/does-not-exist"
  out_file="$TEST_DIR/bad.txt"

  run "$FETCH_SH" "$bad_url" "$out_file"
  [ "$status" -ne 0 ]
  [ ! -e "$out_file" ]
}

@test "README entry gains empty-file warning and curl -fsSL alternative" {
  run grep -F "curl -fsSL" "$REPO_ROOT/README.md"
  [ "$status" -eq 0 ]
  run grep -i -E "empty.*file|leaves an empty" "$REPO_ROOT/README.md"
  [ "$status" -eq 0 ]
}
