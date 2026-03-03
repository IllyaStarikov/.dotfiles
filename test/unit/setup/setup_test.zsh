#!/usr/bin/env zsh
# Unit tests for install.sh setup script

# Tests handle errors explicitly

# Set up test environment
export TEST_DIR="${TEST_DIR:-$(dirname "$0")/../..}"
export DOTFILES_DIR="${DOTFILES_DIR:-$(dirname "$TEST_DIR")}"

# Source test framework
source "$TEST_DIR/lib/test_helpers.zsh"

describe "install.sh setup script"

# Test: Script exists and is executable
it "should exist and be executable" && {
  assert_file_exists "$DOTFILES_DIR/src/setup/install.sh"
  assert_file_executable "$DOTFILES_DIR/src/setup/install.sh"
}

# Test: Valid shell syntax
it "should have valid shell syntax" && {
  if zsh -n "$DOTFILES_DIR/src/setup/install.sh" 2>/dev/null; then
    pass
  else
    fail "Syntax error in install.sh"
  fi
}

# Test: Help message
it "should display help message" && {
  output=$("$DOTFILES_DIR/src/setup/install.sh" --help 2>&1 || true)
  assert_contains "$output" "Usage"
  assert_contains "$output" "core"
  assert_contains "$output" "symlinks"
}

# Test: Required tools validation
it "should validate required tools" && {
  assert_command_exists "git"
}

# Test: Configuration file paths
it "should use correct configuration paths" && {
  local script_content=$(cat "$DOTFILES_DIR/src/setup/install.sh" 2>/dev/null || echo "")
  assert_contains "$script_content" "DOTFILES_DIR"
  assert_contains "$script_content" ".zshrc"
  assert_contains "$script_content" ".config"
}

# Test: Platform detection
it "should detect operating system" && {
  local script_content=$(cat "$DOTFILES_DIR/src/setup/install.sh")
  assert_contains "$script_content" "darwin"
  assert_contains "$script_content" "linux"
}

# Run tests
run_tests
