# R01-T026: Regex Matching Quiz - Avoiding Greedy Wildcards

## Exercise 1: Strip delimited tokens with negated character class
- **Problem:** Remove each `A-*-e` token without removing the delimiter or text between tokens.
- **Input:** `start A-1-e middle A-2-e end`
- **Expected Output:** `start  middle  end`
- **Technique:** `sed 's/A-[^-]*-e//g'`

## Exercise 2: Match only numeric token variants
- **Problem:** Remove tokens where the middle component consists strictly of one or more digits (`A-<digits>-e`), leaving non-numeric tokens untouched.
- **Input:** `prefix A-123-e text A-xyz-e keep A-456-e suffix`
- **Expected Output:** `prefix  text A-xyz-e keep  suffix`
- **Technique:** `sed 's/A-[0-9]\+-e//g'`

## Exercise 3: Non-greedy token removal in awk
- **Problem:** Use awk's `gsub()` to strip `A-*-e` tokens non-greedily.
- **Input:** `item1 A-foo-e item2 A-bar-e item3`
- **Expected Output:** `item1  item2  item3`
- **Technique:** `awk '{ gsub(/A-[^-]*-e/, ""); print }'`

## Exercise 4: Strip inline HTML tags
- **Problem:** Remove inline tags `<...>` without removing the content between them.
- **Input:** `<b>bold text</b> and <i>italic text</i>`
- **Expected Output:** `bold text and italic text`
- **Technique:** `sed 's/<[^>]*>//g'`

## Exercise 5: Strip bracketed metadata
- **Problem:** Remove bracketed tags `[...]` without removing text in between.
- **Input:** `[tag1] data [tag2]`
- **Expected Output:** ` data `
- **Technique:** `sed 's/\[[^]]*\]//g'`

## Exercise 6: Transform delimited tokens with backreference
- **Problem:** Transform `A-<id>-e` tokens into `B-<id>-f` preserving the inner ID.
- **Input:** `A-101-e and A-202-e`
- **Expected Output:** `B-101-f and B-202-f`
- **Technique:** `sed 's/A-\([^-]*\)-e/B-\1-f/g'`
