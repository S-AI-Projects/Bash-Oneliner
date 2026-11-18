#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-all}"

normalise_users() {
  local input="${1:-$(users)}"
  printf '%s\n' "$input" | tr ' ' '\n' | sort -u | grep -v '^$' || true
}

normalise_who() {
  local input="${1:-$(who)}"
  printf '%s\n' "$input" | awk '{print $1}' | sort -u | grep -v '^$' || true
}

normalise_loginctl() {
  local input="$1"
  printf '%s\n' "$input" | awk '$1 ~ /^[0-9]+$/ && NF == 2 {print $2}' | sort -u | grep -v '^$' || true
}

case "$MODE" in
  users)
    if [ ! -t 0 ]; then
      normalise_users "$(cat)"
    else
      normalise_users "$(users)"
    fi
    ;;
  who)
    if [ ! -t 0 ]; then
      normalise_who "$(cat)"
    else
      normalise_who "$(who)"
    fi
    ;;
  loginctl)
    if [ ! -t 0 ]; then
      normalise_loginctl "$(cat)"
    elif command -v loginctl >/dev/null 2>&1; then
      normalise_loginctl "$(loginctl list-users)"
    else
      echo "loginctl not available on this host" >&2
      exit 0
    fi
    ;;
  all)
    echo "--- Normalised 'users' ---"
    u_out=$(normalise_users "$(users)")
    echo "$u_out"

    echo "--- Normalised 'who' ---"
    w_out=$(normalise_who "$(who)")
    echo "$w_out"

    if [ "$u_out" != "$w_out" ]; then
      echo "Mismatch between normalised users and who!" >&2
      exit 1
    fi
    echo "Users and Who match!"

    if command -v loginctl >/dev/null 2>&1; then
      echo "--- Normalised 'loginctl' ---"
      l_out=$(normalise_loginctl "$(loginctl list-users)")
      echo "$l_out"
      if [ "$u_out" != "$l_out" ]; then
        echo "Note: loginctl output differs (tracked in NOTES.md)"
      fi
    else
      echo "Note: loginctl unavailable in this environment (macOS/non-systemd)"
    fi
    ;;
  *)
    echo "Usage: $0 [users|who|loginctl|all]" >&2
    exit 1
    ;;
esac
