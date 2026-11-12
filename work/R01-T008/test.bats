#!/usr/bin/env bats

setup() {
  DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" >/dev/null 2>&1 && pwd)"
  SCRIPT="$DIR/read_exact.sh"
}

@test "preserves leading, internal, and trailing whitespace ('  two  spaces  ')" {
  input="  two  spaces  "
  run "$SCRIPT" <<< "$input"
  [ "$status" -eq 0 ]
  [ "$output" = "$input" ]
  diff -u <(printf '%s\n' "$input" | od -c) <(printf '%s\n' "$output" | od -c)
}

@test "preserves backslashes ('C:\new\dir')" {
  input='C:\new\dir'
  run "$SCRIPT" <<< "$input"
  [ "$status" -eq 0 ]
  [ "$output" = "$input" ]
  diff -u <(printf '%s\n' "$input" | od -c) <(printf '%s\n' "$output" | od -c)
}

@test "preserves glob character without pathname expansion ('*')" {
  input='*'
  run "$SCRIPT" <<< "$input"
  [ "$status" -eq 0 ]
  [ "$output" = "$input" ]
  diff -u <(printf '%s\n' "$input" | od -c) <(printf '%s\n' "$output" | od -c)
}

@test "preserves option flag without option interpretation ('-n')" {
  input='-n'
  run "$SCRIPT" <<< "$input"
  [ "$status" -eq 0 ]
  [ "$output" = "$input" ]
  diff -u <(printf '%s\n' "$input" | od -c) <(printf '%s\n' "$output" | od -c)
}

@test "preserves empty line ('')" {
  input=''
  run "$SCRIPT" <<< "$input"
  [ "$status" -eq 0 ]
  [ "$output" = "$input" ]
  diff -u <(printf '%s\n' "$input" | od -c) <(printf '%s\n' "$output" | od -c)
}

@test "byte-for-byte stream fidelity check via cmp" {
  inputs=("  two  spaces  " 'C:\new\dir' '*' '-n' '')
  for inp in "${inputs[@]}"; do
    cmp -s <(printf "%s\n" "$inp") <(printf "%s\n" "$inp" | "$SCRIPT")
  done
}
