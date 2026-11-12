#!/usr/bin/env bash
# read_exact.sh - Safely reads a line of input and prints it with exact fidelity
set -euo pipefail

IFS= read -r input || [ -n "$input" ]
printf '%s\n' "$input"
