# R01-T015: Bash history event and word designators

Tested in an interactive GNU Bash 3.2.57 shell on macOS 15.6 (Darwin 25.6.0, arm64). The recorded session is `session.log`; examples use `history -c` between cases so their history references are deterministic.

| Designator | Meaning | Verified example | Output |
|---|---|---|---|
| `!n` | Recall absolute history event number `n`. | `echo number-target`; then `!1` | `number-target` |
| `!-n` | Recall the command `n` events before the current line. | `echo relative-target`; `echo later`; then `!-2` | `relative-target` |
| `!!` | Recall the previous command; same as `!-1`. | `echo double-target`; then `!!` | `double-target` |
| `!string` | Recall the latest command that begins with `string`. | `echo prefix-target`; then `!echo` | `prefix-target` |
| `!?string?` | Recall the latest command containing `string`. | `echo alpha-needle-omega`; then `!?needle?` | `alpha-needle-omega` |
| `!^` | Insert the first argument of the previous command. | `echo alpha beta`; then `echo !^` | `alpha` |
| `!$` | Insert the last argument of the previous command. | `echo alpha beta`; then `echo !$` | `beta` |
| `!*` | Insert all arguments of the previous command, without its command word. | `echo alpha beta`; then `echo !*` | `alpha beta` |
| `:p` | Print the expanded command without executing it. | `echo no-execute-target`; then `!!:p` | Prints `echo no-execute-target`; the marker is not printed a second time. |
| `shopt -s histverify` | Reload history expansions into the readline input line for review and editing. | After `cat /dev/null`, enable the option and enter `!cat`. | The prompt shows `cat /dev/null` for editing; a second Enter executes it. |

## Safer recall with histverify

After `shopt -s histverify`, entering `!cat` recalls the latest command beginning with `cat` and puts the expanded command back on the input line for editing. In `session.log`, `!cat` expands to `cat /dev/null`; the line is visible at the prompt and only runs after a second Enter. This gives the user a chance to inspect or edit the command before it executes. The `:p` modifier provides a print-only preview without running the expansion.

## Manual reference

The event, word, and modifier meanings were checked against the local `man bash` manual under `HISTORY EXPANSION`.

## Automated check

`bash work/R01-T015/check.sh` feeds examples to `bash -i` through standard input and verifies seven event/word designators plus the print-only behavior.
