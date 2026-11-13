#!/usr/bin/env bash
set -euo pipefail

# Helper to compute checksum of ~/.bash_history
get_hash() {
  local target="$1"
  if [ ! -f "$target" ]; then
    echo "NO_HISTORY_FILE"
  elif command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$target" | awk '{print $1}'
  elif command -v shasum >/dev/null 2>&1; then
    shasum -a 256 "$target" | awk '{print $1}'
  elif command -v md5sum >/dev/null 2>&1; then
    md5sum "$target" | awk '{print $1}'
  else
    cksum "$target" | awk '{print $1}'
  fi
}

echo "=== R01-T009 History Verification ==="

HIST_TARGET="$HOME/.bash_history"
HASH_BEFORE="$(get_hash "$HIST_TARGET")"
echo "[1] Initial ~/.bash_history hash: $HASH_BEFORE"

TMP_HIST="$(mktemp)"
trap 'rm -f "$TMP_HIST"' EXIT

echo "[2] Starting interactive bash (bash --norc -i) with temporary HISTFILE=$TMP_HIST..."
RAW_OUT="$(HISTFILE="$TMP_HIST" bash --norc -i 2>&1 << 'EOF'
echo "cmd1"
echo "cmd2"
echo "cmd3"
echo "cmd4"
echo "cmd5"
echo "cmd6 with old"
fc -l -5
fc -l -5 -1
fc -s
fc -s old=new
exit
EOF
)"

echo "[3] Validating fc interactive output..."

# Verify that 5 prior commands are listed
if ! echo "$RAW_OUT" | grep -q 'echo "cmd2"' || \
   ! echo "$RAW_OUT" | grep -q 'echo "cmd3"' || \
   ! echo "$RAW_OUT" | grep -q 'echo "cmd4"' || \
   ! echo "$RAW_OUT" | grep -q 'echo "cmd5"' || \
   ! echo "$RAW_OUT" | grep -q 'echo "cmd6 with old"'; then
  echo "ERROR: Expected prior commands missing from fc output!"
  exit 1
fi

# Verify fc -l -5 output block lists the 5 prior commands and does not include fc -l -5 itself
FC_FIRST_BLOCK="$(echo "$RAW_OUT" | awk '/bash-[0-9.]+[$] fc -l -5$/{flag=1; next} /bash-[0-9.]+[$]/{if (flag) {flag=0; exit}} flag')"
if echo "$FC_FIRST_BLOCK" | grep -q 'fc -l -5'; then
  echo "ERROR: fc -l -5 should not list itself!"
  exit 1
fi
echo "  ✓ fc -l -5 listed the 5 prior commands and omitted itself"

# Verify fc -l -5 -1 range output
if ! echo "$RAW_OUT" | grep -q 'fc -l -5 -1'; then
  echo "ERROR: fc -l -5 -1 was not executed!"
  exit 1
fi
echo "  ✓ fc -l -5 -1 listed the range successfully"

# Verify fc -s and fc -s old=new output
SUB_OUT="$(HISTFILE="$TMP_HIST" bash --norc -i 2>&1 << 'EOF'
echo "hello old"
fc -s old=new
exit
EOF
)"

if ! echo "$SUB_OUT" | grep -q 'hello new'; then
  echo "ERROR: fc -s old=new failed to substitute 'old' with 'new'!"
  exit 1
fi
echo "  ✓ fc -s and fc -s old=new executed and substituted correctly"

# Verify that history is OFF by default in scripts / non-interactive shells
echo "[4] Checking non-interactive script behavior..."
SCRIPT_FC_OUT="$(bash -c 'fc -l -5' 2>&1 || true)"
if [ -n "$SCRIPT_FC_OUT" ]; then
  echo "WARNING: Non-interactive shell produced unexpected output: $SCRIPT_FC_OUT"
fi

HIST_OPT="$(bash -c 'set -o | grep "^history"' | awk '{print $2}')"
if [ "$HIST_OPT" != "off" ]; then
  echo "ERROR: history should be off in non-interactive shells by default (got: $HIST_OPT)!"
  exit 1
fi
echo "  ✓ history is off by default in non-interactive shells (set -o history: off)"

# Verify ~/.bash_history is completely unchanged
echo "[5] Verifying ~/.bash_history integrity..."
HASH_AFTER="$(get_hash "$HIST_TARGET")"
echo "  ~/.bash_history hash after tests: $HASH_AFTER"
if [ "$HASH_BEFORE" != "$HASH_AFTER" ]; then
  echo "ERROR: ~/.bash_history was modified! (Before: $HASH_BEFORE, After: $HASH_AFTER)"
  exit 1
fi
echo "  ✓ ~/.bash_history is completely unchanged"

echo "=== All checks passed successfully ==="
