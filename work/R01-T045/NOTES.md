# R01-T045 — Make `!!` safe to use

## Environment
- OS: Ubuntu-based GitHub Codespaces
- Shell: GNU Bash 5.2.21
- Recording: `session.log`

## History expansion demonstrations

The recorded session demonstrates:

- `!!` — repeats the previous command.
- `!!:p` — prints the expanded command without executing it.
- `!!:s/world/bash/` — substitutes `world` with `bash` in the previous command.
- `!!:0` — extracts the first word (the command name).
- `!!:$` — extracts the last argument. In the demonstration, it extracted `beta`, which Bash then tried to run as a command.

## Using `histverify`

Enabled with:

```bash
shopt -s histverify
```
The recorded session showed that entering `sudo !!` expanded the previous
command to `sudo echo safety-check` on the input line for review. It was
cancelled with Ctrl+C and was not executed.

## One risk of `sudo !!`

`sudo !!` repeats the entire previous command with elevated privileges.
If the previous command was mistyped or had unintended arguments, repeating
it with `sudo` could cause unintended system-level changes.

Preview the expansion with `!!:p` before running it. Enabling `histverify`
provides another opportunity to inspect and edit the expanded command.

## Evidence

`session.log` contains the interactive demonstrations, including the
history modifiers and the `histverify` behaviour.
