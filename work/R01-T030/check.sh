#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
NORM_SCRIPT="$SCRIPT_DIR/normalise.sh"
NOTES_FILE="$SCRIPT_DIR/NOTES.md"

echo "1. Checking shellcheck on normalise.sh..."
shellcheck "$NORM_SCRIPT"
echo "normalise.sh passed shellcheck!"

echo "2. Testing normalisation logic across all sources..."
# Test multi-session users stream
mock_users="alice bob alice charlie bob"
exp_norm=$(printf "alice\nbob\ncharlie\n")

u_norm=$(echo "$mock_users" | "$NORM_SCRIPT" users)
if [ "$u_norm" != "$exp_norm" ]; then
  echo "normalise.sh users failed. Expected:"
  echo "$exp_norm"
  echo "Got:"
  echo "$u_norm"
  exit 1
fi

mock_who=$(cat << 'WHO'
alice    ttys000  Nov 18 00:01
bob      ttys001  Nov 18 00:02
alice    ttys002  Nov 18 00:03
charlie  ttys003  Nov 18 00:04
bob      ttys004  Nov 18 00:05
WHO
)

w_norm=$(echo "$mock_who" | "$NORM_SCRIPT" who)
if [ "$w_norm" != "$exp_norm" ]; then
  echo "normalise.sh who failed. Expected:"
  echo "$exp_norm"
  echo "Got:"
  echo "$w_norm"
  exit 1
fi

mock_loginctl=$(cat << 'LOGINCTL'
 UID USER
1000 alice
1001 bob
1002 charlie

3 users listed.
LOGINCTL
)

l_norm=$(echo "$mock_loginctl" | "$NORM_SCRIPT" loginctl)
if [ "$l_norm" != "$exp_norm" ]; then
  echo "normalise.sh loginctl failed. Expected:"
  echo "$exp_norm"
  echo "Got:"
  echo "$l_norm"
  exit 1
fi
echo "All three normalised outputs match identically!"

echo "3. Running normalise.sh in live system mode..."
"$NORM_SCRIPT" all

echo "4. Checking NOTES.md contents..."
grep -qi "hyperfine" "$NOTES_FILE" || { echo "Missing hyperfine section in NOTES.md"; exit 1; }
grep -qi "loginctl" "$NOTES_FILE" || { echo "Missing loginctl section in NOTES.md"; exit 1; }

echo "5. Checking README.md updates..."
grep -F "who | awk '{print \$1}' | sort -u" "$REPO_ROOT/README.md" >/dev/null || {
  echo "Missing 'who | awk' in README.md"
  exit 1
}
echo "README update verified!"
echo "All R01-T030 checks passed successfully!"
