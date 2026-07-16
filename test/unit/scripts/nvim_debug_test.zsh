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

it "should source the shared library for colors" && {
  # Terminal/color detection is owned by src/lib/colors.zsh, loaded via
  # init.zsh; nvim-debug no longer probes the terminal itself.
  if grep -q 'src/lib/init.zsh' "$NVIM_DEBUG"; then
    pass
  else
    fail "Should source src/lib/init.zsh for colors/logging"
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

it "should get colors from the shared library" && {
  # No inline `readonly RED=...` fallbacks anymore: color definitions (and
  # any no-color policy) are owned by src/lib/colors.zsh.
  if grep -q '\$RED\|\${RED}' "$NVIM_DEBUG" \
    && ! grep -q 'readonly RED=' "$NVIM_DEBUG"; then
    pass
  else
    fail "Colors should come from src/lib/colors.zsh, not inline definitions"
  fi
}

cleanup_test

# Return success
exit 0
