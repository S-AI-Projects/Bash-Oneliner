#!/usr/bin/env bash
# Automated check for R01-T040: NR vs FNR, and the two-file idiom
# Requirements:
# 1. NOTES.md records syntax error from the README example as written.
# 2. NR_FNR.md shows corrected output for fileA (a,b,c) and fileB (d,e): NR 1-5, FNR 1-3 then 1-2.
# 3. check.sh verifies join (NR==FNR{seen[$1];next} $1 in seen) and anti-join outputs against expected files.
# 4. README L902 / L926 gains the missing '{' and the two-file idiom.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"

echo "=== R01-T040 Automated Check ==="

# Check 1: Verify syntax error on original broken line
echo "1. Checking original buggy line syntax error..."
if awk 'print FILENAME, NR,FNR,$0}' "$SCRIPT_DIR/fileA" "$SCRIPT_DIR/fileB" 2>/dev/null; then
  echo "FAIL: Expected original line to produce syntax error, but it succeeded." >&2
  exit 1
fi
echo "   PASS: Verified original line fails with syntax error."

# Check 2: Verify corrected awk '{print FILENAME, NR, FNR, $0}' on fileA and fileB
echo "2. Checking corrected NR and FNR output on fileA and fileB..."
expected_nr_fnr=$(cat <<'EOF'
fileA 1 1 a
fileA 2 2 b
fileA 3 3 c
fileB 4 1 d
fileB 5 2 e
EOF
)

actual_nr_fnr=$(
  cd "$SCRIPT_DIR"
  awk '{print FILENAME, NR, FNR, $0}' fileA fileB
)

if [ "$actual_nr_fnr" != "$expected_nr_fnr" ]; then
  echo "FAIL: Expected output:" >&2
  echo "$expected_nr_fnr" >&2
  echo "Got:" >&2
  echo "$actual_nr_fnr" >&2
  exit 1
fi
echo "   PASS: Corrected NR (1-5) and FNR (1-3, 1-2) output verified."

# Check 3: Verify two-file join idiom (lines of B that appear in A)
echo "3. Checking two-file join idiom..."
actual_join=$(awk 'NR==FNR{seen[$1]; next} $1 in seen' "$SCRIPT_DIR/rosterA.txt" "$SCRIPT_DIR/rosterB.txt")
expected_join=$(cat "$SCRIPT_DIR/expected_join.txt")

if [ "$actual_join" != "$expected_join" ]; then
  echo "FAIL: Join output mismatch. Expected:" >&2
  echo "$expected_join" >&2
  echo "Got:" >&2
  echo "$actual_join" >&2
  exit 1
fi
echo "   PASS: Join output matches expected_join.txt ('bob', 'dave')."

# Check 4: Verify two-file anti-join idiom (lines of B that do not appear in A)
echo "4. Checking two-file anti-join idiom..."
actual_antijoin=$(awk 'NR==FNR{seen[$1]; next} !($1 in seen)' "$SCRIPT_DIR/rosterA.txt" "$SCRIPT_DIR/rosterB.txt")
expected_antijoin=$(cat "$SCRIPT_DIR/expected_antijoin.txt")

if [ "$actual_antijoin" != "$expected_antijoin" ]; then
  echo "FAIL: Anti-join output mismatch. Expected:" >&2
  echo "$expected_antijoin" >&2
  echo "Got:" >&2
  echo "$actual_antijoin" >&2
  exit 1
fi
echo "   PASS: Anti-join output matches expected_antijoin.txt ('eve', 'frank')."

# Check 5: Verify README.md entry
echo "5. Checking README.md entry..."
entry=$(awk '/^##### Usage and meaning of NR and FNR/{on=1; next} on && /^##### /{exit} on' "$REPO_ROOT/README.md")
if [ -z "$entry" ]; then
  echo "FAIL: 'Usage and meaning of NR and FNR' entry not found in README.md." >&2
  exit 1
fi

if grep -q "awk 'print FILENAME" <<<"$entry"; then
  echo "FAIL: README.md still contains buggy missing '{' syntax: awk 'print FILENAME" >&2
  exit 1
fi

if ! grep -q "awk '{print FILENAME, NR, FNR, \$0}'" <<<"$entry" && ! grep -q "awk '{print FILENAME, NR,FNR,\$0}'" <<<"$entry"; then
  echo "FAIL: README.md does not contain corrected awk '{print FILENAME, NR, FNR, \$0}'." >&2
  exit 1
fi

if ! grep -q "NR==FNR" <<<"$entry"; then
  echo "FAIL: README.md does not explain the NR==FNR two-file idiom." >&2
  exit 1
fi

echo "   PASS: README.md contains the fixed opening '{' and the two-file idiom."

echo ""
echo "Summary: ALL CHECKS PASSED (R01-T040)."
