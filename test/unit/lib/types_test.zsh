#!/usr/bin/env zsh
# Unit tests for types.zsh library

# Get the test directory path
TEST_DIR="$(cd "$(dirname "$(dirname "$(dirname "$0")")")" && pwd)"
DOTFILES_DIR="$(dirname "$TEST_DIR")"

# Set up test environment
export TEST_TMP_DIR="${TEST_TMP_DIR:-/tmp/dotfiles_test_$$}"
mkdir -p "$TEST_TMP_DIR"

# Test framework
source "${TEST_DIR}/lib/test_helpers.zsh"

# Source the library under test
source "${DOTFILES_DIR}/src/lib/types.zsh"

# ============================================================================
# Basic Type Checking Tests
# ============================================================================

test_is_int_positive() {
  test_case "is_int returns true for positive integer"
  if is_int "42"; then
    pass
  else
    fail "Expected true for '42'"
  fi
}

test_is_int_negative() {
  test_case "is_int returns true for negative integer"
  if is_int "-42"; then
    pass
  else
    fail "Expected true for '-42'"
  fi
}

test_is_int_zero() {
  test_case "is_int returns true for zero"
  if is_int "0"; then
    pass
  else
    fail "Expected true for '0'"
  fi
}

test_is_int_not_int() {
  test_case "is_int returns false for non-integer"
  if ! is_int "3.14"; then
    pass
  else
    fail "Expected false for '3.14'"
  fi
}

test_is_int_string() {
  test_case "is_int returns false for string"
  if ! is_int "hello"; then
    pass
  else
    fail "Expected false for 'hello'"
  fi
}

test_is_float_with_decimal() {
  test_case "is_float returns true for decimal number"
  if is_float "3.14"; then
    pass
  else
    fail "Expected true for '3.14'"
  fi
}

test_is_float_negative() {
  test_case "is_float returns true for negative float"
  if is_float "-3.14"; then
    pass
  else
    fail "Expected true for '-3.14'"
  fi
}

test_is_float_integer_accepted() {
  test_case "is_float accepts integers"
  if is_float "42"; then
    pass
  else
    fail "Expected true for '42' (integers are floats)"
  fi
}

test_is_number_int() {
  test_case "is_number returns true for integer"
  if is_number "42"; then
    pass
  else
    fail "Expected true for '42'"
  fi
}

test_is_number_float() {
  test_case "is_number returns true for float"
  if is_number "3.14"; then
    pass
  else
    fail "Expected true for '3.14'"
  fi
}

test_is_number_string() {
  test_case "is_number returns false for string"
  if ! is_number "hello"; then
    pass
  else
    fail "Expected false for 'hello'"
  fi
}

test_is_bool_true() {
  test_case "is_bool returns true for 'true'"
  if is_bool "true"; then
    pass
  else
    fail "Expected true for 'true'"
  fi
}

test_is_bool_false() {
  test_case "is_bool returns true for 'false'"
  if is_bool "false"; then
    pass
  else
    fail "Expected true for 'false'"
  fi
}

test_is_bool_yes() {
  test_case "is_bool returns true for 'yes'"
  if is_bool "yes"; then
    pass
  else
    fail "Expected true for 'yes'"
  fi
}

test_is_bool_no() {
  test_case "is_bool returns true for 'no'"
  if is_bool "no"; then
    pass
  else
    fail "Expected true for 'no'"
  fi
}

test_is_bool_one() {
  test_case "is_bool returns true for '1'"
  if is_bool "1"; then
    pass
  else
    fail "Expected true for '1'"
  fi
}

test_is_bool_zero() {
  test_case "is_bool returns true for '0'"
  if is_bool "0"; then
    pass
  else
    fail "Expected true for '0'"
  fi
}

test_is_bool_not_bool() {
  test_case "is_bool returns false for non-boolean"
  if ! is_bool "maybe"; then
    pass
  else
    fail "Expected false for 'maybe'"
  fi
}

