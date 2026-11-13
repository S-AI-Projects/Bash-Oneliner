#!/usr/bin/env bats

@test "both portable sorting methods match gawk on three rows" {
    run bash "$BATS_TEST_DIRNAME/check.sh"
    [ "$status" -eq 0 ]
    [[ "$output" == *"POSIX awk insertion sort matches gawk"* ]]
    [[ "$output" == *"tr/sort/paste matches gawk"* ]]
}

@test "README documents GNU awk requirement and portable alternative" {
    root="$BATS_TEST_DIRNAME/../.."
    run grep -F 'Requires GNU awk (gawk)' "$root/README.md"
    [ "$status" -eq 0 ]
    run grep -F "tr '\\t' '\\n' | sort -n | paste -sd '\\t' -" "$root/README.md"
    [ "$status" -eq 0 ]
}
