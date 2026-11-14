#!/usr/bin/env bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
WORK="$ROOT/work/R01-T050"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

compare() {
    local label="$1" expected="$2" actual="$3"
    if ! cmp -s "$expected" "$actual"; then
        echo "FAIL: $label"
        echo "Expected bytes:"
        od -An -tx1 "$expected"
        echo "Actual bytes:"
        od -An -tx1 "$actual"
        return 1
    fi
}

check() {
    local name="$1"
    local input="$WORK/fixtures/$name.txt"
    local sed_expected="$WORK/expected/$name.txt"
    local awk_expected="$sed_expected"

    if [[ "$name" == "no-trailing-newline" ]]; then
        awk_expected="$WORK/expected/no-trailing-newline-awk.txt"
        sed_expected="$WORK/expected/no-trailing-newline-sed.txt"
    fi

    sed 's/^/bbo/' "$input" > "$TMP/sed.out"
    awk '{print "bbo" $0}' "$input" > "$TMP/awk.out"

    compare "sed: $name" "$sed_expected" "$TMP/sed.out"
    compare "awk: $name" "$awk_expected" "$TMP/awk.out"

    echo "PASS: $name"
}

check normal
check empty-lines
check crlf
check no-trailing-newline

echo "All T050 tests passed."
