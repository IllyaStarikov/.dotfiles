#!/usr/bin/env zsh
# Unit tests for json.zsh library

# Get the test directory path
TEST_DIR="$(cd "$(dirname "$(dirname "$(dirname "$0")")")" && pwd)"
DOTFILES_DIR="$(dirname "$TEST_DIR")"

# Set up test environment
export TEST_TMP_DIR="${TEST_TMP_DIR:-/tmp/dotfiles_test_$$}"
mkdir -p "$TEST_TMP_DIR"

# Test framework
source "${TEST_DIR}/lib/test_helpers.zsh"

# Source the library under test
source "${DOTFILES_DIR}/src/lib/json.zsh"

# Check if jq is available for advanced tests
JQ_AVAILABLE=0
command -v jq >/dev/null 2>&1 && JQ_AVAILABLE=1

# ============================================================================
# JSON Encoding Tests
# ============================================================================

test_json_encode_string() {
  test_case "json_encode_string encodes string"
  local result=$(json_encode_string "hello")
  if [[ "$result" == '"hello"' ]]; then
    pass
  else
    fail "Expected '\"hello\"', got: '$result'"
  fi
}

test_json_encode_string_with_quotes() {
  test_case "json_encode_string escapes quotes"
  local result=$(json_encode_string 'say "hello"')
  if [[ "$result" == '"say \"hello\""' ]]; then
    pass
  else
    fail "Expected '\"say \\\"hello\\\"\"', got: '$result'"
  fi
}

test_json_encode_string_with_newline() {
  test_case "json_encode_string escapes newlines"
  local result=$(json_encode_string $'line1\nline2')
  if [[ "$result" == '"line1\nline2"' ]]; then
    pass
  else
    fail "Expected '\"line1\\nline2\"', got: '$result'"
  fi
}

test_json_encode_string_with_tab() {
  test_case "json_encode_string escapes tabs"
  local result=$(json_encode_string $'col1\tcol2')
  if [[ "$result" == '"col1\tcol2"' ]]; then
    pass
  else
    fail "Expected '\"col1\\tcol2\"', got: '$result'"
  fi
}

test_json_encode_string_with_backslash() {
  test_case "json_encode_string escapes backslashes"
  local result=$(json_encode_string 'path\to\file')
  if [[ "$result" == '"path\\to\\file"' ]]; then
    pass
  else
    fail "Expected '\"path\\\\to\\\\file\"', got: '$result'"
  fi
}

test_json_encode_bool_true() {
  test_case "json_encode_bool returns true"
  local result=$(json_encode_bool "true")
  if [[ "$result" == "true" ]]; then
    pass
  else
    fail "Expected 'true', got: '$result'"
  fi
}

test_json_encode_bool_false() {
  test_case "json_encode_bool returns false"
  local result=$(json_encode_bool "false")
  if [[ "$result" == "false" ]]; then
    pass
  else
    fail "Expected 'false', got: '$result'"
  fi
}

test_json_encode_bool_yes() {
  test_case "json_encode_bool converts yes to true"
  local result=$(json_encode_bool "yes")
  if [[ "$result" == "true" ]]; then
    pass
  else
    fail "Expected 'true', got: '$result'"
  fi
}

test_json_encode_bool_no() {
  test_case "json_encode_bool converts no to false"
  local result=$(json_encode_bool "no")
  if [[ "$result" == "false" ]]; then
    pass
  else
    fail "Expected 'false', got: '$result'"
  fi
}

test_json_encode_bool_one() {
  test_case "json_encode_bool converts 1 to true"
  local result=$(json_encode_bool "1")
  if [[ "$result" == "true" ]]; then
    pass
  else
    fail "Expected 'true', got: '$result'"
  fi
}

test_json_encode_bool_zero() {
  test_case "json_encode_bool converts 0 to false"
  local result=$(json_encode_bool "0")
  if [[ "$result" == "false" ]]; then
    pass
  else
    fail "Expected 'false', got: '$result'"
  fi
}

test_json_encode_bool_invalid() {
  test_case "json_encode_bool returns null for invalid"
  local result=$(json_encode_bool "maybe")
  if [[ "$result" == "null" ]]; then
    pass
  else
    fail "Expected 'null', got: '$result'"
  fi
}

test_json_encode_number_integer() {
  test_case "json_encode_number encodes integer"
  local result=$(json_encode_number "42")
  if [[ "$result" == "42" ]]; then
    pass
  else
    fail "Expected '42', got: '$result'"
  fi
}

test_json_encode_number_negative() {
  test_case "json_encode_number encodes negative"
  local result=$(json_encode_number "-42")
  if [[ "$result" == "-42" ]]; then
    pass
  else
    fail "Expected '-42', got: '$result'"
  fi
}

