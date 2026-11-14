# Understanding sed's :a;N;$!ba loop

## 1. Original command

```bash
sed ':a;N;$!ba;s/\n//g'
```
- `:a` creates a label named `a`, which the branch command can return to.
- `N` reads the next input line and appends it to the pattern space, separated by a newline.
- `$!ba` means: if the current line is not the last line (`$!`), branch back to label `a` (`b a`).
- `s/\n//g` removes every newline from the accumulated pattern space.

## 2. Pattern-space walkthrough

Input:

one
two
three

| Stage | Pattern space |
|---|---|
| Initially | `one` |
| After first `N` | `one\ntwo` |
| After second `N` | `one\ntwo\nthree` |
| After substitution | `onetwothree` |

The loop keeps appending lines until it reaches the last line. The substitution then removes all embedded newlines.

## 3. Alternatives

| Command | Description |
|---|---|
| `sed ':a;N;$!ba;s/\n//g'` | Reads the whole input into one pattern space before substitution. |
| `sed -z 's/\n//g'` | GNU sed extension: uses NUL as the record separator and removes newline characters. |
| `tr -d '\n'` | Deletes newline bytes directly while processing the input as a stream. |
| `paste -sd ''` | Joins input lines with an empty delimiter. |

`tr -d '\n'` is the simplest and most memory-efficient choice when the goal is simply to remove newline bytes.

## 4. Trailing-newline behaviour

Tested with both `printf 'one\ntwo\nthree\n'` and `printf 'one\ntwo\nthree'`.

| Command | Input with trailing newline | Input without trailing newline |
|---|---|---|
| Original sed loop | Output has trailing newline | Output has no trailing newline |
| GNU `sed -z` | No trailing newline | No trailing newline |
| `tr -d '\n'` | No trailing newline | No trailing newline |
| `paste -sd ''` | Output has trailing newline | Output has trailing newline |

The commands produce the same joined text, but their final output bytes differ.

## 5. Memory and performance benchmark

Test file: 500 MB (`/tmp/r01-t046-500mb.txt`)

Commands:

`/usr/bin/time -v sed ':a;N;$!ba;s/\n//g' /tmp/r01-t046-500mb.txt > /dev/null`

`/usr/bin/time -v tr -d '\n' < /tmp/r01-t046-500mb.txt > /dev/null`

| Metric | Original sed loop | `tr -d '\n'` |
|---|---:|---:|
| Maximum RSS | 770304 KB | 1920 KB |
| Elapsed time | 41.56 seconds | 0.73 seconds |
| Exit status | 0 | 0 |

The sed loop used approximately 401 times as much peak memory as `tr` in this test.

The sed loop is memory-heavy because it accumulates the entire input in one pattern space. `tr` processes the input as a stream and does not need to store the entire file in memory.

## 6. Test environment

- Platform: GitHub Codespaces, Linux x86_64
- OS: Ubuntu 24.04.5 LTS
- Kernel: Linux 6.8.0-1070-azure
- Bash: 5.2.21
- GNU sed: 4.9
- GNU coreutils: 9.4
- GNU time: 1.9
