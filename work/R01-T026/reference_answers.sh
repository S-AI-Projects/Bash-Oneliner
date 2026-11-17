#!/usr/bin/env bash
# Reference solutions for R01-T026 Quiz

solve_ex1() {
  sed 's/A-[^-]*-e//g'
}

solve_ex2() {
  sed 's/A-[0-9]\+-e//g'
}

solve_ex3() {
  awk '{ gsub(/A-[^-]*-e/, ""); print }'
}

solve_ex4() {
  sed 's/<[^>]*>//g'
}

solve_ex5() {
  sed 's/\[[^]]*\]//g'
}

solve_ex6() {
  sed 's/A-\([^-]*\)-e/B-\1-f/g'
}