test_is_function_true() {
  test_case "is_function returns true for existing function"
  _test_dummy_function() { echo "test"; }
  if is_function "_test_dummy_function"; then
    pass
  else
    fail "Expected true for defined function"
  fi
  unset -f _test_dummy_function
}

test_is_function_false() {
  test_case "is_function returns false for non-existing function"
  if ! is_function "nonexistent_function_xyz123"; then
    pass
  else
    fail "Expected false for non-existing function"
  fi
}

test_is_command_true() {
  test_case "is_command returns true for existing command"
  if is_command "zsh"; then
    pass
  else
    fail "Expected true for 'zsh'"
  fi
}

test_is_command_false() {
  test_case "is_command returns false for non-existing command"
  if ! is_command "nonexistent_command_xyz123"; then
    pass
  else
    fail "Expected false for non-existing command"
  fi
}

# ============================================================================
# File System Type Checking Tests
# ============================================================================

test_is_file_true() {
  test_case "is_file returns true for existing file"
  local testfile="$TEST_TMP_DIR/test_file.txt"
  echo "test" >"$testfile"
  if is_file "$testfile"; then
    pass
  else
    fail "Expected true for existing file"
  fi
  rm -f "$testfile"
}

test_is_file_false() {
  test_case "is_file returns false for non-existing file"
  if ! is_file "$TEST_TMP_DIR/nonexistent_file.txt"; then
    pass
  else
    fail "Expected false for non-existing file"
  fi
}

test_is_dir_true() {
  test_case "is_dir returns true for existing directory"
  if is_dir "$TEST_TMP_DIR"; then
    pass
  else
    fail "Expected true for existing directory"
  fi
}

test_is_dir_false() {
  test_case "is_dir returns false for non-existing directory"
  if ! is_dir "$TEST_TMP_DIR/nonexistent_dir"; then
    pass
  else
    fail "Expected false for non-existing directory"
  fi
}

test_is_readable_true() {
  test_case "is_readable returns true for readable file"
  local testfile="$TEST_TMP_DIR/readable_file.txt"
  echo "test" >"$testfile"
  chmod +r "$testfile"
  if is_readable "$testfile"; then
    pass
  else
    fail "Expected true for readable file"
  fi
  rm -f "$testfile"
}

test_is_executable_true() {
  test_case "is_executable returns true for executable file"
  local testfile="$TEST_TMP_DIR/executable_file.sh"
  echo "#!/bin/bash" >"$testfile"
  chmod +x "$testfile"
  if is_executable "$testfile"; then
    pass
  else
    fail "Expected true for executable file"
  fi
  rm -f "$testfile"
}

test_is_empty_file_true() {
  test_case "is_empty_file returns true for empty file"
  local testfile="$TEST_TMP_DIR/empty_file.txt"
  touch "$testfile"
  if is_empty_file "$testfile"; then
    pass
  else
    fail "Expected true for empty file"
  fi
  rm -f "$testfile"
}

test_is_empty_file_false() {
  test_case "is_empty_file returns false for non-empty file"
  local testfile="$TEST_TMP_DIR/nonempty_file.txt"
  echo "content" >"$testfile"
  if ! is_empty_file "$testfile"; then
    pass
  else
    fail "Expected false for non-empty file"
  fi
  rm -f "$testfile"
}

# ============================================================================
# Path Validation Tests
# ============================================================================

test_is_absolute_path_true() {
  test_case "is_absolute_path returns true for absolute path"
  if is_absolute_path "/usr/bin/zsh"; then
    pass
  else
    fail "Expected true for '/usr/bin/zsh'"
  fi
}

test_is_absolute_path_false() {
  test_case "is_absolute_path returns false for relative path"
  if ! is_absolute_path "usr/bin/zsh"; then
    pass
  else
    fail "Expected false for 'usr/bin/zsh'"
  fi
}

