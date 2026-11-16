#!/usr/bin/env bats
# Tests for R01-T032: What sed -i really does to your files

setup() {
  TEST_DIR="$(mktemp -d)"
  cd "$TEST_DIR"
}

teardown() {
  rm -rf "$TEST_DIR"
}

@test "sed -i.bak leaves backup identical to original and removes matching lines" {
  cat <<'EOF' > f
apple
bbo line 1
banana
bbo line 2
cherry
EOF
  cp f f.orig

  sed -i.bak '/bbo/d' f

  # Backup must be byte-for-byte identical to original
  cmp f.bak f.orig

  # Edited file must not contain 'bbo' lines
  run grep "bbo" f
  [ "$status" -ne 0 ]

  # Remaining lines must be intact
  run grep "apple" f
  [ "$status" -eq 0 ]
  run grep "banana" f
  [ "$status" -eq 0 ]
  run grep "cherry" f
  [ "$status" -eq 0 ]
}

@test "sed -i on a symlink breaks the link into a regular file in GNU sed" {
  echo "initial target data with bbo" > target
  ln -s target link

  # Verify initial state: link is a symlink
  [ -L link ]

  if sed --version 2>&1 | grep -q "GNU"; then
    sed -i '/bbo/d' link

    # In GNU sed without --follow-symlinks, link is replaced by a regular file
    [ ! -L link ]
    [ -f link ]

    # Target remains untouched
    run grep "bbo" target
    [ "$status" -eq 0 ]

    # Modified content went into the regular file that replaced the symlink
    run grep "bbo" link
    [ "$status" -ne 0 ]
  else
    # In BSD sed (macOS), sed -i on symlink fails safely
    run sed -i '' '/bbo/d' link
    [ "$status" -ne 0 ]
    [ -L link ]
  fi
}

@test "sed -i --follow-symlinks preserves symlink and modifies target file" {
  if ! sed --version 2>&1 | grep -q "GNU"; then
    skip "GNU sed required for --follow-symlinks"
  fi

  echo "initial target data with bbo" > target
  ln -s target link

  [ -L link ]

  sed --follow-symlinks -i '/bbo/d' link

  # Symlink is preserved
  [ -L link ]

  # Target file was modified in-place
  run grep "bbo" target
  [ "$status" -ne 0 ]
}

@test "sed -i creates a new file with a different inode" {
  echo "original content" > f

  if stat -c "%i" f >/dev/null 2>&1; then
    # GNU stat
    inode_before=$(stat -c "%i" f)
    sed -i.bak 's/original/modified/' f
    inode_after=$(stat -c "%i" f)
    inode_bak=$(stat -c "%i" f.bak)
  else
    # BSD stat
    inode_before=$(stat -f "%i" f)
    sed -i.bak 's/original/modified/' f
    inode_after=$(stat -f "%i" f)
    inode_bak=$(stat -f "%i" f.bak)
  fi

  # Inode of edited file changed because sed wrote to a temp file and renamed
  [ "$inode_before" != "$inode_after" ]

  # Inode of backup file matches the original inode
  [ "$inode_before" = "$inode_bak" ]
}
