# R01-T025: Fix the 'Pass variable' awk entry

## 1. Analysis of the Original Command

The original README recipe at line 846 was:
```bash
a=bbo;b=obb;
awk -v a="$a" -v b="$b" "$1==a && $10=b" filename
```

This recipe suffers from two distinct and serious bugs:

### Bug 1: Double Quotes Trigger Shell Parameter Expansion
Because the awk expression is enclosed in double quotes (`"..."`), the shell attempts parameter expansion on `$1` and `$10` before `awk` is ever invoked.

Running with `set -x` in bash demonstrates this:
```bash
$ set -x
$ a=bbo; b=obb; awk -v a="$a" -v b="$b" "$1==a && $10=b" fixture.txt
+ a=bbo
+ b=obb
+ awk -v a=bbo -v b=obb '==a && =b' fixture.txt
awk: syntax error at source line 1
 context is
	 >>> == <<< 
awk: bailing out at source line 1
```
- In an interactive shell or script without positional arguments, `$1` and `$10` expand to empty strings, resulting in the malformed awk script `'==a && =b'`.
- If positional parameters `$1` (e.g. `arg1`) were set in a surrounding shell script, `$10` expands to `${1}0` (`arg10`), injecting arbitrary shell values into the awk program text.

### Bug 2: Assignment Operator (`=`) Instead of Comparison (`==`)
In awk:
- `==` is the equality comparison operator.
- `=` is the assignment operator.

In the original expression `$10=b`, awk assigns the value of variable `b` into field 10 (`$10`). Because assignment expressions evaluate to the assigned value, if `b` is non-empty (`"obb"`), the expression evaluates to truthy for any line matching `$1==a`, mutating column 10 rather than validating it.

## 2. The Solution

Use single quotes (`'...'`) to prevent shell expansion, and use `==` for comparison:
```bash
a=bbo;b=obb;
awk -v a="$a" -v b="$b" '$1==a && $10==b' filename
```

## 3. Fixture Validation

With `fixture.txt`:
```text
bbo c2 c3 c4 c5 c6 c7 c8 c9 obb
bbo c2 c3 c4 c5 c6 c7 c8 c9 nomatch
nomatch c2 c3 c4 c5 c6 c7 c8 c9 obb
bbo c2 c3 c4 c5 c6 c7 c8 c9 obb
other c2 c3 c4 c5 c6 c7 c8 c9 other
```

Running the fixed command:
```bash
$ a=bbo; b=obb; awk -v a="$a" -v b="$b" '$1==a && $10==b' fixture.txt
bbo c2 c3 c4 c5 c6 c7 c8 c9 obb
bbo c2 c3 c4 c5 c6 c7 c8 c9 obb
```
Only lines 1 and 4 (where column 1 is `bbo` AND column 10 is `obb`) are selected, with record fields preserved unmutated.
