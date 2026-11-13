#!/usr/bin/env bash
set -u

readme=${1:-README.md}
entry=$(awk '
  /^##### Simple math with expr$/ { in_entry = 1; next }
  in_entry && /^##### / { exit }
  in_entry { print }
' "$readme")

if [[ -z $entry ]]; then
  printf 'ERROR: could not find the Simple math with expr entry in %s\n' "$readme" >&2
  exit 2
fi

failures=0
while IFS= read -r line; do
  [[ $line =~ ^[[:space:]]*([^#]+)[[:space:]]+#(.*)$ ]] || continue
  command=${BASH_REMATCH[1]}
  claim=${BASH_REMATCH[2]}
  expected=${claim%%[[:space:]]*}

  if actual=$(bash -c "$command" 2>/dev/null); then
    :
  else
    actual="(exit $?)"
  fi

  if [[ $actual == "$expected" ]]; then
    result=OK
  else
    result=MISMATCH
    failures=$((failures + 1))
  fi
  printf '%s | command: %s | expected: %s | actual: %s\n' \
    "$result" "${command%[[:space:]]}" "$expected" "$actual"
done <<< "$entry"

if (( failures > 0 )); then
  printf '%d expr claim(s) mismatched\n' "$failures" >&2
  exit 1
fi
