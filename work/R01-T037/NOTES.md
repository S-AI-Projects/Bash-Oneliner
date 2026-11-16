# Task R01-T037 Notes: Make 'Download If Necessary' Reliable

- **Student**: Anumoy Dasmaji
- **Task ID**: R01-T037 (7 of 10)
- **Repository**: https://github.com/S-AI-Projects/Bash-Oneliner
- **Target Item**: `README.md` L1410 / L1425 — "Download file if necessary"

---

## 1. Environment

- **OS**: Darwin 24.3.0 / Linux compatible
- **Shell**: GNU bash / zsh
- **Tools**: `curl` (8.21.0), `wget`, `shasum` / `sha256sum`, `bats`
- **Date**: 17 November 2026

---

## 2. Analysis of the Original Snippet

Original snippet in `README.md`:
```bash
data=file.txt
url=http://www.example.net/$data
if [ ! -s $data ];then
    echo "downloading test data..."
    wget $url
fi
```

### 2.1 Failure Modes Identified

1. **Dead/Unreachable URL (`http://www.example.net/file.txt`)**:
   `example.net` returns `HTTP/1.1 404 Not Found`.
   - With `wget`, `wget` writes the HTML 404 error page into `file.txt` and exits with code `8` (`Server issued an error response`).
   - If `curl` were used without `-f` (`--fail`), `curl` writes the HTML error body to disk and exits `0`.
   - Because `file.txt` now has a non-zero size (the 404 HTML text), subsequent runs see `[ -s $data ]` as true and skip downloading, leaving the user with an unusable error page thinking the download succeeded.
2. **Unquoted Variables**:
   `$data` and `$url` are unquoted. If paths contain spaces or glob metacharacters, `[ ! -s $data ]` triggers word-splitting syntax errors (`too many arguments`).
3. **No Network Resiliency**:
   Lacks retry flags (`--retry 2`) or silent/fail flags (`-fsSL`) to recover from transient packet loss or network hiccups.
4. **No Timestamp / Cache Checking**:
   `[ ! -s $data ]` only checks if the local file exists and is non-empty. If the remote resource is updated upstream, the local script never fetches updates.

---

## 3. Improved Solution: Quoting, Retries, and `curl -z` (If-Modified-Since)

### 3.1 Working URL & Variables
- **File**: `LICENSE`
- **URL**: `https://raw.githubusercontent.com/onceupon/Bash-Oneliner/master/LICENSE`
- **Expected SHA-256**: `2d4924a0bc53af5dd1d7be35b8f2a0d5718781803576caccab180e35ae083f98`

### 3.2 Conditional Download with `curl -z` (If-Modified-Since)
Instead of relying solely on shell conditionals, `curl` supports `-z <file>` (`--time-cond`), which sends an `If-Modified-Since` header containing the file's local mtime.

```bash
curl -fsSL -z "$data" -o "$data" "$url"
```

#### Run 1: Fresh Download
```bash
$ curl -v -fsSL -z LICENSE -o LICENSE "https://raw.githubusercontent.com/onceupon/Bash-Oneliner/master/LICENSE"
> GET /onceupon/Bash-Oneliner/master/LICENSE HTTP/2
> Host: raw.githubusercontent.com
> Accept: */*
< HTTP/2 200
< content-type: text/plain; charset=utf-8
< etag: "f969e7aa9784e2c2465f3471e27d45e47af6feab6be7df4e8ca3f31e366afad6"
```
- File is cleanly downloaded (size: 1,065 bytes).
- SHA-256 verified: `2d4924a0bc53af5dd1d7be35b8f2a0d5718781803576caccab180e35ae083f98`.

#### Run 2: Conditional Check (`If-Modified-Since`)
```bash
$ curl -v -fsSL -z LICENSE -o LICENSE "https://raw.githubusercontent.com/onceupon/Bash-Oneliner/master/LICENSE"
> GET /onceupon/Bash-Oneliner/master/LICENSE HTTP/2
> Host: raw.githubusercontent.com
> If-Modified-Since: Mon, 16 Nov 2026 18:50:36 GMT
```
- Request sends `If-Modified-Since`.
- Remote server responds with `304 Not Modified` or `curl` detects no change; the existing file timestamp and contents remain untouched with zero re-download payload.

#### Run 3: Bad / 404 URL Behavior
```bash
$ curl -fsSL "https://example.com/nonexistent_file_404.txt" -o "nonexistent.txt"
$ echo $?
22
$ [ -f nonexistent.txt ] || echo "File was NOT created"
File was NOT created
```
- With `-f` (`--fail`), `curl` suppresses the HTTP error response body and exits with code `22`, preventing corrupted 404 HTML files from being saved.

---

## 4. Code Change for README.md

Updated entry at L1425:
```bash
##### Download file if necessary
```bash
data="LICENSE"
url="https://raw.githubusercontent.com/onceupon/Bash-Oneliner/master/$data"

# download if missing or empty:
if [ ! -s "$data" ]; then
    echo "downloading test data..."
    curl -fsSL --retry 2 -o "$data" "$url"
fi

# or use curl -z (If-Modified-Since) to download only if newer than local file:
curl -fsSL -z "$data" -o "$data" "$url"
```
```

---

## 5. Automated Testing

Covered in `work/R01-T037/test.bats` and `work/R01-T037/check.sh`:
- First run: downloads `LICENSE` successfully and validates SHA-256 hash.
- Second run: runs `curl -z` and verifies file content and modification timestamp remain unchanged.
- Bad URL run: confirms non-zero exit status and ensures no phantom file is generated.
