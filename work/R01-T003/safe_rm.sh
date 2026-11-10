#!/usr/bin/env bash
# safe_rm.sh: Guard script that ensures deletions only occur inside work/R01-T003/sandbox

set -euo pipefail

if [ "$#" -ne 1 ]; then
  echo "Usage: $0 <path-to-remove>" >&2
  exit 1
fi

target="$1"

if [ ! -e "$target" ]; then
  echo "Error: Target '$target' does not exist." >&2
  exit 1
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)"
mkdir -p "$script_dir/sandbox"
sandbox_root="$(realpath "$script_dir/sandbox")"
target_resolved="$(realpath "$target")"

# Refuse any path that is not the sandbox itself or inside the sandbox
if [ "$target_resolved" != "$sandbox_root" ] && [[ "$target_resolved" != "$sandbox_root"/* ]]; then
  echo "Error: Refused. Target '$target_resolved' is not under sandbox '$sandbox_root'." >&2
  exit 1
fi

# Target is safely within sandbox; auto-confirm deletion using yes | rm -r
# Disable pipefail here so SIGPIPE on yes does not mask rm's exit status
set +o pipefail
# shellcheck disable=SC2216
yes | rm -r -- "$target_resolved"
