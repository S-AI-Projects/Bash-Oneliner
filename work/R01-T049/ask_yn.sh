#!/usr/bin/env bash

while true; do
    answer=

    # -r: read literally; -s: hide input; -p: show prompt;
    # -n1: read one character; -t 5: time out after 5 seconds.
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
