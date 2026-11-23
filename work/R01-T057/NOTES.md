# Task R01-T057: Teaching comm with Class Rosters

## Unsorted Warning & Resolution
When files are not sorted, `comm` fails with:
`comm: file 1 is not in sorted order`
Resolution: Always pre-sort inputs with `sort -u` or use process substitution:
`comm <(sort -u rosterA.txt) <(sort -u rosterB.txt)`

## Comm Columns
- Column 1: Lines unique to File 1.
- Column 2: Lines unique to File 2.
- Column 3: Lines common to both files.
Options `-1`, `-2`, `-3` suppress the respective columns. E.g., `-12` shows only Column 3 (common lines).
