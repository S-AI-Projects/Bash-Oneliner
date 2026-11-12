# R01-T017: Base64 MD5 methods and benchmark

## Environment

Tested on macOS 26.6.2 (Apple silicon), GNU Bash 3.2.57, OpenSSL 4.1.0, Python 3.14.7, Hyperfine 2.0.0, and the system `md5sum` (Darwin 1.0). The required GNU `md5sum` pipeline ran successfully with the compatible system utility. A Linux/Ubuntu environment was not available; Docker was installed but its daemon was not running.

## Methods and verification

The README command is `openssl md5 -binary FILE | base64`. The two comparison methods are:

```bash
md5sum FILE | cut -d' ' -f1 | xxd -r -p | base64
python3 -c 'import base64, hashlib, pathlib, sys; print(base64.b64encode(hashlib.md5(pathlib.Path(sys.argv[1]).read_bytes()).digest()).decode())' FILE
```

`bash work/R01-T017/check.sh` creates and removes its own temporary files. It compared all three methods on an empty file, a text file, and a 209,715,200-byte random file; they agreed for all inputs. For the empty file, every method returned the expected `1B2M2Y8AsgTpgAmY7PhCfg==`.

## Hyperfine benchmark

`bash work/R01-T017/benchmark.sh` generated a temporary 200 MiB random file and ran Hyperfine with one warmup and five measured runs per method. The file was removed after benchmarking. Results are wall-clock means ± standard deviation:

| Method | Mean | Standard deviation |
| --- | ---: | ---: |
| `openssl md5 -binary FILE | base64` | 487.9 ms | 4.6 ms |
| `md5sum FILE | cut -d' ' -f1 | xxd -r -p | base64` | 531.5 ms | 2.2 ms |
| Python `hashlib` one-liner | 525.4 ms | 11.8 ms |

The Python version reads the whole file into memory, so its measured peak memory was about 220 MiB; the OpenSSL and `md5sum` pipelines used about 3.9 MiB and 1.9 MiB respectively. Timings vary by machine and filesystem cache. The full Hyperfine export is in `benchmark.md`.

## Use and security

A base64-encoded MD5 digest is a compact checksum representation. It can be used in legacy `Content-MD5` headers or as a file-transfer integrity check where a protocol expects it. Base64 is an encoding, not encryption, and MD5 is not suitable for authentication or security-sensitive integrity checks because collisions can be constructed.

MD5 must not be used for passwords: it is fast and unsalted, which makes large-scale guessing and precomputed lookup attacks practical. Passwords need a deliberately slow, salted password-hashing scheme such as Argon2id, scrypt, bcrypt, or PBKDF2.
