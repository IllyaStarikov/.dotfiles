#!/usr/bin/env zsh
# Unit tests for hash.zsh library

# Get the test directory path
TEST_DIR="$(cd "$(dirname "$(dirname "$(dirname "$0")")")" && pwd)"
DOTFILES_DIR="$(dirname "$TEST_DIR")"

# Set up test environment
export TEST_TMP_DIR="${TEST_TMP_DIR:-/tmp/dotfiles_test_$$}"
mkdir -p "$TEST_TMP_DIR"

# Test framework
source "${TEST_DIR}/lib/test_helpers.zsh"

# Source the library under test
source "${DOTFILES_DIR}/src/lib/hash.zsh"

# ============================================================================
# Hash Creation Tests
# ============================================================================

test_hash_new_empty() {
  test_case "hash_new creates empty hash"
  local -A h
  hash_new h
  if [[ ${#h[@]} -eq 0 ]]; then
    pass
  else
    fail "Expected empty hash, got ${#h[@]} elements"
  fi
}

test_hash_new_with_pairs() {
  test_case "hash_new with key-value pairs"
  local -A h
  hash_new h "name" "John" "age" "30"
  if [[ "${h[name]}" == "John" ]] && [[ "${h[age]}" == "30" ]]; then
    pass
  else
    fail "Expected name=John, age=30"
  fi
}

test_hash_from_string() {
  test_case "hash_from_string parses string"
  local -A h
  hash_from_string h "a=1,b=2,c=3"
  if [[ "${h[a]}" == "1" ]] && [[ "${h[b]}" == "2" ]] && [[ "${h[c]}" == "3" ]]; then
    pass
  else
    fail "Expected a=1, b=2, c=3"
  fi
}

test_hash_from_string_custom_delimiters() {
  test_case "hash_from_string with custom delimiters"
  local -A h
  hash_from_string h "a:1;b:2;c:3" ";" ":"
  if [[ "${h[a]}" == "1" ]] && [[ "${h[b]}" == "2" ]]; then
    pass
  else
    fail "Expected a=1, b=2"
  fi
}

# ============================================================================
# Hash Information Tests
# ============================================================================

test_hash_size_empty() {
  test_case "hash_size returns 0 for empty hash"
  local -A h=()
  local size=$(hash_size h)
  if [[ "$size" == "0" ]]; then
    pass
  else
    fail "Expected 0, got: $size"
  fi
}

test_hash_size_with_items() {
  test_case "hash_size returns correct count"
  local -A h=(a 1 b 2 c 3)
  local size=$(hash_size h)
  if [[ "$size" == "3" ]]; then
    pass
  else
    fail "Expected 3, got: $size"
  fi
}

test_hash_is_empty_true() {
  test_case "hash_is_empty returns true for empty hash"
  local -A h=()
  if hash_is_empty h; then
    pass
  else
    fail "Expected true for empty hash"
  fi
}

test_hash_is_empty_false() {
  test_case "hash_is_empty returns false for non-empty hash"
  local -A h=(key value)
  if ! hash_is_empty h; then
    pass
  else
    fail "Expected false for non-empty hash"
  fi
}

test_hash_has_key_exists() {
  test_case "hash_has_key returns true for existing key"
  local -A h=(name John age 30)
  if hash_has_key h "name"; then
    pass
  else
    fail "Expected to find key 'name'"
  fi
}

test_hash_has_key_not_exists() {
  test_case "hash_has_key returns false for missing key"
  local -A h=(name John)
  if ! hash_has_key h "missing"; then
    pass
  else
    fail "Should not find key 'missing'"
  fi
}

test_hash_has_value_exists() {
  test_case "hash_has_value returns true for existing value"
  local -A h=(name John age 30)
  if hash_has_value h "John"; then
    pass
  else
    fail "Expected to find value 'John'"
  fi
}

test_hash_has_value_not_exists() {
  test_case "hash_has_value returns false for missing value"
  local -A h=(name John)
  if ! hash_has_value h "Jane"; then
    pass
  else
    fail "Should not find value 'Jane'"
  fi
}

# ============================================================================
# Hash Access Tests
# ============================================================================

test_hash_get_existing() {
  test_case "hash_get returns value for existing key"
  local -A h=(name John)
  local result=$(hash_get h "name")
  if [[ "$result" == "John" ]]; then
    pass
  else
    fail "Expected 'John', got: '$result'"
  fi
}

test_hash_get_missing_with_default() {
  test_case "hash_get returns default for missing key"
  local -A h=(name John)
  local result=$(hash_get h "missing" "default")
  if [[ "$result" == "default" ]]; then
    pass
  else
    fail "Expected 'default', got: '$result'"
  fi
}

test_hash_set() {
  test_case "hash_set adds/updates key"
  local -A h=()
  hash_set h "key" "value"
  if [[ "${h[key]}" == "value" ]]; then
    pass
  else
    fail "Expected 'value', got: '${h[key]}'"
  fi
}

test_hash_get_or_set_existing() {
  test_case "hash_get_or_set returns existing value"
  local -A h=(key existing)
  local result=$(hash_get_or_set h "key" "new")
  if [[ "$result" == "existing" ]]; then
    pass
  else
    fail "Expected 'existing', got: '$result'"
  fi
}

test_hash_get_or_set_missing() {
  test_case "hash_get_or_set sets and returns default"
  local -A h=()
  local result=$(hash_get_or_set h "key" "default")
  if [[ "$result" == "default" ]] && [[ "${h[key]}" == "default" ]]; then
    pass
  else
    fail "Expected 'default'"
  fi
}

# ============================================================================
# Hash Modification Tests
# ============================================================================

test_hash_delete_existing() {
  test_case "hash_delete removes existing key"
  local -A h=(a 1 b 2)
  hash_delete h "a"
  if [[ -z "${h[a]+x}" ]] && [[ ${#h[@]} -eq 1 ]]; then
    pass
  else
    fail "Key 'a' should be deleted"
  fi
}

test_hash_delete_missing() {
  test_case "hash_delete returns failure for missing key"
  local -A h=(a 1)
  if ! hash_delete h "missing"; then
    pass
  else
    fail "Expected failure for missing key"
  fi
}

test_hash_clear() {
  test_case "hash_clear empties hash"
  local -A h=(a 1 b 2 c 3)
  hash_clear h
  if [[ ${#h[@]} -eq 0 ]]; then
    pass
  else
    fail "Expected empty hash"
  fi
}

test_hash_update() {
  test_case "hash_update merges hashes"
  local -A h=(a 1 b 2)
  local -A update=(b 3 c 4)
  hash_update h update
  if [[ "${h[b]}" == "3" ]] && [[ "${h[c]}" == "4" ]]; then
    pass
  else
    fail "Expected b=3, c=4"
  fi
}

test_hash_setdefault_missing() {
  test_case "hash_setdefault sets value for missing key"
  local -A h=()
  local result=$(hash_setdefault h "key" "default")
  if [[ "$result" == "default" ]]; then
    pass
  else
    fail "Expected 'default', got: '$result'"
  fi
}

test_hash_setdefault_existing() {
  test_case "hash_setdefault preserves existing value"
  local -A h=(key existing)
  local result=$(hash_setdefault h "key" "default")
  if [[ "$result" == "existing" ]]; then
    pass
  else
    fail "Expected 'existing', got: '$result'"
  fi
}

# ============================================================================
# Hash Comparison Tests
# ============================================================================

test_hash_equals_identical() {
  test_case "hash_equals returns true for identical hashes"
  local -A h1=(a 1 b 2)
  local -A h2=(a 1 b 2)
  if hash_equals h1 h2; then
    pass
  else
    fail "Expected hashes to be equal"
  fi
}

test_hash_equals_different() {
  test_case "hash_equals returns false for different hashes"
  local -A h1=(a 1 b 2)
  local -A h2=(a 1 b 3)
  if ! hash_equals h1 h2; then
    pass
  else
    fail "Expected hashes to be different"
  fi
}

test_hash_find_key() {
  test_case "hash_find_key finds key by value"
  local -A h=(a 1 b 2 c 3)
  local result=$(hash_find_key h "2")
  if [[ "$result" == "b" ]]; then
    pass
  else
    fail "Expected 'b', got: '$result'"
  fi
}

# ============================================================================
# Hash Conversion Tests
# ============================================================================

test_hash_to_string() {
  test_case "hash_to_string formats hash"
  local -A h=(a 1)
  local result=$(hash_to_string h)
  if [[ "$result" == "a=1" ]]; then
    pass
  else
    fail "Expected 'a=1', got: '$result'"
  fi
}

test_hash_copy() {
  test_case "hash_copy creates independent copy"
  local -A h1=(a 1 b 2)
  local -A h2
  hash_copy h1 h2
  h1[a]=99
  if [[ "${h2[a]}" == "1" ]]; then
    pass
  else
    fail "Copy should be independent"
  fi
}

test_hash_invert() {
  test_case "hash_invert swaps keys and values"
  local -A h=(a 1 b 2)
  local -A result
  hash_invert h result
  if [[ "${result[1]}" == "a" ]] && [[ "${result[2]}" == "b" ]]; then
    pass
  else
    fail "Expected inverted hash"
  fi
}

test_hash_to_json() {
  test_case "hash_to_json creates JSON"
  local -A h=(name John age 30)
  local result=$(hash_to_json h "true")
  if [[ "$result" == *'"name"'* ]] && [[ "$result" == *'"John"'* ]]; then
    pass
  else
    fail "Expected JSON object, got: '$result'"
  fi
}

# ============================================================================
# Run Tests
# ============================================================================

test_suite "Hash Library" \
  test_hash_new_empty \
  test_hash_new_with_pairs \
  test_hash_from_string \
  test_hash_from_string_custom_delimiters \
  test_hash_size_empty \
  test_hash_size_with_items \
  test_hash_is_empty_true \
  test_hash_is_empty_false \
  test_hash_has_key_exists \
  test_hash_has_key_not_exists \
  test_hash_has_value_exists \
  test_hash_has_value_not_exists \
  test_hash_get_existing \
  test_hash_get_missing_with_default \
  test_hash_set \
  test_hash_get_or_set_existing \
  test_hash_get_or_set_missing \
  test_hash_delete_existing \
  test_hash_delete_missing \
  test_hash_clear \
  test_hash_update \
  test_hash_setdefault_missing \
  test_hash_setdefault_existing \
  test_hash_equals_identical \
  test_hash_equals_different \
  test_hash_find_key \
  test_hash_to_string \
  test_hash_copy \
  test_hash_invert \
  test_hash_to_json
