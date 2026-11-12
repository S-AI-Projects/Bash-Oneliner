# Task R01-T006: Probe a Web Server with `nc`

## 1. Netcat Flavours Comparison

When inspecting `nc` across Linux and Unix platforms, two primary flavours exist in widespread use:

1. **Traditional Netcat (Hobbit)**:
   - Original release written by *Hobbit* in 1995.
   - Identified by `netcat -h` showing `[options] host port[s]` and the presence of the `-e command` option (execute command on connection).
   - In Debian/Ubuntu, provided by the package `netcat-traditional`.

2. **OpenBSD Netcat (`netcat-openbsd`)**:
   - Complete rewrite by OpenBSD developers for portability, security, and modern networking (IPv6, TLS, UNIX sockets).
   - In Debian/Ubuntu, provided by the package `netcat-openbsd` and symlinked via `update-alternatives` to `/bin/nc`.
   - On macOS/Darwin, `/usr/bin/nc` is derived from the BSD/OpenBSD lineage.

### Key Option Differences:
- **`-e <command>` (Execute program)**:
  - Supported in **Traditional Netcat**. Used to spawn shells upon inbound connections (`nc -l -p 8080 -e /bin/sh`).
  - **Removed in OpenBSD Netcat** for security reasons (to prevent trivial remote shell exploitation).
- **`-C` (Send CRLF line endings)**:
  - Supported in **OpenBSD Netcat** to convert newline characters (`\n`) to network standard CRLF (`\r\n`), essential for HTTP/SMTP.
  - Not present in Traditional Netcat.
- **`-U` (UNIX-domain socket)**:
  - Supported in **OpenBSD Netcat** for communication over local UNIX domain sockets.
  - Not present in Traditional Netcat.

---

## 2. Raw HTTP HEAD Request Structure

HTTP/1.1 mandates the use of CRLF line terminators (`\r\n`) and requires a `Host` header:
```bash
printf 'HEAD / HTTP/1.1\r\nHost: example.net\r\nConnection: close\r\n\r\n' | nc example.net 80
```

- `HEAD / HTTP/1.1\r\n`: Request line specifying the HEAD method, root URI path, and HTTP protocol version 1.1.
- `Host: example.net\r\n`: Mandatory header for HTTP/1.1 name-based virtual hosting.
- `Connection: close\r\n`: Informs the server to close the TCP connection immediately after transmitting the response headers.
- `\r\n`: An empty line terminating the HTTP header section.

### Server Response:
The server responds with standard HTTP/1.1 headers:
```http
HTTP/1.1 200 OK
Date: Thu, 12 Nov 2026 09:15:10 GMT
Content-Type: text/html; charset=utf-8
Connection: close
Server: cloudflare
...
```
The first line of response is: `HTTP/1.1 200 OK`.

---

## 3. Probe Script Verification (`probe.sh`)

`work/R01-T006/probe.sh` tests whether a given `HOST:PORT` is open or closed, with automated timeout enforcement:
```bash
$ bash work/R01-T006/probe.sh example.net 80
OPEN
# Exits with 0 in ~0.1s

$ bash work/R01-T006/probe.sh example.net 22
CLOSED
# Exits with 1 in ~5.4s
```

Automated check:
```bash
$ bash work/R01-T006/probe.sh example.net 80 && ! bash work/R01-T006/probe.sh example.net 22
OPEN
CLOSED
```
- Passes `shellcheck` with zero warnings.
- Finishes within ~5.4 seconds for filtered/closed ports.