test_is_relative_path_true() {
  test_case "is_relative_path returns true for relative path"
  if is_relative_path "usr/bin/zsh"; then
    pass
  else
    fail "Expected true for 'usr/bin/zsh'"
  fi
}

test_is_relative_path_false() {
  test_case "is_relative_path returns false for absolute path"
  if ! is_relative_path "/usr/bin/zsh"; then
    pass
  else
    fail "Expected false for '/usr/bin/zsh'"
  fi
}

# ============================================================================
# String Validation Tests
# ============================================================================

test_is_empty_true() {
  test_case "is_empty returns true for empty string"
  if is_empty ""; then
    pass
  else
    fail "Expected true for empty string"
  fi
}

test_is_empty_false() {
  test_case "is_empty returns false for non-empty string"
  if ! is_empty "hello"; then
    pass
  else
    fail "Expected false for 'hello'"
  fi
}

test_is_alpha_true() {
  test_case "is_alpha returns true for alphabetic string"
  if is_alpha "hello"; then
    pass
  else
    fail "Expected true for 'hello'"
  fi
}

test_is_alpha_false() {
  test_case "is_alpha returns false for string with numbers"
  if ! is_alpha "hello123"; then
    pass
  else
    fail "Expected false for 'hello123'"
  fi
}

test_is_alnum_true() {
  test_case "is_alnum returns true for alphanumeric string"
  if is_alnum "hello123"; then
    pass
  else
    fail "Expected true for 'hello123'"
  fi
}

test_is_alnum_false() {
  test_case "is_alnum returns false for string with special chars"
  if ! is_alnum "hello!"; then
    pass
  else
    fail "Expected false for 'hello!'"
  fi
}

test_is_digit_true() {
  test_case "is_digit returns true for digits"
  if is_digit "12345"; then
    pass
  else
    fail "Expected true for '12345'"
  fi
}

test_is_digit_false() {
  test_case "is_digit returns false for non-digits"
  if ! is_digit "12a45"; then
    pass
  else
    fail "Expected false for '12a45'"
  fi
}

test_is_upper_true() {
  test_case "is_upper returns true for uppercase"
  if is_upper "HELLO"; then
    pass
  else
    fail "Expected true for 'HELLO'"
  fi
}

test_is_lower_true() {
  test_case "is_lower returns true for lowercase"
  if is_lower "hello"; then
    pass
  else
    fail "Expected true for 'hello'"
  fi
}

# ============================================================================
# Format Validation Tests
# ============================================================================

test_is_email_valid() {
  test_case "is_email returns true for valid email"
  if is_email "user@example.com"; then
    pass
  else
    fail "Expected true for 'user@example.com'"
  fi
}

test_is_email_invalid_no_at() {
  test_case "is_email returns false for email without @"
  if ! is_email "userexample.com"; then
    pass
  else
    fail "Expected false for 'userexample.com'"
  fi
}

test_is_email_invalid_no_domain() {
  test_case "is_email returns false for email without domain"
  if ! is_email "user@"; then
    pass
  else
    fail "Expected false for 'user@'"
  fi
}

test_is_url_http() {
  test_case "is_url returns true for http URL"
  if is_url "http://example.com"; then
    pass
  else
    fail "Expected true for 'http://example.com'"
  fi
}

test_is_url_https() {
  test_case "is_url returns true for https URL"
  if is_url "https://example.com/path"; then
    pass
  else
    fail "Expected true for 'https://example.com/path'"
  fi
}

test_is_url_invalid() {
  test_case "is_url returns false for invalid URL"
  if ! is_url "not-a-url"; then
    pass
  else
    fail "Expected false for 'not-a-url'"
  fi
}

test_is_ipv4_valid() {
  test_case "is_ipv4 returns true for valid IPv4"
  if is_ipv4 "192.168.1.1"; then
    pass
  else
    fail "Expected true for '192.168.1.1'"
  fi
}

