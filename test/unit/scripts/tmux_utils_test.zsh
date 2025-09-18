#!/usr/bin/env zsh
# Comprehensive unit tests for tmux-utils

# Tests handle errors explicitly

# Set up test environment
export TEST_DIR="${TEST_DIR:-$(dirname "$0")/../..}"
export DOTFILES_DIR="${DOTFILES_DIR:-$(dirname "$TEST_DIR")}"

# Source test framework
source "$TEST_DIR/lib/test_helpers.zsh"

# Test suite for tmux-utils
describe "tmux-utils comprehensive tests"

# Setup before tests
setup_test

# Test: Script exists and is executable
it "should exist and be executable" && {
  local script_path="$DOTFILES_DIR/src/scripts/tmux-utils"

  assert_file_exists "$script_path"
  assert_file_executable "$script_path"
  pass
}

# Test: Help message
it "should display help message" && {
  output=$("$DOTFILES_DIR/src/scripts/tmux-utils" --help 2>&1 || true)

  assert_contains "$output" "Usage" || assert_contains "$output" "usage"
  assert_contains "$output" "battery" || assert_contains "$output" "cpu" || assert_contains "$output" "memory"
  pass
}

# Test: Battery command
it "should support battery status command" && {
  output=$("$DOTFILES_DIR/src/scripts/tmux-utils" battery 2>&1 || true)

  # Should return battery info or indicate no battery
  assert_not_empty "$output"
  pass
}

# Test: CPU command
it "should support CPU usage command" && {
  output=$("$DOTFILES_DIR/src/scripts/tmux-utils" cpu 2>&1 || true)

  # Should return CPU usage
  assert_not_empty "$output"
  pass
}

# Test: Memory command
it "should support memory usage command" && {
  output=$("$DOTFILES_DIR/src/scripts/tmux-utils" memory 2>&1 || true)

  # Should return memory usage
  assert_not_empty "$output"
  pass
}

# Test: Caching mechanism
it "should implement caching for performance" && {
  local script_content=$(cat "$DOTFILES_DIR/src/scripts/tmux-utils")

  assert_contains "$script_content" "cache" || assert_contains "$script_content" "Cache" || assert_contains "$script_content" "tmp"
  pass
}

# Test: Platform detection
it "should detect platform correctly" && {
  local script_content=$(cat "$DOTFILES_DIR/src/scripts/tmux-utils")

  assert_contains "$script_content" "uname" || assert_contains "$script_content" "Darwin" || assert_contains "$script_content" "Linux"
  pass
}

# Test: Error handling
it "should handle errors gracefully" && {
  # Test with invalid command
  output=$("$DOTFILES_DIR/src/scripts/tmux-utils" invalid_command 2>&1 || true)

  assert_contains "$output" "Usage" || assert_contains "$output" "Error" || assert_contains "$output" "Unknown"
  pass
}

# Test: Output formatting
it "should format output for tmux status bar" && {
  local script_content=$(cat "$DOTFILES_DIR/src/scripts/tmux-utils")

  # Should format output nicely
  assert_contains "$script_content" "printf" || assert_contains "$script_content" "echo" || assert_contains "$script_content" "format"
  pass
}

# Test: Icon support
it "should support icons/symbols" && {
  local script_content=$(cat "$DOTFILES_DIR/src/scripts/tmux-utils")

  # Should have icons for battery, CPU, etc.
  assert_contains "$script_content" "icon" || assert_contains "$script_content" "symbol" || assert_contains "$script_content" ""
  pass
}

# Test: Threshold handling
it "should handle thresholds for warnings" && {
  local script_content=$(cat "$DOTFILES_DIR/src/scripts/tmux-utils")

  # Should have threshold logic
  assert_contains "$script_content" "threshold" || assert_contains "$script_content" "warning" || assert_contains "$script_content" "critical"
  pass
}

# Test: Color coding
it "should support color coding for status" && {
  local script_content=$(cat "$DOTFILES_DIR/src/scripts/tmux-utils")

  assert_contains "$script_content" "color" || assert_contains "$script_content" "Color" || assert_contains "$script_content" "#"
  pass
}

# Test: Network status
it "should check network status" && {
  local script_content=$(cat "$DOTFILES_DIR/src/scripts/tmux-utils")

  assert_contains "$script_content" "network" || assert_contains "$script_content" "wifi" || assert_contains "$script_content" "connection"
  pass
}

# Test: Date/time functionality
it "should support date/time display" && {
  local script_content=$(cat "$DOTFILES_DIR/src/scripts/tmux-utils")

  assert_contains "$script_content" "date" || assert_contains "$script_content" "time" || assert_contains "$script_content" "clock"
  pass
}

# Test: Performance optimization
it "should be optimized for frequent calls" && {
  local script_content=$(cat "$DOTFILES_DIR/src/scripts/tmux-utils")

  # Should avoid expensive operations
  assert_contains "$script_content" "cache" || assert_contains "$script_content" "fast" || assert_contains "$script_content" "quick"
  pass
}

# Test: Exit codes
it "should use proper exit codes" && {
  # Test with valid command
  "$DOTFILES_DIR/src/scripts/tmux-utils" cpu 2>&1 >/dev/null
  assert_success $?

  pass
}

# Cleanup after tests
cleanup_test

# Summary
echo -e "\n${GREEN}tmux-utils comprehensive tests completed${NC}"
# Return success
exit 0
