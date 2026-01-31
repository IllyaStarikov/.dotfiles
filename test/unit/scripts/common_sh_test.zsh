#!/usr/bin/env zsh
# Test suite for common.sh library
# Tests cross-platform utility functions to ensure portability
# Based on Google Shell Style Guide: https://google.github.io/styleguide/shellguide.html

# Initialize test environment paths
# Handles both standalone and runner execution contexts
export TEST_DIR="${TEST_DIR:-$(dirname "$0")/../..}"
export DOTFILES_DIR="${DOTFILES_DIR:-$(dirname "$TEST_DIR")}"

# Source test framework
source "$TEST_DIR/lib/test_helpers.zsh"

describe "common.sh library behavioral tests"

setup_test
COMMON_LIB="$DOTFILES_DIR/src/scripts/common.sh"

it "should provide OS detection functions" && {
  # Source the library in a subshell to avoid polluting test environment
  # Tests that core OS detection functions are properly exported
  if (source "$COMMON_LIB" && type detect_os >/dev/null 2>&1); then
    pass
  else
    fail "Missing OS detection functions"
  fi
}

it "should detect current OS correctly" && {
  # Verify OS detection matches system uname output
  # Ensures cross-platform compatibility functions work correctly
  os_result=$(source "$COMMON_LIB" && detect_os)

  if [[ "$(uname)" == "Darwin" ]] && [[ "$os_result" == "macos" ]]; then
    pass
  elif [[ "$(uname)" == "Linux" ]] && [[ "$os_result" == "linux" ]]; then
    pass
  else
    fail "OS detection mismatch: expected $(uname), got $os_result"
  fi
}

it "should provide color printing functions" && {
  # Test that color output utilities are available
  # These functions provide consistent user feedback across scripts
  if (source "$COMMON_LIB" && type print_color >/dev/null 2>&1); then
    pass
  else
    fail "Missing print_color function"
  fi
}

it "should provide command existence checking" && {
  # Verify command detection utilities are present
  # Critical for conditional functionality based on available tools
  if (source "$COMMON_LIB" && type has_command >/dev/null 2>&1); then
    pass
  else
    fail "Missing has_command function"
  fi
}

it "should correctly check command existence" && {
  # Test with a command that definitely exists
  if (source "$COMMON_LIB" && has_command ls); then
    pass
  else
    fail "has_command failed for 'ls'"
  fi
}

it "should provide platform-specific command execution" && {
  if (source "$COMMON_LIB" && type platform_command >/dev/null 2>&1); then
    pass
  else
    fail "Missing platform_command function"
  fi
}

it "should provide CPU count detection" && {
  if (source "$COMMON_LIB" && type get_cpu_count >/dev/null 2>&1); then
    # Test that it returns a number
    cpu_count=$(source "$COMMON_LIB" && get_cpu_count)
    if [[ "$cpu_count" =~ ^[0-9]+$ ]] && [[ "$cpu_count" -gt 0 ]]; then
      pass
    else
      fail "Invalid CPU count: $cpu_count"
    fi
  else
    fail "Missing get_cpu_count function"
  fi
}

cleanup_test

# Return success
exit 0
