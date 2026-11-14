# R01-T050: Cross-platform prefix one-liner

## Commands tested

```bash
sed 's/^/bbo/' filename
awk '{print "bbo" $0}' filename
```

Both commands prefix each line with bbo.

## CRLF behaviour

Windows-style CRLF files use a carriage return (\r) followed by a
line feed (\n) as the line ending.

Using cat -A displays the carriage return as ^M, so a CRLF line
appears as alpha^M$.

Both sed and awk preserve that carriage return when adding the prefix.
It remains immediately before the line ending.

## Empty lines

Empty lines are also processed. Both commands output bbo on an
otherwise empty line.

## Missing trailing newline

The test checks a file whose last line has no trailing newline.
The expected outputs are separate because GNU sed on Linux preserves
the missing final newline, while BSD sed on macOS appends one.
Awk's print statement adds a newline on both platforms.

## Test environment

Local tests: GitHub Codespaces Linux, Bash.

The GitHub Actions matrix additionally checks ubuntu-latest
and macos-latest.
