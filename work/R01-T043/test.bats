#!/usr/bin/env bats

@test "xargs -t prints command to stderr and result to stdout" {
    tmpdir="$(mktemp -d)"

    echo abcd | xargs -t > "$tmpdir/stdout" 2> "$tmpdir/stderr"

    [ "$(cat "$tmpdir/stdout")" = "abcd" ]
    [ "$(cat "$tmpdir/stderr")" = "echo abcd" ]

    rm -rf "$tmpdir"
}
