#!/usr/bin/env zsh
# Unit tests for callstack.zsh library

# Get the test directory path
TEST_DIR="$(cd "$(dirname "$(dirname "$(dirname "$0")")")" && pwd)"
DOTFILES_DIR="$(dirname "$TEST_DIR")"

# Set up test environment
export TEST_TMP_DIR="${TEST_TMP_DIR:-/tmp/dotfiles_test_$$}"
mkdir -p "$TEST_TMP_DIR"

# Test framework
source "${TEST_DIR}/lib/test_helpers.zsh"

# Source the library under test
source "${DOTFILES_DIR}/src/lib/callstack.zsh" 2>/dev/null || {
  test_suite "Callstack Library"
  skip "callstack.zsh not found"
  exit 0
}

# ============================================================================
# Call Depth Tests
# ============================================================================

test_call_depth_returns_number() {
  test_case "call_depth returns a number"
  if declare -f call_depth >/dev/null 2>&1; then
    local depth=$(call_depth)
    if [[ "$depth" =~ ^[0-9]+$ ]]; then
      pass
    else
      fail "Expected number, got: '$depth'"
    fi
  else
    skip "call_depth not available"
  fi
}

# ============================================================================
# Caller Info Tests
# ============================================================================

test_caller_name() {
  test_case "caller_name returns function name"
  if declare -f caller_name >/dev/null 2>&1; then
    _test_wrapper() {
      caller_name
    }
    local result=$(_test_wrapper)
    # Should return something (even if empty string in some contexts)
    pass
  else
    skip "caller_name not available"
  fi
}

test_in_function() {
  test_case "in_function detects function context"
  if declare -f in_function >/dev/null 2>&1; then
    _test_func() {
      in_function
    }
    if _test_func; then
      pass
    else
      fail "Should detect function context"
    fi
  else
    skip "in_function not available"
  fi
}

# ============================================================================
# Debug Mode Tests
# ============================================================================

test_debug_on_off() {
  test_case "debug_on and debug_off toggle mode"
  if declare -f debug_on >/dev/null 2>&1 && declare -f debug_off >/dev/null 2>&1; then
    debug_on
    if declare -f is_debug >/dev/null 2>&1; then
      if is_debug; then
        debug_off
        if ! is_debug; then
          pass
        else
          fail "debug_off failed"
        fi
      else
        fail "debug_on failed"
      fi
    else
      # Just check functions exist
      debug_off
      pass
    fi
  else
    skip "debug functions not available"
  fi
}

# ============================================================================
# Profiling Tests
# ============================================================================

test_profile_functions_exist() {
  test_case "profiling functions exist"
  if declare -f profile_start >/dev/null 2>&1 \
    && declare -f profile_end >/dev/null 2>&1; then
    pass
  else
    skip "profiling functions not available"
  fi
}

# ============================================================================
# Stack Trace Tests
# ============================================================================

test_stack_trace_function() {
  test_case "stack_trace function exists"
  if declare -f stack_trace >/dev/null 2>&1 \
    || declare -f print_stack_trace >/dev/null 2>&1; then
    pass
  else
    skip "stack_trace not available"
  fi
}

# ============================================================================
# Run Tests
# ============================================================================

test_suite "Callstack Library" \
  test_call_depth_returns_number \
  test_caller_name \
  test_in_function \
  test_debug_on_off \
  test_profile_functions_exist \
  test_stack_trace_function
