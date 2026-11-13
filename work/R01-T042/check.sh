#!/usr/bin/env bash
set -euo pipefail

input=$(printf '1\t40\t35\t12\t23\n5\t9\t2\t18\t1\n10\t3\t7\t2\t6\n')

expected=$(printf '%s\n' "$input" | gawk '
{
    n = split($0, a, "\t")
    asort(a)
    for (i = 1; i <= n; i++) {
        if (i > 1) printf "\t"
        printf "%s", a[i]
    }
    printf "\n"
}')

awk_result=$(printf '%s\n' "$input" | awk '
{
    n = split($0, a, "\t")
    for (i = 2; i <= n; i++) {
        value = a[i]
        j = i - 1
        while (j >= 1 && a[j] + 0 > value + 0) {
            a[j + 1] = a[j]
            j--
        }
        a[j + 1] = value
    }
    for (i = 1; i <= n; i++) {
        if (i > 1) printf "\t"
        printf "%s", a[i]
    }
    printf "\n"
}')

utility_result=$(
    while IFS= read -r row; do
        printf '%s\n' "$row" |
            tr '\t' '\n' |
            sort -n |
            paste -sd "$(printf '\t')" -
    done <<< "$input"
)

if [[ "$awk_result" != "$expected" ]]; then
    echo "FAIL: POSIX awk insertion sort differs from gawk."
    diff -u <(printf '%s\n' "$expected") <(printf '%s\n' "$awk_result") || true
    exit 1
fi

if [[ "$utility_result" != "$expected" ]]; then
    echo "FAIL: tr/sort/paste differs from gawk."
    diff -u <(printf '%s\n' "$expected") <(printf '%s\n' "$utility_result") || true
    exit 1
fi

echo "PASS: POSIX awk insertion sort matches gawk (3 rows)."
echo "PASS: tr/sort/paste matches gawk (3 rows)."
