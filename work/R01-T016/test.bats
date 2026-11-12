#!/usr/bin/env bats

setup() {
  sandbox="$BATS_TEST_DIRNAME/sandbox/case-$BATS_TEST_NUMBER"
  source_dir="$sandbox/source"
  temp_home="$sandbox/home"
  target="$temp_home/old"
  newline_name=$'line\nbreak.bak'

  mkdir -p "$source_dir" "$temp_home"
  printf 'plain backup\n' > "$source_dir/plain.bak"
  printf 'space backup\n' > "$source_dir/a b.bak"
  printf 'newline backup\n' > "$source_dir/$newline_name"
  printf 'keep this file\n' > "$source_dir/keep.txt"
}

teardown() {
  rm -rf "$sandbox"
}

assert_expected_files_moved() {
  local name
  for name in plain.bak 'a b.bak' "$newline_name"; do
    [ -f "$target/$name" ]
    [ ! -e "$source_dir/$name" ]
  done
  [ -f "$source_dir/keep.txt" ]
  [ ! -e "$target/keep.txt" ]
}

@test "-print0 and xargs -I {} move all .bak files safely" {
  run env HOME="$temp_home" bash -euo pipefail -c \
    'cd "$1" && mkdir -p ~/old && find . -name "*.bak" -print0 | xargs -0 -I {} mv {} ~/old' \
    _ "$source_dir"
  [ "$status" -eq 0 ]
  assert_expected_files_moved
}

@test "-print0 and xargs -I file handle spaces and newlines" {
  run env HOME="$temp_home" bash -euo pipefail -c \
    'cd "$1" && mkdir -p ~/old && find . -name "*.bak" -print0 | xargs -0 -I file mv file ~/old' \
    _ "$source_dir"
  [ "$status" -eq 0 ]
  assert_expected_files_moved
}
