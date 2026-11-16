# Task R01-T038 Notes: Test `sed '$d'` on Linux and macOS in CI

- **Student**: Anumoy Dasmaji
- **Task ID**: R01-T038 (8 of 10)
- **Repository**: https://github.com/S-AI-Projects/Bash-Oneliner
- **Target Item**: `README.md` L670 / L677 — "Delete/remove last line"

---

## 1. Environment & Systems Under Test

- **GNU / Linux**: Ubuntu 24.04 (`ubuntu-latest`), GNU sed 4.9
- **BSD / macOS**: macOS Sonoma / Sequoia (`macos-latest`, Darwin 24.x), BSD sed
- **Shell**: GNU bash / zsh
- **Date**: 17 November 2026

---

## 2. Fixture Design and Test Matrix

We test `sed '$d'` on four representative file shapes:

1. **`normal.txt`**: Standard multi-line file with trailing newline (`line 1\nline 2\nline 3\n`).
   - Expected: `line 1\nline 2\n` (last line removed).
2. **`single.txt`**: Single-line file with trailing newline (`single line\n`).
   - Expected: Empty file (`0` bytes).
3. **`empty.txt`**: Completely empty file (`0` bytes).
   - Expected: Empty file (`0` bytes, no errors).
4. **`no_trailing_newline.txt`**: Incomplete file missing trailing newline on final line (`line 1\nline 2`).
   - Expected: `line 1\n` (last incomplete line removed, preceding line preserved with newline).

---

## 3. Findings & Comparison: GNU sed vs BSD sed

| Fixture | Input Shape | GNU sed (`$d`) | BSD sed (`$d`) | Match Expected? |
|---|---|---|---|:---:|
| `normal.txt` | 3 lines with trailing `\n` | 2 lines with `\n` | 2 lines with `\n` | ✅ Yes (Both) |
| `single.txt` | 1 line with trailing `\n` | 0 lines (empty) | 0 lines (empty) | ✅ Yes (Both) |
| `empty.txt` | 0 bytes | 0 bytes | 0 bytes | ✅ Yes (Both) |
| `no_trailing_newline.txt` | `line 1\nline 2` (no EOF `\n`) | `line 1\n` | `line 1\n` | ✅ Yes (Both) |

### 3.1 Behavior with Incomplete Lines (No Trailing Newline)
- According to POSIX.1-2017, a text file is a stream of zero or more lines, where a **line** is defined as characters ended by a `<newline>`.
- When an incomplete line without a trailing newline is passed:
  - Both GNU sed and BSD sed trigger the `$` address on the final chunk before EOF and delete it.
  - Because `line 1` was already properly terminated by `\n`, both implementations yield `line 1\n`.
  - However, for general stream processing without deletion (`sed ''` or `sed -n 'p'`), GNU sed automatically synthesizes a trailing newline for non-empty incomplete lines, whereas older BSD sed versions either dropped the incomplete line or preserved the lack of trailing newline.

---

## 4. The Awk Alternative: One-Line Buffer Pattern

An alternative one-liner to delete the last line of a file using `awk` is:

```bash
awk 'NR>1{print prev} {prev=$0}' filename
```

### How It Works:
1. `NR>1 {print prev}`: For every line starting from line 2 onward, print the *previous* line stored in `prev`.
2. `{prev=$0}`: Update `prev` with the current line.
3. When EOF is reached, the last line remains in `prev` and is never printed.
4. If the file has 0 or 1 line, `NR>1` never triggers, correctly producing empty output.

---

## 5. Continuous Integration (GitHub Actions)

A dedicated GitHub Actions workflow `.github/workflows/r01-t038.yml` runs `bash work/R01-T038/test.sh` across:
- `ubuntu-latest` (validating GNU sed)
- `macos-latest` (validating BSD sed)

Both environments exit `0` with all tests passing.
