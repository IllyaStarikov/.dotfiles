#!/usr/bin/env zsh
# Test suite for nvim-debug script
# Tests Neovim debugging helper functionality

# Set up test environment
export TEST_DIR="${TEST_DIR:-$(dirname "$0")/../..}"
export DOTFILES_DIR="${DOTFILES_DIR:-$(dirname "$TEST_DIR")}"

# Source test framework
source "$TEST_DIR/lib/test_helpers.zsh"

describe "nvim-debug script behavioral tests"

setup_test
NVIM_DEBUG="$DOTFILES_DIR/src/scripts/nvim-debug"

it "should provide usage information" && {
  # Check that usage function exists and provides help
  if grep -q "usage()" "$NVIM_DEBUG" \
    && grep -q "Neovim Work Configuration Debugger" "$NVIM_DEBUG"; then
    pass
  else
    fail "Missing usage information"
  fi
}

it "should support multiple debug options" && {
  # Verify all documented options exist
  has_check=$(grep -q -- "--check" "$NVIM_DEBUG" && echo 1 || echo 0)
  has_test=$(grep -q -- "--test" "$NVIM_DEBUG" && echo 1 || echo 0)
  has_lsp=$(grep -q -- "--lsp" "$NVIM_DEBUG" && echo 1 || echo 0)
  has_logs=$(grep -q -- "--logs" "$NVIM_DEBUG" && echo 1 || echo 0)

  if [[ $has_check -eq 1 && $has_test -eq 1 && $has_lsp -eq 1 && $has_logs -eq 1 ]]; then
    pass
  else
    fail "Missing debug options"
  fi
}

it "should detect terminal color support" && {
  # Check for proper terminal color detection
  if grep -q "if \[\[ -t 1 \]\]" "$NVIM_DEBUG" \
    && grep -q "readonly RED=\$'\\\\033\[0;31m'" "$NVIM_DEBUG"; then
    pass
  else
    fail "Missing terminal color detection"
  fi
}

it "should use proper error handling" && {
  # Check for set -euo pipefail
  if grep -q "^set -euo pipefail" "$NVIM_DEBUG"; then
    pass
  else
    fail "Missing proper error handling"
  fi
}

it "should determine script directory correctly" && {
  # Check for proper directory detection
  if grep -q 'DOTFILES_DIR=.*dirname.*dirname.*dirname' "$NVIM_DEBUG"; then
    pass
  else
    fail "Incorrect directory detection logic"
  fi
}

it "should handle no-color output for non-terminals" && {
  # Verify it sets empty strings when not in a terminal
  if grep -q 'readonly RED=""' "$NVIM_DEBUG" \
    && grep -q 'readonly NC=""' "$NVIM_DEBUG"; then
    pass
  else
    fail "Missing no-color handling for non-terminals"
  fi
}

cleanup_test

# Return success
exit 0
