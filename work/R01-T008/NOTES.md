# R01-T008: Analysis of Breaking Inputs for `read input; echo $input`

## Overview

The classic Bash idiom:
```bash
read input
echo $input
```
fails to preserve user input accurately across several common scenarios. It silently alters whitespace, removes backslashes, expands wildcards into filenames, and treats option-like strings as flags to `echo`.

The safe, exact alternative is:
```bash
IFS= read -r input
printf '%s\n' "$input"
```

---

## Breakdown of Breaking Inputs

| Input | Original Output (`read input; echo $input`) | Safe Output (`IFS= read -r input; printf '%s\n' "$input"`) | Reason for Change / Mechanism |
| :--- | :--- | :--- | :--- |
| `'  two  spaces  '` | `two spaces` | `  two  spaces  ` | **IFS Trimming & Word Splitting**: By default, `read` uses `IFS=$' \t\n'`, stripping leading and trailing whitespace. Furthermore, referencing `$input` unquoted causes Bash word splitting, condensing contiguous interior spaces into single space delimiters. |
| `'C:\new\dir'` | `C:newdir` | `C:\new\dir` | **Backslash Escaping**: Without the `-r` option, `read` treats `\` as an escape character (`help read`: *"do not allow backslashes to escape any characters"*). Consequently, `\n` and `\d` have their backslashes stripped upon assignment. |
| `'*'` | `CODE_OF_CONDUCT.md LICENSE README.md _config.yml work` | `*` | **Pathname Expansion (Globbing)**: An unquoted `$input` undergoes filename expansion (globbing) before `echo` executes. The shell expands `*` to the list of matching files and directories in the current working directory. |
| `'-n'` | *(empty / nothing)* | `-n` | **Option Flag Parsing in `echo`**: The `echo` built-in parses `-n` as an option flag instructing it to suppress the trailing newline. Because no positional arguments remain, `echo` outputs nothing at all. `printf '%s\n'` safely treats the variable value as data, not an option. |
| `''` *(empty line)* | *(empty line with newline)* | *(empty line with newline)* | **Empty Input Handling**: `read` reads an empty string up to the newline. `echo ""` outputs a single newline `\n`. In `printf '%s\n' "$input"`, an empty string is similarly formatted with a single newline, preserving the line structure cleanly. |

---

## Detailed Technical Explanations

### 1. Leading, Trailing, and Internal Whitespace (`'  two  spaces  '`)
- **`read` behavior without `IFS=`**:
  According to `help read`, word splitting is performed on the input line using the characters in `IFS` (default space, tab, newline). Any leading or trailing characters in `IFS` are discarded.
- **`echo $input` unquoted**:
  When `$input` is evaluated without double quotes, Bash performs word splitting on its content. The tokens `two` and `spaces` are passed as two distinct arguments (`$1="two"`, `$2="spaces"`) to `echo`, which joins them with a single space.
- **Fix**:
  Prefixing `read` with `IFS=` clears field separators for the command invocation, preserving all leading and trailing whitespace. Quoting `"$input"` prevents word splitting.

### 2. Backslashes (`'C:\new\dir'`)
- **`read` behavior without `-r`**:
  `help read`:
  > `-r` do not allow backslashes to escape any characters
  Without `-r`, a backslash escapes the next character (e.g. `\n` becomes `n`, `\d` becomes `d`), removing backslashes entirely.
- **Fix**:
  Using `read -r` disables escape sequence processing and preserves raw backslashes byte-for-byte.

### 3. Wildcards and Globbing (`'*'`)
- **Shell pathname expansion**:
  Unquoted `$input` triggers filename expansion. The wildcard `*` matches all non-hidden files and directories in the current directory (`CODE_OF_CONDUCT.md LICENSE README.md _config.yml work`).
- **Fix**:
  Using double quotes `"$input"` disables pathname expansion.

### 4. Option Flags (`'-n'`)
- **`echo` option parsing**:
  Built-in `echo` parses arguments starting with `-` (such as `-n`, `-e`, `-E`) as options. `echo -n` suppresses the trailing newline and outputs nothing.
- **Fix**:
  Using `printf '%s\n' "$input"` cleanly separates format specifications from data: `"$input"` is passed as an argument to the `%s` conversion specifier and is never parsed as a command option.

---

## Verification

The test script `work/R01-T008/test.bats` verifies that all 5 inputs match byte-for-byte when passed through `work/R01-T008/read_exact.sh`:

```bash
bats work/R01-T008/test.bats
```
Output:
```
1..6
ok 1 preserves leading, internal, and trailing whitespace ('  two  spaces  ')
ok 2 preserves backslashes ('C:\new\dir')
ok 3 preserves glob character without pathname expansion ('*')
ok 4 preserves option flag without option interpretation ('-n')
ok 5 preserves empty line ('')
ok 6 byte-for-byte stream fidelity check via cmp
```
