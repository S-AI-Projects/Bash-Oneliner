#!/usr/bin/env bash
set -euo pipefail

script_dir=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
hindi_file="$script_dir/hindi.txt"
tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

for command_name in head busybox iconv python3 wc cmp locale; do
  if ! command -v "$command_name" >/dev/null 2>&1; then
    printf 'Required command not found: %s\n' "$command_name" >&2
    exit 1
  fi
done

utf8_locale=
for candidate in C.UTF-8 C.utf8 en_US.UTF-8; do
  if LC_ALL="$candidate" locale charmap 2>/dev/null | grep -qi '^UTF-8$'; then
    utf8_locale=$candidate
    break
  fi
done
if [[ -z "$utf8_locale" ]]; then
  printf 'No UTF-8 locale is available for wc -m.\n' >&2
  exit 1
fi

head -c 50 "$hindi_file" > "$tmp_dir/gnu-50.bin"
busybox head -c 50 "$hindi_file" > "$tmp_dir/busybox-50.bin"
[[ $(wc -c < "$tmp_dir/gnu-50.bin" | tr -d '[:space:]') == 50 ]]
[[ $(wc -c < "$tmp_dir/busybox-50.bin" | tr -d '[:space:]') == 50 ]]
if iconv -f UTF-8 -t UTF-8 "$tmp_dir/gnu-50.bin" >/dev/null 2>&1; then
  printf 'GNU head output unexpectedly remained valid UTF-8.\n' >&2
  exit 1
fi
if iconv -f UTF-8 -t UTF-8 "$tmp_dir/busybox-50.bin" >/dev/null 2>&1; then
  printf 'BusyBox head output unexpectedly remained valid UTF-8.\n' >&2
  exit 1
fi
cmp -s "$tmp_dir/gnu-50.bin" "$tmp_dir/busybox-50.bin"

python3 -c 'import sys; text=sys.stdin.buffer.read().decode("utf-8"); sys.stdout.buffer.write(text[:50].encode("utf-8"))' \
  < "$hindi_file" > "$tmp_dir/safe-50.txt"
char_count=$(LC_ALL="$utf8_locale" wc -m < "$tmp_dir/safe-50.txt" | tr -d '[:space:]')
[[ "$char_count" == 50 ]]
iconv -f UTF-8 -t UTF-8 "$tmp_dir/safe-50.txt" >/dev/null

printf 'PASS: GNU head -c 50 outputs 50 bytes and splits a UTF-8 character.\n'
printf 'PASS: BusyBox head -c 50 matches GNU and also splits a UTF-8 character.\n'
printf 'PASS: Python alternative outputs exactly 50 characters (%s locale), valid UTF-8.\n' "$utf8_locale"
