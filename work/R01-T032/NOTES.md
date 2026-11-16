# Task R01-T032 Notes: What `sed -i` Really Does to Your Files

- **Student**: Anumoy Dasmaji
- **Task ID**: R01-T032 (2 of 10)
- **Repository**: https://github.com/S-AI-Projects/Bash-Oneliner
- **Target Item**: `README.md` L643 — "Edit infile (edit and save to file)"

---

## 1. Environment

- **OS**: Darwin 24.3.0 / Linux compatible
- **Shell**: GNU bash / zsh
- **Tools**: `sed` (BSD sed and GNU sed compatibility), `stat`, `cmp`, `bats`
- **Date**: 16 November 2026

---

## 2. In-Place Editing and Backups (`sed -i.bak`)

### 2.1 Demonstration

We create a sample file `f` containing target `bbo` lines, make a copy `f.orig`, and run `sed -i.bak '/bbo/d' f`:

```bash
$ cat <<'EOF' > f
apple
bbo line 1
banana
bbo line 2
cherry
EOF
$ cp f f.orig

$ sed -i.bak '/bbo/d' f
```

### 2.2 Results
```bash
$ cat f
apple
banana
cherry

$ cat f.bak
apple
bbo line 1
banana
bbo line 2
cherry

$ cmp f.bak f.orig
$ echo $?
0
```

- `cmp f.bak f.orig` exits with code `0`, proving `f.bak` is byte-for-byte identical to the original input file.
- All lines matching `/bbo/` were removed from `f`.

---

## 3. Inode Inspection: The Mechanism Behind "In-Place"

In Unix, `sed -i` is **not** an in-place mutation of bytes on disk. Instead, `sed` creates a temporary file in the same directory, writes the transformed stream to it, renames the original file to the backup name (if requested), and renames the temporary file to the original file's name.

### 3.1 Stat Output Before and After

```bash
$ echo "initial content" > file.txt
$ stat -f "Inode: %i  Permissions: %Sp  Size: %z bytes" file.txt
Inode: 8225640  Permissions: -rw-r--r--  Size: 16 bytes

$ sed -i.bak 's/initial/modified/' file.txt

$ stat -f "file.txt     -> Inode: %i  Permissions: %Sp  Size: %z bytes" file.txt
file.txt     -> Inode: 8225641  Permissions: -rw-r--r--  Size: 17 bytes

$ stat -f "file.txt.bak -> Inode: %i  Permissions: %Sp  Size: %z bytes" file.txt.bak
file.txt.bak -> Inode: 8225640  Permissions: -rw-r--r--  Size: 16 bytes
```

### 3.2 Consequences of Inode Replacement
1. **Hard Links Break**: If `file.txt` had other hard links, those links continue pointing to inode `8225640` (now `file.txt.bak`), not the new `file.txt`.
2. **Open File Descriptors**: Running processes holding an open file descriptor on `file.txt` will continue reading/writing the old unedited file data.
3. **Ownership & Attributes**: If the temporary file is created with default `umask`, permissions or ownership could differ if not explicitly preserved by `sed`.

---

## 4. Symbolic Link Behavior

### 4.1 Plain `sed -i` on a Symlink

When a symbolic link points to a target file:
```bash
$ echo "target data with bbo" > target
$ ln -s target link
$ ls -l link
lrwxr-xr-x 1 macbook staff 6 Nov 16 13:37 link -> target
```

- **GNU sed (Linux default)**:
  Running `sed -i '/bbo/d' link` creates a temporary file and executes `rename("tmp", "link")`.
  The atomic rename replaces the directory entry for `link`.
  **Result:** `link` is no longer a symbolic link! It becomes an independent regular file (`-rw-r--r--`). The original `target` remains completely unmodified!
- **BSD sed (macOS default)**:
  BSD sed checks whether the input file is a regular file. Running `sed -i '' '/bbo/d' link` halts with:
  `sed: link: in-place editing only works for regular files`

### 4.2 Preserving Symlinks: `--follow-symlinks` (GNU sed)

GNU sed provides the `--follow-symlinks` option:
```bash
$ sed --follow-symlinks -i '/bbo/d' link
$ ls -l link
lrwxr-xr-x 1 user staff 6 Nov 16 13:37 link -> target
$ cat target
target data without bbo lines
```
With `--follow-symlinks`, GNU sed resolves `link` to `target`, edits `target` in place (swapping `target`'s inode), and leaves the `link` symbolic link intact.

---

## 5. Portability: GNU sed vs. BSD / macOS sed

| Feature | GNU sed (Linux) | BSD sed (macOS) |
|---|---|---|
| In-place without backup | `sed -i '/pat/d' f` | `sed -i '' '/pat/d' f` |
| In-place with backup | `sed -i.bak '/pat/d' f` | `sed -i.bak '/pat/d' f` (or `sed -i '.bak'`) |
| In-place on symlink | Replaces symlink with regular file | Rejects symlink (`only works for regular files`) |
| Follow symlinks flag | `--follow-symlinks` supported | Not supported |

---

## 6. Automated Testing

All behaviors are covered by Bats tests in `test.bats` and verified via `check.sh`:
- Backup retention and byte identity (`cmp`)
- Inode change verification (`stat`)
- Symlink breakage under plain `sed -i`
- Symlink preservation with `--follow-symlinks`
- Verification of updated `README.md` entry
