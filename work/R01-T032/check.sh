#!/usr/bin/env bash
# Automated check for R01-T032: What sed -i really does to your files
# Requirements:
# 1. sed -i.bak leaves f.bak identical to original and f without bbo lines.
# 2. Symlink demo shows link replaced by regular file with plain -i and preserved with --follow-symlinks.
# 3. stat output before/after shows inode change.
# 4. test.bats covers backup and both symlink cases; README entry (L643) gains -i.bak and macOS note.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"

echo "=== R01-T032 Automated Check ==="

# Check 1: If bats is installed, run test.bats directly
if command -v bats >/dev/null 2>&1; then
  echo "1. Running test.bats with bats..."
  bats "$SCRIPT_DIR/test.bats"
  echo "   PASS: bats test.bats passed."
else
  echo "1. bats not found in PATH; running equivalent assertions natively..."
  TMP_DIR=$(mktemp -d)
  trap 'rm -rf "$TMP_DIR"' EXIT
  (
    cd "$TMP_DIR"
    
    # Test A: Backup fidelity and line deletion
    cat <<'EOF' > f
apple
bbo line 1
banana
bbo line 2
cherry
EOF
    cp f f.orig
    sed -i.bak '/bbo/d' f
    cmp f.bak f.orig
    if grep -q "bbo" f; then
      echo "FAIL: f still contains bbo" >&2
      exit 1
    fi
    echo "   PASS: sed -i.bak keeps f.bak identical to original and cleans f."

    # Test B: Inode tracking
    if stat -c "%i" f >/dev/null 2>&1; then
      in_before=$(stat -c "%i" f)
      sed -i.bak2 's/apple/orange/' f
      in_after=$(stat -c "%i" f)
      in_bak=$(stat -c "%i" f.bak2)
    else
      in_before=$(stat -f "%i" f)
      sed -i.bak2 's/apple/orange/' f
      in_after=$(stat -f "%i" f)
      in_bak=$(stat -f "%i" f.bak2)
    fi

    if [ "$in_before" = "$in_after" ]; then
      echo "FAIL: Expected inode to change after in-place edit." >&2
      exit 1
    fi
    if [ "$in_before" != "$in_bak" ]; then
      echo "FAIL: Expected backup file to retain original inode." >&2
      exit 1
    fi
    echo "   PASS: Inode change verified (before=$in_before, after=$in_after, bak=$in_bak)."

    # Test C: Symlink behavior
    echo "target data bbo" > target
    ln -s target link
    if sed --version 2>&1 | grep -q "GNU"; then
      sed -i '/bbo/d' link
      if [ -L link ]; then
        echo "FAIL: GNU sed should replace symlink with regular file." >&2
        exit 1
      fi
      echo "   PASS: Plain sed -i replaced symlink with regular file."
    else
      if sed -i '' '/bbo/d' link 2>/dev/null; then
        echo "FAIL: BSD sed unexpectedly edited symlink." >&2
        exit 1
      fi
      echo "   PASS: BSD sed safely rejected editing symlink."
    fi
  )
fi

# Check 2: Verify README.md contains sed -i.bak and macOS note
echo "2. Checking README.md entry..."
entry=$(awk '/^##### Edit infile/{on=1; next} on && /^##### /{exit} on' "$REPO_ROOT/README.md")
if [ -z "$entry" ]; then
  echo "FAIL: 'Edit infile' entry not found in README.md." >&2
  exit 1
fi

if ! grep -q "sed -i.bak" <<<"$entry"; then
  echo "FAIL: README.md does not mention 'sed -i.bak'." >&2
  exit 1
fi

if ! grep -qi "macOS" <<<"$entry"; then
  echo "FAIL: README.md does not include note about macOS." >&2
  exit 1
fi

echo "   PASS: README.md contains 'sed -i.bak' and macOS note."

echo ""
echo "Summary: ALL CHECKS PASSED (R01-T032)."
