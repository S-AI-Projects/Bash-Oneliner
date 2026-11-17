# R01-T023: Rebuild `lspci -n` from `/sys`

## 1. Tracing `lspci` Data Sources with `strace`

Running `strace -e trace=openat lspci 2>&1 | grep -E 'sys|pci.ids'` on a Linux system reveals exactly how `lspci` discovers PCI devices and resolves their human-readable hardware names:

```text
openat(AT_FDCWD, "/sys/bus/pci/devices", O_RDONLY|O_NONBLOCK|O_CLOEXEC|O_DIRECTORY) = 3
openat(AT_FDCWD, "/sys/bus/pci/devices/0000:00:00.0/vendor", O_RDONLY|O_CLOEXEC) = 4
openat(AT_FDCWD, "/sys/bus/pci/devices/0000:00:00.0/device", O_RDONLY|O_CLOEXEC) = 4
openat(AT_FDCWD, "/sys/bus/pci/devices/0000:00:00.0/class", O_RDONLY|O_CLOEXEC) = 4
openat(AT_FDCWD, "/sys/bus/pci/devices/0000:00:00.0/subsystem_vendor", O_RDONLY|O_CLOEXEC) = 4
openat(AT_FDCWD, "/sys/bus/pci/devices/0000:00:00.0/subsystem_device", O_RDONLY|O_CLOEXEC) = 4
openat(AT_FDCWD, "/sys/bus/pci/devices/0000:00:00.0/config", O_RDONLY|O_CLOEXEC) = 4
...
openat(AT_FDCWD, "/usr/share/misc/pci.ids", O_RDONLY) = 3
```

*(Note: In lightweight container environments like Docker/LXC without PCI device passthrough, or on macOS hosts, `/sys/bus/pci/devices` is either empty or absent, in which case both `lspci` and `pci_from_sys.sh` output nothing or exit cleanly without errors).*

## 2. Data Flow Architecture

1. **Hardware IDs from `/sys` (Kernel sysfs interface):**
   - The Linux kernel creates an entry under `/sys/bus/pci/devices/<slot>/` for every detected PCI bus device (e.g. `0000:00:1f.3`).
   - Inside each device directory:
     - `vendor`: Contains the hexadecimal PCI Vendor ID (e.g. `0x8086`).
     - `device`: Contains the hexadecimal Device ID (e.g. `0x1237`).
     - `class`: Contains the Device Class ID (e.g. `0x060000`).

2. **Name Resolution from `pci.ids`:**
   - `lspci` translates numeric IDs into readable vendor and model names using the central PCI ID database file (typically at `/usr/share/misc/pci.ids` or `/usr/share/hwdata/pci.ids`).

## 3. Manual Lookup in `pci.ids`

Looking up Intel Corporation (`8086`):
```text
8086  Intel Corporation
	1237  440FX - 82441FX PMC [Natoma]
	a170  100 Series/C230 Series Chipset Family HD Audio Controller
```

- Vendor ID `8086` maps directly to top-level entry `Intel Corporation`.
- Indented under `8086` by a single tab, Device ID `1237` maps to `440FX - 82441FX PMC [Natoma]`.
- Device ID `a170` maps to `100 Series/C230 Series Chipset Family HD Audio Controller`.

When `lspci -nn` is used, `lspci` displays both the human-readable text from `pci.ids` and the raw numeric `[vendor:device]` identifiers extracted from sysfs.
