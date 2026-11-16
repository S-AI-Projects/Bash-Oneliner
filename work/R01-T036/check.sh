#!/usr/bin/env bash
# Automated check for R01-T036: Measure what `xargs -P` buys you
# Requirements:
# 1. Assert the -P 5 sleep run takes < 2 s.
# 2. Verify gzip compression under xargs -P produces valid output.
# 3. Demonstrate interleaved-output problem and its fix.
# 4. Check README.md entry (L1059) contains the CPU-bound example with measured time.

set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd -- "$SCRIPT_DIR/../.." && pwd)"

echo "=== R01-T036 Automated Check ==="

# Check 1: Assert -P 5 sleep run takes < 2 seconds
echo "1. Asserting -P 5 sleep run takes < 2 s..."
start_time=$(date +%s)
echo 1 1 1 1 1 | xargs -n 1 -P 5 sleep
end_time=$(date +%s)
elapsed=$(( end_time - start_time ))

echo "   Elapsed time: ${elapsed}s"
if [ "$elapsed" -ge 2 ]; then
  echo "FAIL: Expected -P 5 run to finish in < 2 s, but took ${elapsed}s." >&2
  exit 1
fi
echo "   PASS: -P 5 sleep run took < 2 s (actual: ${elapsed}s)."

# Check 2: Verify real CPU-bound work with gzip using xargs -P
echo "2. Verifying parallel gzip compression with xargs -P..."
TMP_DIR=$(mktemp -d)
trap 'rm -rf "$TMP_DIR"' EXIT

(
  cd "$TMP_DIR"
  # Generate 4 test data files
  for i in 1 2 3 4; do
    echo "test data block $i $(date)" > "data_${i}.txt"
    cp "data_${i}.txt" "orig_${i}.txt"
  done

  # Run parallel gzip compression
  ls data_*.txt | xargs -P 4 -n 1 gzip -k -f

  # Verify all .gz files were created and are valid
  for i in 1 2 3 4; do
    if [ ! -f "data_${i}.txt.gz" ]; then
      echo "FAIL: Expected data_${i}.txt.gz to be created." >&2
      exit 1
    fi
    gzip -t "data_${i}.txt.gz"
  done
  echo "   PASS: Parallel gzip produced valid compressed archives."
)

# Check 3: Interleaved output mitigation
echo "3. Verifying output isolation for parallel jobs..."
(
  cd "$TMP_DIR"
  printf "%s\n" 1 2 3 4 | xargs -P 4 -n 1 sh -c 'echo "output from job $1" > "job_$1.out"' _
  for i in 1 2 3 4; do
    if [ ! -f "job_${i}.out" ]; then
      echo "FAIL: Missing isolated output file job_${i}.out" >&2
      exit 1
    fi
    if ! grep -q "output from job $i" "job_${i}.out"; then
      echo "FAIL: Content mismatch in job_${i}.out" >&2
      exit 1
    fi
  done
  echo "   PASS: Per-job output redirection successfully isolated outputs."
)

# Check 4: Check README.md entry contains CPU-bound example with measured timing
echo "4. Checking README.md entry..."
entry=$(awk '/^##### Parallel/{on=1; next} on && /^##### /{exit} on' "$REPO_ROOT/README.md")
if [ -z "$entry" ]; then
  echo "FAIL: 'Parallel' entry not found in README.md." >&2
  exit 1
fi

if ! grep -q "gzip" <<<"$entry"; then
  echo "FAIL: README.md does not contain the CPU-bound gzip example." >&2
  exit 1
fi

if ! grep -q "xargs -P" <<<"$entry"; then
  echo "FAIL: README.md does not contain 'xargs -P'." >&2
  exit 1
fi

if ! grep -qi "speedup" <<<"$entry" && ! grep -qi "timing" <<<"$entry" && ! grep -qi "took" <<<"$entry"; then
  echo "FAIL: README.md does not contain timing/speedup comment for the CPU-bound example." >&2
  exit 1
fi

echo "   PASS: README.md entry contains the CPU-bound example with measured timing."

echo ""
echo "Summary: ALL CHECKS PASSED (R01-T036)."
