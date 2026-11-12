#!/usr/bin/env bash
# extract.sh: Extract the first ```bash code block under '##### HEADING' from README.md
set -euo pipefail

if [ "$#" -lt 1 ]; then
  echo "Usage: $0 <HEADING> [README_PATH]" >&2
  exit 1
fi

heading="$1"

# Determine path to README.md
script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
if [ "$#" -ge 2 ]; then
  readme="$2"
elif [ -f "$script_dir/../../README.md" ]; then
  readme="$script_dir/../../README.md"
elif [ -f "README.md" ]; then
  readme="README.md"
else
  echo "Error: README.md not found" >&2
  exit 1
fi

awk -v heading="$heading" '
BEGIN {
  found = 0
  in_block = 0
}
!found {
  if ($0 ~ /^#####[[:space:]]+/) {
    h = $0
    sub(/^#####[[:space:]]+/, "", h)
    sub(/[[:space:]]+$/, "", h)
    if (h == heading) {
      found = 1
    }
  }
  next
}
found {
  if ($0 ~ /^#####/) {
    exit
  }
  if (!in_block && $0 ~ /^```bash/) {
    in_block = 1
    next
  }
  if (in_block && $0 ~ /^```/) {
    exit
  }
  if (in_block) {
    print
  }
}
' "$readme"
