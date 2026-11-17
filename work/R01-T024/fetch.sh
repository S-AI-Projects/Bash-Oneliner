#!/usr/bin/env bash
set -euo pipefail

if [ "$#" -ne 2 ]; then
  echo "Usage: $0 <URL> <OUTPUT_FILE>" >&2
  exit 1
fi

url="$1"
out="$2"

out_dir="$(dirname "$out")"
tmp_file="$(mktemp "${out_dir}/tmp.fetch.XXXXXX")"
trap 'rm -f "$tmp_file"' EXIT

if command -v curl >/dev/null 2>&1; then
  curl -fsSL "$url" -o "$tmp_file"
elif command -v wget >/dev/null 2>&1; then
  wget -q -O "$tmp_file" "$url"
else
  echo "Error: neither curl nor wget found" >&2
  exit 1
fi

mv "$tmp_file" "$out"
trap - EXIT
