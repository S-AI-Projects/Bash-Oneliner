#!/usr/bin/env bash
set -euo pipefail

random_source=""
args=()

for arg in "$@"; do
  case "$arg" in
    --random-source=*)
      random_source="${arg#*=}"
      ;;
    *)
      args+=("$arg")
      ;;
  esac
done

shuf_cmd=(shuf)
if [[ -n "$random_source" ]]; then
  shuf_cmd+=(--random-source="$random_source")
fi

if [[ ${#args[@]} -gt 0 ]]; then
  printf '%s\n' "${args[@]}" | "${shuf_cmd[@]}"
else
  "${shuf_cmd[@]}"
fi