test_json_encode_number_float() {
  test_case "json_encode_number encodes float"
  local result=$(json_encode_number "3.14")
  if [[ "$result" == "3.14" ]]; then
    pass
  else
    fail "Expected '3.14', got: '$result'"
  fi
}

test_json_encode_number_invalid() {
  test_case "json_encode_number returns null for invalid"
  local result=$(json_encode_number "abc")
  if [[ "$result" == "null" ]]; then
    pass
  else
    fail "Expected 'null', got: '$result'"
  fi
}

# ============================================================================
# JSON Auto-Encoding Tests
# ============================================================================

test_json_encode_auto_null() {
  test_case "json_encode_auto encodes null"
  local result=$(json_encode_auto "null")
  if [[ "$result" == "null" ]]; then
    pass
  else
    fail "Expected 'null', got: '$result'"
  fi
}

test_json_encode_auto_empty() {
  test_case "json_encode_auto encodes empty as null"
  local result=$(json_encode_auto "")
  if [[ "$result" == "null" ]]; then
    pass
  else
    fail "Expected 'null', got: '$result'"
  fi
}

test_json_encode_auto_true() {
  test_case "json_encode_auto encodes true"
  local result=$(json_encode_auto "true")
  if [[ "$result" == "true" ]]; then
    pass
  else
    fail "Expected 'true', got: '$result'"
  fi
}

test_json_encode_auto_false() {
  test_case "json_encode_auto encodes false"
  local result=$(json_encode_auto "false")
  if [[ "$result" == "false" ]]; then
    pass
  else
    fail "Expected 'false', got: '$result'"
  fi
}

test_json_encode_auto_number() {
  test_case "json_encode_auto encodes number"
  local result=$(json_encode_auto "42")
  if [[ "$result" == "42" ]]; then
    pass
  else
    fail "Expected '42', got: '$result'"
  fi
}

test_json_encode_auto_string() {
  test_case "json_encode_auto encodes string"
  local result=$(json_encode_auto "hello world")
  if [[ "$result" == '"hello world"' ]]; then
    pass
  else
    fail "Expected '\"hello world\"', got: '$result'"
  fi
}

# ============================================================================
# JSON Decoding Tests
# ============================================================================

test_json_decode_basic_null() {
  test_case "json_decode_basic decodes null"
  local result=$(json_decode_basic "null")
  if [[ -z "$result" ]]; then
    pass
  else
    fail "Expected empty string, got: '$result'"
  fi
}

test_json_decode_basic_true() {
  test_case "json_decode_basic decodes true"
  local result=$(json_decode_basic "true")
  if [[ "$result" == "true" ]]; then
    pass
  else
    fail "Expected 'true', got: '$result'"
  fi
}

test_json_decode_basic_false() {
  test_case "json_decode_basic decodes false"
  local result=$(json_decode_basic "false")
  if [[ "$result" == "false" ]]; then
    pass
  else
    fail "Expected 'false', got: '$result'"
  fi
}

test_json_decode_basic_number() {
  test_case "json_decode_basic decodes number"
  local result=$(json_decode_basic "42")
  if [[ "$result" == "42" ]]; then
    pass
  else
    fail "Expected '42', got: '$result'"
  fi
}

test_json_decode_string_unescape_newline() {
  test_case "json_decode_string unescapes newlines"
  local result=$(json_decode_string 'line1\nline2')
  if [[ "$result" == $'line1\nline2' ]]; then
    pass
  else
    fail "Expected two-line string, got: '$result'"
  fi
}

test_json_decode_string_unescape_tab() {
  test_case "json_decode_string unescapes tabs"
  local result=$(json_decode_string 'col1\tcol2')
  if [[ "$result" == $'col1\tcol2' ]]; then
    pass
  else
    fail "Expected tabbed string, got: '$result'"
  fi
}

# ============================================================================
# JSON Validation Tests
# ============================================================================

test_json_validate_basic_valid_object() {
  test_case "json_validate_basic validates balanced braces"
  if json_validate_basic '{"key":"value"}'; then
    pass
  else
    fail "Expected valid for balanced braces"
  fi
}

test_json_validate_basic_valid_array() {
  test_case "json_validate_basic validates balanced brackets"
  if json_validate_basic '[1,2,3]'; then
    pass
  else
    fail "Expected valid for balanced brackets"
  fi
}

test_json_validate_basic_unbalanced_braces() {
  test_case "json_validate_basic detects unbalanced braces"
  if ! json_validate_basic '{"key":"value"'; then
    pass
  else
    fail "Expected invalid for unbalanced braces"
  fi
}

