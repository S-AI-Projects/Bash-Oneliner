# R01-T044 — What LC_ALL=C changes: order and speed

## Environment

- OS: Ubuntu 24.04 (GitHub Codespaces)
- Shell: Bash
- Tool: GNU coreutils `sort`, GNU grep, hyperfine 1.18.0
- Available locales: `C`, `C.utf8`, `en_US.utf8`, `POSIX`

## 1. Sort order comparison

Input words:

```text
apple Banana _x éclair Zebra 10 9
```

### LC_ALL=C

```text
10
9
Banana
Zebra
_x
apple
éclair
```

### LC_ALL=en_US.utf8

```text
10
9
apple
Banana
éclair
_x
Zebra
```

The C locale uses byte-oriented ordering, while `en_US.utf8` uses locale-aware collation rules. The `C.utf8` locale produced the same ordering as `C` in this environment.

## 2. Benchmark: sort

Dataset: 1,000,000 lines generated using `seq` and `awk`.

Command tested:

```bash
LC_ALL=C sort /tmp/r01-t044-data.txt
LC_ALL=en_US.utf8 sort /tmp/r01-t044-data.txt
```

Hyperfine settings: 2 warm-ups and 5 measured runs.

| Locale | Mean time | Standard deviation |
|---|---:|---:|
| C | 187.7 ms | 19.1 ms |
| en_US.utf8 | 2.145 s | 0.076 s |

C locale sorting was approximately 11.4 times faster in this experiment.

## 3. Benchmark: grep -i

The same dataset contained 100,000 matching lines.

To get longer measurements, each benchmark command ran grep 20 times.

| Locale | Mean time for 20 searches | Standard deviation |
|---|---:|---:|
| C | 25.9 ms | 1.6 ms |
| en_US.utf8 | 30.1 ms | 1.5 ms |

C locale was approximately 1.16 times faster in this experiment.

## 4. Non-ASCII text handling

Tested Bash string length with the character `é`:

```bash
LC_ALL=C bash -c 'text="é"; printf "%s\n" "${#text}"'
# 2

LC_ALL=en_US.utf8 bash -c 'text="é"; printf "%s\n" "${#text}"'
# 1
```

In the C locale, Bash counts the two UTF-8 bytes. In the UTF-8 locale, it counts one character.

This demonstrates that `LC_ALL=C` can change how non-ASCII text is handled.

## 5. When should scripts use LC_ALL=C?

Use `LC_ALL=C` when:
- Predictable byte-oriented sorting is required.
- Processing machine-generated text or ASCII data.
- Locale-independent output is important.
- Faster text processing is useful.

Avoid forcing it when:
- Processing human-readable multilingual text.
- Character counts or text operations must follow UTF-8 locale rules.
- Language-aware sorting is required.

## Conclusion

`LC_ALL=C` provides predictable byte-oriented behavior and was faster in the sorting and grep benchmarks on this dataset. However, it changes text handling, so scripts should use it only when byte-oriented processing is appropriate.

Benchmark results are specific to this Codespaces environment and dataset.