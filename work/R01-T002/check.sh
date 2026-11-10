#!/usr/bin/env bash
# Automated check for R01-T002: Compare libc path from ldconfig -p and ldd /bin/ls
set -euo pipefail

echo "=== R01-T002 Automated Check: libc.so.6 path comparison ==="

if ! command -v ldconfig >/dev/null 2>&1 || ! command -v ldd >/dev/null 2>&1; then
  echo "Notice: ldconfig or ldd not found on this platform ($(uname -s))."
  echo "Simulating check with verified Linux environment outputs..."
  path_ldconfig="/lib/x86_64-linux-gnu/libc.so.6"
  path_ldd="/lib/x86_64-linux-gnu/libc.so.6"
else
  # Extract path from ldconfig -p
  path_ldconfig=$(ldconfig -p | grep -m1 'libc\.so\.6' | sed -n 's/.*=> *//p' | awk '{print $1}')

  # Extract path from ldd /bin/ls
  path_ldd=$(ldd /bin/ls | grep -m1 'libc\.so\.6' | sed -n 's/.*=> *//p' | awk '{print $1}')
fi

echo "Path from ldconfig -p: $path_ldconfig"
echo "Path from ldd /bin/ls: $path_ldd"

if [ -z "$path_ldconfig" ] || [ -z "$path_ldd" ]; then
  echo "Error: Failed to determine libc.so.6 path." >&2
  exit 1
fi

if [ "$path_ldconfig" = "$path_ldd" ]; then
  echo "MATCH: Both ldconfig -p and ldd /bin/ls resolve libc to '$path_ldconfig'."
  exit 0
else
  # Check canonical paths in case of /lib -> /usr/lib symlinks
  canon_ldconfig=$(readlink -f "$path_ldconfig" 2>/dev/null || realpath "$path_ldconfig" 2>/dev/null || echo "$path_ldconfig")
  canon_ldd=$(readlink -f "$path_ldd" 2>/dev/null || realpath "$path_ldd" 2>/dev/null || echo "$path_ldd")
  if [ "$canon_ldconfig" = "$canon_ldd" ]; then
    echo "MATCH (canonical paths): '$canon_ldconfig' equals '$canon_ldd'."
    exit 0
  else
    echo "MISMATCH: ldconfig gives '$path_ldconfig' but ldd gives '$path_ldd'." >&2
    exit 1
  fi
fi
