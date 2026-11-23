# Task R01-T056: Comparing !$, $_, and Alt + .

## Behavioral Comparison
1. `!$`: History expansion token for the last argument of the preceding history line.
   - **Context**: Interactive shells only (`set -H`). Disabled in non-interactive scripts.
2. `$_`: Special shell parameter set to the last argument of the previous command executed in the current environment.
   - **Context**: Works in both interactive shells AND non-interactive shell scripts.
3. `Alt + .` / `Esc .`: GNU Readline shortcut `yank-last-arg`.
   - **Context**: Interactive terminal input line before command execution.

## Divergence Case (Pipelines & Redirections)
Consider:
`cat file.txt | grep target`
- `!$` expands to `target` (the last token of the command line).
- `$_` in bash after a pipeline expands to `target`.
However, after redirection:
`echo hello > output.txt`
- `!$` expands to `output.txt`.
- `$_` expands to `output.txt`.
If history expansion is disabled (`set +H`), `!$` is treated as a literal string `!$`, while `$_` continues to work seamlessly!
