#!/usr/bin/env bats
# Tests for R01-T033: Fix the number-rounding awk program

setup() {
  TEST_DIR="$(mktemp -d)"
  cd "$TEST_DIR"
}

teardown() {
  rm -rf "$TEST_DIR"
}

run_round_awk() {
  awk '{
    while (match($0, /[0-9]+\.[0-9]+/)) {
      printf "%s%.2f", substr($0, 1, RSTART-1), substr($0, RSTART, RLENGTH)
      $0 = substr($0, RSTART + RLENGTH)
    }
    print
  }'
}

@test "round awk program correctly rounds decimals on fixture 'pi=3.14159 e=2.71828 n=42 v=[1[2'" {
  result=$(echo "pi=3.14159 e=2.71828 n=42 v=[1[2" | run_round_awk)
  [ "$result" = "pi=3.14 e=2.72 n=42 v=[1[2" ]
}

@test "round awk program handles a line with no numbers" {
  result=$(echo "no numbers in this text" | run_round_awk)
  [ "$result" = "no numbers in this text" ]
}

@test "round awk program handles a number at the start of the line" {
  result=$(echo "12.3456 starts the line" | run_round_awk)
  [ "$result" = "12.35 starts the line" ]
}

@test "round awk program handles a number at the end of the line" {
  result=$(echo "ends with 98.7654" | run_round_awk)
  [ "$result" = "ends with 98.77" ]
}

@test "round awk program handles multiple floats on one line" {
  result=$(echo "vals: 1.111, 2.222, and 3.333" | run_round_awk)
  [ "$result" = "vals: 1.11, 2.22, and 3.33" ]
}

@test "round awk program preserves integers without decimal parts" {
  result=$(echo "count=42, total=1000" | run_round_awk)
  [ "$result" = "count=42, total=1000" ]
}
