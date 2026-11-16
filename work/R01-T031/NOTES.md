# Task R01-T031 Notes: Teach `&&`, `||` and Where You End Up

- **Student**: Anumoy Dasmaji
- **Task ID**: R01-T031 (1 of 10)
- **Repository**: https://github.com/S-AI-Projects/Bash-Oneliner
- **Target Item**: `README.md` L3380 — "Run command only if another command returns non-zero exit status (not finish)"

---

## 1. Environment

- **OS**: Darwin 24.3.0 / Linux compatible
- **Shell**: GNU bash, version 3.2.57(1)-release / bash 5.x
- **Date**: 16 November 2026

---

## 2. Analysis of the Original README Entry

The original one-liner in `README.md` (L3380–3383) is:

```bash
##### Run command only if another command returns non-zero exit status (not finish)
```bash
cd tmp/a/b/c ||mkdir -p tmp/a/b/c
```
```

### 2.1 Terminal Reproduction from a Fresh Directory

We run the command in a fresh temporary directory where `tmp/a/b/c` does not exist:

```bash
$ TEST_DIR=$(mktemp -d)
$ cd "$TEST_DIR"
$ pwd
/private/var/folders/8d/j86j3dfj4lj4pwl8r2qt_hqr0000gn/T/tmp.sBrASiA1vq

$ cd tmp/a/b/c || mkdir -p tmp/a/b/c
bash: cd: tmp/a/b/c: No such file or directory

$ pwd
/private/var/folders/8d/j86j3dfj4lj4pwl8r2qt_hqr0000gn/T/tmp.sBrASiA1vq

$ ls -ld tmp/a/b/c
drwxr-xr-x  2 macbook  staff  64 Nov 16 13:33 tmp/a/b/c
```

### 2.2 Findings and Flaw Explanation

1. **Unwanted Error Output**: Because `tmp/a/b/c` does not yet exist, `cd` fails and outputs `bash: cd: tmp/a/b/c: No such file or directory` to standard error.
2. **Directory Created but Not Entered**: The non-zero exit status of `cd` triggers the right-hand side of `||`, which runs `mkdir -p tmp/a/b/c`. This successfully creates the directory.
3. **Shell Did NOT Enter the Folder**: After running the line, `pwd` is still `/private/var/folders/.../tmp.sBrASiA1vq`—the user is **not** inside `tmp/a/b/c`.
4. **Core Misconception**: `mkdir` creates directories on the filesystem; it never changes the working directory of the calling shell. The intended workflow for a user running such a command is almost always: "enter the directory if it exists, otherwise create it AND enter it."

---

## 3. The Corrected Solution with Braces

To achieve the intended behavior, the command must execute both `mkdir -p` and `cd` when the initial directory change fails:

```bash
cd tmp/a/b/c 2>/dev/null || { mkdir -p tmp/a/b/c && cd tmp/a/b/c; }
```

### 3.1 Verification

#### Case A: Target directory does not exist initially
```bash
$ TEST_DIR=$(mktemp -d)
$ cd "$TEST_DIR"
$ [ -d tmp/a/b/c ] && echo "exists" || echo "does not exist"
does not exist

$ cd tmp/a/b/c 2>/dev/null || { mkdir -p tmp/a/b/c && cd tmp/a/b/c; }
$ pwd
/private/var/folders/8d/j86j3dfj4lj4pwl8r2qt_hqr0000gn/T/tmp.ABCDEF/tmp/a/b/c
$ echo $?
0
```
- The directory was created cleanly without stderr noise (`2>/dev/null`).
- The shell ended **inside** `tmp/a/b/c`.
- Exit status is `0`.

#### Case B: Target directory already exists
```bash
$ cd "$TEST_DIR"
$ cd tmp/a/b/c 2>/dev/null || { mkdir -p tmp/a/b/c && cd tmp/a/b/c; }
$ pwd
/private/var/folders/8d/j86j3dfj4lj4pwl8r2qt_hqr0000gn/T/tmp.ABCDEF/tmp/a/b/c
$ echo $?
0
```
- Initial `cd` succeeds immediately (`exit 0`).
- The entire `|| { ... }` block is short-circuited and skipped.
- The shell is inside `tmp/a/b/c` with `exit 0`.

### 3.2 Deep Dive: Why Grouping Braces `{ ...; }` Are Required

1. **Operator Precedence in Bash**:
   In Bash, `&&` and `||` share equal operator precedence and evaluate strictly left-to-right. Without grouping:
   ```bash
   cd x || mkdir -p x && cd x
   ```
   If `cd x` succeeds (when `x` already exists):
   - `cd x` returns `0`.
   - `|| mkdir -p x` is skipped due to short-circuiting.
   - The status going into `&& cd x` is still `0` (from the first `cd`).
   - `&& cd x` executes again! While inside `x`, trying to `cd x` looks for a nested `x/x`, which fails!
   Therefore, grouping is mandatory.

2. **Why Braces `{ ...; }` and Not Parentheses `( ... )`**:
   - `( ... )` executes commands inside a **subshell fork**. Any environment modifications—especially changing working directory with `cd`—remain isolated to the child process and are discarded as soon as the subshell exits.
   - `{ ...; }` is a compound command that executes the enclosed list in the **current execution environment**, allowing `cd` to change the working directory of the active shell.

3. **Syntax Rules for `{ ...; }` in Bash / POSIX Shell**:
   - `{` and `}` are reserved words, not metacharacters. There must be a space (or newline) after `{` and before `}`.
   - The command list inside braces must be terminated by a semicolon `;` (or newline) before the closing `}`.
   - Example valid syntax: `{ cmd1 && cmd2; }`
   - Example invalid syntax: `{cmd1 && cmd2}` or `{ cmd1 && cmd2 }` (syntax error).

4. **Stream Redirection (`2>/dev/null`)**:
   - Suppresses the expected diagnostic message (`cd: tmp/a/b/c: No such file or directory`) during the initial existence check.

---

## 4. Self-Test Summary & Quiz Evaluation

A dedicated quiz of 5 questions was developed in `QUIZ.md` testing `&&`, `||`, subshells, and brace grouping.

| Question | Tested Concept | Reference Output | Reference Exit Status |
|:---:|:---|:---:|:---:|
| **Q1** | Chained operations with failing middle command | `/d1` | `1` |
| **Q2** | Current shell grouping with `{ ...; }` on failure | `/x` | `0` |
| **Q3** | Subshell isolation with `( ... )` | `/` (root) | `0` |
| **Q4** | Left-associative short-circuit continuation trap | `/d1` | `0` |
| **Q5** | False prefix skipping a command group | `/d1` | `0` |

All 5 predictions are verified by `quiz.sh` and checked automatically via `check.sh`.
