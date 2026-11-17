#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
PCI_SCRIPT="$SCRIPT_DIR/pci_from_sys.sh"

echo "1. Checking shellcheck on pci_from_sys.sh..."
shellcheck "$PCI_SCRIPT"
echo "pci_from_sys.sh passed shellcheck!"

echo "2. Testing with mock sysfs fixture..."
MOCK_SYS="$SCRIPT_DIR/mock_sys/bus/pci/devices"
mock_output="$("$PCI_SCRIPT" "$MOCK_SYS")"
expected_mock=$(cat << 'EXPECTED'
00:00.0 8086:1237
00:1f.3 8086:a170
EXPECTED
)

if [ "$mock_output" != "$expected_mock" ]; then
  echo "Mock sysfs output did not match expected!"
  echo "Expected:"
  echo "$expected_mock"
  echo "Got:"
  echo "$mock_output"
  exit 1
fi
echo "Mock sysfs test passed!"

echo "3. Comparing pci_from_sys.sh with system lspci -n..."
sys_pci_out="$("$PCI_SCRIPT" | sort)"
if command -v lspci >/dev/null 2>&1; then
  # On Linux with lspci:
  # lspci -n outputs format: "<slot> <class>: <vendor>:<device> (rev ...)"
  # Extract slot and vendor:device
  lspci_out="$(lspci -n | awk '{print $1, $3}' | sort)"
  diff_pci="$(diff -u <(echo "$sys_pci_out") <(echo "$lspci_out") || true)"
  if [ -n "$diff_pci" ]; then
    echo "Difference found between pci_from_sys.sh and lspci -n:"
    echo "$diff_pci"
    exit 1
  fi
  echo "lspci -n matches pci_from_sys.sh output!"
else
  # Container or non-Linux host without lspci / sysfs
  echo "lspci or /sys/bus/pci/devices not available in current environment; verified both are empty or handled gracefully."
  [ -z "$sys_pci_out" ] || { echo "Unexpected output in non-sysfs environment"; exit 1; }
fi

echo "4. Checking README.md entry at line 2535..."
grep -F "lspci -nn" "$REPO_ROOT/README.md" >/dev/null || {
  echo "Missing 'lspci -nn' in README.md"
  exit 1
}
grep -F "pci.ids" "$REPO_ROOT/README.md" >/dev/null || {
  echo "Missing data source comment (pci.ids) in README.md"
  exit 1
}

echo "All R01-T023 checks passed successfully!"
