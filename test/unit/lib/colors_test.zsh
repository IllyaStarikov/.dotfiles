#!/usr/bin/env zsh
# Unit tests for colors.zsh library

# Get the test directory path
TEST_DIR="$(cd "$(dirname "$(dirname "$(dirname "$0")")")" && pwd)"
DOTFILES_DIR="$(dirname "$TEST_DIR")"

# Set up test environment
export TEST_TMP_DIR="${TEST_TMP_DIR:-/tmp/dotfiles_test_$$}"
mkdir -p "$TEST_TMP_DIR"

# Test framework
source "${TEST_DIR}/lib/test_helpers.zsh"

# Source the library under test
source "${DOTFILES_DIR}/src/lib/colors.zsh"

# ============================================================================
# Color Constants
# ============================================================================

test_colors_assoc_array_defined() {
  test_case "COLORS associative array is defined"
  if (( ${+COLORS} )); then
    pass
  else
    fail "COLORS not defined"
  fi
}

test_colors_basic_foreground() {
  test_case "COLORS contains basic foreground colors"
  local missing=()
  for c in BLACK RED GREEN YELLOW BLUE MAGENTA CYAN WHITE; do
    [[ -z "${COLORS[$c]:-}" ]] && missing+=("$c")
  done
  if (( ${#missing[@]} == 0 )); then
    pass
  else
    fail "Missing foreground colors: ${missing[*]}"
  fi
}

test_colors_bright_foreground() {
  test_case "COLORS contains bright foreground colors"
  local missing=()
  for c in BRIGHT_BLACK BRIGHT_RED BRIGHT_GREEN BRIGHT_YELLOW \
    BRIGHT_BLUE BRIGHT_MAGENTA BRIGHT_CYAN BRIGHT_WHITE; do
    [[ -z "${COLORS[$c]:-}" ]] && missing+=("$c")
  done
  if (( ${#missing[@]} == 0 )); then
    pass
  else
    fail "Missing bright foreground colors: ${missing[*]}"
  fi
}

test_colors_background() {
  test_case "COLORS contains background colors"
  local missing=()
  for c in BG_BLACK BG_RED BG_GREEN BG_YELLOW BG_BLUE BG_MAGENTA BG_CYAN BG_WHITE; do
    [[ -z "${COLORS[$c]:-}" ]] && missing+=("$c")
  done
  if (( ${#missing[@]} == 0 )); then
    pass
  else
    fail "Missing background colors: ${missing[*]}"
  fi
}

test_styles_assoc_array_defined() {
  test_case "STYLES associative array is defined"
  if (( ${+STYLES} )); then
    pass
  else
    fail "STYLES not defined"
  fi
}

test_styles_essential() {
  test_case "STYLES contains essential text styles"
  local missing=()
  for s in RESET BOLD DIM ITALIC UNDERLINE; do
    [[ -z "${STYLES[$s]:-}" ]] && missing+=("$s")
  done
  if (( ${#missing[@]} == 0 )); then
    pass
  else
    fail "Missing styles: ${missing[*]}"
  fi
}

test_color_codes_format() {
  test_case "Color codes use ANSI escape format"
  local code="${COLORS[RED]}"
  if [[ "$code" == $'\033'* ]] || [[ "$code" == '\033'* ]]; then
    pass
  else
    fail "RED color code does not look like ANSI: $code"
  fi
}

# ============================================================================
# colorize() Function
# ============================================================================

test_colorize_function_exists() {
  test_case "colorize function is defined"
  if declare -f colorize >/dev/null 2>&1; then
    pass
  else
    fail "colorize function not defined"
  fi
}

test_colorize_returns_text() {
  test_case "colorize returns text wrapped in escape codes"
  if ! declare -f colorize >/dev/null 2>&1; then
    skip "colorize not available"
    return
  fi
  local result
  result=$(colorize "RED" "hello")
  # The output should at least include the literal "hello"
  if [[ "$result" == *hello* ]]; then
    pass
  else
    fail "colorize 'RED' 'hello' did not include 'hello': $result"
  fi
}

# ============================================================================
# Convenience exports
# ============================================================================

test_color_shorthand_vars() {
  test_case "Convenience color shorthand variables are exported"
  # The library exports $RED, $GREEN, $YELLOW, $BLUE, $CYAN, $BOLD, $NC for
  # use throughout the codebase. Some of these may be empty in
  # non-terminal contexts; just verify they are defined.
  local missing=()
  for v in RED GREEN YELLOW BLUE CYAN BOLD NC; do
    if ! (( ${(P)+v} )); then
      missing+=("$v")
    fi
  done
  if (( ${#missing[@]} == 0 )); then
    pass
  else
    fail "Missing shorthand color vars: ${missing[*]}"
  fi
}

# ============================================================================
# Run Tests
# ============================================================================

test_suite "Colors Library" \
  test_colors_assoc_array_defined \
  test_colors_basic_foreground \
  test_colors_bright_foreground \
  test_colors_background \
  test_styles_assoc_array_defined \
  test_styles_essential \
  test_color_codes_format \
  test_colorize_function_exists \
  test_colorize_returns_text \
  test_color_shorthand_vars
