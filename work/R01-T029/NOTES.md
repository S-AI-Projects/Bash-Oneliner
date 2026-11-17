# R01-T029: What 'Count All Files' Really Counts

## 1. Analysis of `ls | xargs -n1 wc -l`

The original README heading was:
```markdown
##### Count all files
ls | xargs -n1 wc -l
```

### Flaws Demonstrated
When executed inside a test folder containing:
- `two_lines.txt` (2 lines)
- `five_lines.txt` (5 lines)
- `zero_lines.txt` (0 lines)
- `my notes.txt` (file with whitespace)
- `subdir/` (directory)

The output is:
```text
       5 five_lines.txt
wc: my: open: No such file or directory
wc: notes.txt: open: No such file or directory
wc: subdir: read: Is a directory
       2 two_lines.txt
       0 zero_lines.txt
```

### Three Major Issues
1. **Counts lines, not files:** The command invokes `wc -l` on each argument, which outputs the line count of each file rather than counting how many files exist.
2. **Breaks on whitespace:** `xargs` splits input on standard whitespace (spaces, tabs, newlines). The file `my notes.txt` is split into two distinct arguments `my` and `notes.txt`, causing two `No such file or directory` errors.
3. **Fails on directories:** `ls` lists directories alongside regular files; `wc -l` fails with `Is a directory`.

## 2. The Solution

### Accurate Line Counter
Rename the original recipe heading to accurately describe its action:
```markdown
##### Count lines in each file
ls | xargs -n1 wc -l
```

### Accurate File Counter
To count the number of regular files in the current directory:
```bash
find . -maxdepth 1 -type f | wc -l
```
- `-maxdepth 1`: Restricts file selection strictly to the current directory (non-recursive).
- `-type f`: Restricts selection exclusively to regular files, ignoring subdirectories, sockets, and fifos.
- `wc -l`: Counts total newline-separated paths matching the criteria (returns 4 for our fixture).
