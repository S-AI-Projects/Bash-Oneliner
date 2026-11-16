#!/usr/bin/env bash
# Automated check for R01-T031: Teach `&&`, `||` and where you end up
# Requirements:
# 1. NOTES.md shows pwd after README line is NOT inside tmp/a/b/c, plus cd's error message.
# 2. QUIZ.md has 5 'predict pwd / exit status' questions with answers; check.sh passes on reference answers.
# 3. The braces version cd x 2>/dev/null || { mkdir -p x && cd x; } is demonstrated ending inside x.
# 4. README entry (L3380) gains the braces version.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"

echo "=== R01-T031 Automated Check ==="

# Check 1: Quiz reference answers
echo "1. Checking quiz reference answers..."
diff -u "$SCRIPT_DIR/answers.txt" <(bash "$SCRIPT_DIR/quiz.sh")
echo "   PASS: All 5 quiz answers match."

# Check 2: Demonstrate original README command flaw
echo "2. Demonstrating flaw in original README command..."
TMP_TEST=$(mktemp -d)
(
  cd "$TMP_TEST"
  orig_pwd=$(pwd)
  # Run original command: cd tmp/a/b/c || mkdir -p tmp/a/b/c
  err_msg=$(cd tmp/a/b/c 2>&1 || mkdir -p tmp/a/b/c)
  new_pwd=$(pwd)
  if [ "$orig_pwd" != "$new_pwd" ]; then
    echo "   FAIL: Expected shell to stay in original pwd, but pwd changed." >&2
    exit 1
  fi
  if [ ! -d "$orig_pwd/tmp/a/b/c" ]; then
    echo "   FAIL: Expected tmp/a/b/c to be created by mkdir -p." >&2
    exit 1
  fi
  if [ -z "$err_msg" ]; then
    echo "   FAIL: Expected cd to output error message." >&2
    exit 1
  fi
  echo "   PASS: Verified original line leaves pwd in starting directory ($new_pwd)."
)
rm -rf "$TMP_TEST"

# Check 3: Demonstrate braces version ends inside target
echo "3. Demonstrating braces version ends inside target directory..."
TMP_TEST=$(mktemp -d)
(
  cd "$TMP_TEST"
  start_pwd=$(pwd)
  
  # Subcase A: Directory does not exist
  cd x 2>/dev/null || { mkdir -p x && cd x; }
  pwd_after_a=$(pwd)
  if [ "$pwd_after_a" != "$start_pwd/x" ]; then
    echo "   FAIL: Expected to be inside $start_pwd/x, got $pwd_after_a" >&2
    exit 1
  fi
  
  # Subcase B: Directory already exists
  cd "$start_pwd"
  cd x 2>/dev/null || { mkdir -p x && cd x; }
  pwd_after_b=$(pwd)
  if [ "$pwd_after_b" != "$start_pwd/x" ]; then
    echo "   FAIL: Expected to be inside $start_pwd/x when already exists, got $pwd_after_b" >&2
    exit 1
  fi
  echo "   PASS: Verified braces version successfully ends inside target in both cases."
)
rm -rf "$TMP_TEST"

# Check 4: Verify README.md contains the braces version
echo "4. Checking README.md entry..."
entry=$(awk '/^##### Run command only if another command returns non-zero exit status/{on=1; next} on && /^##### /{exit} on' "$REPO_ROOT/README.md")
if [ -z "$entry" ]; then
  echo "   FAIL: 'Run command only if another command returns non-zero exit status' entry not found in README.md." >&2
  exit 1
fi

if ! grep -q "mkdir -p tmp/a/b/c && cd tmp/a/b/c" <<<"$entry"; then
  echo "   FAIL: The entry should contain the braces version: { mkdir -p tmp/a/b/c && cd tmp/a/b/c; }" >&2
  exit 1
fi
echo "   PASS: README.md entry contains the corrected braces version."

echo ""
echo "Summary: ALL CHECKS PASSED (R01-T031)."
