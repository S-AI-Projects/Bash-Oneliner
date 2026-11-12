# R01-T018: Does `head -c 50` mean 50 characters?

## Goal

Demonstrate that `head -c 50` reads 50 **bytes**, not 50 Unicode characters, and compare GNU coreutils with BusyBox using UTF-8 Hindi text.

## Test environment

- OS: Debian GNU/Linux 13 (trixie), x86_64
- Kernel: Linux 6.18.57
- Shell: GNU Bash 5.2.37
- GNU coreutils `head`: 9.7
- BusyBox: 1.37.0
- Python: 3.13.5
- `iconv`: glibc 2.41
- Character-count locale: `C.UTF-8`

## Input

`hindi.txt` contains the UTF-8 text `नमस्ते` repeated 20 times, without a trailing newline. Each code point in this fixture is encoded using three UTF-8 bytes. A 50-byte prefix therefore ends part-way through a code point.

## Results

| Command | Bytes emitted | `iconv -f UTF-8 -t UTF-8` | Meaning |
| --- | ---: | --- | --- |
| `head -c 50 hindi.txt` | 50 | Fails: incomplete UTF-8 sequence | GNU counts bytes |
| `busybox head -c 50 hindi.txt` | 50 | Fails: incomplete UTF-8 sequence | BusyBox counts bytes |
| Python UTF-8 alternative below | 150 | Passes | 50 Unicode code points |

GNU and BusyBox produced identical 50-byte prefixes for this input. Both split a multi-byte UTF-8 character, so the resulting byte sequence is not valid UTF-8.

## Character-safe alternative

Run Python in explicit UTF-8 mode by decoding the input bytes and then encoding the selected text back to UTF-8:

```bash
python3 -c 'import sys; text=sys.stdin.buffer.read().decode("utf-8"); sys.stdout.buffer.write(text[:50].encode("utf-8"))' < hindi.txt
```

With `LC_ALL=C.UTF-8`, `wc -m` reported exactly 50 characters for this output. The output was 150 bytes and passed the `iconv` validation. This counts Unicode code points, not user-perceived grapheme clusters; a character made from a base letter plus combining marks can contain more than one code point.

## Automated check

Run from the repository root:

```bash
bash work/R01-T018/check.sh
```

The check verifies that GNU and BusyBox each emit 50 bytes, both outputs fail UTF-8 validation, both outputs match, and the Python alternative contains exactly 50 locale-counted characters and passes UTF-8 validation.

## Actual check output

```text
PASS: GNU head -c 50 outputs 50 bytes and splits a UTF-8 character.
PASS: BusyBox head -c 50 matches GNU and also splits a UTF-8 character.
PASS: Python alternative outputs exactly 50 characters (C.UTF-8 locale), valid UTF-8.
```

## Conclusion

The `-c` option is byte-oriented in both GNU `head` and BusyBox `head`. For UTF-8 text where a character-safe prefix is required, decode the text as UTF-8 and select the first 50 code points (or use a verified locale-aware character-processing tool).
