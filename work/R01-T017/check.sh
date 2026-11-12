#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
tmp_dir=$(mktemp -d "$script_dir/sandbox/check.XXXXXX")
trap 'rm -rf "$tmp_dir"' EXIT

: > "$tmp_dir/empty"
printf 'Bash checksum examples\nsecond line\n' > "$tmp_dir/text.txt"
printf 'Creating a 200 MiB random test file...\n'
head -c 209715200 /dev/urandom > "$tmp_dir/random-200mb.bin"

check_file() {
  local label=$1 file=$2 openssl_result md5sum_result python_result
  openssl_result=$(openssl md5 -binary "$file" | base64 | tr -d '\n')
  md5sum_result=$(md5sum "$file" | cut -d' ' -f1 | xxd -r -p | base64 | tr -d '\n')
  python_result=$(python3 -c 'import base64, hashlib, pathlib, sys; print(base64.b64encode(hashlib.md5(pathlib.Path(sys.argv[1]).read_bytes()).digest()).decode())' "$file")

  if [[ "$openssl_result" != "$md5sum_result" || "$openssl_result" != "$python_result" ]]; then
    printf 'FAIL: methods disagree for %s\n' "$label" >&2
    printf 'openssl=%s\nmd5sum=%s\npython=%s\n' "$openssl_result" "$md5sum_result" "$python_result" >&2
    return 1
  fi
  printf 'PASS: %s -> %s\n' "$label" "$openssl_result"
}

check_file empty "$tmp_dir/empty"
[[ "$(openssl md5 -binary "$tmp_dir/empty" | base64 | tr -d '\n')" == '1B2M2Y8AsgTpgAmY7PhCfg==' ]]
check_file text "$tmp_dir/text.txt"
check_file 200MiB-random "$tmp_dir/random-200mb.bin"
printf 'PASS: all three methods agree for every input.\n'
