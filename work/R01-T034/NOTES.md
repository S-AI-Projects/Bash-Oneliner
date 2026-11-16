# Task R01-T034 Notes: Test the 'Grep AND' Entry

- **Student**: Anumoy Dasmaji
- **Task ID**: R01-T034 (4 of 10)
- **Repository**: https://github.com/S-AI-Projects/Bash-Oneliner
- **Target Item**: `README.md` L566 — "Grep AND (e.g. A and B)"

---

## 1. Environment

- **OS**: Darwin 24.3.0 / Linux compatible
- **Shell**: GNU bash / zsh
- **Tools**: `grep` (GNU grep / BSD grep), `awk`, `perl`, `bats`
- **Date**: 16 November 2026

---

## 2. Analysis of the Original Command

The original one-liner in `README.md` (L566–569) is:

```bash
##### Grep AND (e.g. A and B)
```bash
grep 'A.*B'
```
```

### 2.1 The Semantic Flaw: Order Dependence

A logical boolean **AND** is order-independent: a line contains both `A` and `B` regardless of whether `A` appears before `B` or `B` appears before `A`.
However, the regular expression `'A.*B'` strictly matches the literal sequence `A` followed anywhere later by `B`.

### 2.2 Test Fixture
We test across 5 representative cases:
1. `A then B` — contains both, `A` precedes `B`
2. `B then A` — contains both, `B` precedes `A`
3. `only A` — false positive candidate (only has A)
4. `only B` — false positive candidate (only has B)
5. `AB` — adjacent match, `A` precedes `B`

### 2.3 Demonstration
```bash
$ cat fixture.txt
A then B
B then A
only A
only B
AB

$ grep 'A.*B' fixture.txt
A then B
AB
```
- Line `B then A` is silently omitted!
- Therefore, `grep 'A.*B'` is actually "A followed by B", not a general boolean AND.

---

## 3. Order-Independent Alternatives

To perform true order-independent boolean AND matching, three canonical approaches can be used:

### Method 1: Pipelined Grep (Most Portable and Common)
```bash
grep 'A' file | grep 'B'
```
- First `grep` filters for lines containing `A`; second `grep` filters the result for lines containing `B`.
- Output:
  ```
  A then B
  B then A
  AB
  ```
- Works identically across all POSIX systems and shells.

### Method 2: Awk Pattern Conjunction
```bash
awk '/A/ && /B/' file
```
- Evaluates both regex conditions logically in a single pass.
- Highly readable and efficient.
- Output:
  ```
  A then B
  B then A
  AB
  ```

### Method 3: PCRE Positive Lookahead (Single Grep Process)
```bash
grep -P '^(?=.*A)(?=.*B)' file
```
- Uses zero-width positive lookahead assertions from the start of the line `^`.
- Does not consume characters, allowing both patterns to match anywhere along the line.
- Requires GNU grep compiled with PCRE support (`-P`).

---

## 4. Proposed README Wording

Update the entry to distinguish between ordered sequence and order-independent AND:

```markdown
##### Grep AND (e.g. A and B)
```bash
# Order-independent (matches both A and B in any order):
grep 'A' filename | grep 'B'

# or using awk:
awk '/A/ && /B/' filename

# Order-dependent (matches only when A appears before B):
grep 'A.*B' filename
```
```

---

## 5. Automated Testing

Implemented in `work/R01-T034/test.bats` and `work/R01-T034/check.sh`:
- Asserts that `grep 'A.*B'` matches 2 lines and misses `B then A`.
- Asserts that piped grep, awk, and PCRE lookahead all return all 3 matching lines.
- Validates the updated `README.md` entry.
