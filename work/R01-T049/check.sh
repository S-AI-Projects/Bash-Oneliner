#!/usr/bin/env bash

set -u

script=${1:-"$(dirname "$0")/ask_yn.sh"}
passed=0
failed=0

check_case() {
    name=$1
    input=$2
    expected=$3

    printf '%s' "$input" | "$script" >/dev/null 2>&1
    actual=$?

    if [ "$actual" -eq "$expected" ]; then
        echo "PASS: $name"
        ((passed += 1))
    else
        echo "FAIL: $name (expected $expected, got $actual)"
        ((failed += 1))
    fi
}

check_case "y returns 0" "y" 0
check_case "n returns 1" "n" 1
newline=$'\n'
check_case "Enter returns 1" "$newline" 1
check_case "x then y returns 0" "xy" 0

echo "Waiting for timeout test (about 5 seconds)..."
sleep 6 | "$script" >/dev/null 2>&1
actual=$?

if [ "$actual" -eq 1 ]; then
    echo "PASS: timeout returns 1"
    ((passed += 1))
else
    echo "FAIL: timeout (expected 1, got $actual)"
    ((failed += 1))
fi

echo "$passed passed, $failed failed"
[ "$failed" -eq 0 ]
