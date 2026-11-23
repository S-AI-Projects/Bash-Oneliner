# Task R01-T058: Find -delete Option Order and Size Rounding Rules

## Size Rounding Behavior
In `find`, `-size n` measures in 512-byte blocks or unit prefixes (`k`, `M`, `G`, `c`).
Crucially, when using units without `c` (bytes), find rounds sizes UP to the unit boundary:
- `-size -1k` matches files with size strictly less than 1 kilobyte block, which after integer rounding rounds down to 0 blocks! Thus `-size -1k` matches ONLY 0-byte (empty) files!
- To match files between 0 and 1023 bytes, one must use exact character/byte counts: `-size -1024c`.

## Option Order Pitfall
`find . -delete -name "*.mso"`
Because find evaluates expressions from left to right, placing `-delete` first deletes EVERY file in the directory traversal before evaluating `-name`! Always place `-delete` as the final action.
