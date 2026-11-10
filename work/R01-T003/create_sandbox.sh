#!/usr/bin/env bash
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P)/sandbox"
mkdir -p "$DIR"
rm -rf "${DIR:?}"/*

# Create 20 files
for i in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20; do
  echo "Sample content in file $i" > "$DIR/file_${i}.txt"
done

# Set mode 444 (read-only) on 5 files: file_01 to file_05
for i in 01 02 03 04 05; do
  chmod 444 "$DIR/file_${i}.txt"
done

echo "Successfully created 20 files in $DIR (5 with mode 444)."