test_is_ipv4_invalid_octet() {
  test_case "is_ipv4 returns false for invalid octet"
  if ! is_ipv4 "256.168.1.1"; then
    pass
  else
    fail "Expected false for '256.168.1.1'"
  fi
}

test_is_ipv4_invalid_format() {
  test_case "is_ipv4 returns false for invalid format"
  if ! is_ipv4 "192.168.1"; then
    pass
  else
    fail "Expected false for '192.168.1'"
  fi
}

test_is_port_valid() {
  test_case "is_port returns true for valid port"
  if is_port "8080"; then
    pass
  else
    fail "Expected true for '8080'"
  fi
}

test_is_port_out_of_range() {
  test_case "is_port returns false for port > 65535"
  if ! is_port "70000"; then
    pass
  else
    fail "Expected false for '70000'"
  fi
}

test_is_port_zero() {
  test_case "is_port returns false for port 0"
  if ! is_port "0"; then
    pass
  else
    fail "Expected false for '0'"
  fi
}

test_is_uuid_valid() {
  test_case "is_uuid returns true for valid UUID"
  if is_uuid "123e4567-e89b-12d3-a456-426614174000"; then
    pass
  else
    fail "Expected true for valid UUID"
  fi
}

test_is_uuid_invalid() {
  test_case "is_uuid returns false for invalid UUID"
  if ! is_uuid "not-a-uuid"; then
    pass
  else
    fail "Expected false for 'not-a-uuid'"
  fi
}

test_is_hex_valid() {
  test_case "is_hex returns true for hex string"
  if is_hex "deadbeef"; then
    pass
  else
    fail "Expected true for 'deadbeef'"
  fi
}

test_is_hex_invalid() {
  test_case "is_hex returns false for non-hex"
  if ! is_hex "xyz123"; then
    pass
  else
    fail "Expected false for 'xyz123'"
  fi
}

test_is_mac_address_valid() {
  test_case "is_mac_address returns true for valid MAC"
  if is_mac_address "00:1B:44:11:3A:B7"; then
    pass
  else
    fail "Expected true for '00:1B:44:11:3A:B7'"
  fi
}

test_is_time_valid() {
  test_case "is_time returns true for valid time"
  if is_time "14:30:00"; then
    pass
  else
    fail "Expected true for '14:30:00'"
  fi
}

test_is_time_without_seconds() {
  test_case "is_time returns true for time without seconds"
  if is_time "14:30"; then
    pass
  else
    fail "Expected true for '14:30'"
  fi
}

# ============================================================================
# Length Validation Tests
# ============================================================================

test_has_length_exact() {
  test_case "has_length returns true for exact length"
  if has_length "hello" 5; then
    pass
  else
    fail "Expected true for 'hello' with length 5"
  fi
}

test_has_length_wrong() {
  test_case "has_length returns false for wrong length"
  if ! has_length "hello" 3; then
    pass
  else
    fail "Expected false for 'hello' with length 3"
  fi
}

test_min_length_satisfied() {
  test_case "min_length returns true when satisfied"
  if min_length "hello" 3; then
    pass
  else
    fail "Expected true for 'hello' with min 3"
  fi
}

test_min_length_not_satisfied() {
  test_case "min_length returns false when not satisfied"
  if ! min_length "hi" 5; then
    pass
  else
    fail "Expected false for 'hi' with min 5"
  fi
}

test_max_length_satisfied() {
  test_case "max_length returns true when satisfied"
  if max_length "hi" 5; then
    pass
  else
    fail "Expected true for 'hi' with max 5"
  fi
}

test_max_length_exceeded() {
  test_case "max_length returns false when exceeded"
  if ! max_length "hello world" 5; then
    pass
  else
    fail "Expected false for 'hello world' with max 5"
  fi
}

# ============================================================================
# Type Conversion Tests
# ============================================================================

