# R01-T043 — Fix the xargs -t example

## Environment
- OS: Ubuntu 24.04.5 LTS
- Shell: Bash

## Experiment 1: xargs -t abcd </dev/null

Command:
`xargs -t abcd </dev/null`

Observed output:
- stderr: `abcd`
- error: `xargs: abcd: No such file or directory`

## Experiment 2: echo x | xargs -t abcd

Command:
`echo x | xargs -t abcd`

Observed output:
- stderr: `abcd x`
- error: `xargs: abcd: No such file or directory`

## Correct usage

Command:
`echo abcd | xargs -t`

Observed output:
- stdout: `abcd`
- stderr: `echo abcd`

The -t option prints the command being executed to stderr. It does not
make xargs print its input as output.
