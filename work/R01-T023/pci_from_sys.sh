#!/usr/bin/env bash
set -euo pipefail

SYS_DIR="${1:-/sys/bus/pci/devices}"

if [ ! -d "$SYS_DIR" ]; then
  # No sysfs directory present (macOS or container without sysfs)
  exit 0
fi

shopt -s nullglob
devices=("$SYS_DIR"/*)
shopt -u nullglob

if [ ${#devices[@]} -eq 0 ]; then
  exit 0
fi

for dev in "${devices[@]}"; do
  slot="$(basename "$dev")"
  if [ -f "$dev/vendor" ] && [ -f "$dev/device" ]; then
    vendor="$(cat "$dev/vendor")"
    device="$(cat "$dev/device")"
    # Remove leading 0x if present
    vendor="${vendor#0x}"
    device="${device#0x}"
    # Normalize slot format (strip 0000: domain if present to match lspci standard format)
    short_slot="${slot#0000:}"
    echo "$short_slot $vendor:$device"
  fi
done | sort
