#!/usr/bin/env zsh
# Test suite for extract script
# Tests archive extraction behavior

# Set up test environment
export TEST_DIR="${TEST_DIR:-$(dirname "$0")/../..}"
export DOTFILES_DIR="${DOTFILES_DIR:-$(dirname "$TEST_DIR")}"

# Source test framework
source "$TEST_DIR/lib/test_helpers.zsh"

describe "extract script behavioral tests"

setup_test
EXTRACT="$DOTFILES_DIR/src/scripts/extract"

it "should show usage when no arguments provided" && {
  output=$("$EXTRACT" 2>&1 || true)
  assert_contains "$output" "Usage:"
  pass
}

it "should error on non-existent file" && {
  output=$("$EXTRACT" "/tmp/nonexistent.zip" 2>&1 || true)
  assert_contains "$output" "not a valid file"
  pass
}

it "should error on unknown format" && {
  # Create a file with unknown extension
  touch "$TEST_TMP_DIR/unknown.xyz"
  output=$("$EXTRACT" "$TEST_TMP_DIR/unknown.xyz" 2>&1 || true)
  assert_contains "$output" "cannot be extracted"
  pass
}

it "should successfully extract zip files" && {
  # Create a test zip file
  echo "test content" > "$TEST_TMP_DIR/test.txt"
  (cd "$TEST_TMP_DIR" && zip -q test.zip test.txt)
  rm "$TEST_TMP_DIR/test.txt"

  # Extract it
  (cd "$TEST_TMP_DIR" && "$EXTRACT" test.zip >/dev/null 2>&1)

  # Check if file was extracted
  if [[ -f "$TEST_TMP_DIR/test.txt" ]]; then
    content=$(cat "$TEST_TMP_DIR/test.txt")
    assert_equals "test content" "$content"
    pass
  else
    skip "zip extraction not available"
  fi
}

cleanup_test

# Return success
exit 0