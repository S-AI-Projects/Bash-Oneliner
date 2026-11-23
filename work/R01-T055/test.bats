#!/usr/bin/env bats

@test "awk NR%3==0 matches expected 3 6 9 on seq 10" {
  run awk 'NR%3==0' <(seq 10)
  [ "$status" -eq 0 ]
  [ "$output" = $'3
6
9' ]
}

@test "awk NR%3==1 matches expected 1 4 7 10 on seq 10" {
  run awk 'NR%3==1' <(seq 10)
  [ "$status" -eq 0 ]
  [ "$output" = $'1
4
7
10' ]
}

@test "awk NR%1==0 matches all 10 lines" {
  run awk 'NR%1==0' <(seq 10)
  [ "$status" -eq 0 ]
  [ "$output" = "$(seq 10)" ]
}

@test "file shorter than step returns empty" {
  run awk 'NR%5==0' <(seq 3)
  [ "$status" -eq 0 ]
  [ "$output" = "" ]
}

@test "awk NR>=5 && (NR-5)%3==0 matches 5~3p on seq 10" {
  run awk 'NR>=5 && (NR-5)%3==0' <(seq 10)
  [ "$status" -eq 0 ]
  [ "$output" = $'5
8' ]
}
