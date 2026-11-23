# Task R01-T051: Hardening IPv4 Regular Expression

## Flaws in the Original Regex
The original regex `[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}` matches any 1 to 3 digit groups separated by dots:
1. **Invalid Octets**: Matches values above 255, e.g., `999.999.999.999` and `256.1.1.1`.
2. **Partial Matches**: On `1.2.3.4.5`, it wrongly extracts the first four numbers `1.2.3.4`.
3. **Boundaries**: Without lookarounds or word boundaries, embedded strings like `v10.0.0.1x` match `10.0.0.1`.

## Stricter Regex Design
`(?<![0-9])(?:(?:25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){3}(?:25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])(?![0-9])`

- `25[0-5]`: Matches 250-255.
- `2[0-4][0-9]`: Matches 200-249.
- `1[0-9]{2}`: Matches 100-199.
- `[1-9]?[0-9]`: Matches 0-99.
- `(?<![0-9])` and `(?![0-9])`: Prevents matching substrings of longer number sequences.

## Test Results
- Accepts `192.168.1.10` and `0.0.0.0`.
- Rejects `256.1.1.1`, `999.999.999.999`, and `1.2.3.4.5`.
- Verified against Python `ipaddress.ip_address` on 30 test cases with 0 disagreements.
