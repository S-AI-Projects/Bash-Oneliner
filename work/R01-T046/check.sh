#!/usr/bin/env bash
set -euo pipefail

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

input_newline="$tmpdir/input-newline"
input_no_newline="$tmpdir/input-no-newline"
expected="$tmpdir/expected"
actual="$tmpdir/actual"

printf 'one\ntwo\nthree\n' > "$input_newline"
printf 'one\ntwo\nthree' > "$input_no_newline"

check() {
    local name="$1"
    local input="$2"
    local expected_output="$3"

    if ! cmp -s "$actual" "$expected_output"; then
        echo "FAIL: $name"
        echo "Expected:"
        od -An -t x1 "$expected_output"
        echo "Actual:"
        od -An -t x1 "$actual"
        exit 1
    fi

    echo "PASS: $name"
}

for input_type in newline no_newline; do
    if [[ "$input_type" == newline ]]; then
        input="$input_newline"
    else
        input="$input_no_newline"
    fi

    # Original sed loop
    sed ':a;N;$!ba;s/\n//g' "$input" > "$actual"
    if [[ "$input_type" == newline ]]; then
        printf 'onetwothree\n' > "$expected"
    else
        printf 'onetwothree' > "$expected"
    fi
    check "Original sed ($input_type)" "$input" "$expected"

    # GNU sed -z
    sed -z 's/\n//g' "$input" > "$actual"
    printf 'onetwothree' > "$expected"
    check "GNU sed -z ($input_type)" "$input" "$expected"

    # tr
    tr -d '\n' < "$input" > "$actual"
    printf 'onetwothree' > "$expected"
    check "tr ($input_type)" "$input" "$expected"

    # paste
    paste -sd '' "$input" > "$actual"
    printf 'onetwothree\n' > "$expected"
    check "paste ($input_type)" "$input" "$expected"
done

echo "All R01-T046 checks passed."
