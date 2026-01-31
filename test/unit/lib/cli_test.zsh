#!/usr/bin/env zsh
# Unit tests for cli.zsh library

# Get the test directory path
TEST_DIR="$(cd "$(dirname "$(dirname "$(dirname "$0")")")" && pwd)"
DOTFILES_DIR="$(dirname "$TEST_DIR")"

# Set up test environment
export TEST_TMP_DIR="${TEST_TMP_DIR:-/tmp/dotfiles_test_$$}"
mkdir -p "$TEST_TMP_DIR"

# Test framework
source "${TEST_DIR}/lib/test_helpers.zsh"

# Source the library under test
source "${DOTFILES_DIR}/src/lib/cli.zsh"

# Helper to reset CLI state between tests
reset_cli() {
  CLI_FLAGS=()
  CLI_ARGS=()
  CLI_COMMAND=""
  CLI_OPTIONS=()
  CLI_DESCRIPTIONS=()
  CLI_DEFAULTS=()
  CLI_REQUIRED=()
  CLI_TYPES=()
  CLI_COMMANDS=()
  CLI_COMMAND_DESCRIPTIONS=()
}

# ============================================================================
# Flag Definition Tests
# ============================================================================

test_cli_flag_defines_flag() {
  test_case "cli_flag defines a flag"
  reset_cli
  cli_flag "verbose" "v" "Enable verbose output" "false" "bool"
  if [[ "${CLI_OPTIONS[verbose]}" == "v" ]] && \
     [[ "${CLI_DESCRIPTIONS[verbose]}" == "Enable verbose output" ]]; then
    pass
  else
    fail "Flag not properly defined"
  fi
}

test_cli_flag_bool_default() {
  test_case "cli_flag sets bool default to false"
  reset_cli
  cli_flag "debug" "d" "Debug mode" "" "bool"
  if [[ "${CLI_FLAGS[debug]}" == "false" ]]; then
    pass
  else
    fail "Expected 'false', got: '${CLI_FLAGS[debug]}'"
  fi
}

test_cli_flag_string_default() {
  test_case "cli_flag sets string default"
  reset_cli
  cli_flag "output" "o" "Output file" "out.txt" "string"
  if [[ "${CLI_FLAGS[output]}" == "out.txt" ]]; then
    pass
  else
    fail "Expected 'out.txt', got: '${CLI_FLAGS[output]}'"
  fi
}

# ============================================================================
# Command Definition Tests
# ============================================================================

test_cli_command_defines_command() {
  test_case "cli_command defines a subcommand"
  reset_cli
  cli_command "build" "Build the project"
  if [[ "${CLI_COMMANDS[1]}" == "build" ]] && \
     [[ "${CLI_COMMAND_DESCRIPTIONS[build]}" == "Build the project" ]]; then
    pass
  else
    fail "Command not properly defined"
  fi
}

# ============================================================================
# Program Info Tests
# ============================================================================

test_cli_program_sets_info() {
  test_case "cli_program sets program info"
  reset_cli
  cli_program "myapp" "My Application" "2.0.0"
  if [[ "$CLI_PROGRAM_NAME" == "myapp" ]] && \
     [[ "$CLI_PROGRAM_DESCRIPTION" == "My Application" ]] && \
     [[ "$CLI_PROGRAM_VERSION" == "2.0.0" ]]; then
    pass
  else
    fail "Program info not set correctly"
  fi
}

# ============================================================================
# Parsing Tests
# ============================================================================

test_cli_parse_long_flag() {
  test_case "cli_parse handles long flag"
  reset_cli
  cli_flag "verbose" "v" "Verbose" "false" "bool"
  cli_parse --verbose
  if [[ "${CLI_FLAGS[verbose]}" == "true" ]]; then
    pass
  else
    fail "Expected 'true', got: '${CLI_FLAGS[verbose]}'"
  fi
}

test_cli_parse_short_flag() {
  test_case "cli_parse handles short flag"
  reset_cli
  cli_flag "verbose" "v" "Verbose" "false" "bool"
  cli_parse -v
  if [[ "${CLI_FLAGS[verbose]}" == "true" ]]; then
    pass
  else
    fail "Expected 'true', got: '${CLI_FLAGS[verbose]}'"
  fi
}

test_cli_parse_flag_with_value() {
  test_case "cli_parse handles flag with value"
  reset_cli
  cli_flag "output" "o" "Output file" "" "string"
  cli_parse --output file.txt
  if [[ "${CLI_FLAGS[output]}" == "file.txt" ]]; then
    pass
  else
    fail "Expected 'file.txt', got: '${CLI_FLAGS[output]}'"
  fi
}

test_cli_parse_flag_equals_syntax() {
  test_case "cli_parse handles --flag=value syntax"
  reset_cli
  cli_flag "output" "o" "Output file" "" "string"
  cli_parse --output=file.txt
  if [[ "${CLI_FLAGS[output]}" == "file.txt" ]]; then
    pass
  else
    fail "Expected 'file.txt', got: '${CLI_FLAGS[output]}'"
  fi
}

test_cli_parse_positional_args() {
  test_case "cli_parse captures positional args"
  reset_cli
  cli_parse arg1 arg2 arg3
  if [[ ${#CLI_ARGS[@]} -eq 3 ]] && [[ "${CLI_ARGS[1]}" == "arg1" ]]; then
    pass
  else
    fail "Expected 3 positional args, got: ${#CLI_ARGS[@]}"
  fi
}

test_cli_parse_double_dash() {
  test_case "cli_parse handles -- separator"
  reset_cli
  cli_flag "verbose" "v" "Verbose" "false" "bool"
  cli_parse -v -- --not-a-flag
  if [[ "${CLI_FLAGS[verbose]}" == "true" ]] && \
     [[ "${CLI_ARGS[1]}" == "--not-a-flag" ]]; then
    pass
  else
    fail "Double dash not handled correctly"
  fi
}

test_cli_parse_unknown_flag() {
  test_case "cli_parse rejects unknown flag"
  reset_cli
  if ! cli_parse --unknown 2>/dev/null; then
    pass
  else
    fail "Expected failure for unknown flag"
  fi
}

# ============================================================================
# Access Tests
# ============================================================================

test_cli_get_returns_value() {
  test_case "CLI_FLAGS contains parsed values"
  reset_cli
  cli_flag "name" "n" "Name" "" "string"
  cli_parse --name John
  if [[ "${CLI_FLAGS[name]}" == "John" ]]; then
    pass
  else
    fail "Expected 'John', got: '${CLI_FLAGS[name]}'"
  fi
}

# ============================================================================
# Run Tests
# ============================================================================

test_suite "CLI Library" \
  test_cli_flag_defines_flag \
  test_cli_flag_bool_default \
  test_cli_flag_string_default \
  test_cli_command_defines_command \
  test_cli_program_sets_info \
  test_cli_parse_long_flag \
  test_cli_parse_short_flag \
  test_cli_parse_flag_with_value \
  test_cli_parse_flag_equals_syntax \
  test_cli_parse_positional_args \
  test_cli_parse_double_dash \
  test_cli_parse_unknown_flag \
  test_cli_get_returns_value
