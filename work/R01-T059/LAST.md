# Task R01-T059: System Boot History and Data Sources

## Data Sources for `last`
`last` inspects the binary accounting log file `/var/log/wtmp` (or `/var/log/btmp` for failed logins):
- Running `file /var/log/wtmp` identifies it as binary data.
- The binary utmp/wtmp records contain structured entries (`struct utmp`) logging `BOOT_TIME`, `USER_PROCESS`, `DEAD_PROCESS`, and timestamps.
- Tools like `utmpdump` dump the raw structured binary into readable text format.

## Comparison of Boot Time Commands
1. `last reboot`: Lists reboot and shutdown records chronologically from wtmp.
2. `who -b`: Queries the single system boot record (`system boot YYYY-MM-DD HH:MM`).
3. `uptime -s`: Displays timestamp of system up time in format `YYYY-MM-DD HH:MM:SS`.
4. `journalctl --list-boots`: Systemd journal list of boots with IDs, timestamps, and offsets.
