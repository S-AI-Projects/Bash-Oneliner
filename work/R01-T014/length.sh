#!/usr/bin/env bash
set -euo pipefail

if (( $# != 1 )); then
  printf 'Usage: %s STRING\n' "${0##*/}" >&2
  exit 2
fi

foo=$1
characters=${#foo}
bytes=$(printf '%s' "$foo" | wc -c)
bytes=${bytes//[[:space:]]/}
printf 'characters=%s\nbytes=%s\n' "$characters" "$bytes"
