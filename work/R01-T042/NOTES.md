# R01-T042 — Make "sort a row" work without gawk

## Environment
- OS: Ubuntu 24.04.5 LTS (GitHub Codespaces)
- awk implementations: GNU awk, mawk, BusyBox awk
- Test shell: Bash

## 1. Original GNU awk command

Input:
`1<TAB>40<TAB>35<TAB>12<TAB>23`

Command using `gawk` and `asort()`:
- Output: `1<TAB>12<TAB>23<TAB>35<TAB>40`

## 2. Portability results

- `gawk`: successfully sorts the row.
- `mawk`: `mawk: line 2: function asort never defined`
- `busybox awk`: `awk: cmd. line:1: Call to undefined function`

`asort()` is a GNU awk extension and is not available in these other implementations.

## 3. Trailing-tab observation

Using `cat -A`, the GNU awk output was:

`1^I12^I23^I35^I40^I$`

The final `^I` shows that the original command prints a tab after the last value. The portable alternatives omit this unnecessary trailing tab. The values and their order are unchanged.

## 4. Portable alternatives

### POSIX awk insertion sort

Split the row into fields, then use insertion sort with numeric comparisons (`+ 0`). Print tabs only between values.

### External utilities

For each input row:

`tr '\t' '\n' | sort -n | paste -sd '\t' -`

This splits fields, sorts them numerically, and joins them with tabs.

## 5. Three-row verification

Input rows:
- `1 40 35 12 23`
- `5 9 2 18 1`
- `10 3 7 2 6`

Both portable methods produced the same sorted values as the GNU awk reference:

- `1 12 23 35 40`
- `1 2 5 9 18`
- `2 3 6 7 10`

Automated verification is provided by `check.sh`.
