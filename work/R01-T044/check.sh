#!/usr/bin/env bash
set -euo pipefail

c_output=$(printf '%s\n' B a _ | LC_ALL=C sort)
utf8_output=$(printf '%s\n' B a _ | LC_ALL=en_US.utf8 sort)

expected_c=$(printf 'B\n_\na')
expected_utf8=$(printf '_\na\nB')

if [[ "$c_output" != "$expected_c" ]]; then
    echo "FAIL: C locale sort order did not match."
    exit 1
fi

if [[ "$utf8_output" != "$expected_utf8" ]]; then
    echo "FAIL: UTF-8 locale sort order did not match."
    exit 1
fi

echo "PASS: Both locale sorting orders match the documented output."
