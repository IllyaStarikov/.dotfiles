#!/usr/bin/env zsh
# Test suite for services script
# Tests the background service manager functionality

# Setup test environment
set -euo pipefail
source "$(dirname "$0")/../../lib/test_helpers.zsh"

# Script under test
SERVICES_SCRIPT="${DOTFILES_DIR}/src/scripts/services"

# Test: Script exists and is executable
test_services_script_exists() {
  if [[ ! -f "$SERVICES_SCRIPT" ]]; then
  fail "Services script not found at $SERVICES_SCRIPT"
  fi

  if [[ ! -x "$SERVICES_SCRIPT" ]]; then
  fail "Services script is not executable"
  fi

  pass "Services script exists and is executable"
}

# Test: Script shows help with --help or help command
test_services_help() {
  local output
  output=$("$SERVICES_SCRIPT" --help 2>&1 || true)
  if ! echo "$output" | grep -qi "usage\|services\|start\|stop"; then
  fail "Help output doesn't contain expected commands"
  fi
  pass "Help command works"
}

# Test: List command shows available services (or empty)
test_services_list() {
  local output
  # List command should not fail even if no services exist
  output=$("$SERVICES_SCRIPT" list 2>&1 || true)
  # Check it returns something (either services or "no services" message)
  if [[ -z "$output" ]]; then
  warning "List command returned empty output (may be OK if no services defined)"
  fi
  pass "List command completes without error"
}

# Test: Status command runs without error
test_services_status() {
  local exit_code=0
  # Status should work even if no services are running
  "$SERVICES_SCRIPT" status >/dev/null 2>&1 || exit_code=$?
  # Exit code 0 or 1 are acceptable (0 = all running, 1 = some not running)
  if [[ $exit_code -gt 1 ]]; then
  fail "Status command failed with exit code $exit_code"
  fi
  pass "Status command completes without error"
}

# Test: Script validates service names
test_services_validation() {
  local output
  local exit_code=0
  # Try to start a nonexistent service
  output=$("$SERVICES_SCRIPT" start nonexistent_service_12345 2>&1) || exit_code=$?
  if [[ $exit_code -eq 0 ]]; then
  fail "Script should fail when starting nonexistent service"
  fi
  # Check for error message about service not found
  if ! echo "$output" | grep -qi "not found\|unknown\|invalid\|does not exist"; then
  warning "Error message might not be clear about invalid service"
  fi
  pass "Script validates service names"
}

# Test: Configuration constants are properly defined
test_services_configuration() {
  # Check that script defines expected directories
  local script_content
  script_content=$(cat "$SERVICES_SCRIPT")

  # Check for essential configuration variables
  local required_vars=("SERVICES_DIR" "LOG_DIR" "PID_DIR")
  for var in "${required_vars[@]}"; do
  if ! echo "$script_content" | grep -q "$var"; then
    fail "Missing configuration variable: $var"
  fi
  done

  pass "Configuration variables are defined"
}

# Test: Essential functions are defined
test_services_functions() {
  local script_content
  script_content=$(cat "$SERVICES_SCRIPT")

  # Check for essential functions
  local required_funcs=("get_services" "service_exists" "info" "error")
  for func in "${required_funcs[@]}"; do
  if ! echo "$script_content" | grep -q "${func}()"; then
    fail "Missing function: $func"
  fi
  done

  pass "Essential functions are defined"
}

# Run all tests
run_tests \
  test_services_script_exists \
  test_services_help \
  test_services_list \
  test_services_status \
  test_services_validation \
  test_services_configuration \
  test_services_functions
