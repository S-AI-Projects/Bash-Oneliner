# R01-T024: Handle Download Failures with `wget -O`

## 1. Investigation of `wget -O` Behavior on Failure

When using `wget -O <filename> <URL>`, `wget` opens and truncates the destination file descriptor immediately upon initializing the request, *before* verifying the HTTP response status code.

### Test 1: Successful Download (200 OK)
```bash
wget -O lic.txt https://raw.githubusercontent.com/onceupon/Bash-Oneliner/master/LICENSE
```
- **HTTP Status:** `200 OK`
- **Wget Exit Code:** `0` (`EXIT_SUCCESS`)
- **File Result:** `lic.txt` created with size 1,065 bytes.

### Test 2: Failed Download (404 Not Found)
```bash
wget -O bad.txt https://raw.githubusercontent.com/onceupon/Bash-Oneliner/master/does-not-exist
```
- **HTTP Status:** `404 Not Found`
- **Wget Exit Code:** `8` (`Server error response` per `man wget` EXIT STATUS)
- **File Result:** `bad.txt` was left on disk as a **0-byte empty file** (`-rw-r--r-- 0 bytes`).

### Hazard
In automated scripts, build pipelines, or data processing workflows, checking `[ -f filename ]` or relying on standard file-existence checks will incorrectly indicate that the file exists, leading to corrupted downstream processing.

## 2. Safer Solutions

### Option A: `curl -fsSL -o filename URL`
`curl -fsSL` treats HTTP errors as failures (`-f` / `--fail`), follows redirects (`-L`), runs quietly (`-s`), and crucially does **not** create or leave behind an empty destination file when the HTTP transfer fails:
```bash
curl -fsSL -o filename "https://example.com/file"
```

### Option B: Atomic Temporary File with `fetch.sh`
When `wget` must be used, download to a temporary file (`mktemp`) first, and atomically move it to the final destination only after verifying exit status 0:
```bash
tmp=$(mktemp "${out}.XXXXXX")
wget -O "$tmp" "$url" && mv "$tmp" "$out" || rm -f "$tmp"
```
