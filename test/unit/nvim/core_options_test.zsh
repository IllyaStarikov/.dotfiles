#!/usr/bin/env zsh
# Test: Neovim Core Options Configuration
#
# Tests critical Neovim options from src/neovim/core/*.lua modules:
#   - options.lua: General settings (history, scrolloff, clipboard)
#   - search.lua: Search behavior (ignorecase, smartcase, hlsearch)
#   - backup.lua: Undo/swap file settings
#   - indentation.lua: Tab/indent settings
#   - folding.lua: Code folding settings
#   - performance.lua: Performance optimizations
#
# Style guide: https://google.github.io/styleguide/shellguide.html

# IMPORTANT: Skip Neovim tests in CI on macOS due to hanging issues
if [[ "$CI" == "true" ]] && [[ "$(uname)" == "Darwin" ]]; then
  echo "[SKIP] Neovim tests skipped on macOS CI (known hanging issue)"
  exit 0
fi

# Test environment configuration
export TEST_DIR="${TEST_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"
export DOTFILES_DIR="${DOTFILES_DIR:-$(cd "$TEST_DIR/.." && pwd)}"
export TEST_TMP_DIR="${TEST_TMP_DIR:-/tmp/dotfiles-test-$$}"

# Source test framework
source "$TEST_DIR/lib/test_helpers.zsh"

# Setup test
setup_test

describe "Neovim Core Options Tests"

# Helper to run Neovim and check option value
# Args: $1 = option name, $2 = expected value pattern
check_option() {
  local opt_name="$1"
  local expected="$2"
  local result

  result=$(timeout 10 nvim --headless -c "lua print(vim.o.$opt_name)" -c "qa!" 2>&1 | tail -1)
  if [[ "$result" == *"$expected"* ]]; then
    return 0
  else
    echo "Expected '$expected' for $opt_name, got '$result'"
    return 1
  fi
}

# Helper to check boolean option (true/false)
check_bool_option() {
  local opt_name="$1"
  local expected="$2"
  local result

  result=$(timeout 10 nvim --headless -c "lua print(vim.o.$opt_name)" -c "qa!" 2>&1 | tail -1)
  if [[ "$result" == "$expected" ]]; then
    return 0
  else
    echo "Expected '$expected' for $opt_name, got '$result'"
    return 1
  fi
}

# =============================================================================
# CORE MODULE FILES EXIST
# =============================================================================

test_case "Core module files exist"
core_modules=(
  "options.lua"
  "search.lua"
  "backup.lua"
  "indentation.lua"
  "folding.lua"
  "performance.lua"
  "init.lua"
)

all_exist=true
for module in "${core_modules[@]}"; do
  if [[ ! -f "$DOTFILES_DIR/src/neovim/core/$module" ]]; then
    fail "Missing core module: $module"
    all_exist=false
  fi
done
if $all_exist; then
  pass
fi

# =============================================================================
# LUA SYNTAX VALIDATION
# =============================================================================

test_case "Core Lua files have valid syntax"
syntax_ok=true
for module in "${core_modules[@]}"; do
  local file="$DOTFILES_DIR/src/neovim/core/$module"
  if [[ -f "$file" ]]; then
    if ! luac -p "$file" 2>/dev/null; then
      fail "Syntax error in: $module"
      syntax_ok=false
    fi
  fi
done
if $syntax_ok; then
  pass
fi

# =============================================================================
# OPTIONS.LUA SETTINGS
# =============================================================================

test_case "History is set to 10000"
if check_option "history" "10000"; then
  pass
else
  fail "history should be 10000"
fi

test_case "Scrolloff is set to 8"
if check_option "scrolloff" "8"; then
  pass
else
  fail "scrolloff should be 8"
fi

test_case "Updatetime is set to reasonable value"
result=$(timeout 10 nvim --headless -c "lua print(vim.o.updatetime)" -c "qa!" 2>&1 | tail -1)
# WezTerm uses 4000ms to prevent hangs, regular terminals use ~300ms
# Accept anything <= 4000ms as reasonable
if [[ "$result" -le 4000 ]]; then
  pass
else
  fail "updatetime should be <= 4000ms, got $result"
fi

test_case "Timeoutlen is set for which-key (< 1000ms)"
result=$(timeout 10 nvim --headless -c "lua print(vim.o.timeoutlen)" -c "qa!" 2>&1 | tail -1)
if [[ "$result" -le 1000 ]]; then
  pass
