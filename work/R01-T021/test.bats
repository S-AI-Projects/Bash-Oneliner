setup() {
  export PATH="/opt/homebrew/opt/coreutils/libexec/gnubin:/opt/homebrew/bin:$PATH"
  DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
  REPO_ROOT="$(cd "$DIR/../.." && pwd)"
  DRAW_SH="$DIR/draw.sh"
}

@test "draw.sh passes shellcheck" {
  run shellcheck "$DRAW_SH"
  [ "$status" -eq 0 ]
}

@test "draw.sh handles empty input gracefully (no output, exit 0)" {
  run "$DRAW_SH" < /dev/null
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "draw.sh handles duplicate names" {
  run "$DRAW_SH" "alice" "alice" "bob"
  [ "$status" -eq 0 ]
  # Check line count
  [ "${#lines[@]}" -eq 3 ]
  # Ensure both alice and bob are present
  echo "$output" | grep -q "bob"
  [ $(echo "$output" | grep -c "alice") -eq 2 ]
}

@test "draw.sh preserves names containing spaces" {
  run "$DRAW_SH" "Alice Smith" "Bob Dylan" "Charlie Chaplin"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 3 ]
  echo "$output" | grep -q "^Alice Smith$"
  echo "$output" | grep -q "^Bob Dylan$"
  echo "$output" | grep -q "^Charlie Chaplin$"
}

@test "Reproducible mode produces identical order across two runs" {
  seed_file="$BATS_TMPDIR/seed.bin"
  dd if=/dev/zero bs=1024 count=4 of="$seed_file" 2>/dev/null

  run "$DRAW_SH" --random-source="$seed_file" a b c d e
  [ "$status" -eq 0 ]
  out1="$output"

  run "$DRAW_SH" --random-source="$seed_file" a b c d e
  [ "$status" -eq 0 ]
  out2="$output"

  [ "$out1" = "$out2" ]
  rm -f "$seed_file"
}

@test "README contains --random-source example" {
  run grep -F -- "--random-source" "$REPO_ROOT/README.md"
  [ "$status" -eq 0 ]
}
