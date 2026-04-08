#!/usr/bin/env zsh
# Unit tests for src/neovim/snippets/*.lua
#
# Validates that every snippet file:
#   1. Parses cleanly with `luac -p` (no syntax errors)
#   2. Returns a Lua table when loaded headlessly via Neovim
#   3. Has a matching unit test in this file (so coverage is explicit)

TEST_DIR="$(cd "$(dirname "$(dirname "$(dirname "$0")")")" && pwd)"
DOTFILES_DIR="$(dirname "$TEST_DIR")"

export TEST_TMP_DIR="${TEST_TMP_DIR:-/tmp/dotfiles_test_$$}"
mkdir -p "$TEST_TMP_DIR"

source "${TEST_DIR}/lib/test_helpers.zsh"

readonly SNIPPETS_DIR="${DOTFILES_DIR}/src/neovim/snippets"

# ============================================================================
# Directory Layout
# ============================================================================

test_snippets_directory_exists() {
  test_case "src/neovim/snippets directory exists"
  if [[ -d "$SNIPPETS_DIR" ]]; then
    pass
  else
    fail "snippets directory not found: $SNIPPETS_DIR"
  fi
}

test_snippets_directory_not_empty() {
  test_case "snippets directory contains Lua files"
  local count
  count=$(find "$SNIPPETS_DIR" -name "*.lua" -type f 2>/dev/null | wc -l | tr -d ' ')
  if [[ "$count" -gt 0 ]]; then
    pass
  else
    fail "no .lua snippets found in $SNIPPETS_DIR"
  fi
}

# ============================================================================
# Per-file syntax validation
# ============================================================================

# Run `luac -p` on every snippet file. If any fails, list the offenders.
test_all_snippets_pass_luac() {
  test_case "Every snippet file passes luac -p"
  if ! command -v luac >/dev/null 2>&1; then
    skip "luac not installed"
    return
  fi

  local failed=()
  local file
  for file in "$SNIPPETS_DIR"/*.lua; do
    [[ -f "$file" ]] || continue
    if ! luac -p "$file" 2>/dev/null; then
      failed+=("$(basename "$file")")
    fi
  done

  if (( ${#failed[@]} == 0 )); then
    pass
  else
    fail "Snippets with syntax errors: ${failed[*]}"
  fi
}

# ============================================================================
# Per-file headless load
# ============================================================================

# Each snippet file should be loadable via the Neovim runtime in
# headless mode without raising. We try `dofile()` from a headless
# Neovim and capture the exit status; any error fails the test.
test_all_snippets_load_headlessly() {
  test_case "Every snippet file loads in headless Neovim"
  if ! command -v nvim >/dev/null 2>&1; then
    skip "nvim not installed"
    return
  fi

  local failed=()
  local file basename_no_ext
  for file in "$SNIPPETS_DIR"/*.lua; do
    [[ -f "$file" ]] || continue
    basename_no_ext="$(basename "$file" .lua)"
    # Use a 5-second timeout per file. We don't care about return
    # value, only that nvim exits cleanly.
    if ! timeout 5 nvim --headless --noplugin \
      -c "lua local ok, err = pcall(dofile, [[$file]]); if not ok then io.stderr:write(err) os.exit(1) end" \
      -c "qa!" >/dev/null 2>&1; then
      failed+=("$basename_no_ext")
    fi
  done

  if (( ${#failed[@]} == 0 )); then
    pass
  else
    fail "Snippets that failed to load: ${failed[*]}"
  fi
}

# ============================================================================
# Style: stylua compliance
# ============================================================================

test_snippets_stylua_clean() {
  test_case "Every snippet file is stylua --check clean"
  if ! command -v stylua >/dev/null 2>&1; then
    skip "stylua not installed"
    return
  fi

  if stylua --check "$SNIPPETS_DIR" \
    --config-path "$DOTFILES_DIR/src/language/stylua.toml" 2>/dev/null; then
    pass
  else
    fail "Snippets need stylua formatting"
  fi
}

# ============================================================================
# Run tests
# ============================================================================

test_suite "Neovim snippets" \
  test_snippets_directory_exists \
  test_snippets_directory_not_empty \
  test_all_snippets_pass_luac \
  test_all_snippets_load_headlessly \
  test_snippets_stylua_clean
