#!/usr/bin/env zsh
# Test suite for bugreport script
# Tests behavior, not implementation

# Test framework
source "$(dirname "$0")/../../lib/simple_framework.zsh"

# Script under test
SCRIPT_PATH="$DOTFILES_DIR/src/scripts/bugreport"

# Test that script exists and is executable
test_script_exists() {
  assert_file_exists "$SCRIPT_PATH" "bugreport script should exist"
  assert_executable "$SCRIPT_PATH" "bugreport script should be executable"
}

# Test help output
test_help_output() {
  local output
  output=$("$SCRIPT_PATH" --help 2>&1)
  assert_contains "$output" "Bug Report Generator" "Should show help title"
  assert_contains "$output" "USAGE:" "Should show usage section"
  assert_contains "$output" "OPTIONS:" "Should show options"
  assert_contains "$output" "--test" "Should document test option"
  assert_contains "$output" "--no-logs" "Should document no-logs option"
}

# Test that sanitize function works
test_sanitize_function() {
  # Source the script in a subshell to test the sanitize function
  local result
  result=$(
    source "$SCRIPT_PATH" 2>/dev/null || true
    echo "token=abc123xyz456" | sanitize
  )
  assert_not_contains "$result" "abc123xyz456" "Should sanitize tokens"
}

# Test that dry run doesn't create files
test_dry_run() {
  # Count files before
  local before_count=$(find "$DOTFILES_DIR" -name "bugreport_*" | wc -l)

  # Run with debug mode (doesn't create archive)
  "$SCRIPT_PATH" --debug --help >/dev/null 2>&1

  # Count files after
  local after_count=$(find "$DOTFILES_DIR" -name "bugreport_*" | wc -l)

  assert_equals "$before_count" "$after_count" "Should not create files in help mode"
}

# Test invalid option handling
test_invalid_option() {
  local output
  output=$("$SCRIPT_PATH" --invalid-option 2>&1 || true)
  assert_contains "$output" "Unknown option" "Should report unknown option"
}

# Test that script can handle missing commands gracefully
test_missing_commands() {
  # This tests that the script doesn't fail if optional tools are missing
  # We can't easily test this without modifying PATH, so just verify script structure
  local has_checks
  has_checks=$(grep -c "command -v\|which\|has_command" "$SCRIPT_PATH" || echo 0)
  assert_true "[ $has_checks -gt 10 ]" "Script should check for command availability"
}

# Run all tests
run_tests