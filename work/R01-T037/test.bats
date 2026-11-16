#!/usr/bin/env bats
# Tests for R01-T037: Make 'download if necessary' reliable

setup() {
  TEST_DIR="$(mktemp -d)"
  cd "$TEST_DIR"
  URL="https://raw.githubusercontent.com/onceupon/Bash-Oneliner/master/LICENSE"
  DATA="LICENSE"
  EXPECTED_SHA="2d4924a0bc53af5dd1d7be35b8f2a0d5718781803576caccab180e35ae083f98"
}

teardown() {
  rm -rf "$TEST_DIR"
}

calc_sha256() {
  local target="$1"
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$target" | awk '{print $1}'
  else
    shasum -a 256 "$target" | awk '{print $1}'
  fi
}

@test "first run downloads LICENSE, checks non-empty and verifies sha256" {
  [ ! -f "$DATA" ]

  if [ ! -s "$DATA" ]; then
    curl -fsSL --retry 2 -o "$DATA" "$URL"
  fi

  [ -s "$DATA" ]

  actual_sha=$(calc_sha256 "$DATA")
  [ "$actual_sha" = "$EXPECTED_SHA" ]
}

@test "second run skips download and leaves timestamp unchanged" {
  # Perform initial download
  curl -fsSL --retry 2 -o "$DATA" "$URL"
  [ -s "$DATA" ]

  # Record initial modification time and sha256
  if stat -c "%Y" "$DATA" >/dev/null 2>&1; then
    mtime_before=$(stat -c "%Y" "$DATA")
  else
    mtime_before=$(stat -f "%m" "$DATA")
  fi
  sha_before=$(calc_sha256 "$DATA")

  # Small sleep
  sleep 1

  # Second run using the conditional check
  if [ ! -s "$DATA" ]; then
    curl -fsSL --retry 2 -o "$DATA" "$URL"
  fi

  if stat -c "%Y" "$DATA" >/dev/null 2>&1; then
    mtime_after=$(stat -c "%Y" "$DATA")
  else
    mtime_after=$(stat -f "%m" "$DATA")
  fi
  sha_after=$(calc_sha256 "$DATA")

  # Assert timestamp and sha256 remain completely unchanged
  [ "$mtime_before" = "$mtime_after" ]
  [ "$sha_before" = "$sha_after" ]
}

@test "bad URL fails cleanly with non-zero exit code and creates no file" {
  bad_url="https://example.com/nonexistent_file_404_test.txt"
  bad_file="bad_file.txt"

  run curl -fsSL "$bad_url" -o "$bad_file"
  [ "$status" -ne 0 ]
  [ ! -f "$bad_file" ]
}
