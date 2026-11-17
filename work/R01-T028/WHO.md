# R01-T028: Document `who` and Its Data Sources

## 1. Options Reference Table

| Option | Meaning | Real Command Output | Notes |
| :--- | :--- | :--- | :--- |
| `who` | Default listing of currently logged-in users | `nikhil console Nov 12 12:16` | Shows username, terminal line, and login timestamp. |
| `who -b` | Time of last system boot | `system boot Nov 12 12:15` | Reads `BOOT_TIME` record. Portable alternative to `uptime -s`. |
| `who -q` | Quick count of logged-in users and total | `nikhil`<br>`# users = 1` | Displays list of usernames followed by total session count. |
| `who -u` | List logged-in users with idle time and PID | `nikhil console Nov 12 12:16 old 405` | Shows idle duration (`.` if active in last minute, `old` if > 24 hours) and session PID (405). |
| `who -H` | Print column headings | `NAME LINE TIME FROM`<br>`nikhil console Nov 12 12:16` | Adds a header line to clarify table columns. |
| `who -a` | All entries (equivalent to `-b -d --login -p -r -t -T -u`) | `system boot Nov 12 12:15`<br>`nikhil console Nov 12 12:16`<br>`. run-level 3` | Comprehensive dump including run-level and system boot state. |

## 2. Data Sources and Container Environment Differences

### Data Source Evidence
`who` queries system user accounting records stored in fixed-format binary log structures:
- **Linux:** `/var/run/utmp` (symlinked to `/run/utmp`) maintained by `glibc` / `systemd-update-utmp`.
  - From Linux `man 1 who` (FILES section):
    ```text
    FILES
           /var/run/utmp
                  information about who is currently logged on
    ```
  - In `strace who 2>&1 | grep utmp`:
    ```text
    openat(AT_FDCWD, "/var/run/utmp", O_RDONLY|O_CLOEXEC) = 3
    ```
- **macOS / BSD:** `/var/run/utmpx` containing POSIX `utmpx` structures.
  - From macOS `man 1 who` (FILES section):
    ```text
    FILES
         /var/run/utmpx  database of currently logged-in users
    ```

### Why Containers Often Show Empty `who` Output
Inside minimal Docker/OCI containers:
- Containers generally run a single application process (e.g. `CMD ["node", "app.js"]`) without an init supervisor (`systemd` or `sysvinit`) or login managers (`getty`, `login`, `sshd`).
- The `/run/utmp` database is either uninitialized, missing, or empty.
- When commands like `docker exec -it <container> sh` are run, container runtimes attach directly via pseudo-terminals without inserting utmp accounting records. Therefore, `who` returns empty with exit code 0.

## 3. Comparison: `who -b` vs `uptime -s`

| Feature | `who -b` | `uptime -s` |
| :--- | :--- | :--- |
| **Output format** | `system boot Nov 12 12:15` | `2026-11-12 12:15:00` |
| **Data source** | Reads `BOOT_TIME` record in utmp/utmpx | Computes boot timestamp by subtracting uptime from current time (or reading `/proc/uptime`) |
| **Portability** | Standard POSIX (supported on Linux, macOS, BSD) | GNU coreutils / Linux procps only (`uptime -s` fails on macOS/BSD with `illegal option -- s`) |
| **Container behavior**| Returns empty if utmp lacks boot record | Returns the host kernel's boot time because `/proc/uptime` is shared across container namespaces |
