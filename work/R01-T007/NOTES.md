# Task R01-T007: Run a README One-Liner Automatically in GitHub Actions

## 1. README Entry Extraction

The script [`work/R01-T007/extract.sh`](extract.sh) parses `README.md` using pure `awk` to extract the first ```bash code block directly under any specified `##### HEADING`.

### Heading Extraction Tests:
1. **Target Heading**: `Print detail of all hard disks`
   ```bash
   $ bash work/R01-T007/extract.sh 'Print detail of all hard disks'
   lsblk -io KNAME,TYPE,MODEL,VENDOR,SIZE,ROTA
   #where ROTA means rotational device / spinning hard disks (1 if true, 0 if false)
   ```

2. **Heading with Special Characters**: `List all PCI (Peripheral Component Interconnect) devices`
   ```bash
   $ bash work/R01-T007/extract.sh 'List all PCI (Peripheral Component Interconnect) devices'
   lspci
   # List information about NIC
   lspci | egrep -i --color 'network|ethernet'
   ```

3. **General Heading**: `Generate an UUID`
   ```bash
   $ bash work/R01-T007/extract.sh 'Generate an UUID'
   uuidgen
   ```

---

## 2. Explanation of the `ROTA` Column on Runner Disks

When querying block devices via `lsblk`, the `ROTA` attribute indicates whether a storage device is a **rotational device**:
- **`ROTA = 1` (Rotational)**: The device relies on physical spinning magnetic platters, such as a traditional mechanical Hard Disk Drive (HDD).
- **`ROTA = 0` (Non-Rotational)**: The device is solid-state storage with no moving mechanical parts, such as a Solid-State Drive (SSD), NVMe drive, virtual disk image, or RAM disk.

### Observations on GitHub Actions Runners (`ubuntu-latest`):
On GitHub Actions runners hosted in Microsoft Azure, block devices report `ROTA = 0`:
```bash
$ lsblk -d -o NAME,ROTA
NAME ROTA
loop0   0
loop1   0
sda     0
sdb     0
```

- Disks attached to the runner VM (such as `/dev/sda` and `/dev/sdb`) are virtualized block devices provisioned on Azure Premium SSDs.
- Loopback block devices (`/dev/loop0`, `/dev/loop1`, etc.) used by snap packages are memory-mapped or backed by host SSD images.
- Because none of these virtual devices possess spinning platters, the Linux kernel sets `/sys/block/<device>/queue/rotational` to `0`.

---

## 3. GitHub Actions CI Workflow (`r01-t007.yml`)

- **Green Actions Run Link**: https://github.com/aanyaahuja002-pixel/Bash-Oneliner/actions/runs/43191760701

The workflow `.github/workflows/r01-t007.yml`:
1. Triggers on push and pull request events touching `work/R01-T007/**` or `.github/workflows/r01-t007.yml`.
2. Runs on `ubuntu-latest`.
3. Invokes `extract.sh` to extract the `lsblk` code block from `README.md` and executes it directly through `bash`.
4. Asserts that the output header contains `KNAME`, `TYPE`, and `ROTA`.
