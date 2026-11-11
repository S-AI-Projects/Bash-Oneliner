# R01-T012: Bash quick substitution

## Observed behavior

Tested in an interactive GNU Bash 3.2.57 shell on macOS 15.6 (Darwin 25.6.0, arm64), recorded in `session.log`. The assignment asks for Ubuntu 22.04/24.04; this machine is macOS, so these observations document the local shell and are not an Ubuntu test.

- After `echo aaa aaa`, `^aaa^bbb` expands and runs `echo bbb aaa`. The quick substitution changes the first matching `aaa` only.
- After `echo aaa aaa`, `!!:gs/aaa/bbb/` runs `echo bbb bbb`. `!!` selects the previous history event, `:s/aaa/bbb/` substitutes, and `g` applies the substitution throughout that event.
- After `echo xyz`, `^aaa^bbb` prints `bash: :s^aaa^bbb: substitution failed`, because `aaa` is absent from the previous command.
- After `set +H`, Bash history expansion is disabled. The same caret text is treated as an ordinary command and prints `command not found`.

## Bash manual reference

The `HISTORY EXPANSION` section of `man bash` says history expansion is enabled by default for interactive shells and can be disabled with `set +H`. It describes history expansion as happening after a complete line is read and before the shell breaks that line into words. Under `Modifiers`, `s/old/new/` replaces the first occurrence in the selected event, and `g` applies the changes over the entire event line when used with `:s`.

This explains why the syntax works at an interactive prompt: Bash expands the history reference before executing the resulting command. A non-interactive shell does not perform history expansion by default, so `^aaa^bbb` is not a general script substitution command.
