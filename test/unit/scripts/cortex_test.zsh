#!/usr/bin/env zsh
# Behavioral tests for cortex AI model management script

# Set up test environment
export TEST_DIR="${TEST_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
export DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$TEST_DIR/.." && pwd)}"

# Source test framework
source "$TEST_DIR/lib/test_helpers.zsh"

# Test suite for cortex
describe "cortex AI management script tests"

# Setup before tests
setup_test
CORTEX="$DOTFILES_DIR/src/scripts/cortex"

# Test: Script exists and is executable
it "should exist and be executable" && {
  if [[ -f "$CORTEX" ]]; then
    if [[ -x "$CORTEX" ]]; then
      pass "Cortex script exists and is executable"
    else
      fail "Cortex script exists but is not executable"
    fi
  else
    fail "Cortex script not found at $CORTEX"
  fi
}

# Test: Script sets Python path correctly
it "should set PYTHONPATH for cortex module" && {
  if grep -q "PYTHONPATH" "$CORTEX" 2>/dev/null; then
    pass "Script sets PYTHONPATH"
  else
    fail "Script does not set PYTHONPATH"
  fi
}

# Test: Script calls cortex.cli module
it "should call cortex.cli module" && {
  if grep -q "cortex.cli" "$CORTEX" 2>/dev/null; then
    pass "Script calls cortex.cli module"
  else
    fail "Script does not call cortex.cli module"
  fi
}
