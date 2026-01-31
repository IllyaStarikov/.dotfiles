#!/usr/bin/env zsh
# Unit tests for utils.zsh library

# Get the test directory path
TEST_DIR="$(cd "$(dirname "$(dirname "$(dirname "$0")")")" && pwd)"
DOTFILES_DIR="$(dirname "$TEST_DIR")"

# Set up test environment
export TEST_TMP_DIR="${TEST_TMP_DIR:-/tmp/dotfiles_test_$$}"
mkdir -p "$TEST_TMP_DIR"

# Test framework
source "${TEST_DIR}/lib/test_helpers.zsh"

# Source the library under test
source "${DOTFILES_DIR}/src/lib/utils.zsh"

# ============================================================================
# String Manipulation Tests
# ============================================================================

test_trim_leading_whitespace() {
  test_case "trim removes leading whitespace"
  local result=$(trim "   hello")
  if [[ "$result" == "hello" ]]; then
    pass
  else
    fail "Expected 'hello', got: '$result'"
  fi
}

test_trim_trailing_whitespace() {
  test_case "trim removes trailing whitespace"
  local result=$(trim "hello   ")
  if [[ "$result" == "hello" ]]; then
    pass
  else
    fail "Expected 'hello', got: '$result'"
  fi
}

test_trim_both_whitespace() {
  test_case "trim removes both leading and trailing whitespace"
  local result=$(trim "   hello world   ")
  if [[ "$result" == "hello world" ]]; then
    pass
  else
    fail "Expected 'hello world', got: '$result'"
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

test_capitalize() {
  test_case "capitalize capitalizes first letter"
  local result=$(capitalize "hello world")
  if [[ "$result" == "Hello world" ]]; then
    pass
  else
    fail "Expected 'Hello world', got: '$result'"
  fi
}

test_contains_found() {
  test_case "contains returns true when substring found"
  if contains "hello world" "world"; then
    pass
  else
    fail "Expected to find 'world' in 'hello world'"
  fi
}

test_contains_not_found() {
  test_case "contains returns false when substring not found"
  if ! contains "hello world" "foo"; then
    pass
  else
    fail "Should not find 'foo' in 'hello world'"
  fi
}

test_starts_with_match() {
  test_case "starts_with returns true for matching prefix"
  if starts_with "hello world" "hello"; then
    pass
  else
    fail "Expected 'hello world' to start with 'hello'"
  fi
}

test_starts_with_no_match() {
  test_case "starts_with returns false for non-matching prefix"
  if ! starts_with "hello world" "world"; then
    pass
  else
    fail "'hello world' should not start with 'world'"
  fi
}

test_ends_with_match() {
  test_case "ends_with returns true for matching suffix"
  if ends_with "hello world" "world"; then
    pass
  else
    fail "Expected 'hello world' to end with 'world'"
  fi
}

test_ends_with_no_match() {
  test_case "ends_with returns false for non-matching suffix"
  if ! ends_with "hello world" "hello"; then
    pass
  else
    fail "'hello world' should not end with 'hello'"
  fi
}

test_replace_all_single() {
  test_case "replace_all replaces single occurrence"
  local result=$(replace_all "hello world" "world" "universe")
  if [[ "$result" == "hello universe" ]]; then
    pass
  else
    fail "Expected 'hello universe', got: '$result'"
  fi
}

test_replace_all_multiple() {
  test_case "replace_all replaces multiple occurrences"
  local result=$(replace_all "hello hello hello" "hello" "hi")
  if [[ "$result" == "hi hi hi" ]]; then
    pass
  else
    fail "Expected 'hi hi hi', got: '$result'"
  fi
}

test_str_repeat() {
  test_case "str_repeat repeats string n times"
  local result=$(str_repeat "ab" 3)
  if [[ "$result" == "ababab" ]]; then
    pass
  else
    fail "Expected 'ababab', got: '$result'"
  fi
}

test_join() {
  test_case "join combines elements with delimiter"
  local result=$(join "," "a" "b" "c")
  if [[ "$result" == "a,b,c" ]]; then
    pass
  else
    fail "Expected 'a,b,c', got: '$result'"
  fi
}

# ============================================================================
# File and Directory Tests
# ============================================================================

test_file_exists_true() {
  test_case "file_exists returns true for existing file"
  local testfile="$TEST_TMP_DIR/test_file.txt"
  echo "test" > "$testfile"
  if file_exists "$testfile"; then
    pass
  else
    fail "Expected true for existing file"
  fi
  rm -f "$testfile"
}

test_file_exists_false() {
  test_case "file_exists returns false for non-existing file"
  if ! file_exists "$TEST_TMP_DIR/nonexistent_file.txt"; then
    pass
  else
    fail "Expected false for non-existing file"
  fi
}

test_dir_exists_true() {
  test_case "dir_exists returns true for existing directory"
  if dir_exists "$TEST_TMP_DIR"; then
    pass
  else
    fail "Expected true for existing directory"
  fi
}

test_dir_exists_false() {
  test_case "dir_exists returns false for non-existing directory"
  if ! dir_exists "$TEST_TMP_DIR/nonexistent_dir"; then
    pass
  else
    fail "Expected false for non-existing directory"
  fi
}

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

test_file_extension() {
  test_case "file_extension extracts extension"
  local result=$(file_extension "document.pdf")
  if [[ "$result" == "pdf" ]]; then
    pass
  else
    fail "Expected 'pdf', got: '$result'"
  fi
}

test_file_extension_multiple_dots() {
  test_case "file_extension handles multiple dots"
  local result=$(file_extension "file.name.tar.gz")
  if [[ "$result" == "gz" ]]; then
    pass
  else
    fail "Expected 'gz', got: '$result'"
  fi
}

test_file_basename() {
  test_case "file_basename extracts name without extension"
  local result=$(file_basename "document.pdf")
  if [[ "$result" == "document" ]]; then
    pass
  else
    fail "Expected 'document', got: '$result'"
  fi
}

test_file_dirname() {
  test_case "file_dirname extracts directory"
  local result=$(file_dirname "/usr/local/bin/script.sh")
  if [[ "$result" == "/usr/local/bin" ]]; then
    pass
  else
    fail "Expected '/usr/local/bin', got: '$result'"
  fi
}

test_ensure_dir() {
  test_case "ensure_dir creates directory if it doesn't exist"
  local testdir="$TEST_TMP_DIR/new_dir_$$"
  ensure_dir "$testdir"
  if [[ -d "$testdir" ]]; then
    pass
    rmdir "$testdir"
  else
    fail "Directory was not created"
  fi
}

# ============================================================================
# System Utilities Tests
# ============================================================================

test_command_exists_true() {
  test_case "command_exists returns true for existing command"
  if command_exists "zsh"; then
    pass
  else
    fail "Expected true for 'zsh'"
  fi
}

test_command_exists_false() {
  test_case "command_exists returns false for non-existing command"
  if ! command_exists "nonexistent_command_xyz123"; then
    pass
  else
    fail "Expected false for non-existing command"
  fi
}

test_first_available_command() {
  test_case "first_available_command returns first existing command"
  local result=$(first_available_command "nonexistent_xyz" "zsh" "bash")
  if [[ "$result" == "zsh" ]]; then
    pass
  else
    fail "Expected 'zsh', got: '$result'"
  fi
}

test_get_os() {
  test_case "get_os returns valid OS name"
  local result=$(get_os)
  if [[ "$result" == "macos" ]] || [[ "$result" == "linux" ]] || [[ "$result" == "windows" ]]; then
    pass
  else
    fail "Expected valid OS, got: '$result'"
  fi
}

test_get_arch() {
  test_case "get_arch returns valid architecture"
  local result=$(get_arch)
  if [[ "$result" == "amd64" ]] || [[ "$result" == "arm64" ]] || [[ "$result" == "arm" ]] || [[ "$result" == "386" ]]; then
    pass
  else
    fail "Expected valid arch, got: '$result'"
  fi
}

test_is_macos_or_linux() {
  test_case "is_macos or is_linux returns true on current system"
  if is_macos || is_linux; then
    pass
  else
    fail "Expected either macOS or Linux"
  fi
}

test_cpu_cores() {
  test_case "cpu_cores returns positive number"
  local cores=$(cpu_cores)
  if [[ "$cores" -gt 0 ]]; then
    pass
  else
    fail "Expected positive number, got: $cores"
  fi
}

test_memory_mb() {
  test_case "memory_mb returns positive number"
  local mem=$(memory_mb)
  if [[ "$mem" -gt 0 ]]; then
    pass
  else
    fail "Expected positive number, got: $mem"
  fi
}

# ============================================================================
# Validation Tests
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

test_is_not_empty_true() {
  test_case "is_not_empty returns true for non-empty string"
  if is_not_empty "hello"; then
    pass
  else
    fail "Expected true for 'hello'"
  fi
}

test_is_numeric_integer() {
  test_case "is_numeric returns true for integer"
  if is_numeric "12345"; then
    pass
  else
    fail "Expected true for '12345'"
  fi
}

test_is_numeric_non_numeric() {
  test_case "is_numeric returns false for non-numeric"
  if ! is_numeric "12.34"; then
    pass
  else
    fail "Expected false for '12.34'"
  fi
}

test_is_decimal_true() {
  test_case "is_decimal returns true for decimal"
  if is_decimal "12.34"; then
    pass
  else
    fail "Expected true for '12.34'"
  fi
}

test_is_decimal_false() {
  test_case "is_decimal returns false for integer"
  if ! is_decimal "1234"; then
    pass
  else
    fail "Expected false for '1234'"
  fi
}

test_is_boolean_true_values() {
  test_case "is_boolean returns true for boolean values"
  local passed=1
  for val in true false yes no 1 0; do
    if ! is_boolean "$val"; then
      fail "Expected true for '$val'"
      passed=0
      break
    fi
  done
  [[ $passed -eq 1 ]] && pass
}

test_is_boolean_false_value() {
  test_case "is_boolean returns false for non-boolean"
  if ! is_boolean "maybe"; then
    pass
  else
    fail "Expected false for 'maybe'"
  fi
}

test_to_boolean_true_values() {
  test_case "to_boolean converts true values"
  local result=$(to_boolean "yes")
  if [[ "$result" == "true" ]]; then
    pass
  else
    fail "Expected 'true', got: '$result'"
  fi
}

test_to_boolean_false_values() {
  test_case "to_boolean converts false values"
  local result=$(to_boolean "no")
  if [[ "$result" == "false" ]]; then
    pass
  else
    fail "Expected 'false', got: '$result'"
  fi
}

# ============================================================================
# URL Tests
# ============================================================================

test_url_encode() {
  test_case "url_encode encodes special characters"
  local result=$(url_encode "hello world")
  if [[ "$result" == "hello%20world" ]]; then
    pass
  else
    fail "Expected 'hello%20world', got: '$result'"
  fi
}

test_url_decode() {
  test_case "url_decode decodes encoded string"
  local result=$(url_decode "hello%20world")
  if [[ "$result" == "hello world" ]]; then
    pass
  else
    fail "Expected 'hello world', got: '$result'"
  fi
}

test_extract_domain() {
  test_case "extract_domain extracts domain from URL"
  local result=$(extract_domain "https://www.example.com/path/to/page")
  if [[ "$result" == "www.example.com" ]]; then
    pass
  else
    fail "Expected 'www.example.com', got: '$result'"
  fi
}

# ============================================================================
# Temp File Tests
# ============================================================================

test_temp_file() {
  test_case "temp_file creates temporary file"
  local tmpfile=$(temp_file "test" ".txt")
  if [[ -f "$tmpfile" ]] || [[ "$tmpfile" =~ ^/.*test.*\.txt$ ]]; then
    pass
    rm -f "$tmpfile"
  else
    fail "Temp file not created or invalid path: $tmpfile"
  fi
}

test_temp_dir() {
  test_case "temp_dir creates temporary directory"
  local tmpdir=$(temp_dir "testdir")
  if [[ -d "$tmpdir" ]]; then
    pass
    rmdir "$tmpdir"
  else
    fail "Temp directory not created: $tmpdir"
  fi
}

# ============================================================================
# Miscellaneous Tests
# ============================================================================

test_generate_uuid() {
  test_case "generate_uuid returns UUID format"
  local uuid=$(generate_uuid)
  # UUID format: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
  if [[ "$uuid" =~ ^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$ ]]; then
    pass
  else
    fail "Invalid UUID format: $uuid"
  fi
}

test_timestamp() {
  test_case "timestamp returns current time in seconds"
  local ts=$(timestamp)
  local now=$(date +%s)
  local diff=$((now - ts))
  if [[ ${diff#-} -le 1 ]]; then
    pass
  else
    fail "Timestamp differs by more than 1 second"
  fi
}

test_date_format() {
  test_case "date_format formats date correctly"
  local result=$(date_format "%Y")
  local expected=$(date +"%Y")
  if [[ "$result" == "$expected" ]]; then
    pass
  else
    fail "Expected '$expected', got: '$result'"
  fi
}

# ============================================================================
# Run Tests
# ============================================================================

test_suite "Utils Library" \
  test_trim_leading_whitespace \
  test_trim_trailing_whitespace \
  test_trim_both_whitespace \
  test_to_upper \
  test_to_lower \
  test_capitalize \
  test_contains_found \
  test_contains_not_found \
  test_starts_with_match \
  test_starts_with_no_match \
  test_ends_with_match \
  test_ends_with_no_match \
  test_replace_all_single \
  test_replace_all_multiple \
  test_str_repeat \
  test_join \
  test_file_exists_true \
  test_file_exists_false \
  test_dir_exists_true \
  test_dir_exists_false \
  test_is_absolute_path_true \
  test_is_absolute_path_false \
  test_file_extension \
  test_file_extension_multiple_dots \
  test_file_basename \
  test_file_dirname \
  test_ensure_dir \
  test_command_exists_true \
  test_command_exists_false \
  test_first_available_command \
  test_get_os \
  test_get_arch \
  test_is_macos_or_linux \
  test_cpu_cores \
  test_memory_mb \
  test_is_empty_true \
  test_is_empty_false \
  test_is_not_empty_true \
  test_is_numeric_integer \
  test_is_numeric_non_numeric \
  test_is_decimal_true \
  test_is_decimal_false \
  test_is_boolean_true_values \
  test_is_boolean_false_value \
  test_to_boolean_true_values \
  test_to_boolean_false_values \
  test_url_encode \
  test_url_decode \
  test_extract_domain \
  test_temp_file \
  test_temp_dir \
  test_generate_uuid \
  test_timestamp \
  test_date_format
