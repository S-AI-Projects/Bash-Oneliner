#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"

diff -u "$SCRIPT_DIR/answers.txt" <(bash "$SCRIPT_DIR/quiz.sh")

echo "PASS: All 8 answers match."