test_json_validate_basic_empty() {
  test_case "json_validate_basic rejects empty"
  if ! json_validate_basic ''; then
    pass
  else
    fail "Expected invalid for empty string"
  fi
}

# ============================================================================
# JSON Type Detection Tests
# ============================================================================

test_json_get_type_basic_null() {
  test_case "json_get_type_basic detects null"
  local result=$(json_get_type_basic "null")
  if [[ "$result" == "null" ]]; then
    pass
  else
    fail "Expected 'null', got: '$result'"
  fi
}

test_json_get_type_basic_boolean() {
  test_case "json_get_type_basic detects boolean"
  local result=$(json_get_type_basic "true")
  if [[ "$result" == "boolean" ]]; then
    pass
  else
    fail "Expected 'boolean', got: '$result'"
  fi
}

test_json_get_type_basic_number() {
  test_case "json_get_type_basic detects number"
  local result=$(json_get_type_basic "42")
  if [[ "$result" == "number" ]]; then
    pass
  else
    fail "Expected 'number', got: '$result'"
  fi
}

test_json_get_type_basic_string() {
  test_case "json_get_type_basic detects string"
  local result=$(json_get_type_basic '"hello"')
  if [[ "$result" == "string" ]]; then
    pass
  else
    fail "Expected 'string', got: '$result'"
  fi
}

test_json_get_type_basic_array() {
  test_case "json_get_type_basic detects array"
  local result=$(json_get_type_basic '[1,2,3]')
  if [[ "$result" == "array" ]]; then
    pass
  else
    fail "Expected 'array', got: '$result'"
  fi
}

test_json_get_type_basic_object() {
  test_case "json_get_type_basic detects object"
  local result=$(json_get_type_basic '{"key":"value"}')
  if [[ "$result" == "object" ]]; then
    pass
  else
    fail "Expected 'object', got: '$result'"
  fi
}

# ============================================================================
# JSON Builder Tests
# ============================================================================

test_json_object_empty() {
  test_case "json_object creates empty object"
  local result=$(json_object)
  if [[ "$result" == "{}" ]]; then
    pass
  else
    fail "Expected '{}', got: '$result'"
  fi
}

test_json_object_single_key() {
  test_case "json_object creates object with single key"
  local result=$(json_object "name" "John")
  if [[ "$result" == '{"name":"John"}' ]]; then
    pass
  else
    fail "Expected '{\"name\":\"John\"}', got: '$result'"
  fi
}

test_json_object_multiple_keys() {
  test_case "json_object creates object with multiple keys"
  local result=$(json_object "name" "John" "age" "30")
  # Order may vary, check for both keys
  if [[ "$result" == *'"name":"John"'* ]] && [[ "$result" == *'"age":30'* ]]; then
    pass
  else
    fail "Expected object with name and age, got: '$result'"
  fi
}

test_json_array_empty() {
  test_case "json_array creates empty array"
  local result=$(json_array)
  if [[ "$result" == "[]" ]]; then
    pass
  else
    fail "Expected '[]', got: '$result'"
  fi
}

test_json_array_single_element() {
  test_case "json_array creates array with single element"
  local result=$(json_array "hello")
  if [[ "$result" == '["hello"]' ]]; then
    pass
  else
    fail "Expected '[\"hello\"]', got: '$result'"
  fi
}

test_json_array_multiple_elements() {
  test_case "json_array creates array with multiple elements"
  local result=$(json_array "a" "b" "c")
  if [[ "$result" == '["a","b","c"]' ]]; then
    pass
  else
    fail "Expected '[\"a\",\"b\",\"c\"]', got: '$result'"
  fi
}

test_json_array_numbers() {
  test_case "json_array creates array with numbers"
  local result=$(json_array 1 2 3)
  if [[ "$result" == '[1,2,3]' ]]; then
    pass
  else
    fail "Expected '[1,2,3]', got: '$result'"
  fi
}

test_json_array_mixed() {
  test_case "json_array creates array with mixed types"
  local result=$(json_array "hello" 42 "true")
  # Note: "true" is a string, true would be bool
  if [[ "$result" == '["hello",42,true]' ]]; then
    pass
  else
    fail "Expected '[\"hello\",42,true]', got: '$result'"
  fi
}

# ============================================================================
# JSON File Operations Tests
# ============================================================================

test_json_read_existing_file() {
  test_case "json_read reads existing file"
  local testfile="$TEST_TMP_DIR/test.json"
  echo '{"key":"value"}' >"$testfile"
  local result=$(json_read "$testfile")
  if [[ "$result" == '{"key":"value"}' ]]; then
    pass
  else
    fail "Expected '{\"key\":\"value\"}', got: '$result'"
  fi
  rm -f "$testfile"
}

