#!/usr/bin/env zsh
# Unit tests for logging.zsh library

# Get the test directory path
TEST_DIR="$(cd "$(dirname "$(dirname "$(dirname "$0")")")" && pwd)"
DOTFILES_DIR="$(dirname "$TEST_DIR")"

# Set up test environment
export TEST_TMP_DIR="${TEST_TMP_DIR:-/tmp/dotfiles_test_$$}"
mkdir -p "$TEST_TMP_DIR"

# Test framework
source "${TEST_DIR}/lib/test_helpers.zsh"

# Source the library under test
source "${DOTFILES_DIR}/src/lib/logging.zsh"

# ============================================================================
# Log Level Tests
# ============================================================================

test_log_level_default() {
  test_case "LOG_LEVEL defaults to INFO"
  # Reset to default
  export LOG_LEVEL=INFO
  if [[ "$LOG_LEVEL" == "INFO" ]]; then
    pass
  else
    fail "Expected 'INFO', got: '$LOG_LEVEL'"
  fi
}

test_set_log_level_valid() {
  test_case "SET_LOG_LEVEL sets valid level"
  SET_LOG_LEVEL DEBUG 2>/dev/null
  if [[ "$LOG_LEVEL" == "DEBUG" ]]; then
    pass
  else
    fail "Expected 'DEBUG', got: '$LOG_LEVEL'"
  fi
  SET_LOG_LEVEL INFO 2>/dev/null
}

test_set_log_level_invalid() {
  test_case "SET_LOG_LEVEL rejects invalid level"
  local original="$LOG_LEVEL"
  if ! SET_LOG_LEVEL INVALID 2>/dev/null; then
    pass
  else
    fail "Expected failure for invalid level"
  fi
  LOG_LEVEL="$original"
}

test_set_log_level_case_insensitive() {
  test_case "SET_LOG_LEVEL is case insensitive"
  SET_LOG_LEVEL debug 2>/dev/null
  if [[ "$LOG_LEVEL" == "DEBUG" ]]; then
    pass
  else
    fail "Expected 'DEBUG', got: '$LOG_LEVEL'"
  fi
  SET_LOG_LEVEL INFO 2>/dev/null
}

# ============================================================================
# SHOULD_LOG Tests
# ============================================================================

test_should_log_at_level() {
  test_case "SHOULD_LOG returns true at current level"
  export LOG_LEVEL=INFO
  if SHOULD_LOG INFO; then
    pass
  else
    fail "Expected true for INFO at INFO level"
  fi
}

test_should_log_above_level() {
  test_case "SHOULD_LOG returns true above current level"
  export LOG_LEVEL=INFO
  if SHOULD_LOG ERROR; then
    pass
  else
    fail "Expected true for ERROR at INFO level"
  fi
}

test_should_log_below_level() {
  test_case "SHOULD_LOG returns false below current level"
  export LOG_LEVEL=INFO
  if ! SHOULD_LOG DEBUG; then
    pass
  else
    fail "Expected false for DEBUG at INFO level"
  fi
}

test_should_log_trace_at_trace() {
  test_case "SHOULD_LOG TRACE at TRACE level"
  export LOG_LEVEL=TRACE
  if SHOULD_LOG TRACE; then
    pass
  else
    fail "Expected true for TRACE at TRACE level"
  fi
  export LOG_LEVEL=INFO
}

# ============================================================================
# LOG Output Tests
# ============================================================================

test_log_info_outputs() {
  test_case "LOG INFO outputs message"
  export LOG_LEVEL=INFO
  local output=$(LOG INFO "test message" 2>&1)
  if [[ "$output" == *"[INFO]"* ]] && [[ "$output" == *"test message"* ]]; then
    pass
  else
    fail "Expected INFO log with message, got: '$output'"
  fi
}

test_log_error_outputs() {
  test_case "LOG ERROR outputs message"
  export LOG_LEVEL=INFO
  local output=$(LOG ERROR "error message" 2>&1)
  if [[ "$output" == *"[ERROR]"* ]] && [[ "$output" == *"error message"* ]]; then
    pass
  else
    fail "Expected ERROR log with message, got: '$output'"
  fi
}

test_log_debug_suppressed() {
  test_case "LOG DEBUG suppressed at INFO level"
  export LOG_LEVEL=INFO
  local output=$(LOG DEBUG "debug message" 2>&1)
  if [[ -z "$output" ]]; then
    pass
  else
    fail "Expected no output for DEBUG at INFO level, got: '$output'"
  fi
}

