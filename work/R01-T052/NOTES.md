# Task R01-T052: Portability of \s in sed and CRLF Blank Line Handling

## Summary of Findings

| Command Pattern | GNU sed | BusyBox sed | BSD sed | Handles CRLF (`\r\n`) | Portability Status |
| --- | --- | --- | --- | --- | --- |
| `sed '/^\s*$/d'` | Removes empty & whitespace lines | Fails / does not recognize `\s` | Does not recognize `\s` | Yes (in GNU) | Non-portable (GNU extension) |
| `sed '/^$/d'` | Removes strictly 0-byte lines | Removes strictly 0-byte lines | Removes strictly 0-byte lines | **No** (leaves `\r` blank line) | POSIX compliant, but misses CRLF & whitespace |
| `sed '/^[[:space:]]*$/d'` | Removes all empty, whitespace, & CRLF lines | Removes all empty, whitespace, & CRLF lines | Removes all empty, whitespace, & CRLF lines | **Yes** (`\r` is in `[:space:]`) | **Fully Portable (POSIX)** |

## CRLF Line Behavior
Windows CRLF line endings end with `\r\n`. In standard Unix utilities, line-break is `\n`, leaving `\r` at the end of the line.
Because `^$` checks for immediate end-of-line after start, `\r$` does not match `^$` and CRLF empty lines are preserved!
In contrast, POSIX `[[:space:]]` includes space, tab, `\r`, `\n`, `\v`, and `\f`. Thus `/^[[:space:]]*$/d` seamlessly removes CRLF blank lines across all platforms!
