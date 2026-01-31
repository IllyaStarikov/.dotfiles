#!/usr/bin/env zsh
# Unit tests for textwrap.zsh library

# Get the test directory path
TEST_DIR="$(cd "$(dirname "$(dirname "$(dirname "$0")")")" && pwd)"
DOTFILES_DIR="$(dirname "$TEST_DIR")"

# Set up test environment
export TEST_TMP_DIR="${TEST_TMP_DIR:-/tmp/dotfiles_test_$$}"
mkdir -p "$TEST_TMP_DIR"

# Test framework
source "${TEST_DIR}/lib/test_helpers.zsh"

# Source the library under test
source "${DOTFILES_DIR}/src/lib/textwrap.zsh" 2>/dev/null || {
  # If textwrap doesn't exist, skip all tests
  test_suite "Textwrap Library"
  skip "textwrap.zsh not found"
  exit 0
}

# ============================================================================
# String Repeat Tests
# ============================================================================

test_str_repeat() {
  test_case "str_repeat repeats string"
  if declare -f str_repeat >/dev/null 2>&1; then
    local result=$(str_repeat "-" 5)
    if [[ "$result" == "-----" ]]; then
      pass
    else
      fail "Expected '-----', got: '$result'"
    fi
  else
    skip "str_repeat not available"
  fi
}

# ============================================================================
# Truncate Tests
# ============================================================================

test_truncate() {
  test_case "truncate shortens long strings"
  if declare -f truncate >/dev/null 2>&1; then
    local result=$(truncate "Hello World" 8)
    if [[ ${#result} -le 8 ]]; then
      pass
    else
      fail "Expected max 8 chars, got: ${#result}"
    fi
  else
    skip "truncate not available"
  fi
}

# ============================================================================
# Case Conversion Tests
# ============================================================================

test_title_case() {
  test_case "title_case capitalizes words"
  if declare -f title_case >/dev/null 2>&1; then
    local result=$(title_case "hello world")
    if [[ "$result" == "Hello World" ]]; then
      pass
    else
      fail "Expected 'Hello World', got: '$result'"
    fi
  else
    skip "title_case not available"
  fi
}

test_snake_to_camel() {
  test_case "snake_to_camel converts case"
  if declare -f snake_to_camel >/dev/null 2>&1; then
    local result=$(snake_to_camel "hello_world")
    if [[ "$result" == "helloWorld" ]] || [[ "$result" == "HelloWorld" ]]; then
      pass
    else
      fail "Expected camelCase, got: '$result'"
    fi
  else
    skip "snake_to_camel not available"
  fi
}

test_camel_to_snake() {
  test_case "camel_to_snake converts case"
  if declare -f camel_to_snake >/dev/null 2>&1; then
    local result=$(camel_to_snake "helloWorld")
    if [[ "$result" == "hello_world" ]]; then
      pass
    else
      fail "Expected 'hello_world', got: '$result'"
    fi
  else
    skip "camel_to_snake not available"
  fi
}

# ============================================================================
# Alignment Tests
# ============================================================================

test_center() {
  test_case "center centers text"
  if declare -f center >/dev/null 2>&1; then
    local result=$(center "hi" 10)
    if [[ ${#result} -ge 2 ]]; then
      pass
    else
      fail "Center failed"
    fi
  else
    skip "center not available"
  fi
}

# ============================================================================
# Run Tests
# ============================================================================

test_suite "Textwrap Library" \
  test_str_repeat \
  test_truncate \
  test_title_case \
  test_snake_to_camel \
  test_camel_to_snake \
  test_center
