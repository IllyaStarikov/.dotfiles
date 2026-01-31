#!/usr/bin/env zsh
# Unit tests for yaml.zsh library

# Get the test directory path
TEST_DIR="$(cd "$(dirname "$(dirname "$(dirname "$0")")")" && pwd)"
DOTFILES_DIR="$(dirname "$TEST_DIR")"

# Set up test environment
export TEST_TMP_DIR="${TEST_TMP_DIR:-/tmp/dotfiles_test_$$}"
mkdir -p "$TEST_TMP_DIR"

# Test framework
source "${TEST_DIR}/lib/test_helpers.zsh"

# Source the library under test
source "${DOTFILES_DIR}/src/lib/yaml.zsh" 2>/dev/null || {
  test_suite "YAML Library"
  skip "yaml.zsh not found"
  exit 0
}

# ============================================================================
# YAML Encoding Tests
# ============================================================================

test_yaml_encode_string() {
  test_case "yaml_encode_scalar encodes string"
  if declare -f yaml_encode_scalar >/dev/null 2>&1; then
    local result=$(yaml_encode_scalar "hello")
    if [[ -n "$result" ]]; then
      pass
    else
      fail "Expected encoded string"
    fi
  else
    skip "yaml_encode_scalar not available"
  fi
}

test_yaml_encode_number() {
  test_case "yaml_encode_scalar encodes number"
  if declare -f yaml_encode_scalar >/dev/null 2>&1; then
    local result=$(yaml_encode_scalar 42)
    if [[ "$result" == "42" ]]; then
      pass
    else
      fail "Expected '42', got: '$result'"
    fi
  else
    skip "yaml_encode_scalar not available"
  fi
}

test_yaml_encode_bool() {
  test_case "yaml_encode_scalar encodes boolean"
  if declare -f yaml_encode_scalar >/dev/null 2>&1; then
    local result=$(yaml_encode_scalar "true")
    if [[ "$result" == "true" ]]; then
      pass
    else
      fail "Expected 'true', got: '$result'"
    fi
  else
    skip "yaml_encode_scalar not available"
  fi
}

# ============================================================================
# YAML Quote Tests
# ============================================================================

test_yaml_quote_string() {
  test_case "yaml_quote_string handles special chars"
  if declare -f yaml_quote_string >/dev/null 2>&1; then
    local result=$(yaml_quote_string "hello: world")
    if [[ "$result" == *"hello"* ]]; then
      pass
    else
      fail "Quoting failed"
    fi
  else
    skip "yaml_quote_string not available"
  fi
}

# ============================================================================
# YAML Validation Tests
# ============================================================================

test_yaml_validate_basic() {
  test_case "yaml_validate_basic checks YAML"
  if declare -f yaml_validate_basic >/dev/null 2>&1; then
    if yaml_validate_basic "key: value"; then
      pass
    else
      fail "Valid YAML rejected"
    fi
  else
    skip "yaml_validate_basic not available"
  fi
}

# ============================================================================
# YAML Decoding Tests
# ============================================================================

test_yaml_decode_value_string() {
  test_case "yaml_decode_value decodes string"
  if declare -f yaml_decode_value >/dev/null 2>&1; then
    local result=$(yaml_decode_value "hello")
    if [[ "$result" == "hello" ]]; then
      pass
    else
      fail "Expected 'hello', got: '$result'"
    fi
  else
    skip "yaml_decode_value not available"
  fi
}

test_yaml_decode_value_bool() {
  test_case "yaml_decode_value decodes bool"
  if declare -f yaml_decode_value >/dev/null 2>&1; then
    local result=$(yaml_decode_value "true")
    if [[ "$result" == "true" ]] || [[ "$result" == "1" ]]; then
      pass
    else
      fail "Expected boolean, got: '$result'"
    fi
  else
    skip "yaml_decode_value not available"
  fi
}

test_yaml_decode_value_null() {
  test_case "yaml_decode_value decodes null"
  if declare -f yaml_decode_value >/dev/null 2>&1; then
    local result=$(yaml_decode_value "null")
    if [[ -z "$result" ]] || [[ "$result" == "null" ]]; then
      pass
    else
      fail "Expected null/empty, got: '$result'"
    fi
  else
    skip "yaml_decode_value not available"
  fi
}

# ============================================================================
# Run Tests
# ============================================================================

test_suite "YAML Library" \
  test_yaml_encode_string \
  test_yaml_encode_number \
  test_yaml_encode_bool \
  test_yaml_quote_string \
  test_yaml_validate_basic \
  test_yaml_decode_value_string \
  test_yaml_decode_value_bool \
  test_yaml_decode_value_null
