#!/usr/bin/env zsh

# unit.zsh - Unit testing framework for ZSH
# Provides assertions, test suites, mocking, and test reporting

# Source dependencies if available
[[ -f "${0:A:h}/colors.zsh" ]] && source "${0:A:h}/colors.zsh"
[[ -f "${0:A:h}/logging.zsh" ]] && source "${0:A:h}/logging.zsh"

# Test state
typeset -g UNIT_TEST_SUITE=""
typeset -g UNIT_TEST_NAME=""
typeset -gi UNIT_TESTS_RUN=0
typeset -gi UNIT_TESTS_PASSED=0
typeset -gi UNIT_TESTS_FAILED=0
typeset -gi UNIT_TESTS_SKIPPED=0
typeset -ga UNIT_TEST_FAILURES=()
typeset -gA UNIT_TEST_RESULTS=()
typeset -g UNIT_TEST_OUTPUT=""
typeset -g UNIT_VERBOSE=${UNIT_VERBOSE:-0}
typeset -g UNIT_STOP_ON_FAIL=${UNIT_STOP_ON_FAIL:-0}
typeset -g UNIT_COLOR=${UNIT_COLOR:-1}

# Mock state
typeset -gA UNIT_MOCKS=()
typeset -gA UNIT_MOCK_CALLS=()
typeset -gA UNIT_MOCK_RETURNS=()

# Test suite definition
test_suite() {
  local name="$1"
  UNIT_TEST_SUITE="$name"
  UNIT_TESTS_RUN=0
  UNIT_TESTS_PASSED=0
  UNIT_TESTS_FAILED=0
  UNIT_TESTS_SKIPPED=0
  UNIT_TEST_FAILURES=()

  _unit_print "TEST SUITE: $name" "CYAN" "BOLD"
  _unit_print "$(repeat '=' 50)" "CYAN"
}

# Define a test
test_case() {
  local name="$1"
  shift
  local test_function="$*"

  UNIT_TEST_NAME="$name"
  ((UNIT_TESTS_RUN++))

  if [[ $UNIT_VERBOSE -eq 1 ]]; then
    _unit_print "Running: $name" "BLUE"
  else
    echo -n "."
  fi

  # Capture test output
  local test_output=""
  local test_error=""
  local test_result=0

  # Run test in subshell to isolate
  (
    # Run test function
    eval "$test_function"
  ) 2>&1

  test_result=$?

  if [[ $test_result -eq 0 ]]; then
    ((UNIT_TESTS_PASSED++))
    UNIT_TEST_RESULTS[$name]="PASSED"
    if [[ $UNIT_VERBOSE -eq 1 ]]; then
      _unit_print "  ✓ PASSED" "GREEN"
    fi
  else
    ((UNIT_TESTS_FAILED++))
    UNIT_TEST_RESULTS[$name]="FAILED"
    UNIT_TEST_FAILURES+=("$name")
    if [[ $UNIT_VERBOSE -eq 0 ]]; then
      echo
    fi
    _unit_print "  ✗ FAILED: $name" "RED"

    if [[ $UNIT_STOP_ON_FAIL -eq 1 ]]; then
      _unit_print "Stopping on first failure" "YELLOW"
      test_summary
      exit 1
    fi
  fi
}

# Skip a test
test_skip() {
  local name="$1"
  local reason="${2:-}"

  UNIT_TEST_NAME="$name"
  ((UNIT_TESTS_SKIPPED++))
  UNIT_TEST_RESULTS[$name]="SKIPPED"

  if [[ $UNIT_VERBOSE -eq 1 ]]; then
    _unit_print "Skipping: $name" "YELLOW"
    [[ -n "$reason" ]] && _unit_print "  Reason: $reason" "YELLOW"
  else
    echo -n "s"
  fi
}

