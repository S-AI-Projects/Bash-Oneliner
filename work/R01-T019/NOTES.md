# R01-T019: Test what plain `xargs` does to its input

## Environment

Reproduced on macOS 15.6 (Darwin 25.6.0, arm64), using the system BSD `xargs` and `paste`, Bash 3.2.57, and Bats 1.14.0. The issue's automated check is `bats work/R01-T019/test.bats`.

## Findings (`man xargs`)

The manual says plain `xargs` reads whitespace-delimited strings; quotes and backslashes let whitespace be embedded in arguments. As a result, it parses those characters rather than preserving them as ordinary input. With `alpha`, `multiple   spaces`, and `omega` on separate lines, plain `xargs` outputs one line, `alpha multiple spaces omega`: it joins lines with spaces and collapses repeated spaces. A backslash escapes the next character, so `path\\to` is passed as `pathto`.

An apostrophe starts single-quote syntax. If the input contains `it's quoted` without a closing apostrophe, `xargs` reports an unterminated/unmatched quote and exits nonzero (status 1 on this macOS system). GNU xargs uses the wording “unmatched single quote.”

`xargs -0` switches the input separator to NUL, so quote and backslash characters inside each NUL-delimited argument are literal. The Bats test shows the apostrophe intact. This is useful for NUL-delimited argument lists, such as `find -print0` output.

`paste -sd' ' file` joins the lines in a file with spaces, preserving the apostrophe (and other punctuation) as ordinary text. It is the safe choice here when the goal is to join text lines without xargs quote parsing.

The fixtures and checks use `printf` generated input, never `ls -l` output, so names, spacing, and punctuation are deterministic.
