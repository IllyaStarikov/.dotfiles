#!/usr/bin/env zsh
# Test suite for fallback script
# Tests command fallback behavior

# Set up test environment
export TEST_DIR="${TEST_DIR:-$(dirname "$0")/../..}"
export DOTFILES_DIR="${DOTFILES_DIR:-$(dirname "$TEST_DIR")}"

# Source test framework
source "$TEST_DIR/lib/test_helpers.zsh"

describe "fallback script behavioral tests"

setup_test
FALLBACK="$DOTFILES_DIR/src/scripts/fallback"

it "should show usage with --help" && {
  output=$("$FALLBACK" --help 2>&1)
  assert_contains "$output" "Usage:"
  assert_contains "$output" "fallback"
  pass
}

it "should error when no commands provided" && {
  output=$("$FALLBACK" 2>&1 || true)
  assert_contains "$output" "No commands provided"
  pass
}

it "should execute first available command" && {
  # Use commands we know exist
  output=$("$FALLBACK" echo printf -- "test" 2>&1)
  assert_equals "test" "$output"
  pass
}

it "should fall back to second command if first not found" && {
  # Use a non-existent command followed by echo
  output=$("$FALLBACK" nonexistentcmd123 echo -- "fallback worked" 2>&1)
  assert_equals "fallback worked" "$output"
  pass
}

it "should handle verbose mode" && {
  output=$("$FALLBACK" -v nonexistentcmd123 echo -- "test" 2>&1)
  assert_contains "$output" "Checking if"
  assert_contains "$output" "not found"
  pass
}

it "should error when no commands are found" && {
  output=$("$FALLBACK" nonexistent1 nonexistent2 2>&1 || true)
  assert_contains "$output" "None of the following commands were found"
  pass
}

it "should pass multiple arguments correctly" && {
  output=$("$FALLBACK" echo -- "arg1" "arg2" "arg3" 2>&1)
  assert_equals "arg1 arg2 arg3" "$output"
  pass
}

cleanup_test

# Return success
exit 0