test_to_bool_true_values() {
  test_case "to_bool converts true values"
  local result=$(to_bool "yes")
  if [[ "$result" == "true" ]]; then
    pass
  else
    fail "Expected 'true', got: '$result'"
  fi
}

test_to_bool_false_values() {
  test_case "to_bool converts false values"
  local result=$(to_bool "no")
  if [[ "$result" == "false" ]]; then
    pass
  else
    fail "Expected 'false', got: '$result'"
  fi
}

test_to_int_from_float() {
  test_case "to_int converts float to int"
  local result=$(to_int "3.14")
  if [[ "$result" == "3" ]]; then
    pass
  else
    fail "Expected '3', got: '$result'"
  fi
}

test_to_int_from_int() {
  test_case "to_int passes through int"
  local result=$(to_int "42")
  if [[ "$result" == "42" ]]; then
    pass
  else
    fail "Expected '42', got: '$result'"
  fi
}

test_to_float_from_int() {
  test_case "to_float converts int to float"
  local result=$(to_float "42")
  if [[ "$result" == "42.00" ]]; then
    pass
  else
    fail "Expected '42.00', got: '$result'"
  fi
}

test_to_upper() {
  test_case "to_upper converts to uppercase"
  local result=$(to_upper "hello")
  if [[ "$result" == "HELLO" ]]; then
    pass
  else
    fail "Expected 'HELLO', got: '$result'"
  fi
}

test_to_lower() {
  test_case "to_lower converts to lowercase"
  local result=$(to_lower "HELLO")
  if [[ "$result" == "hello" ]]; then
    pass
  else
    fail "Expected 'hello', got: '$result'"
  fi
}

test_to_title() {
  test_case "to_title converts to title case"
  local result=$(to_title "hello world")
  if [[ "$result" == "Hello World" ]]; then
    pass
  else
    fail "Expected 'Hello World', got: '$result'"
  fi
}

# ============================================================================
# Coercion Tests
# ============================================================================

test_coerce_int_valid() {
  test_case "coerce_int returns value for valid int"
  local result=$(coerce_int "42" "0")
  if [[ "$result" == "42" ]]; then
    pass
  else
    fail "Expected '42', got: '$result'"
  fi
}

test_coerce_int_default() {
  test_case "coerce_int returns default for invalid"
  local result=$(coerce_int "abc" "0")
  if [[ "$result" == "0" ]]; then
    pass
  else
    fail "Expected '0', got: '$result'"
  fi
}

# ============================================================================
# Validation Tests
# ============================================================================

test_validate_required() {
  test_case "validate required passes for non-empty"
  if validate "hello" required; then
    pass
  else
    fail "Expected pass for non-empty value"
  fi
}

test_validate_required_fails() {
  test_case "validate required fails for empty"
  if ! validate "" required; then
    pass
  else
    fail "Expected fail for empty value"
  fi
}

test_validate_email() {
  test_case "validate email rule"
  if validate "user@example.com" email; then
    pass
  else
    fail "Expected pass for valid email"
  fi
}

test_validate_min_length() {
  test_case "validate min: rule for string"
  if validate "hello" "min:3"; then
    pass
  else
    fail "Expected pass for 'hello' with min:3"
  fi
}

test_validate_max_length() {
  test_case "validate max: rule for string"
  if validate "hi" "max:5"; then
    pass
  else
    fail "Expected pass for 'hi' with max:5"
  fi
}

test_validate_in_list() {
  test_case "validate in: rule"
  if validate "apple" "in:apple,banana,cherry"; then
    pass
  else
    fail "Expected pass for 'apple' in list"
  fi
}

test_validate_in_list_fails() {
  test_case "validate in: rule fails for missing value"
  if ! validate "grape" "in:apple,banana,cherry"; then
    pass
  else
    fail "Expected fail for 'grape' not in list"
  fi
}

# ============================================================================
# Type Inference Tests
# ============================================================================

