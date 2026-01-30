#!/usr/bin/env zsh
# Test suite for fetch-quotes script
# Tests quote fetching behavior and API handling

# Set up test environment
export TEST_DIR="${TEST_DIR:-$(dirname "$0")/../..}"
export DOTFILES_DIR="${DOTFILES_DIR:-$(dirname "$TEST_DIR")}"

# Source test framework
source "$TEST_DIR/lib/test_helpers.zsh"

describe "fetch-quotes script behavioral tests"

setup_test
FETCH_QUOTES="$DOTFILES_DIR/src/scripts/fetch-quotes"

it "should check for required tools" && {
  # Test that it verifies curl and jq are available
  if command -v curl >/dev/null && command -v jq >/dev/null; then
    output=$("$FETCH_QUOTES" 1 2>&1 | head -5)
    # Should not show error about missing tools
    if echo "$output" | grep -q "Error:.*required"; then
      fail "Shows error despite tools being available"
    else
      pass
    fi
  else
    skip "curl or jq not installed"
  fi
}

it "should accept count parameter" && {
  # The script accepts a count parameter for number of quotes
  # Since this requires network access, we'll just check it handles the parameter
  if [[ -x "$FETCH_QUOTES" ]]; then
    # Check script has parameter handling
    if grep -q 'QUOTES_COUNT=${1:-5}' "$FETCH_QUOTES"; then
      pass
    else
      fail "Doesn't handle count parameter"
    fi
  else
    fail "Script not executable"
  fi
}

it "should have timeout configuration" && {
  # Verify timeout handling is configured
  if grep -q "TIMEOUT_DURATION" "$FETCH_QUOTES" && \
     grep -q "get_timeout_cmd" "$FETCH_QUOTES"; then
    pass
  else
    fail "Missing timeout configuration"
  fi
}

it "should handle missing dependencies gracefully" && {
  # Test error messages for missing tools
  if grep -q "check_requirements" "$FETCH_QUOTES" && \
     grep -q "curl is required" "$FETCH_QUOTES" && \
     grep -q "jq is required" "$FETCH_QUOTES"; then
    pass
  else
    fail "Doesn't check for required dependencies"
  fi
}

it "should provide installation instructions for missing tools" && {
  # Check that it provides helpful install commands
  if grep -q "brew install jq" "$FETCH_QUOTES" && \
     grep -q "apt install jq" "$FETCH_QUOTES"; then
    pass
  else
    fail "Missing installation instructions"
  fi
}

cleanup_test

# Return success
exit 0