test_json_read_missing_file() {
  test_case "json_read returns {} for missing file"
  local result=$(json_read "$TEST_TMP_DIR/nonexistent.json")
  if [[ "$result" == "{}" ]]; then
    pass
  else
    fail "Expected '{}', got: '$result'"
  fi
}

test_json_write() {
  test_case "json_write writes to file"
  local testfile="$TEST_TMP_DIR/output.json"
  json_write "$testfile" '{"key":"value"}'
  if [[ -f "$testfile" ]]; then
    local content=$(cat "$testfile")
    if [[ "$content" == '{"key":"value"}' ]]; then
      pass
    else
      fail "File content mismatch: '$content'"
    fi
  else
    fail "File was not created"
  fi
  rm -f "$testfile"
}

# ============================================================================
# JSON jq-dependent Tests (skip if jq not available)
# ============================================================================

test_json_get_with_jq() {
  test_case "json_get extracts value (requires jq)"
  if [[ $JQ_AVAILABLE -eq 0 ]]; then
    skip "jq not available"
    return
  fi

  local result=$(json_get '{"name":"John","age":30}' '.name')
  if [[ "$result" == "John" ]]; then
    pass
  else
    fail "Expected 'John', got: '$result'"
  fi
}

test_json_get_with_default() {
  test_case "json_get returns default for missing key (requires jq)"
  if [[ $JQ_AVAILABLE -eq 0 ]]; then
    skip "jq not available"
    return
  fi

  local result=$(json_get '{"name":"John"}' '.missing' "default")
  if [[ "$result" == "default" ]]; then
    pass
  else
    fail "Expected 'default', got: '$result'"
  fi
}

test_json_validate_with_jq() {
  test_case "json_validate validates JSON (requires jq)"
  if [[ $JQ_AVAILABLE -eq 0 ]]; then
    skip "jq not available"
    return
  fi

  if json_validate '{"key":"value"}'; then
    pass
  else
    fail "Expected valid JSON"
  fi
}

test_json_compact_with_jq() {
  test_case "json_compact removes whitespace (requires jq)"
  if [[ $JQ_AVAILABLE -eq 0 ]]; then
    skip "jq not available"
    return
  fi

  local result=$(json_compact '{ "key" : "value" }')
  if [[ "$result" == '{"key":"value"}' ]]; then
    pass
  else
    fail "Expected '{\"key\":\"value\"}', got: '$result'"
  fi
}

# ============================================================================
# Run Tests
# ============================================================================

test_suite "JSON Library" \
  test_json_encode_string \
  test_json_encode_string_with_quotes \
  test_json_encode_string_with_newline \
  test_json_encode_string_with_tab \
  test_json_encode_string_with_backslash \
  test_json_encode_bool_true \
  test_json_encode_bool_false \
  test_json_encode_bool_yes \
  test_json_encode_bool_no \
  test_json_encode_bool_one \
  test_json_encode_bool_zero \
  test_json_encode_bool_invalid \
  test_json_encode_number_integer \
  test_json_encode_number_negative \
  test_json_encode_number_float \
  test_json_encode_number_invalid \
  test_json_encode_auto_null \
  test_json_encode_auto_empty \
  test_json_encode_auto_true \
  test_json_encode_auto_false \
  test_json_encode_auto_number \
  test_json_encode_auto_string \
  test_json_decode_basic_null \
  test_json_decode_basic_true \
  test_json_decode_basic_false \
  test_json_decode_basic_number \
  test_json_decode_string_unescape_newline \
  test_json_decode_string_unescape_tab \
  test_json_validate_basic_valid_object \
  test_json_validate_basic_valid_array \
  test_json_validate_basic_unbalanced_braces \
  test_json_validate_basic_empty \
  test_json_get_type_basic_null \
  test_json_get_type_basic_boolean \
  test_json_get_type_basic_number \
  test_json_get_type_basic_string \
  test_json_get_type_basic_array \
  test_json_get_type_basic_object \
  test_json_object_empty \
  test_json_object_single_key \
  test_json_object_multiple_keys \
  test_json_array_empty \
  test_json_array_single_element \
  test_json_array_multiple_elements \
  test_json_array_numbers \
  test_json_array_mixed \
  test_json_read_existing_file \
  test_json_read_missing_file \
  test_json_write \
  test_json_get_with_jq \
  test_json_get_with_default \
  test_json_validate_with_jq \
  test_json_compact_with_jq
