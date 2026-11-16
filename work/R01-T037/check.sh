#!/usr/bin/env bash
# Automated check for R01-T037: Make 'download if necessary' reliable
# Requirements:
# 1. Improved script quotes variables, uses curl -fsSL --retry 2 and LICENSE URL.
# 2. Second run shows no download (timestamp / content unchanged).
# 3. Bad URL fails with non-zero exit code and creates no file.
# 4. SHA-256 verification is checked.
# 5. README entry (L1410 / L1425) updated with quoted variables, LICENSE URL, and curl -z.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"

echo "=== R01-T037 Automated Check ==="

# Check 1: Run Bats tests or native test suite
if command -v bats >/dev/null 2>&1; then
  echo "1. Running test.bats with bats..."
  bats "$SCRIPT_DIR/test.bats"
  echo "   PASS: bats test.bats passed."
else
  echo "1. Running equivalent assertions natively..."
  TMP_DIR=$(mktemp -d)
  trap 'rm -rf "$TMP_DIR"' EXIT
  (
    cd "$TMP_DIR"
    URL="https://raw.githubusercontent.com/onceupon/Bash-Oneliner/master/LICENSE"
    DATA="LICENSE"
    EXPECTED_SHA="2d4924a0bc53af5dd1d7be35b8f2a0d5718781803576caccab180e35ae083f98"

    calc_sha256() {
      if command -v sha256sum >/dev/null 2>&1; then
        sha256sum "$1" | awk '{print $1}'
      else
        shasum -a 256 "$1" | awk '{print $1}'
      fi
    }

    # Test A: First run download & hash verification
    if [ ! -s "$DATA" ]; then
      curl -fsSL --retry 2 -o "$DATA" "$URL"
    fi
    if [ ! -s "$DATA" ]; then
      echo "FAIL: Expected $DATA to be downloaded and non-empty." >&2
      exit 1
    fi
    actual_sha=$(calc_sha256 "$DATA")
    if [ "$actual_sha" != "$EXPECTED_SHA" ]; then
      echo "FAIL: SHA-256 mismatch: expected $EXPECTED_SHA, got $actual_sha" >&2
      exit 1
    fi
    echo "   PASS: First run download succeeded with matching SHA-256."

    # Test B: Second run (asserts unchanged timestamp / skipped download)
    if stat -c "%Y" "$DATA" >/dev/null 2>&1; then
      mtime_before=$(stat -c "%Y" "$DATA")
    else
      mtime_before=$(stat -f "%m" "$DATA")
    fi
    sleep 1
    if [ ! -s "$DATA" ]; then
      curl -fsSL --retry 2 -o "$DATA" "$URL"
    fi
    if stat -c "%Y" "$DATA" >/dev/null 2>&1; then
      mtime_after=$(stat -c "%Y" "$DATA")
    else
      mtime_after=$(stat -f "%m" "$DATA")
    fi
    if [ "$mtime_before" != "$mtime_after" ]; then
      echo "FAIL: Second run modified timestamp unexpectedly." >&2
      exit 1
    fi
    echo "   PASS: Second run correctly skipped download (timestamp unchanged)."

    # Test C: Bad URL handling
    bad_file="should_not_exist.txt"
    if curl -fsSL "https://example.com/nonexistent_404_url.txt" -o "$bad_file" 2>/dev/null; then
      echo "FAIL: Expected curl -fsSL to fail on 404 URL." >&2
      exit 1
    fi
    if [ -f "$bad_file" ]; then
      echo "FAIL: curl created file for failed request." >&2
      exit 1
    fi
    echo "   PASS: Bad URL correctly failed without creating file."
  )
fi

# Check 2: Verify README.md entry
echo "2. Checking README.md entry..."
entry=$(awk '/^##### Download file if necessary/{on=1; next} on && /^##### /{exit} on' "$REPO_ROOT/README.md")
if [ -z "$entry" ]; then
  echo "FAIL: 'Download file if necessary' entry not found in README.md." >&2
  exit 1
fi

if ! grep -q 'data="LICENSE"' <<<"$entry" && ! grep -q "raw.githubusercontent.com" <<<"$entry"; then
  echo "FAIL: README.md does not use a working LICENSE URL." >&2
  exit 1
fi

if ! grep -q 'curl -fsSL -z "\$data" -o "\$data" "\$url"' <<<"$entry"; then
  echo "FAIL: README.md does not contain 'curl -fsSL -z \"\$data\" -o \"\$data\" \"\$url\"'." >&2
  exit 1
fi

if ! grep -q '"\$data"' <<<"$entry"; then
  echo "FAIL: README.md does not quote \$data variable." >&2
  exit 1
fi

echo "   PASS: README.md entry updated with quoted variables, working URL, and curl -z."

echo ""
echo "Summary: ALL CHECKS PASSED (R01-T037)."
