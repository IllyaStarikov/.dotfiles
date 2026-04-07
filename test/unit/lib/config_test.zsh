#!/usr/bin/env zsh
# Unit tests for config.zsh library

# Get the test directory path
TEST_DIR="$(cd "$(dirname "$(dirname "$(dirname "$0")")")" && pwd)"
DOTFILES_DIR="$(dirname "$TEST_DIR")"

# Set up test environment
export TEST_TMP_DIR="${TEST_TMP_DIR:-/tmp/dotfiles_test_$$}"
mkdir -p "$TEST_TMP_DIR"

# Test framework
source "${TEST_DIR}/lib/test_helpers.zsh"

# Source the library under test. Override CONFIG_DIR before sourcing so
# the tests use a sandboxed config directory.
typeset -g CONFIG_TEST_DIR="$TEST_TMP_DIR/config_test_$$"
mkdir -p "$CONFIG_TEST_DIR"
DOTFILES_DIR="$DOTFILES_DIR" source "${DOTFILES_DIR}/src/lib/config.zsh"
CONFIG_DIR="$CONFIG_TEST_DIR"

# ============================================================================
# Test Fixtures
# ============================================================================

setup_fixtures() {
  cat >"$CONFIG_TEST_DIR/sample.json" <<'JSON'
{
  "string_value": "hello",
  "number_value": 42,
  "array_value": ["one", "two", "three"],
  "nested": {
    "key": "nested_value"
  },
  "path_value": "~/.config/test"
}
JSON
}

teardown_fixtures() {
  rm -rf "$CONFIG_TEST_DIR"
}

# ============================================================================
# get_config
# ============================================================================

test_get_config_string() {
  test_case "get_config reads a string value"
  if ! command -v jq >/dev/null 2>&1; then
    skip "jq not installed"
    return
  fi
  setup_fixtures
  local result
  result=$(get_config "sample.json" ".string_value")
  if [[ "$result" == "hello" ]]; then
    pass
  else
    fail "Expected 'hello', got: $result"
  fi
  teardown_fixtures
}

test_get_config_number() {
  test_case "get_config reads a number value"
  if ! command -v jq >/dev/null 2>&1; then
    skip "jq not installed"
    return
  fi
  setup_fixtures
  local result
  result=$(get_config "sample.json" ".number_value")
  if [[ "$result" == "42" ]]; then
    pass
  else
    fail "Expected '42', got: $result"
  fi
  teardown_fixtures
}

test_get_config_nested() {
  test_case "get_config reads a nested value"
  if ! command -v jq >/dev/null 2>&1; then
    skip "jq not installed"
    return
  fi
  setup_fixtures
  local result
  result=$(get_config "sample.json" ".nested.key")
  if [[ "$result" == "nested_value" ]]; then
    pass
  else
    fail "Expected 'nested_value', got: $result"
  fi
  teardown_fixtures
}

test_get_config_default_on_missing_file() {
  test_case "get_config returns default when file is missing"
  setup_fixtures
  local result
  result=$(get_config "nonexistent.json" ".any" "fallback")
  if [[ "$result" == "fallback" ]]; then
    pass
  else
    fail "Expected 'fallback', got: $result"
  fi
  teardown_fixtures
}

test_get_config_default_on_missing_key() {
  test_case "get_config returns default when key is missing"
  if ! command -v jq >/dev/null 2>&1; then
    skip "jq not installed"
    return
  fi
  setup_fixtures
  local result
  result=$(get_config "sample.json" ".missing_key" "fallback")
  if [[ "$result" == "fallback" ]]; then
    pass
  else
    fail "Expected 'fallback', got: $result"
  fi
  teardown_fixtures
}

# ============================================================================
# get_config_array / get_config_array_string
# ============================================================================

test_get_config_array() {
  test_case "get_config_array reads array elements"
  if ! command -v jq >/dev/null 2>&1; then
    skip "jq not installed"
    return
  fi
  setup_fixtures
  local result
  result=$(get_config_array "sample.json" ".array_value" | tr '\n' ' ')
  if [[ "$result" == "one two three "* ]]; then
    pass
  else
    fail "Expected 'one two three', got: $result"
  fi
  teardown_fixtures
}

test_get_config_array_string() {
  test_case "get_config_array_string returns space-separated values"
  if ! command -v jq >/dev/null 2>&1; then
    skip "jq not installed"
    return
  fi
  setup_fixtures
  local result
  result=$(get_config_array_string "sample.json" ".array_value")
  if [[ "$result" == *one* ]] && [[ "$result" == *two* ]] && [[ "$result" == *three* ]]; then
    pass
  else
    fail "Expected all three array values, got: $result"
  fi
  teardown_fixtures
}

# ============================================================================
# load_config_array
# ============================================================================

