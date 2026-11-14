#!/usr/bin/env bash
set -euo pipefail

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

marker="$tmpdir/side-effect"
output="$tmpdir/output"

# Start an interactive Bash shell with controlled history.
HOME="$tmpdir" bash --noprofile --norc -i >"$output" 2>&1 <<EOF
set -H
history -s 'touch "$marker"'
!!:p
exit
EOF

# The expanded command should be printed.
if ! grep -F "touch \"$marker\"" "$output" >/dev/null; then
    echo "FAIL: !!:p did not print the previous command."
    cat "$output"
    exit 1
fi

# The command must not execute.
if [[ -e "$marker" ]]; then
    echo "FAIL: !!:p executed the command."
    exit 1
fi

echo "PASS: !!:p printed the command without executing it."
