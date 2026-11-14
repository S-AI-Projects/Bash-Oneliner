#!/usr/bin/env bats

setup() {
    FIXTURES="$BATS_TEST_DIRNAME/fixtures"
}

@test "shuf -n 100 returns exactly 100 lines from a large unique file" {
    input="$FIXTURES/unique-1000.txt"
    output="$(shuf -n 100 "$input")"

    [ "$(printf '%s\n' "$output" | wc -l)" -eq 100 ]

    while IFS= read -r line; do
        grep -Fxq "$line" "$input" || return 1
    done <<< "$output"

    [ "$(printf '%s\n' "$output" | sort -u | wc -l)" -eq 100 ]
}

@test "shuf -n 100 returns all 50 lines from a short file" {
    input="$FIXTURES/unique-50.txt"
    output="$(shuf -n 100 "$input")"

    [ "$(printf '%s\n' "$output" | wc -l)" -eq 50 ]
    [ "$(printf '%s\n' "$output" | sort -u | wc -l)" -eq 50 ]
    diff -u <(sort "$input") <(printf '%s\n' "$output" | sort)
}

@test "shuf output lines always exist in an input containing duplicates" {
    input="$FIXTURES/duplicates-1000.txt"
    output="$(shuf -n 100 "$input")"

    [ "$(printf '%s\n' "$output" | wc -l)" -eq 100 ]

    while IFS= read -r line; do
        grep -Fxq "$line" "$input" || return 1
    done <<< "$output"
}

@test "shuf -r permits repeated lines" {
    input="$FIXTURES/unique-50.txt"
    output="$(shuf -n 2000 -r "$input")"

    [ "$(printf '%s\n' "$output" | wc -l)" -eq 2000 ]
    [ "$(printf '%s\n' "$output" | sort -u | wc -l)" -lt 2000 ]
}

@test "the same --random-source produces reproducible output" {
    input="$FIXTURES/unique-1000.txt"
    random_source="$BATS_TEST_TMPDIR/random-source"

    awk 'BEGIN {
        srand(42)
        for (i = 0; i < 1048576; i++)
            printf "%c", int(rand() * 256)
    }' > "$random_source"

    first="$(shuf -n 100 --random-source="$random_source" "$input")"
    second="$(shuf -n 100 --random-source="$random_source" "$input")"

    [ "$first" = "$second" ]
}
