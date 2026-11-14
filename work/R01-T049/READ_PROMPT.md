# Bash `read` Options: Safe Prompts

`read` is a Bash builtin that reads input from standard input (stdin).
These examples use Bash.

## 1. `-r` — Read backslashes literally

Without `-r`, backslashes can be treated as escape characters.

```bash
read -r value
printf 'You entered: %s\n' "$value"
```
## 2. `-s` — Silent input

Hides the characters typed by the user. Useful for password prompts.

```bash
read -r -s -p "Enter a secret: " secret
echo
printf 'Input received.\n'
```

The input is stored in `secret` but is not displayed while typing.

## 3. `-p` — Display a prompt

Displays a prompt before reading input.

```bash
read -r -p "What is your name? " name
printf 'Hello, %s!\n' "$name"
```

## 4. `-n1` — Read one character

Stops reading after one character instead of waiting for Enter.

```bash
read -r -n1 -p "Press any key: " key
echo
printf 'A key was received.\n'
```

The character is stored in `key`.

## 5. `$'…'` — Bash ANSI-C quoting

Bash interprets escape sequences inside `$'…'`, such as `\n` for a newline and `\t` for a tab.

```bash
printf '%s' $'First line\nSecond line\n'
```

This prints two lines. It is useful for prompts containing newlines:

```bash
read -r -s -p $'Press any key to continue...\n' -n1 key
```

## 6. `-t 5` — Set a timeout

`-t 5` gives the user five seconds to provide input. If the time expires, `read` returns a non-zero status.

```bash
if read -r -n1 -t 5 -p "Press a key within 5 seconds: " key; then
    echo
    echo "Input received."
else
    echo
    echo "Timed out."
fi
```

## Exercise: Continue? [y/N]

Write `ask_yn.sh` with these requirements:

- Display `Continue? [y/N]`.
- Accept `y` or `Y` and exit with status 0.
- Accept `n`, `N`, or Enter and exit with status 1.
- Allow five seconds for input; timeout means No.
- Any other character should display an error and ask again.

Run the reference solution:

```bash
bash work/R01-T049/ask_yn.sh
```

Run its automated checks:

```bash
bash work/R01-T049/check.sh work/R01-T049/ask_yn.sh
```

## Reference solution

```bash
#!/usr/bin/env bash

while true; do
    answer=

    # -r: preserve backslashes; -s: hide typed input;
    # -n1: read one character; -t 5: wait at most five seconds;
    # -p: display the prompt.
    if ! read -r -s -n1 -t 5 -p "Continue? [y/N] " answer; then
        echo
        exit 1
    fi

    echo
    case "$answer" in
        y|Y) exit 0 ;;
        n|N|"") exit 1 ;;
        *) echo "Please enter y or n." ;;
    esac
done
```

## What changes when stdin is not a terminal?

When input comes from a pipe or redirected file:

- `read` consumes data from that input instead of waiting for keyboard input.
- `-p` does not display its prompt when stdin is not a terminal.
- `-s` cannot hide characters supplied through a pipe; there is no interactive terminal echo to control.
- `-n1` still limits the read to one character.
- `-t 5` can still limit how long `read` waits for input.

For example:

```bash
printf 'y' | bash work/R01-T049/ask_yn.sh
echo $?
```

The script reads `y` from the pipe and exits with status 0.
