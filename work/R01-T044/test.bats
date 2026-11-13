#!/usr/bin/env bats

@test "C locale sorts B, a and underscore in byte order" {
    result="$(printf '%s\n' B a _ | LC_ALL=C sort)"
    [ "$result" = "$(printf 'B\n_\na')" ]
}

@test "en_US UTF-8 locale uses locale-aware sort order" {
    result="$(printf '%s\n' B a _ | LC_ALL=en_US.utf8 sort)"
    [ "$result" = "$(printf '_\na\nB')" ]
}

@test "check script passes" {
    run bash work/R01-T044/check.sh
    [ "$status" -eq 0 ]
    [[ "$output" == *"PASS"* ]]
}