test_log_debug_shown_at_debug() {
  test_case "LOG DEBUG shown at DEBUG level"
  export LOG_LEVEL=DEBUG
  local output=$(LOG DEBUG "debug message" 2>&1)
  if [[ "$output" == *"[DEBUG]"* ]]; then
    pass
  else
    fail "Expected DEBUG output, got: '$output'"
  fi
  export LOG_LEVEL=INFO
}

# ============================================================================
# Convenience Function Tests
# ============================================================================

test_info_function() {
  test_case "INFO function works"
  export LOG_LEVEL=INFO
  local output=$(INFO "info message" 2>&1)
  if [[ "$output" == *"[INFO]"* ]]; then
    pass
  else
    fail "Expected INFO output, got: '$output'"
  fi
}

test_warn_function() {
  test_case "WARN function works"
  export LOG_LEVEL=INFO
  local output=$(WARN "warning message" 2>&1)
  if [[ "$output" == *"[WARN]"* ]]; then
    pass
  else
    fail "Expected WARN output, got: '$output'"
  fi
}

test_error_function() {
  test_case "ERROR function works"
  export LOG_LEVEL=INFO
  local output=$(ERROR "error message" 2>&1)
  if [[ "$output" == *"[ERROR]"* ]]; then
    pass
  else
    fail "Expected ERROR output, got: '$output'"
  fi
}

test_fatal_function() {
  test_case "FATAL function works"
  export LOG_LEVEL=INFO
  local output=$(FATAL "fatal message" 2>&1)
  if [[ "$output" == *"[FATAL]"* ]]; then
    pass
  else
    fail "Expected FATAL output, got: '$output'"
  fi
}

# ============================================================================
# Special Logging Function Tests
# ============================================================================

test_log_success_icon() {
  test_case "LOG_SUCCESS includes checkmark"
  export LOG_LEVEL=INFO
  local output=$(LOG_SUCCESS "done" 2>&1)
  if [[ "$output" == *"✓"* ]]; then
    pass
  else
    fail "Expected checkmark in output, got: '$output'"
  fi
}

test_log_failure_icon() {
  test_case "LOG_FAILURE includes X"
  export LOG_LEVEL=INFO
  local output=$(LOG_FAILURE "failed" 2>&1)
  if [[ "$output" == *"✗"* ]]; then
    pass
  else
    fail "Expected X in output, got: '$output'"
  fi
}

test_log_warning_icon() {
  test_case "LOG_WARNING includes warning icon"
  export LOG_LEVEL=INFO
  local output=$(LOG_WARNING "caution" 2>&1)
  if [[ "$output" == *"⚠"* ]]; then
    pass
  else
    fail "Expected warning icon in output, got: '$output'"
  fi
}

test_log_separator() {
  test_case "LOG_SEPARATOR outputs separator line"
  export LOG_LEVEL=INFO
  local output=$(LOG_SEPARATOR INFO "-" 10 2>&1)
  if [[ "$output" == *"----------"* ]]; then
    pass
  else
    fail "Expected separator line, got: '$output'"
  fi
}

test_log_header() {
  test_case "LOG_HEADER outputs header with separators"
  export LOG_LEVEL=INFO
  local output=$(LOG_HEADER INFO "Title" 2>&1)
  if [[ "$output" == *"━"* ]] && [[ "$output" == *"Title"* ]]; then
    pass
  else
    fail "Expected header with separators, got: '$output'"
  fi
}

test_log_progress() {
  test_case "LOG_PROGRESS includes arrow"
  export LOG_LEVEL=INFO
  local output=$(LOG_PROGRESS INFO "working" 2>&1)
  if [[ "$output" == *"▶"* ]]; then
    pass
  else
    fail "Expected arrow in output, got: '$output'"
  fi
}

test_log_done() {
  test_case "LOG_DONE includes checkmark"
  export LOG_LEVEL=INFO
  local output=$(LOG_DONE INFO "complete" 2>&1)
  if [[ "$output" == *"✓"* ]]; then
    pass
  else
    fail "Expected checkmark in output, got: '$output'"
  fi
}

# ============================================================================
# Run Tests
# ============================================================================

test_suite "Logging Library" \
  test_log_level_default \
  test_set_log_level_valid \
  test_set_log_level_invalid \
  test_set_log_level_case_insensitive \
  test_should_log_at_level \
  test_should_log_above_level \
  test_should_log_below_level \
  test_should_log_trace_at_trace \
  test_log_info_outputs \
  test_log_error_outputs \
  test_log_debug_suppressed \
  test_log_debug_shown_at_debug \
  test_info_function \
  test_warn_function \
  test_error_function \
  test_fatal_function \
  test_log_success_icon \
  test_log_failure_icon \
  test_log_warning_icon \
  test_log_separator \
  test_log_header \
  test_log_progress \
  test_log_done
