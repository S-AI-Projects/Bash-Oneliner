# Bash Command Lists Quiz — R01-T031
## Predict `pwd` and Exit Status with `&&` and `||`

In Bash, `&&` (AND-IF) and `||` (OR-IF) have equal operator precedence and associate left-to-right. Predict the final working directory (relative to the starting test root) and the final exit status (`$?`) for each command before running it.

### Initial Setup for Each Question
Each question runs from a fresh, empty root working directory (`/`) containing two subdirectories: `d1` and `d2`. Directory `x` and directory `sub` do not initially exist.

---

### Question 1: Chained operations with a failing middle command
```bash
cd d1 && cd ../nonexistent 2>/dev/null || cd d2 2>/dev/null
```
- **Predicted `pwd`**:
- **Predicted Exit Status**:

---

### Question 2: Grouping with braces on failure
```bash
cd x 2>/dev/null || { mkdir -p x && cd x; }
```
- **Predicted `pwd`**:
- **Predicted Exit Status**:

---

### Question 3: Subshell grouping vs. current shell
```bash
cd sub 2>/dev/null || ( mkdir -p sub && cd sub )
```
- **Predicted `pwd`**:
- **Predicted Exit Status**:

---

### Question 4: Short-circuiting and continuation trap
```bash
cd d1 || mkdir -p d1 && touch in_d1.txt
```
- **Predicted `pwd`**:
- **Predicted Exit Status**:

---

### Question 5: Short-circuited command group
```bash
false && { cd d1 && touch file; } || cd d1
```
- **Predicted `pwd`**:
- **Predicted Exit Status**:

---

## Answer Key & Detailed Explanations

### Question 1
- **Answer**: `pwd=/d1`, `exit=1`
- **Explanation**:
  1. `cd d1` succeeds (`exit=0`). The current shell is now inside `d1`.
  2. Because the first command succeeded, `&& cd ../nonexistent` runs. The directory does not exist, so `cd` fails (`exit=1`). The working directory remains `/d1`.
  3. Because the preceding command failed, `|| cd d2` runs. However, the current directory is `/d1`. In `/d1`, a subdirectory `d2` does not exist (`../d2` does). Therefore, `cd d2` fails (`exit=1`).
  4. Final state: working directory is `/d1`, and exit status is `1`.

### Question 2
- **Answer**: `pwd=/x`, `exit=0`
- **Explanation**:
  1. `cd x` is evaluated first. Since `x` does not exist, `cd` fails (`exit=1`).
  2. Because `cd x` failed, the right-hand side of `||` is executed: the group `{ mkdir -p x && cd x; }`.
  3. Unlike parentheses `(...)`, braces `{ ...; }` execute within the **current shell environment**.
  4. `mkdir -p x` creates directory `x` (`exit=0`).
  5. Because `mkdir` succeeded, `&& cd x` executes and successfully moves into `/x` (`exit=0`).
  6. Final state: working directory is `/x`, and exit status is `0`.

### Question 3
- **Answer**: `pwd=/`, `exit=0`
- **Explanation**:
  1. `cd sub` fails because `sub` does not exist (`exit=1`).
  2. The `||` operator triggers the subshell `( mkdir -p sub && cd sub )`.
  3. Parentheses `(...)` spawn a subshell process. Inside the subshell, `mkdir -p sub` succeeds and `cd sub` changes the working directory **of the subshell process**.
  4. The subshell exits successfully (`exit=0`), but environment changes (such as `cd`) made inside a subshell do not affect the parent shell process.
  5. Final state: the parent shell remains in `/`, and the exit status of the subshell is `0`.

### Question 4
- **Answer**: `pwd=/d1`, `exit=0`
- **Explanation**:
  1. `cd d1` succeeds (`exit=0`). The shell moves into `/d1`.
  2. Because `cd d1` succeeded, `|| mkdir -p d1` is skipped by short-circuit evaluation.
  3. The exit status going into `&& touch in_d1.txt` remains `0` (from `cd d1`). Therefore, `touch in_d1.txt` is executed!
  4. This illustrates a classic Bash pitfall: `A || B && C` does not behave like `if A then B else C`. If `A` succeeds, `C` still runs.
  5. The file `in_d1.txt` is created inside `/d1`. Final state: working directory is `/d1`, exit status is `0`.

### Question 5
- **Answer**: `pwd=/d1`, `exit=0`
- **Explanation**:
  1. `false` returns `exit=1`.
  2. Because `false` failed, the `&& { cd d1 && touch file; }` group is skipped entirely due to short-circuiting. The commands inside the braces never execute.
  3. Because the chain status before `||` is non-zero, `|| cd d1` executes.
  4. `cd d1` succeeds (`exit=0`).
  5. Final state: working directory is `/d1`, and exit status is `0`.
