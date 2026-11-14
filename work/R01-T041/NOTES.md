# R01-T041 — When tee fails

## Environment
- OS: Ubuntu 24.04.5 LTS (GitHub Codespaces)
- Shell: GNU Bash 5.2.21
- Tool: GNU coreutils `tee`

## 1. When tee cannot write

Command:

```bash
mkdir -p /tmp/tee-experiment/ro
chmod 500 /tmp/tee-experiment/ro
echo hi | tee /tmp/tee-experiment/ro/out.txt
echo $?
```

Observed output:

```text
tee: /tmp/tee-experiment/ro/out.txt: Permission denied
hi
1
```

`tee` reports the write error and exits with status 1. It still prints the input to standard output.

To check the individual exit statuses of both commands in the pipeline:

Command:

```bash
echo hi | tee /tmp/tee-experiment/ro/out.txt
printf 'PIPESTATUS: %s\n' "${PIPESTATUS[*]}"
```

Observed output:

```text
tee: /tmp/tee-experiment/ro/out.txt: Permission denied
hi
PIPESTATUS: 0 1
```

`PIPESTATUS` shows `0 1`: `echo` succeeded, while `tee` failed.

## 2. Pipeline status without pipefail

Commands:

```bash
false | tee out.txt
echo $?
```

Observed exit status: `0`.

By default, Bash uses the exit status of the last command in a pipeline. Since `tee` succeeded, the pipeline reports 0 even though `false` failed.

## 3. Pipeline status with pipefail

Commands:

```bash
set -o pipefail
false | tee out.txt
echo $?
```

Observed exit status: `1`.

With `pipefail`, the pipeline returns a non-zero status when a command in it fails.

## 4. Individual command statuses

Commands:

```bash
false | tee out.txt
printf 'PIPESTATUS: %s\n' "${PIPESTATUS[*]}"
```

Observed output:

```text
PIPESTATUS: 1 0
```

`false` returned 1 and `tee` returned 0. `PIPESTATUS` must be read immediately after the pipeline.

## 5. tee append and multiple files

Commands:

```bash
echo first | tee out1.txt out2.txt
echo second | tee -a out1.txt out2.txt
cat out1.txt
cat out2.txt
```

Both files contained:

```text
first
second
```

`tee` can write to multiple files. The `-a` option appends instead of overwriting.