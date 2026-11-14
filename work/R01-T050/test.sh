#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
WORK="$ROOT/work/R01-T050"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

check() {
    local name="$1"
    local input="$WORK/fixtures/$name.txt"
    local sed_expected="$WORK/expected/$name.txt"
    local awk_expected="$sed_expected"

    if [[ "$name" == "no-trailing-newline" ]]; then
        awk_expected="$WORK/expected/no-trailing-newline-awk.txt"
        if [[ "$(uname -s)" == "Darwin" ]]; then
            sed_expected="$WORK/expected/no-trailing-newline-sed-macos.txt"
        else
            sed_expected="$WORK/expected/no-trailing-newline-sed.txt"
        fi
    fi

    sed 's/^/bbo/' "$input" > "$TMP/sed.out"
    awk '{print "bbo" $0}' "$input" > "$TMP/awk.out"

    cmp "$sed_expected" "$TMP/sed.out"
    cmp "$awk_expected" "$TMP/awk.out"

    echo "PASS: $name"
}

check normal
check empty-lines
check crlf
check no-trailing-newline

echo "All T050 tests passed."
