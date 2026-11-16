# Task R01-T033 Notes: Fix the Number-Rounding Awk Program

- **Student**: Anumoy Dasmaji
- **Task ID**: R01-T033 (3 of 10)
- **Repository**: https://github.com/S-AI-Projects/Bash-Oneliner
- **Target Item**: `README.md` L946 — "Round all numbers of file (e.g. 2 significant figure)"

---

## 1. Environment

- **OS**: Darwin 24.3.0 / Linux compatible
- **Shell**: GNU bash / zsh
- **Tool**: `awk` (BSD/One True Awk 20200816, GNU gawk 5.x, mawk 1.3.4), `bats`
- **Date**: 16 November 2026

---

## 2. Analysis of the Original Buggy Program

The original one-liner in `README.md` (L946–954) was:

```bash
##### Round all numbers of file (e.g. 2 significant figure)
```bash
awk '{while (match($0, /[0-9]+\[0-9]+/)){
    \printf "%s%.2f", substr($0,0,RSTART-1),substr($0,RSTART,RLENGTH)
    \$0=substr($0, RSTART+RLENGTH)
    \}
    \print
    \}'
```
```

### 2.1 Bugs Identified

1. **Incorrect Regular Expression**:
   `/[0-9]+\[0-9]+/` escapes `[` as `\[`, intending to escape `.` as `\.` for a decimal point.
   As a consequence:
   - Genuine floating-point numbers like `3.14159` and `2.71828` never match because there is no period `.` in the pattern.
   - Decimals remain untouched and unrounded.
   - Text containing numbers followed by literal brackets (e.g. `1[2`) is erroneously targeted.
2. **Stray Backslashes**:
   Backslashes preceding `\printf`, `\$0`, `\}`, `\print`, and `\}` were copy-paste artifacts from shell escaped lines. In awk scripts, they cause syntax warnings or parsing errors.
3. **Substring Indexing**:
   `substr($0, 0, RSTART-1)` passes offset `0`. In awk, string indexing is 1-based (`substr($0, 1, RSTART-1)`).

### 2.2 Reproduction on Test Fixture: `pi=3.14159 e=2.71828 n=42 v=[1[2`

When running the original README program on the fixture:
`'pi=3.14159 e=2.71828 n=42 v=[1[2'`

#### Output with original README program:
```bash
$ echo 'pi=3.14159 e=2.71828 n=42 v=[1[2' | awk '{while (match($0, /[0-9]+\[0-9]+/)){
    \printf "%s%.2f", substr($0,0,RSTART-1),substr($0,RSTART,RLENGTH)
    \$0=substr($0, RSTART+RLENGTH)
    \}
    \print
    \}'
pi=3.14159 e=2.71828 n=42 v=[1.00
```

- **Unchanged Decimals**: `pi=3.14159` and `e=2.71828` are left completely unrounded.
- **Mangled Non-decimal Expression**: The regex mistakenly matched the bracketed expression `1[2` instead of decimal numbers, converting `v=[1[2` into `v=[1.00` because awk numerically coerced `1[2` to `1` when formatting with `%.2f`.

---

## 3. Results across Awk Implementations (gawk and mawk)

We tested and recorded the behavior across GNU `gawk` and `mawk`:

### 3.1 GNU Awk (`gawk`)
- **Original Program**:
  - Emits warnings about stray escape backslashes: `warning: backslash not at end of string`.
  - Fails to round `3.14159` and `2.71828`.
  - Regex `/[0-9]+\[0-9]+/` treats `\[` as matching a literal bracket character `[`.
- **Fixed Program (`/[0-9]+\.[0-9]+/`)**:
  ```bash
  $ echo "pi=3.14159 e=2.71828 n=42 v=[1[2" | gawk '{while (match($0, /[0-9]+\.[0-9]+/)){
      printf "%s%.2f", substr($0, 1, RSTART-1), substr($0, RSTART, RLENGTH)
      $0=substr($0, RSTART+RLENGTH)
      }
      print
      }'
  pi=3.14 e=2.72 n=42 v=[1[2
  ```
  - Clean execution with 0 warnings.
  - Correct output: `pi=3.14 e=2.72 n=42 v=[1[2`.

### 3.2 Mike's Awk (`mawk`)
- **Original Program**:
  - Stray backslashes violate strict syntax handling in mawk.
  - Floats are skipped.
- **Fixed Program (`/[0-9]+\.[0-9]+/`)**:
  ```bash
  $ echo "pi=3.14159 e=2.71828 n=42 v=[1[2" | mawk '{while (match($0, /[0-9]+\.[0-9]+/)){
      printf "%s%.2f", substr($0, 1, RSTART-1), substr($0, RSTART, RLENGTH)
      $0=substr($0, RSTART+RLENGTH)
      }
      print
      }'
  pi=3.14 e=2.72 n=42 v=[1[2
  ```
  - Correct output: `pi=3.14 e=2.72 n=42 v=[1[2`.

### 3.3 POSIX / BSD Awk (`awk` on macOS)
- Produces the exact same expected output:
  `pi=3.14 e=2.72 n=42 v=[1[2`

---

## 4. The Corrected Solution

We change the regular expression to `/[0-9]+\.[0-9]+/`, use 1-based indexing `substr($0, 1, RSTART-1)`, and remove all stray backslashes:

```bash
awk '{while (match($0, /[0-9]+\.[0-9]+/)){
    printf "%s%.2f", substr($0, 1, RSTART-1), substr($0, RSTART, RLENGTH)
    $0=substr($0, RSTART+RLENGTH)
    }
    print
    }'
```

### Verification on Test Fixture:
```bash
$ echo "pi=3.14159 e=2.71828 n=42 v=[1[2" | awk '{while (match($0, /[0-9]+\.[0-9]+/)){
    printf "%s%.2f", substr($0, 1, RSTART-1), substr($0, RSTART, RLENGTH)
    $0=substr($0, RSTART+RLENGTH)
    }
    print
    }'
pi=3.14 e=2.72 n=42 v=[1[2
```

- `3.14159` is correctly rounded to `3.14`.
- `2.71828` is correctly rounded to `2.72`.
- Integer `42` without decimal part is preserved as `42`.
- Literal bracket expression `v=[1[2` is untouched.

---

## 5. Edge Cases Tested

1. **Line with no numbers**:
   - Input: `"no numbers in this text"`
   - Output: `"no numbers in this text"`
2. **Number at the start**:
   - Input: `"12.3456 starts the line"`
   - Output: `"12.35 starts the line"`
3. **Number at the end**:
   - Input: `"ends with 98.7654"`
   - Output: `"ends with 98.77"`
4. **Multiple floats on one line**:
   - Input: `"vals: 1.111, 2.222, and 3.333"`
   - Output: `"vals: 1.11, 2.22, and 3.33"`
5. **Integers preserved**:
   - Input: `"count=42, total=1000"`
   - Output: `"count=42, total=1000"`

---

## 6. Automated Testing

All tests are implemented in `work/R01-T033/test.bats` and can be validated natively via `work/R01-T033/check.sh`.
Both exit `0` with all assertions passing.