test_infer_type_int() {
  test_case "infer_type returns int for integer"
  local result=$(infer_type "42")
  if [[ "$result" == "int" ]]; then
    pass
  else
    fail "Expected 'int', got: '$result'"
  fi
}

test_infer_type_bool() {
  test_case "infer_type returns bool for boolean"
  local result=$(infer_type "true")
  if [[ "$result" == "bool" ]]; then
    pass
  else
    fail "Expected 'bool', got: '$result'"
  fi
}

test_infer_type_email() {
  test_case "infer_type returns email for email"
  local result=$(infer_type "user@example.com")
  if [[ "$result" == "email" ]]; then
    pass
  else
    fail "Expected 'email', got: '$result'"
  fi
}

test_infer_type_url() {
  test_case "infer_type returns url for URL"
  local result=$(infer_type "https://example.com")
  if [[ "$result" == "url" ]]; then
    pass
  else
    fail "Expected 'url', got: '$result'"
  fi
}

test_infer_type_string() {
  test_case "infer_type returns string for plain text"
  local result=$(infer_type "hello world")
  if [[ "$result" == "string" ]]; then
    pass
  else
    fail "Expected 'string', got: '$result'"
  fi
}

# ============================================================================
# Run Tests
# ============================================================================

test_suite "Types Library" \
  test_is_int_positive \
  test_is_int_negative \
  test_is_int_zero \
  test_is_int_not_int \
  test_is_int_string \
  test_is_float_with_decimal \
  test_is_float_negative \
  test_is_float_integer_accepted \
  test_is_number_int \
  test_is_number_float \
  test_is_number_string \
  test_is_bool_true \
  test_is_bool_false \
  test_is_bool_yes \
  test_is_bool_no \
  test_is_bool_one \
  test_is_bool_zero \
  test_is_bool_not_bool \
  test_is_function_true \
  test_is_function_false \
  test_is_command_true \
  test_is_command_false \
  test_is_file_true \
  test_is_file_false \
  test_is_dir_true \
  test_is_dir_false \
  test_is_readable_true \
  test_is_executable_true \
  test_is_empty_file_true \
  test_is_empty_file_false \
  test_is_absolute_path_true \
  test_is_absolute_path_false \
  test_is_relative_path_true \
  test_is_relative_path_false \
  test_is_empty_true \
  test_is_empty_false \
  test_is_alpha_true \
  test_is_alpha_false \
  test_is_alnum_true \
  test_is_alnum_false \
  test_is_digit_true \
  test_is_digit_false \
  test_is_upper_true \
  test_is_lower_true \
  test_is_email_valid \
  test_is_email_invalid_no_at \
  test_is_email_invalid_no_domain \
  test_is_url_http \
  test_is_url_https \
  test_is_url_invalid \
  test_is_ipv4_valid \
  test_is_ipv4_invalid_octet \
  test_is_ipv4_invalid_format \
  test_is_port_valid \
  test_is_port_out_of_range \
  test_is_port_zero \
  test_is_uuid_valid \
  test_is_uuid_invalid \
  test_is_hex_valid \
  test_is_hex_invalid \
  test_is_mac_address_valid \
  test_is_time_valid \
  test_is_time_without_seconds \
  test_has_length_exact \
  test_has_length_wrong \
  test_min_length_satisfied \
  test_min_length_not_satisfied \
  test_max_length_satisfied \
  test_max_length_exceeded \
  test_to_bool_true_values \
  test_to_bool_false_values \
  test_to_int_from_float \
  test_to_int_from_int \
  test_to_float_from_int \
  test_to_upper \
  test_to_lower \
  test_to_title \
  test_coerce_int_valid \
  test_coerce_int_default \
  test_validate_required \
  test_validate_required_fails \
  test_validate_email \
  test_validate_min_length \
  test_validate_max_length \
  test_validate_in_list \
  test_validate_in_list_fails \
  test_infer_type_int \
  test_infer_type_bool \
  test_infer_type_email \
  test_infer_type_url \
  test_infer_type_string
