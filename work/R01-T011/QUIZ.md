# Bash Quoting Quiz — R01-T011

Predict the exact output of each command before running it.

## Question 1: Double quotes
```bash
foo=bar; printf '%s\n' "$foo"
```

## Question 2: Single quotes
```bash
foo=bar; printf '%s\n' '$foo'
```

## Question 3: Nested quotes
```bash
foo=bar; printf '%s\n' "'$foo'"
```

## Question 4: Escaped dollar sign
```bash
foo=bar; printf '%s\n' \$foo
```

## Question 5: ANSI-C quoting
```bash
printf '%s\n' $'first\nsecond'
```

## Question 6: Unset variable in double quotes
```bash
unset missing_var; printf '<%s>\n' "$missing_var"
```

## Question 7: Unset variable name in single quotes
```bash
unset missing_var; printf '%s\n' '$missing_var'
```

## Question 8: Escaped nested double quotes
```bash
foo=world; printf '%s\n' "She said: \"hello, $foo\""
```