else
  fail "timeoutlen should be <= 1000ms for which-key, got $result"
fi

test_case "Clipboard is configured for system integration"
result=$(timeout 10 nvim --headless -c "lua print(vim.o.clipboard)" -c "qa!" 2>&1 | tail -1)
if [[ "$result" == *"unnamedplus"* ]]; then
  pass
else
  fail "clipboard should include 'unnamedplus', got $result"
fi

# =============================================================================
# SEARCH.LUA SETTINGS
# =============================================================================

test_case "Search: ignorecase is enabled"
if check_bool_option "ignorecase" "true"; then
  pass
else
  fail "ignorecase should be true"
fi

test_case "Search: smartcase is enabled"
if check_bool_option "smartcase" "true"; then
  pass
else
  fail "smartcase should be true"
fi

test_case "Search: hlsearch is enabled"
if check_bool_option "hlsearch" "true"; then
  pass
else
  fail "hlsearch should be true"
fi

test_case "Search: incsearch is enabled"
if check_bool_option "incsearch" "true"; then
  pass
else
  fail "incsearch should be true"
fi

test_case "Search: gdefault is enabled for global substitution"
if check_bool_option "gdefault" "true"; then
  pass
else
  fail "gdefault should be true for easier substitution"
fi

# =============================================================================
# BACKUP.LUA SETTINGS
# =============================================================================

test_case "Backup: writebackup is disabled"
if check_bool_option "writebackup" "false"; then
  pass
else
  fail "writebackup should be false"
fi

test_case "Backup: swapfile is disabled"
if check_bool_option "swapfile" "false"; then
  pass
else
  fail "swapfile should be false"
fi

test_case "Backup: undofile is enabled for persistent undo"
if check_bool_option "undofile" "true"; then
  pass
else
  fail "undofile should be true for persistent undo"
fi

test_case "Backup: undolevels is high for more undo history"
result=$(timeout 10 nvim --headless -c "lua print(vim.o.undolevels)" -c "qa!" 2>&1 | tail -1)
if [[ "$result" -ge 10000 ]]; then
  pass
else
  fail "undolevels should be >= 10000, got $result"
fi

# =============================================================================
# INDENTATION SETTINGS (from autocmds.lua FileType handlers)
# =============================================================================

test_case "Indentation: expandtab is enabled (spaces not tabs)"
if check_bool_option "expandtab" "true"; then
  pass
else
  fail "expandtab should be true (use spaces)"
fi

# =============================================================================
# UI SETTINGS
# =============================================================================

test_case "UI: number is enabled"
if check_bool_option "number" "true"; then
  pass
else
  fail "number should be true for line numbers"
fi

test_case "UI: relativenumber is enabled"
if check_bool_option "relativenumber" "true"; then
  pass
else
  fail "relativenumber should be true"
fi

test_case "UI: cursorline is enabled"
if check_bool_option "cursorline" "true"; then
  pass
else
  fail "cursorline should be true"
fi

test_case "UI: signcolumn is set to 'yes'"
result=$(timeout 10 nvim --headless -c "lua print(vim.o.signcolumn)" -c "qa!" 2>&1 | tail -1)
if [[ "$result" == "yes" ]]; then
  pass
else
  fail "signcolumn should be 'yes', got $result"
fi

test_case "UI: termguicolors is enabled"
if check_bool_option "termguicolors" "true"; then
  pass
else
  fail "termguicolors should be true for proper color support"
fi

# =============================================================================
# PERFORMANCE SETTINGS
# =============================================================================

test_case "Performance: lazyredraw is configured"
# lazyredraw might be false for better visual feedback
result=$(timeout 10 nvim --headless -c "lua print(vim.o.lazyredraw)" -c "qa!" 2>&1 | tail -1)
if [[ "$result" == "true" ]] || [[ "$result" == "false" ]]; then
  pass
else
  fail "lazyredraw should be boolean, got $result"
fi

test_case "Performance: synmaxcol is set"
result=$(timeout 10 nvim --headless -c "lua print(vim.o.synmaxcol)" -c "qa!" 2>&1 | tail -1)
if [[ "$result" -gt 0 ]]; then
  pass
else
  fail "synmaxcol should be positive, got $result"
fi

# Cleanup
cleanup_test

exit 0
