# Annotating NR vs FNR in Awk

## Input Files

### `fileA`
```
a
b
c
```

### `fileB`
```
d
e
```

---

## Corrected Command & Output

```bash
$ awk '{print FILENAME, NR, FNR, $0}' fileA fileB
fileA 1 1 a
fileA 2 2 b
fileA 3 3 c
fileB 4 1 d
fileB 5 2 e
```

---

## Column-by-Column Annotation

| Column | Awk Variable | Description | Value in `fileA` | Value in `fileB` |
|:---:|:---:|:---|:---:|:---:|
| **Col 1** | `FILENAME` | Name of the file currently being read by `awk` | `fileA` | `fileB` |
| **Col 2** | `NR` | **Cumulative Record Number**: Overall line count across all processed files | `1`, `2`, `3` | `4`, `5` (continues counting) |
| **Col 3** | `FNR` | **File Record Number**: Line count within the current active file | `1`, `2`, `3` | `1`, `2` (resets to 1 at start of each file) |
| **Col 4** | `$0` | **Full Line Content**: The entire unparsed input record text | `a`, `b`, `c` | `d`, `e` |

---

## Key Observation: Why `NR == FNR` Identifies the First File

```
Record 1: NR=1, FNR=1  --> NR == FNR is TRUE  (fileA)
Record 2: NR=2, FNR=2  --> NR == FNR is TRUE  (fileA)
Record 3: NR=3, FNR=3  --> NR == FNR is TRUE  (fileA)
----------------------- (file boundary) -----------------------
Record 4: NR=4, FNR=1  --> NR == FNR is FALSE (fileB)
Record 5: NR=5, FNR=2  --> NR == FNR is FALSE (fileB)
```

Because `FNR` resets to 1 upon entering each new file while `NR` monotonically increases, `NR == FNR` is **guaranteed to be true if and only if awk is reading the first file** on the command line.

---

## The Two-File Idiom in Practice

### Roster A
```
alice
bob
charlie
dave
```

### Roster B
```
bob
dave
eve
frank
```

### 1. Inner Join: Lines of B that appear in A
```bash
$ awk 'NR==FNR { seen[$1]; next } $1 in seen' rosterA.txt rosterB.txt
bob
dave
```

### 2. Anti-Join: Lines of B that do NOT appear in A
```bash
$ awk 'NR==FNR { seen[$1]; next } !($1 in seen)' rosterA.txt rosterB.txt
eve
frank
```
