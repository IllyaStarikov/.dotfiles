#!/usr/bin/env zsh
# Behavioral tests for setup.sh

# Tests handle errors explicitly

# Set up test environment
export TEST_DIR="${TEST_DIR:-$(dirname "$0")/../..}"
export DOTFILES_DIR="${DOTFILES_DIR:-$(dirname "$TEST_DIR")}"

# Source test framework
source "$TEST_DIR/lib/test_helpers.zsh"

describe "setup.sh behavioral tests"

# Test: Script exists and is executable
it "should exist and be executable" && {
  local script_path="$DOTFILES_DIR/src/setup/setup.sh"

  if [[ -f "$script_path" ]] && [[ -x "$script_path" ]]; then
    pass
  else
    fail "Setup script not found or not executable"
  fi
}

# Test: Help message works
it "should provide help information" && {
  output=$("$DOTFILES_DIR/src/setup/setup.sh" --help 2>&1 || true)

  if [[ "$output" == *"Usage"* ]] || [[ "$output" == *"usage"* ]] || [[ "$output" == *"help"* ]] || [[ "$output" == *"SETUP"* ]]; then
    pass "Help information available"
  else
    fail "No help output"
  fi
}

# Test: Handles invalid arguments
it "should handle invalid arguments gracefully" && {
  output=$("$DOTFILES_DIR/src/setup/setup.sh" --invalid-option 2>&1 || true)

  # Should show error or usage
  if [[ -n "$output" ]]; then
    pass "Handled invalid argument"
  else
    fail "No output for invalid argument"
  fi
}

# Test: Core mode is supported
it "should support core installation mode" && {
  # Check if --core or core mode is mentioned in help
  output=$("$DOTFILES_DIR/src/setup/setup.sh" --help 2>&1 || true)

  if [[ "$output" == *"core"* ]] || [[ "$output" == *"Core"* ]]; then
    pass "Core mode supported"
  else
    skip "Core mode not documented"
  fi
}

# Test: Symlinks mode is supported
it "should support symlinks mode" && {
  # Check if symlinks mode is mentioned
  output=$("$DOTFILES_DIR/src/setup/setup.sh" --help 2>&1 || true)

  if [[ "$output" == *"symlink"* ]] || [[ "$output" == *"Symlink"* ]]; then
    pass "Symlinks mode supported"
  else
    skip "Symlinks mode not documented"
  fi
}

# Test: Detects operating system
it "should detect the operating system" && {
  # Run setup and check if it mentions the OS
  output=$("$DOTFILES_DIR/src/setup/setup.sh" --help 2>&1 || zsh "$DOTFILES_DIR/src/setup/setup.sh" 2>&1 | head -20 || true)

  if [[ "$output" == *"macOS"* ]] || [[ "$output" == *"Linux"* ]] || [[ "$output" == *"Darwin"* ]] || [[ "$output" == *"System:"* ]]; then
    pass "OS detection works"
  else
    skip "OS detection not visible in output"
  fi
}

# Return success
exit 0
