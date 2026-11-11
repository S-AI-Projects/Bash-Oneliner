#!/usr/bin/env bash

foo=bar; printf '%s\n' "$foo"
foo=bar; printf '%s\n' '$foo'
foo=bar; printf '%s\n' "'$foo'"
foo=bar; printf '%s\n' \$foo
printf '%s\n' $'first\nsecond'
unset missing_var; printf '<%s>\n' "$missing_var"
unset missing_var; printf '%s\n' '$missing_var'
foo=world; printf '%s\n' "She said: \"hello, $foo\""
