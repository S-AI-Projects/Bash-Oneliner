# Task R01-T002: Find where `ldconfig -p` gets its answer

## Investigation Summary
This document investigates how Linux dynamically discovers and resolves shared libraries such as `libc.so.6`, identifying the underlying cache file read by `ldconfig -p` and the configuration pipeline feeding it.

---

## 1. First Line and Library Count from `ldconfig -p`

Running `ldconfig -p | head`:
```bash
$ ldconfig -p | head -n 5
897 libs found in cache `/etc/ld.so.cache`
	libzstd.so.1 (libc6,x86-64) => /lib/x86_64-linux-gnu/libzstd.so.1
	libz.so.1 (libc6,x86-64) => /lib/x86_64-linux-gnu/libz.so.1
	libyaml-0.so.2 (libc6,x86-64) => /lib/x86_64-linux-gnu/libyaml-0.so.2
	libxxhash.so.0 (libc6,x86-64) => /lib/x86_64-linux-gnu/libxxhash.so.0
```

- **First line of `ldconfig -p`**:
  `897 libs found in cache \`/etc/ld.so.cache\``
- **Total library count**:
  `897`
- Verification command:
  ```bash
  $ ldconfig -p | tail -n +2 | wc -l
  897
  ```
  The library count of 897 exactly matches `ldconfig -p | tail -n +2 | wc -l`.

---

## 2. Strace Analysis: Identifying the Cache File

Tracing `openat` system calls during `ldconfig -p`:
```bash
$ strace -e trace=openat ldconfig -p 2>&1 >/dev/null
openat(AT_FDCWD, "/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3
```

- **Pasted strace line**:
  `openat(AT_FDCWD, "/etc/ld.so.cache", O_RDONLY|O_CLOEXEC) = 3`
- **Cache file identified**:
  `/etc/ld.so.cache`

`ldconfig -p` reads its index directly from the binary cache file `/etc/ld.so.cache`.

---

## 3. Resolving `libc.so.6` with `ldconfig -p` and `ldd /bin/ls`

### From `ldconfig -p | grep libc.so.6`:
```bash
$ ldconfig -p | grep libc.so.6
	libc.so.6 (libc6,x86-64, OS ABI: Linux 3.2.0) => /lib/x86_64-linux-gnu/libc.so.6
```
- Path from `ldconfig -p`: `/lib/x86_64-linux-gnu/libc.so.6`

### From `ldd /bin/ls | grep libc`:
```bash
$ ldd /bin/ls | grep libc
	libc.so.6 => /lib/x86_64-linux-gnu/libc.so.6 (0x00007f35b2e00000)
```
- Path from `ldd /bin/ls`: `/lib/x86_64-linux-gnu/libc.so.6`

### Comparison:
Both commands resolve `libc.so.6` to `/lib/x86_64-linux-gnu/libc.so.6`.

---

## 4. Pipeline Explanation: `/etc/ld.so.conf(.d)` → `ldconfig` → `/etc/ld.so.cache`

1. **Configuration files (`/etc/ld.so.conf` and `/etc/ld.so.conf.d/*.conf`)**:
   These plain-text configuration files specify the directories containing dynamic shared library files (such as `/usr/local/lib`, `/lib/x86_64-linux-gnu`, `/usr/lib/x86_64-linux-gnu`). Package managers (like `dpkg`/`apt`) install snippet files into `/etc/ld.so.conf.d/` (e.g. `x86_64-linux-gnu.conf`) to register library search paths.

2. **Cache generation (`sudo ldconfig`)**:
   `ldconfig` parses `/etc/ld.so.conf` and all included `.conf` files. It traverses the specified directories, inspects the ELF header of each shared object to determine its SONAME, ABI, and architecture, creates/updates symlinks (e.g. `libc.so.6 -> libc.so`), and compiles this lookup table into the optimized binary cache file `/etc/ld.so.cache`.

3. **Runtime execution (`ld.so` / dynamic linker)**:
   When an ELF binary (like `/bin/ls`) is executed, the dynamic linker (`/lib64/ld-linux-x86-64.so.2`) opens and maps `/etc/ld.so.cache` into memory (`openat(..., "/etc/ld.so.cache", ...)`). This provides fast $O(1)$ lookup from library SONAMEs (`libc.so.6`) to actual filesystem paths, avoiding costly directory scans on each program execution.

---

## 5. What Changes After `sudo ldconfig` (Explanation Only)

- When shared libraries are added, removed, or updated in the system directories, or when a new directory is added to `/etc/ld.so.conf.d/`, running `sudo ldconfig`:
  1. Updates or creates soname symlinks in the configured directories.
  2. Atomically rebuilds `/etc/ld.so.cache` (writing to a temporary file and renaming it).
  3. Updates the mtime and file size of `/etc/ld.so.cache`.
  4. Any newly discovered libraries become immediately queryable via `ldconfig -p` and available to the runtime dynamic linker.
- *Notice*: No system files or configurations were modified during this investigation.
