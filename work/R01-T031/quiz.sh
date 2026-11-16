#!/usr/bin/env bash
# Quiz script for R01-T031: Predict pwd and exit status with && and ||

BASE=$(mktemp -d)
trap 'rm -rf "$BASE"' EXIT

run_q() {
  local q_num="$1"
  local cmd="$2"
  local workdir="$BASE/q$q_num"
  mkdir -p "$workdir"
  (
    cd "$workdir"
    mkdir -p d1 d2
    set +e
    eval "$cmd"
    st=$?
    curr=$(pwd)
    rel=${curr#$workdir}
    [ -z "$rel" ] && rel="/"
    echo "Q$q_num: pwd=$rel exit=$st"
  )
}

run_q 1 "cd d1 && cd ../nonexistent 2>/dev/null || cd d2 2>/dev/null"
run_q 2 "cd x 2>/dev/null || { mkdir -p x && cd x; }"
run_q 3 "cd sub 2>/dev/null || ( mkdir -p sub && cd sub )"
run_q 4 "cd d1 || mkdir -p d1 && touch in_d1.txt"
run_q 5 "false && { cd d1 && touch file; } || cd d1"
