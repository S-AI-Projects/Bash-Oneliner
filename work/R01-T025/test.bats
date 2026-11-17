setup() {
  DIR="$(cd "$(dirname "$BATS_TEST_FILENAME")" && pwd)"
  REPO_ROOT="$(cd "$DIR/../.." && pwd)"
  FIXTURE="$DIR/fixture.txt"
}

@test "fixture has >= 10 columns and valid structure" {
  [ -f "$FIXTURE" ]
  line_count=$(wc -l < "$FIXTURE")
  [ "$line_count" -ge 5 ]
  # Check first line has at least 10 fields
  fields=$(head -n 1 "$FIXTURE" | awk '{print NF}')
  [ "$fields" -ge 10 ]
}

@test "fixed awk command correctly filters matching lines" {
  a="bbo"
  b="obb"
  run awk -v a="$a" -v b="$b" '$1==a && $10==b' "$FIXTURE"
  [ "$status" -eq 0 ]
  [ "${#lines[@]}" -eq 2 ]
  [ "${lines[0]}" = "bbo c2 c3 c4 c5 c6 c7 c8 c9 obb" ]
  [ "${lines[1]}" = "bbo c2 c3 c4 c5 c6 c7 c8 c9 obb" ]
}

@test "original double-quoted command with set -x shows shell expansion issue" {
  run bash -c '
    a="bbo"; b="obb"
    awk -v a="$a" -v b="$b" "$1==a && $10=b" "'"$FIXTURE"'"
  '
  # Shell expansion produces syntax error in awk or fails comparison
  [ "$status" -ne 0 ]
}

@test "README uses single quotes and double equals" {
  run grep -F "awk -v a=\"\$a\" -v b=\"\$b\" '\$1==a && \$10==b' filename" "$REPO_ROOT/README.md"
  [ "$status" -eq 0 ]
}
