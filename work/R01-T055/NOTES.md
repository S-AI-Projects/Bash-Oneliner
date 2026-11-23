# Task R01-T055: GNU sed first~step Address Specification & Portable awk Alternative

## GNU sed first~step Address Behavior on seq 10
- `0~3p`: Lines 3, 6, 9.
- `1~3p`: Lines 1, 4, 7, 10.
- `0~1p`: All lines (1 through 10).
- `5~3p`: Lines 5, 8.
- `2~0p`: Prediction: Step 0 is invalid or prints only line 2. GNU sed treats step 0 as error or single match on line 2 depending on version.

## Portable awk Equivalents
- `sed -n '0~3p'` == `awk 'NR%3==0'`
- `sed -n '1~3p'` == `awk 'NR%3==1'`
- `sed -n '1~2p'` == `awk 'NR%2==1'` (odd lines)
- `sed -n '0~2p'` == `awk 'NR%2==0'` (even lines)
