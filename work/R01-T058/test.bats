#!/usr/bin/env bats

setup() {
  TEST_DIR="$BATS_TMPDIR/find_delete_test"
  rm -rf "$TEST_DIR"
  mkdir -p "$TEST_DIR"
  truncate -s 0 "$TEST_DIR/0.mso"
  truncate -s 10 "$TEST_DIR/10.mso"
  truncate -s 73 "$TEST_DIR/73.mso"
  truncate -s 74 "$TEST_DIR/74.mso"
  truncate -s 75 "$TEST_DIR/75.mso"
  truncate -s 2000 "$TEST_DIR/2000.mso"
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "-size -74c deletes only files strictly under 74 bytes (0, 10, 73)" {
  find "$TEST_DIR" -name "*.mso" -size -74c -delete
  [ ! -f "$TEST_DIR/0.mso" ]
  [ ! -f "$TEST_DIR/10.mso" ]
  [ ! -f "$TEST_DIR/73.mso" ]
  [ -f "$TEST_DIR/74.mso" ]
  [ -f "$TEST_DIR/75.mso" ]
  [ -f "$TEST_DIR/2000.mso" ]
}
