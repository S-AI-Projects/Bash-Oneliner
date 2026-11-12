#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
file="$script_dir/sandbox/random-200mb.bin"
trap 'rm -f "$file"' EXIT
head -c 209715200 /dev/urandom > "$file"
printf 'Benchmarking three methods on %s bytes...\n' "$(wc -c < "$file" | tr -d ' ')"
hyperfine --shell=default --warmup 1 --runs 5 \
  --export-markdown "$script_dir/benchmark.md" \
  --command-name 'OpenSSL + base64' \
  --command-name 'md5sum + xxd + base64' \
  --command-name 'Python hashlib' \
  "openssl md5 -binary '$file' | base64 >/dev/null" \
  "md5sum '$file' | cut -d' ' -f1 | xxd -r -p | base64 >/dev/null" \
  "python3 -c 'import base64, hashlib, pathlib, sys; print(base64.b64encode(hashlib.md5(pathlib.Path(sys.argv[1]).read_bytes()).digest()).decode())' '$file' >/dev/null"
