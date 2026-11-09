#!/usr/bin/env bash
# Automated check for R01-T001: Correct the 'Show group of user' entry
# Must print the same groups for `groups $USER` and `id -Gn $USER` and exit 0.
# Must print identical group lists for $USER and root.

set -euo pipefail

fail=0

echo "=== R01-T001 Automated Check ==="

target_user="${USER:-$(id -un)}"
users=("$target_user" "root")

for u in "${users[@]}"; do
  echo "Checking user: $u"
  
  # groups output (strip 'username : ' prefix if present, as in GNU coreutils)
  groups_raw=$(groups "$u")
  groups_clean=$(echo "$groups_raw" | sed 's/^.*: *//')
  
  # id -Gn output
  id_clean=$(id -Gn "$u")
  
  echo "  groups: $groups_clean"
  echo "  id -Gn: $id_clean"
  
  if [ "$groups_clean" = "$id_clean" ]; then
    echo "  Result: MATCH (identical group list)"
  else
    echo "  Result: MISMATCH" >&2
    fail=1
  fi
  echo ""
done

if [ $fail -eq 0 ]; then
  echo "Summary: PASSED. 'groups' and 'id -Gn' output identical groups for all tested users."
  exit 0
else
  echo "Summary: FAILED. Output mismatch detected." >&2
  exit 1
fi
