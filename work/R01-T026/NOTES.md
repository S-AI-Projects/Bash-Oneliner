# R01-T026: Teach Greedy Matching with `.*`

## 1. The Greedy Quantifier Problem

The original README recipe at line 817 uses:
```bash
sed 's/A-.*-e//g' filename
```

In standard regular expressions, the `*` quantifier is **greedy**: it matches as many characters as possible up to the *final* matching token in the entire line, rather than stopping at the first one.

### Demonstration
Consider the input string:
```text
A-1-e x A-2-e
```

Running the original command:
```bash
$ echo 'A-1-e x A-2-e' | sed 's/A-.*-e//g'

```
Output is empty (`""`), because `A-.*-e` matched:
- Starting at the first `A-`
- `.*` consumed `1-e x A-2` (including the `x` and separators!)
- Ending at the final `-e`

Everything from the first `A-` to the second `-e` was removed, unintentionally destroying the text ` x ` between the two tokens.

## 2. Non-Greedy Matching in POSIX Basic Regular Expressions

Standard POSIX BRE/ERE tools like `sed` do not support Perl-style non-greedy quantifiers (`.*?`). Instead, non-greedy matching is accomplished using **negated character classes**:

### Solution: Match anything except the closing delimiter
```bash
sed 's/A-[^-]*-e//g' filename
```
- `A-`: Matches the starting prefix.
- `[^-]*`: Matches zero or more characters that are **not** a hyphen `-`. Because it cannot cross a hyphen, it cannot overshoot the closing `-e` of the current token.
- `-e`: Matches the ending suffix.

Running on the test string:
```bash
$ echo 'A-1-e x A-2-e' | sed 's/A-[^-]*-e//g'
 x 
```
The individual tokens `A-1-e` and `A-2-e` are removed, while ` x ` is correctly preserved.