# Test summary
test_summary() {
  echo
  _unit_print "$(repeat '=' 50)" "CYAN"
  _unit_print "TEST SUMMARY" "CYAN" "BOLD"
  _unit_print "$(repeat '-' 50)" "CYAN"

  local total=$((UNIT_TESTS_PASSED + UNIT_TESTS_FAILED + UNIT_TESTS_SKIPPED))

  _unit_print "Total:   $total" "CYAN"
  _unit_print "Passed:  $UNIT_TESTS_PASSED" "GREEN"
  _unit_print "Failed:  $UNIT_TESTS_FAILED" "RED"
  _unit_print "Skipped: $UNIT_TESTS_SKIPPED" "YELLOW"

  if [[ ${#UNIT_TEST_FAILURES[@]} -gt 0 ]]; then
    echo
    _unit_print "Failed tests:" "RED" "BOLD"
    for test in "${UNIT_TEST_FAILURES[@]}"; do
      _unit_print "  • $test" "RED"
    done
  fi

  # Return failure if any tests failed
  [[ $UNIT_TESTS_FAILED -eq 0 ]]
}

# Assertions
# ==========

# Assert equality
assert_equals() {
  local expected="$1"
  local actual="$2"
  local message="${3:-Expected '$expected' but got '$actual'}"

  if [[ "$expected" != "$actual" ]]; then
    _unit_fail "$message"
  fi
}

# Assert inequality
assert_not_equals() {
  local unexpected="$1"
  local actual="$2"
  local message="${3:-Expected value different from '$unexpected' but got '$actual'}"

  if [[ "$unexpected" == "$actual" ]]; then
    _unit_fail "$message"
  fi
}

# Assert true
assert_true() {
  local condition="$1"
  local message="${2:-Expected condition to be true: $condition}"

  if ! eval "$condition"; then
    _unit_fail "$message"
  fi
}

# Assert false
assert_false() {
  local condition="$1"
  local message="${2:-Expected condition to be false: $condition}"

  if eval "$condition"; then
    _unit_fail "$message"
  fi
}

# Assert null/empty
assert_empty() {
  local value="$1"
  local message="${2:-Expected empty value but got '$value'}"

  if [[ -n "$value" ]]; then
    _unit_fail "$message"
  fi
}

# Assert not empty
assert_not_empty() {
  local value="$1"
  local message="${2:-Expected non-empty value}"

  if [[ -z "$value" ]]; then
    _unit_fail "$message"
  fi
}

# Assert contains
assert_contains() {
  local haystack="$1"
  local needle="$2"
  local message="${3:-Expected '$haystack' to contain '$needle'}"

  if [[ "$haystack" != *"$needle"* ]]; then
    _unit_fail "$message"
  fi
}

# Assert not contains
assert_not_contains() {
  local haystack="$1"
  local needle="$2"
  local message="${3:-Expected '$haystack' to not contain '$needle'}"

  if [[ "$haystack" == *"$needle"* ]]; then
    _unit_fail "$message"
  fi
}

# Assert starts with
assert_starts_with() {
  local string="$1"
  local prefix="$2"
  local message="${3:-Expected '$string' to start with '$prefix'}"

  if [[ "$string" != "$prefix"* ]]; then
    _unit_fail "$message"
  fi
}

# Assert ends with
assert_ends_with() {
  local string="$1"
  local suffix="$2"
  local message="${3:-Expected '$string' to end with '$suffix'}"

  if [[ "$string" != *"$suffix" ]]; then
    _unit_fail "$message"
  fi
}

# Assert matches regex
assert_matches() {
  local string="$1"
  local pattern="$2"
  local message="${3:-Expected '$string' to match pattern '$pattern'}"

  if ! [[ "$string" =~ $pattern ]]; then
    _unit_fail "$message"
  fi
}

# Assert file exists
assert_file_exists() {
  local file="$1"
  local message="${2:-Expected file to exist: $file}"

  if [[ ! -f "$file" ]]; then
    _unit_fail "$message"
  fi
}

# Assert directory exists
assert_dir_exists() {
  local dir="$1"
  local message="${2:-Expected directory to exist: $dir}"

  if [[ ! -d "$dir" ]]; then
    _unit_fail "$message"
  fi
}

# Assert command succeeds
assert_success() {
  local command="$1"
  local message="${2:-Expected command to succeed: $command}"

  if ! eval "$command" >/dev/null 2>&1; then
    _unit_fail "$message"
  fi
}

# Assert command fails
assert_failure() {
  local command="$1"
  local message="${2:-Expected command to fail: $command}"

  if eval "$command" >/dev/null 2>&1; then
    _unit_fail "$message"
  fi
}

# Assert exit code
assert_exit_code() {
  local expected="$1"
  local command="$2"
  local message="${3:-Expected exit code $expected}"

  eval "$command" >/dev/null 2>&1
  local actual=$?

  if [[ $actual -ne $expected ]]; then
    _unit_fail "$message (got $actual)"
  fi
}

# Assert array equals
assert_array_equals() {
  local -a expected=("${!1}")
  local -a actual=("${!2}")
  local message="${3:-Arrays are not equal}"

  if [[ ${#expected[@]} -ne ${#actual[@]} ]]; then
    _unit_fail "$message (different lengths: ${#expected[@]} vs ${#actual[@]})"
  fi

  for i in {1..${#expected[@]}}; do
    if [[ "${expected[$i]}" != "${actual[$i]}" ]]; then
      _unit_fail "$message (element $i: '${expected[$i]}' != '${actual[$i]}')"
    fi
  done
}

# Assert numeric comparison
assert_greater_than() {
  local actual="$1"
  local threshold="$2"
  local message="${3:-Expected $actual > $threshold}"

  if [[ $actual -le $threshold ]]; then
    _unit_fail "$message"
  fi
}

assert_less_than() {
  local actual="$1"
  local threshold="$2"
  local message="${3:-Expected $actual < $threshold}"

  if [[ $actual -ge $threshold ]]; then
    _unit_fail "$message"
  fi
}

# Mocking
# =======

# Create a mock function
mock() {
  local func_name="$1"
  local return_value="${2:-}"

  # Save original function if it exists
  if declare -f "$func_name" >/dev/null 2>&1; then
    UNIT_MOCKS[$func_name]="$(declare -f "$func_name")"
  fi

  # Reset call count
  UNIT_MOCK_CALLS[$func_name]=0
  UNIT_MOCK_RETURNS[$func_name]="$return_value"

  # Create mock function
  eval "
    $func_name() {
        ((UNIT_MOCK_CALLS[$func_name]++))
        echo \"\${UNIT_MOCK_RETURNS[$func_name]}\"
        return 0
    }
    "
}

# Restore original function
unmock() {
  local func_name="$1"

  if [[ -n "${UNIT_MOCKS[$func_name]}" ]]; then
    eval "${UNIT_MOCKS[$func_name]}"
    unset "UNIT_MOCKS[$func_name]"
  else
    unset -f "$func_name" 2>/dev/null
  fi

  unset "UNIT_MOCK_CALLS[$func_name]"
  unset "UNIT_MOCK_RETURNS[$func_name]"
}

# Get mock call count
mock_calls() {
  local func_name="$1"
  echo "${UNIT_MOCK_CALLS[$func_name]:-0}"
}

# Assert mock was called
assert_called() {
  local func_name="$1"
  local expected_calls="${2:-1}"
  local actual_calls="${UNIT_MOCK_CALLS[$func_name]:-0}"

  if [[ $actual_calls -ne $expected_calls ]]; then
    _unit_fail "Expected $func_name to be called $expected_calls time(s), but was called $actual_calls time(s)"
  fi
}

# Assert mock was not called
assert_not_called() {
  local func_name="$1"
  local actual_calls="${UNIT_MOCK_CALLS[$func_name]:-0}"

  if [[ $actual_calls -ne 0 ]]; then
    _unit_fail "Expected $func_name to not be called, but was called $actual_calls time(s)"
  fi
}

# Fixtures
# ========

# Setup function (run before each test)
setup() {
  : # Override in test files
}

# Teardown function (run after each test)
teardown() {
  : # Override in test files
}

# Run setup and teardown around test
with_fixtures() {
  local test_function="$1"

  setup
  local result=0
  eval "$test_function" || result=$?
  teardown

  return $result
}

# Helper functions
# ================

# Fail test with message
_unit_fail() {
  local message="$1"
  if [[ $UNIT_VERBOSE -eq 1 ]]; then
    _unit_print "    ASSERTION FAILED: $message" "RED"
  else
    echo
    _unit_print "ASSERTION FAILED in '$UNIT_TEST_NAME': $message" "RED"
  fi
  return 1
}

# Print with optional color
_unit_print() {
  local message="$1"
  local color="${2:-}"
  local style="${3:-}"

  if [[ $UNIT_COLOR -eq 1 ]] && [[ -n "$color" ]]; then
    if [[ -n "${COLORS[$color]}" ]]; then
      local color_code="${COLORS[$color]}"
      local style_code=""
      [[ -n "$style" ]] && [[ -n "${STYLES[$style]}" ]] && style_code="${STYLES[$style]}"
      echo -e "${style_code}${color_code}${message}${STYLES[RESET]}"
    else
      echo "$message"
    fi
  else
    echo "$message"
  fi
}

# Run all test functions in current scope
run_tests() {
  local pattern="${1:-test_*}"

  for func in $(declare -F | awk '{print $3}' | grep "^$pattern"); do
    test_case "$func" "$func"
  done

  test_summary
}
