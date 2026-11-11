# Task R01-T004: Map `getent` Databases to `/etc/nsswitch.conf`

## 1. Overview of Name Service Switch (`/etc/nsswitch.conf`)

In Linux systems using glibc, `/etc/nsswitch.conf` (Name Service Switch configuration) defines the order and search criteria for querying system administrative databases such as users, groups, network hostnames, services, and protocols.

When a utility like `getent` (get entries from administrative databases) is executed:
1. It queries the glibc NSS dispatcher for the requested database.
2. The dispatcher reads `/etc/nsswitch.conf` to identify the service source backends (`files`, `dns`, `systemd`, `db`, etc.).
3. The sources are queried sequentially in the order specified until an entry is resolved.

### Typical `/etc/nsswitch.conf` Database Directives (Ubuntu 22.04 / 24.04):
```ini
passwd:         files systemd
group:          files [SUCCESS=merge] systemd
shadow:         files
gshadow:        files

hosts:          files dns
networks:       files

protocols:      db files
services:       db files
ethers:         db files
rpc:            db files

netgroup:       nis
```

---

## 2. Database Mapping Table

| Database | `/etc/nsswitch.conf` Sources | Lookup Command | Real Output | Field Meanings | Underlying File & Matching Line |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **`passwd`** | `files systemd` | `getent passwd root` | `root:x:0:0:root:/root:/bin/bash` | See Section 3 below for full 7-field breakdown | `/etc/passwd`:<br>`root:x:0:0:root:/root:/bin/bash` |
| **`group`** | `files [SUCCESS=merge] systemd` | `getent group sudo` | `sudo:x:27:runner` | 1. `sudo`: Group name<br>2. `x`: Group password placeholder<br>3. `27`: Group ID (GID)<br>4. `runner`: Member list (comma-separated) | `/etc/group`:<br>`sudo:x:27:runner` |
| **`hosts`** | `files dns` | `getent hosts localhost` | `127.0.0.1       localhost` | 1. `127.0.0.1`: IPv4 address<br>2. `localhost`: Canonical hostname | `/etc/hosts`:<br>`127.0.0.1 localhost` |
| **`services`**| `db files` | `getent services 22` | `ssh 22/tcp` | 1. `ssh`: Service name<br>2. `22/tcp`: Port number and protocol | `/etc/services`:<br>`ssh 22/tcp # SSH Remote Login Protocol` |
| **`protocols`**| `db files` | `getent protocols tcp` | `tcp 6 TCP` | 1. `tcp`: Protocol name<br>2. `6`: Protocol number<br>3. `TCP`: Protocol alias | `/etc/protocols`:<br>`tcp 6 TCP # transmission control protocol` |

---

## 3. Detailed Breakdown of `passwd` Fields

Executing `getent passwd root` yields:
```
root:x:0:0:root:/root:/bin/bash
```

The output contains 7 colon-separated fields as defined by POSIX and glibc:

1. **Username / Login Name**: `root` — The user account name used to authenticate.
2. **Password Placeholder**: `x` — Indicates that the encrypted password hash is stored in the shadow password database (`/etc/shadow`).
3. **User ID (UID)**: `0` — The unique integer identifying the user to the kernel (0 is superuser).
4. **Group ID (GID)**: `0` — The user's primary group ID (referencing group `root` in `/etc/group`).
5. **GECOS / User Info**: `root` — Comment field traditionally containing the user's full name, office details, or phone number.
6. **Home Directory**: `/root` — The initial working directory when the user logs in.
7. **Login Shell**: `/bin/bash` — The program executed immediately upon user login.

---

## 4. Underlying 'files' Source Correlation

When a database lists `files` as a source in `/etc/nsswitch.conf`, `getent` reads the corresponding local configuration file in `/etc/`:

- **Database `services` → `/etc/services`**:
  Querying port 22 via `getent services 22` reads `/etc/services` and returns `ssh 22/tcp`.
  Direct inspection of `/etc/services`:
  ```bash
  $ grep -E '^ssh\s+22/' /etc/services
  ssh                 22/tcp                  # SSH Remote Login Protocol
  ```

- **Database `group` → `/etc/group`**:
  Querying group `sudo` via `getent group sudo` returns `sudo:x:27:runner`.
  Direct inspection of `/etc/group`:
  ```bash
  $ grep '^sudo:' /etc/group
  sudo:x:27:runner
  ```