test_load_config_array_into_variable() {
  test_case "load_config_array populates a named array"
  if ! command -v jq >/dev/null 2>&1; then
    skip "jq not installed"
    return
  fi
  setup_fixtures
  local -a result
  load_config_array result "sample.json" ".array_value"
  if (( ${#result[@]} == 3 )) && [[ "${result[1]}" == "one" ]]; then
    pass
  else
    fail "Expected 3 elements starting with 'one', got: ${result[*]}"
  fi
  teardown_fixtures
}

# ============================================================================
# has_config / validate_configs
# ============================================================================

test_has_config_existing() {
  test_case "has_config returns 0 for existing file"
  setup_fixtures
  if has_config "sample.json"; then
    pass
  else
    fail "has_config should return 0 for sample.json"
  fi
  teardown_fixtures
}

test_has_config_missing() {
  test_case "has_config returns 1 for missing file"
  setup_fixtures
  if ! has_config "nonexistent.json"; then
    pass
  else
    fail "has_config should return non-zero for nonexistent.json"
  fi
  teardown_fixtures
}

test_validate_configs_all_present() {
  test_case "validate_configs returns 0 when all configs exist"
  setup_fixtures
  if validate_configs "sample.json" 2>/dev/null; then
    pass
  else
    fail "validate_configs should succeed when all files exist"
  fi
  teardown_fixtures
}

test_validate_configs_some_missing() {
  test_case "validate_configs returns 1 when a config is missing"
  setup_fixtures
  if ! validate_configs "sample.json" "nonexistent.json" 2>/dev/null; then
    pass
  else
    fail "validate_configs should fail when one file is missing"
  fi
  teardown_fixtures
}

# ============================================================================
# get_config_keys
# ============================================================================

test_get_config_keys() {
  test_case "get_config_keys lists JSON object keys"
  if ! command -v jq >/dev/null 2>&1; then
    skip "jq not installed"
    return
  fi
  setup_fixtures
  local keys
  keys=$(get_config_keys "sample.json" "." | tr '\n' ' ')
  if [[ "$keys" == *string_value* ]] && [[ "$keys" == *array_value* ]]; then
    pass
  else
    fail "Expected sample.json keys, got: $keys"
  fi
  teardown_fixtures
}

# ============================================================================
# expand_config_path / get_config_path
# ============================================================================

test_expand_config_path_tilde() {
  test_case "expand_config_path expands ~ to \$HOME"
  local result
  result=$(expand_config_path "~/example")
  if [[ "$result" == "$HOME/example" ]]; then
    pass
  else
    fail "Expected '$HOME/example', got: $result"
  fi
}

test_expand_config_path_no_tilde() {
  test_case "expand_config_path leaves non-~ paths unchanged"
  local result
  result=$(expand_config_path "/absolute/path")
  if [[ "$result" == "/absolute/path" ]]; then
    pass
  else
    fail "Expected '/absolute/path', got: $result"
  fi
}

test_get_config_path_expands_tilde() {
  test_case "get_config_path returns an expanded path"
  if ! command -v jq >/dev/null 2>&1; then
    skip "jq not installed"
    return
  fi
  setup_fixtures
  local result
  result=$(get_config_path "sample.json" ".path_value")
  if [[ "$result" == "$HOME/.config/test" ]]; then
    pass
  else
    fail "Expected '$HOME/.config/test', got: $result"
  fi
  teardown_fixtures
}

# ============================================================================
# read_config_file
# ============================================================================

test_read_config_file_existing() {
  test_case "read_config_file reads file contents"
  setup_fixtures
  local result
  result=$(read_config_file "sample.json")
  if [[ "$result" == *string_value* ]]; then
    pass
  else
    fail "Expected file contents, got: $result"
  fi
  teardown_fixtures
}

test_read_config_file_missing_returns_empty_object() {
  test_case "read_config_file returns {} for missing file"
  setup_fixtures
  local result
  result=$(read_config_file "nonexistent.json")
  if [[ "$result" == "{}" ]]; then
    pass
  else
    fail "Expected '{}', got: $result"
  fi
  teardown_fixtures
}

# ============================================================================
# Run Tests
# ============================================================================

test_suite "Config Library" \
  test_get_config_string \
  test_get_config_number \
  test_get_config_nested \
  test_get_config_default_on_missing_file \
  test_get_config_default_on_missing_key \
  test_get_config_array \
  test_get_config_array_string \
  test_load_config_array_into_variable \
  test_has_config_existing \
  test_has_config_missing \
  test_validate_configs_all_present \
  test_validate_configs_some_missing \
  test_get_config_keys \
  test_expand_config_path_tilde \
  test_expand_config_path_no_tilde \
  test_get_config_path_expands_tilde \
  test_read_config_file_existing \
  test_read_config_file_missing_returns_empty_object
