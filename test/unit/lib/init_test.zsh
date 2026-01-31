#!/usr/bin/env zsh
# Unit tests for init.zsh and lib.zsh (library loader)

# Get the test directory path
TEST_DIR="$(cd "$(dirname "$(dirname "$(dirname "$0")")")" && pwd)"
DOTFILES_DIR="$(dirname "$TEST_DIR")"

# Set up test environment
export TEST_TMP_DIR="${TEST_TMP_DIR:-/tmp/dotfiles_test_$$}"
mkdir -p "$TEST_TMP_DIR"

# Test framework
source "${TEST_DIR}/lib/test_helpers.zsh"

# ============================================================================
# Library File Tests
# ============================================================================

test_init_file_exists() {
  test_case "init.zsh exists"
  if [[ -f "${DOTFILES_DIR}/src/lib/init.zsh" ]]; then
    pass
  else
    fail "init.zsh not found"
  fi
}

test_lib_file_exists() {
  test_case "lib.zsh exists"
  if [[ -f "${DOTFILES_DIR}/src/lib/lib.zsh" ]]; then
    pass
  else
    fail "lib.zsh not found"
  fi
}

# ============================================================================
# Library Loading Tests
# ============================================================================

test_lib_load_core_available() {
  test_case "lib_load_core function exists"
  source "${DOTFILES_DIR}/src/lib/lib.zsh"
  if declare -f lib_load_core >/dev/null 2>&1; then
    pass
  else
    fail "lib_load_core function not defined"
  fi
}

test_lib_load_function_available() {
  test_case "lib_load function exists"
  source "${DOTFILES_DIR}/src/lib/lib.zsh"
  if declare -f lib_load >/dev/null 2>&1; then
    pass
  else
    fail "lib_load function not defined"
  fi
}

test_lib_is_loaded_function() {
  test_case "lib_is_loaded function works"
  source "${DOTFILES_DIR}/src/lib/lib.zsh"
  lib_load colors
  if lib_is_loaded colors; then
    pass
  else
    fail "colors should be marked as loaded"
  fi
}

test_lib_list_available() {
  test_case "lib_list_available returns modules"
  source "${DOTFILES_DIR}/src/lib/lib.zsh"
  local modules=$(lib_list_available)
  if [[ "$modules" == *"colors"* ]] && [[ "$modules" == *"utils"* ]]; then
    pass
  else
    fail "Expected available modules, got: $modules"
  fi
}

# ============================================================================
# Core Module Loading Tests
# ============================================================================

test_init_loads_colors() {
  test_case "init.zsh loads colors module"
  (
    unset COLORS RED GREEN BLUE NC
    source "${DOTFILES_DIR}/src/lib/init.zsh"
    if [[ -n "$RED" ]] || [[ -n "${COLORS[RED]}" ]] || declare -f colorize >/dev/null 2>&1; then
      exit 0
    else
      exit 1
    fi
  )
  if [[ $? -eq 0 ]]; then
    pass
  else
    fail "Colors not loaded by init.zsh"
  fi
}

test_init_loads_utils() {
  test_case "init.zsh loads utils module"
  (
    source "${DOTFILES_DIR}/src/lib/init.zsh"
    if declare -f command_exists >/dev/null 2>&1; then
      exit 0
    else
      exit 1
    fi
  )
  if [[ $? -eq 0 ]]; then
    pass
  else
    fail "Utils not loaded by init.zsh"
  fi
}

test_init_loads_logging() {
  test_case "init.zsh loads logging module"
  (
    source "${DOTFILES_DIR}/src/lib/init.zsh"
    if declare -f LOG >/dev/null 2>&1; then
      exit 0
    else
      exit 1
    fi
  )
  if [[ $? -eq 0 ]]; then
    pass
  else
    fail "Logging not loaded by init.zsh"
  fi
}

test_init_loads_die() {
  test_case "init.zsh loads die module"
  (
    source "${DOTFILES_DIR}/src/lib/init.zsh"
    if declare -f die >/dev/null 2>&1; then
      exit 0
    else
      exit 1
    fi
  )
  if [[ $? -eq 0 ]]; then
    pass
  else
    fail "Die not loaded by init.zsh"
  fi
}

# ============================================================================
# DOTFILES Detection Tests
# ============================================================================

test_init_sets_dotfiles() {
  test_case "init.zsh sets DOTFILES variable"
  (
    unset DOTFILES
    source "${DOTFILES_DIR}/src/lib/init.zsh"
    if [[ -n "$DOTFILES" ]] && [[ -d "$DOTFILES" ]]; then
      exit 0
    else
      exit 1
    fi
  )
  if [[ $? -eq 0 ]]; then
    pass
  else
    fail "DOTFILES not set by init.zsh"
  fi
}

# ============================================================================
# Library Dependency Tests
# ============================================================================

test_lib_show_dependencies() {
  test_case "lib_show_dependencies returns dependencies"
  source "${DOTFILES_DIR}/src/lib/lib.zsh"
  local deps=$(lib_show_dependencies die)
  # die depends on colors and callstack
  if [[ "$deps" == *"colors"* ]]; then
    pass
  else
    fail "Expected dependencies for die, got: $deps"
  fi
}

# ============================================================================
# Module Loading Tests
# ============================================================================

test_lib_load_array() {
  test_case "lib_load loads array module"
  source "${DOTFILES_DIR}/src/lib/lib.zsh"
  lib_load array
  if declare -f array_new >/dev/null 2>&1; then
    pass
  else
    fail "array module not loaded"
  fi
}

test_lib_load_json() {
  test_case "lib_load loads json module"
  source "${DOTFILES_DIR}/src/lib/lib.zsh"
  lib_load json
  if declare -f json_encode >/dev/null 2>&1; then
    pass
  else
    fail "json module not loaded"
  fi
}

test_lib_load_hash() {
  test_case "lib_load loads hash module"
  source "${DOTFILES_DIR}/src/lib/lib.zsh"
  lib_load hash
  if declare -f hash_new >/dev/null 2>&1; then
    pass
  else
    fail "hash module not loaded"
  fi
}

# ============================================================================
# Run Tests
# ============================================================================

test_suite "Init and Library Loader" \
  test_init_file_exists \
  test_lib_file_exists \
  test_lib_load_core_available \
  test_lib_load_function_available \
  test_lib_is_loaded_function \
  test_lib_list_available \
  test_init_loads_colors \
  test_init_loads_utils \
  test_init_loads_logging \
  test_init_loads_die \
  test_init_sets_dotfiles \
  test_lib_show_dependencies \
  test_lib_load_array \
  test_lib_load_json \
  test_lib_load_hash
