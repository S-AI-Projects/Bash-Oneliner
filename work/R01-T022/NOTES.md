# R01-T022: Does `grep -d skip` Work Everywhere?

## 1. GNU grep Behavior

### Without `-d skip`
When passing a glob like `tree/*` where one of the entries is a directory:
```bash
$ grep 'bbo' tree/*
tree/file1.txt:bbo match in root file1
grep: tree/subdir: Is a directory
```
GNU grep emits an error to stderr for each directory encountered: `grep: <dir>: Is a directory` and sets a non-zero exit status if no matches were found or treated as error.

### With `-d skip`
```bash
$ grep -d skip 'bbo' tree/*
tree/file1.txt:bbo match in root file1
```
With `-d skip`, GNU grep silently ignores directories:
- No `Is a directory` warnings are printed.
- Directories are not descended into (unlike `-r` or `-d recurse`).
- Sub-directory contents (e.g. `tree/subdir/nested.txt`) are not inspected.

## 2. BusyBox grep Behavior

BusyBox implements a stripped-down subset of utilities. In BusyBox grep:

### Without `-d skip`
```bash
$ busybox grep 'bbo' tree/*
tree/file1.txt:bbo match in root file1
grep: tree/subdir: Is a directory
```

### With `-d skip`
BusyBox grep does **not** support the non-standard GNU `-d` option:
```bash
$ busybox grep -d skip 'bbo' tree/*
grep: invalid option -- 'd'
BusyBox v1.36.1 multi-call binary.

Usage: grep [-HhnlLoqvsriwFE] [-m N] [-A/B/C N] { PATTERN | -e PATTERN... | -f FILE... } [FILE]...

Search for PATTERN in FILEs (or stdin)
```
Consequently, scripts relying on `grep -d skip` fail immediately under Alpine Linux containers, embedded Linux systems, and other BusyBox-based environments.

## 3. Portable POSIX Equivalent

To achieve identical behavior portably across all UNIX-like systems (GNU, BSD, BusyBox, macOS):
```bash
find /path -maxdepth 1 -type f -exec grep -H 'bbo' {} +
```
- `-maxdepth 1`: Restricts the search strictly to `/path` without descending into subdirectories.
- `-type f`: Selects only regular files, inherently skipping directories and avoiding `Is a directory` errors.
- `-exec grep -H 'bbo' {} +`: Batches matching filenames into `grep`, using `-H` to ensure the filename prefix is printed even if only one file matches.
