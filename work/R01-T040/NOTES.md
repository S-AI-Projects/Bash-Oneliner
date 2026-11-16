# Task R01-T040 Notes: NR vs FNR, and the Two-File Idiom

- **Student**: Anumoy Dasmaji
- **Task ID**: R01-T040 (10 of 10)
- **Repository**: https://github.com/S-AI-Projects/Bash-Oneliner
- **Target Item**: `README.md` L902 / L926 — "Usage and meaning of NR and FNR"

---

## 1. Environment

- **OS**: Darwin 24.3.0 / Linux compatible
- **Shell**: GNU bash / zsh
- **Tools**: `awk` (BSD awk 20200816, GNU gawk 5.x, mawk 1.3.4)
- **Date**: 17 November 2026

---

## 2. The Bug in the Original README Entry

The snippet at L926 of `README.md` was written as:

```bash
awk 'print FILENAME, NR,FNR,$0}' fileA fileB
```

### 2.1 Recorded Syntax Error
When executed directly, `awk` fails immediately because the opening action brace `{` is missing:

```
$ awk 'print FILENAME, NR,FNR,$0}' fileA fileB
awk: syntax error at source line 1
 context is
	 >>> print <<<  FILENAME, NR,FNR,$0}
	extra }
awk: bailing out at source line 1
```

- In `gawk`: `gawk: cmd. line:1: print FILENAME, NR,FNR,$0}` -> `gawk: cmd. line:1: ^ parse error`
- In `mawk`: `mawk: line 1: syntax error at or near print`

### 2.2 The Fix
Add the missing opening brace `{`:
```bash
awk '{print FILENAME, NR, FNR, $0}' fileA fileB
```

---

## 3. Explaining NR vs FNR

- **`NR` (Number of Records)**: The total cumulative count of input lines read across **all** input files combined.
- **`FNR` (File Number of Records)**: The line number within the **current** input file, resetting to `1` every time `awk` opens a new file.

### Demonstration:
With `fileA` containing lines `a`, `b`, `c` and `fileB` containing lines `d`, `e`:

```bash
$ awk '{print FILENAME, NR, FNR, $0}' fileA fileB
fileA 1 1 a
fileA 2 2 b
fileA 3 3 c
fileB 4 1 d
fileB 5 2 e
```

- Notice that `NR == FNR` evaluates to **true** (1==1, 2==2, 3==3) exclusively while processing `fileA`.
- As soon as `fileB` begins, `NR` is 4 while `FNR` is 1 (`4 != 1`), so `NR == FNR` becomes **false**.

---

## 4. The Classic Two-File Idiom

Because `NR == FNR` differentiates the first file from all subsequent files, Awk programmers use this condition to join or filter two files in a single pass without prior sorting.

### 4.1 Inner Join (Lines of B that appear in A)
```bash
awk 'NR==FNR { seen[$1]; next } $1 in seen' fileA fileB
```
- `NR==FNR { seen[$1]; next }`: While reading the first file (`fileA`), record each key `$1` in associative array `seen`, and call `next` to skip remaining rules.
- `$1 in seen`: For all subsequent files (`fileB`), if the line's key `$1` exists in `seen`, the condition evaluates to true and `awk` defaults to printing `$0`.

### 4.2 Anti-Join (Lines of B that do NOT appear in A)
```bash
awk 'NR==FNR { seen[$1]; next } !($1 in seen)' fileA fileB
```
- Tests negation `!($1 in seen)`, outputting only lines in `fileB` whose key was absent in `fileA`.

---

## 5. Verification

Validated via `work/R01-T040/check.sh`:
- Verifies syntax error on buggy line.
- Verifies corrected output across `fileA` and `fileB`.
- Asserts join and anti-join outputs on sample rosters match expected results.
- Asserts `README.md` includes the corrected `{` and the two-file idiom.
