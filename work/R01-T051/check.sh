#!/usr/bin/env bash
set -euo pipefail
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

python3 -c "
import ipaddress, re, sys

strict_re = re.compile(r'^(?:(?:25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])\.){3}(?:25[0-5]|2[0-4][0-9]|1[0-9]{2}|[1-9]?[0-9])$')

test_strings = [
    '0.0.0.0', '192.168.1.10', '127.0.0.1', '10.0.0.1', '255.255.255.255',
    '1.1.1.1', '8.8.8.8', '172.16.0.1', '224.0.0.1', '100.64.0.1',
    '198.51.100.1', '203.0.113.1', '192.0.2.1', '169.254.1.1', '192.168.0.1',
    '256.1.1.1', '999.999.999.999', '1.2.3.4.5', '192.168.1.256', '1.2.3.-1',
    '1.2.3.4.com', 'a.b.c.d', '192.168.1', '192.168.1.1.1', '300.0.0.1',
    '192.168.01.1', '01.02.03.04', '1.2.3.256', '10.10.10.256', '256.256.256.256'
]

disagreements = 0
for s in test_strings:
    is_re = bool(strict_re.match(s))
    is_valid = False
    try:
        ipaddress.ip_address(s)
        is_valid = True
    except ValueError:
        is_valid = False
    if is_re != is_valid:
        print(f'Disagreement on {s}: regex={is_re}, ipaddress={is_valid}')
        disagreements += 1

if disagreements != 0:
    print(f'FAILED: {disagreements} disagreements found!')
    sys.exit(1)
print(f'SUCCESS: 30/30 strings matched Python ipaddress module perfectly.')
"

echo "PASS: check.sh completed successfully."
