#!/usr/bin/env bats

@test "plain xargs joins lines and normalizes whitespace" {
  run bash -c "printf 'alpha\\nmultiple   spaces\\nomega\\n' | xargs"
  [ "$status" -eq 0 ]
  [ "$output" = "alpha multiple spaces omega" ]
}

@test "plain xargs treats backslashes as escapes" {
  run bash -c "printf 'path\\\\to\\n' | xargs"
  [ "$status" -eq 0 ]
  [ "$output" = "pathto" ]
}

@test "an apostrophe causes an unmatched single quote error and nonzero status" {
  run bash -c "printf 'first\\nit\\047s quoted\\nlast\\n' | xargs"
  [ "$status" -ne 0 ]
  [[ "$output" =~ (unmatched|unterminated).*quote ]]
}

@test "xargs -0 preserves quotes in NUL-delimited arguments" {
  run bash -c "printf 'first\\0it\\047s quoted\\0last\\0' | xargs -0 printf '[%s]\\n'"
  [ "$status" -eq 0 ]
  [ "$output" = $'[first]\n[it\047s quoted]\n[last]' ]
}

@test "paste joins lines while preserving the apostrophe" {
  run bash -c "printf 'first\\nit\\047s quoted\\nlast\\n' | paste -sd' ' -"
  [ "$status" -eq 0 ]
  [ "$output" = "first it's quoted last" ]
}
