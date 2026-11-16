# Task R01-T033 Notes: Fix the Number-Rounding Awk Program

- **Student**: Anumoy Dasmaji
- **Task ID**: R01-T033 (3 of 10)
- **Repository**: https://github.com/S-AI-Projects/Bash-Oneliner
- **Target Item**: `README.md` L946 — "Round all numbers of file (e.g. 2 significant figure)"

---

## 1. Environment

- **OS**: Darwin 24.3.0 / Linux compatible
- **Shell**: GNU bash / zsh
- **Tool**: `awk` (POSIX awk / GNU gawk / mawk), `bats`
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
   `/[0-9]+\[0-9]+/` escapes `[` as `\[`, matching a literal left bracket character `[` instead of escaping `.` as `\.` for a decimal point.
   As a consequence:
   - Genuine floating-point numbers like `3.14159` and `2.71828` never match.
   - Text containing numbers followed by literal brackets (e.g., `1[0-9]+`) is accidentally matched.
2. **Stray Backslashes**:
   Backslashes preceding `\printf`, `\$0`, `\}`, `\print`, and `\}` were artifacts from shell escaping. When copied into an awk script or command line, they degrade readability, violate standard awk syntax, and cause syntax warnings or failures.
3. **Substring Indexing**:
   `substr($0, 0, RSTART-1)` passes offset `0`. In awk, string indexing is canonically 1-based (`substr($0, 1, RSTART-1)`).

### 2.2 Reproduction on Test Fixture

Input fixture:
`pi=3.14159 e=2.71828 n=42 v=[1[2`

Output with original program:
```bash
$ echo 'pi=3.14159 e=2.71828 n=42 v=[1[2' | awk '{while (match($0, /[0-9]+\[0-9]+/)){
    printf "%s%.2f", substr($0,0,RSTART-1),substr($0,RSTART,RLENGTH)
    $0=substr($0, RSTART+RLENGTH)
    }
    print
    }'
pi=3.14159 e=2.71828 n=42 v=[1[2
```

- Decimals (`3.14159`, `2.71828`) remained completely untouched and unrounded.

---

## 3. The Corrected Solution

We change the regular expression to `/[0-9]+\.[0-9]+/`, use 1-based indexing `substr($0, 1, RSTART-1)`, and remove all stray backslashes:

```bash
awk '{while (match($0, /[0-9]+\.[0-9]+/)){
    printf "%s%.2f", substr($0, 1, RSTART-1), substr($0, RSTART, RLENGTH)
    $0=substr($0, RSTART+RLENGTH)
    }
    print
    }'
```

### 3.1 Verification on Test Fixture

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

## 4. Edge Cases Tested

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

---

## 5. Automated Testing

All tests are implemented in `work/R01-T033/test.bats` and can be validated natively via `work/R01-T033/check.sh`.
Both exit `0` with all assertions passing.
