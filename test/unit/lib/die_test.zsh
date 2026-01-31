#!/usr/bin/env zsh
# Unit tests for die.zsh library

# Get the test directory path
TEST_DIR="$(cd "$(dirname "$(dirname "$(dirname "$0")")")" && pwd)"
DOTFILES_DIR="$(dirname "$TEST_DIR")"

# Set up test environment
export TEST_TMP_DIR="${TEST_TMP_DIR:-/tmp/dotfiles_test_$$}"
mkdir -p "$TEST_TMP_DIR"

# Test framework
source "${TEST_DIR}/lib/test_helpers.zsh"

# Source the library under test
source "${DOTFILES_DIR}/src/lib/die.zsh"

# Disable stack trace for cleaner test output
DIE_STACK_TRACE=0

# ============================================================================
# Exit Codes Tests
# ============================================================================

test_exit_codes_defined() {
  test_case "EXIT_CODES contains standard codes"
  if [[ "${EXIT_CODES[SUCCESS]}" == "0" ]] && \
     [[ "${EXIT_CODES[GENERAL_ERROR]}" == "1" ]] && \
     [[ "${EXIT_CODES[NOT_FOUND]}" == "127" ]]; then
    pass
  else
    fail "Standard exit codes not defined"
  fi
}

test_exit_codes_custom() {
  test_case "EXIT_CODES contains custom codes"
  if [[ "${EXIT_CODES[CONFIG_ERROR]}" == "64" ]] && \
     [[ "${EXIT_CODES[NETWORK_ERROR]}" == "65" ]]; then
    pass
  else
    fail "Custom exit codes not defined"
  fi
}

# ============================================================================
# Error Message Tests
# ============================================================================

test_error_message_outputs() {
  test_case "error_message outputs to stderr"
  local output=$(error_message "test error" 2>&1)
  if [[ "$output" == *"ERROR"* ]] && [[ "$output" == *"test error"* ]]; then
    pass
  else
    fail "Expected ERROR message, got: '$output'"
  fi
}

test_warn_outputs() {
  test_case "warn outputs warning to stderr"
  local output=$(warn "test warning" 2>&1)
  if [[ "$output" == *"WARNING"* ]] && [[ "$output" == *"test warning"* ]]; then
    pass
  else
    fail "Expected WARNING message, got: '$output'"
  fi
}

# ============================================================================
# Assert Tests
# ============================================================================

test_assert_true_passes() {
  test_case "assert passes for true condition"
  # Use a subshell to catch exit
  local result=0
  (assert "[[ 1 -eq 1 ]]" "Should be equal" 2>/dev/null) || result=$?
  if [[ $result -eq 0 ]]; then
    pass
  else
    fail "Assert should pass for true condition"
  fi
}

test_assert_false_fails() {
  test_case "assert fails for false condition"
  local result=0
  (assert "[[ 1 -eq 2 ]]" "Should fail" 2>/dev/null) || result=$?
  if [[ $result -ne 0 ]]; then
    pass
  else
    fail "Assert should fail for false condition"
  fi
}

# ============================================================================
# Require Command Tests
# ============================================================================

test_require_command_exists() {
  test_case "require_command passes for existing command"
  local result=0
  (require_command "zsh" 2>/dev/null) || result=$?
  if [[ $result -eq 0 ]]; then
    pass
  else
    fail "require_command should pass for 'zsh'"
  fi
}

test_require_command_missing() {
  test_case "require_command fails for missing command"
  local result=0
  (require_command "nonexistent_command_xyz123" 2>/dev/null) || result=$?
  if [[ $result -ne 0 ]]; then
    pass
  else
    fail "require_command should fail for missing command"
  fi
}

# ============================================================================
# Require File Tests
# ============================================================================

test_require_file_exists() {
  test_case "require_file passes for existing file"
  local testfile="$TEST_TMP_DIR/require_test.txt"
  echo "test" > "$testfile"
  local result=0
  (require_file "$testfile" 2>/dev/null) || result=$?
  rm -f "$testfile"
  if [[ $result -eq 0 ]]; then
    pass
  else
    fail "require_file should pass for existing file"
  fi
}

test_require_file_missing() {
  test_case "require_file fails for missing file"
  local result=0
  (require_file "$TEST_TMP_DIR/nonexistent_file.txt" 2>/dev/null) || result=$?
  if [[ $result -ne 0 ]]; then
    pass
  else
    fail "require_file should fail for missing file"
  fi
}

# ============================================================================
# Require Dir Tests
# ============================================================================

test_require_dir_exists() {
  test_case "require_dir passes for existing directory"
  local result=0
  (require_dir "$TEST_TMP_DIR" 2>/dev/null) || result=$?
  if [[ $result -eq 0 ]]; then
    pass
  else
    fail "require_dir should pass for existing directory"
  fi
}

test_require_dir_missing() {
  test_case "require_dir fails for missing directory"
  local result=0
  (require_dir "$TEST_TMP_DIR/nonexistent_dir" 2>/dev/null) || result=$?
  if [[ $result -ne 0 ]]; then
    pass
  else
    fail "require_dir should fail for missing directory"
  fi
}

# ============================================================================
# Run Tests
# ============================================================================

test_suite "Die Library" \
  test_exit_codes_defined \
  test_exit_codes_custom \
  test_error_message_outputs \
  test_warn_outputs \
  test_assert_true_passes \
  test_assert_false_fails \
  test_require_command_exists \
  test_require_command_missing \
  test_require_file_exists \
  test_require_file_missing \
  test_require_dir_exists \
  test_require_dir_missing
