#!/usr/bin/env bash
set -euo pipefail

# Ensure GNU tools if on macOS
if [ -d "/opt/homebrew/opt/gnu-sed/libexec/gnubin" ]; then
  export PATH="/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH"
fi

ANSWERS_FILE="${1:-}"

if [ -z "$ANSWERS_FILE" ] || [ ! -f "$ANSWERS_FILE" ]; then
  echo "Usage: $0 <path/to/answers_script.sh>"
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# shellcheck source=/dev/null
source "$ANSWERS_FILE"

echo "=== Running Quiz Exercises ==="

# Ex 1
in1="start A-1-e middle A-2-e end"
exp1="start  middle  end"
out1=$(echo "$in1" | solve_ex1)
if [ "$out1" != "$exp1" ]; then
  echo "Ex 1 failed! Expected '$exp1', got '$out1'"
  exit 1
fi
echo "Exercise 1: PASS"

# Ex 2
in2="prefix A-123-e text A-xyz-e keep A-456-e suffix"
exp2="prefix  text A-xyz-e keep  suffix"
out2=$(echo "$in2" | solve_ex2)
if [ "$out2" != "$exp2" ]; then
  echo "Ex 2 failed! Expected '$exp2', got '$out2'"
  exit 1
fi
echo "Exercise 2: PASS"

# Ex 3
in3="item1 A-foo-e item2 A-bar-e item3"
exp3="item1  item2  item3"
out3=$(echo "$in3" | solve_ex3)
if [ "$out3" != "$exp3" ]; then
  echo "Ex 3 failed! Expected '$exp3', got '$out3'"
  exit 1
fi
echo "Exercise 3: PASS"

# Ex 4
in4="<b>bold text</b> and <i>italic text</i>"
exp4="bold text and italic text"
out4=$(echo "$in4" | solve_ex4)
if [ "$out4" != "$exp4" ]; then
  echo "Ex 4 failed! Expected '$exp4', got '$out4'"
  exit 1
fi
echo "Exercise 4: PASS"

# Ex 5
in5="[tag1] data [tag2]"
exp5=" data "
out5=$(echo "$in5" | solve_ex5)
if [ "$out5" != "$exp5" ]; then
  echo "Ex 5 failed! Expected '$exp5', got '$out5'"
  exit 1
fi
echo "Exercise 5: PASS"

# Ex 6
in6="A-101-e and A-202-e"
exp6="B-101-f and B-202-f"
out6=$(echo "$in6" | solve_ex6)
if [ "$out6" != "$exp6" ]; then
  echo "Ex 6 failed! Expected '$exp6', got '$out6'"
  exit 1
fi
echo "Exercise 6: PASS"

echo "=== Testing Deliberately Greedy Answer Rejection ==="
greedy_out=$(echo "start A-1-e middle A-2-e end" | sed 's/A-.*-e//g')
if [ "$greedy_out" = "start  middle  end" ]; then
  echo "Error: Greedy sed unexpectedly passed exercise 1!"
  exit 1
fi
echo "Greedy match correctly failed exercise 1 (output was '$greedy_out')"

echo "=== Verifying README.md ==="
grep -F "sed 's/A-[^-]*-e//g'" "$REPO_ROOT/README.md" >/dev/null || {
  echo "README missing non-greedy alternative"
  exit 1
}
echo "README update verified!"
echo "All R01-T026 tests passed successfully!"
