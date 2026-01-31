#!/usr/bin/env zsh
# Test: Neovim Autocommands Configuration
#
# Tests autocommand registration and behavior from src/neovim/autocmds.lua:
#   - FileType-specific settings (Python, C/C++, Shell, Lua, etc.)
#   - Big file optimizations
#   - Markdown writing environment
#   - Build/Bazel file detection
#   - Spell checking configuration
#   - Auto-reload on external changes
#   - Skeleton file templates
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

describe "Neovim Autocommands Tests"

readonly AUTOCMDS_FILE="$DOTFILES_DIR/src/neovim/autocmds.lua"

# =============================================================================
# FILE EXISTENCE AND SYNTAX
# =============================================================================

test_case "autocmds.lua exists"
if [[ -f "$AUTOCMDS_FILE" ]]; then
  pass
else
  fail "Missing: src/neovim/autocmds.lua"
fi

test_case "autocmds.lua has valid Lua syntax"
if luac -p "$AUTOCMDS_FILE" 2>/dev/null; then
  pass
else
  fail "Syntax error in autocmds.lua"
fi

test_case "autocmds.lua loads without errors"
result=$(timeout 10 nvim --headless -c "luafile $AUTOCMDS_FILE" -c "qa!" 2>&1)
if [[ -z "$result" ]] || [[ "$result" != *"Error"* ]]; then
  pass
else
  fail "autocmds.lua has runtime errors: $result"
fi

# =============================================================================
# AUTOGROUP DEFINITIONS
# =============================================================================

test_case "Autogroups are created with nvim_create_augroup"
if grep -q "nvim_create_augroup" "$AUTOCMDS_FILE"; then
  pass
else
  fail "Should use nvim_create_augroup for autogroups"
fi

test_case "Autogroups use clear = true pattern"
if grep -q "clear = true" "$AUTOCMDS_FILE"; then
  pass
else
  fail "Autogroups should use clear = true to avoid duplicates"
fi

# =============================================================================
# FILETYPE INDENTATION SETTINGS
# =============================================================================

test_case "Python: 4-space indentation (Google Style)"
if grep -A5 'pattern = "python"' "$AUTOCMDS_FILE" | grep -q "shiftwidth = 4"; then
  pass
else
  fail "Python should use 4-space indentation (Google Style)"
fi

test_case "C/C++: 2-space indentation (Google Style)"
# Check for C/C++ pattern with 2-space indent
if grep -A5 'pattern.*"c".*"cpp"' "$AUTOCMDS_FILE" | grep -q "shiftwidth = 2"; then
  pass
else
  fail "C/C++ should use 2-space indentation (Google Style)"
fi

test_case "Shell: 2-space indentation (Google Style)"
if grep -A5 'pattern.*"sh".*"bash"' "$AUTOCMDS_FILE" | grep -q "shiftwidth = 2"; then
  pass
else
  fail "Shell should use 2-space indentation (Google Style)"
fi

test_case "Lua: 2-space indentation"
if grep -A5 'pattern.*"lua"' "$AUTOCMDS_FILE" | grep -q "shiftwidth = 2"; then
  pass
else
  fail "Lua should use 2-space indentation"
fi

test_case "Go: Tab indentation (official Go style)"
if grep -A5 'pattern.*"go"' "$AUTOCMDS_FILE" | grep -q "expandtab = false"; then
  pass
else
  fail "Go should use tabs (expandtab = false)"
fi

# =============================================================================
# BUILD/BAZEL FILE DETECTION
# =============================================================================

test_case "BUILD files are detected as bzl filetype"
if grep -q 'pattern.*BUILD' "$AUTOCMDS_FILE" && grep -q 'filetype = "bzl"' "$AUTOCMDS_FILE"; then
  pass
else
  fail "BUILD files should be detected as bzl filetype"
fi

test_case "WORKSPACE files are detected as bzl filetype"
if grep -q 'WORKSPACE' "$AUTOCMDS_FILE"; then
  pass
else
  fail "WORKSPACE files should be detected as bzl"
fi

test_case "*.bzl files are supported"
if grep -q '*.bzl' "$AUTOCMDS_FILE" || grep -q '"*.bzl"' "$AUTOCMDS_FILE"; then
  pass
else
  fail "*.bzl files should be supported"
fi

# =============================================================================
# BIG FILE OPTIMIZATIONS
# =============================================================================

test_case "Big file detection is implemented"
if grep -q "bigfile\|big_file\|big file" "$AUTOCMDS_FILE"; then
  pass
else
  fail "Should have big file detection"
fi

test_case "Big file disables expensive features"
expensive_features=("syntax" "foldmethod" "swapfile")
found=0
for feature in "${expensive_features[@]}"; do
  if grep -q "$feature" "$AUTOCMDS_FILE"; then
    ((found++))
  fi
done
if [[ $found -ge 2 ]]; then
  pass
else
  fail "Big file handling should disable expensive features"
fi

# =============================================================================
# MARKDOWN SETTINGS
# =============================================================================

test_case "Markdown files have writing environment settings"
if grep -q 'pattern.*markdown' "$AUTOCMDS_FILE" && grep -q "wrap" "$AUTOCMDS_FILE"; then
  pass
else
  fail "Markdown should have word wrap enabled"
fi

test_case "Markdown files have spell checking"
if grep -q 'spell' "$AUTOCMDS_FILE"; then
  pass
else
  fail "Markdown should have spell checking configured"
fi

test_case "Markdown files have linebreak for word wrap"
if grep -q 'linebreak' "$AUTOCMDS_FILE"; then
  pass
else
  fail "Markdown should use linebreak for clean word wrap"
fi

# =============================================================================
# SPELL CHECKING CONFIGURATION
# =============================================================================

test_case "Spell checking targets documentation file types"
spell_types=("markdown" "tex" "gitcommit")
found=0
for ftype in "${spell_types[@]}"; do
  if grep -q "$ftype" "$AUTOCMDS_FILE"; then
    ((found++))
  fi
done
if [[ $found -ge 2 ]]; then
  pass
else
  fail "Spell checking should target markdown, tex, gitcommit"
fi

# =============================================================================
# AUTO-RELOAD ON EXTERNAL CHANGES
# =============================================================================

test_case "Auto-reload on file change is configured"
if grep -q "autoread\|checktime" "$AUTOCMDS_FILE"; then
  pass
else
  fail "Auto-reload on external file changes should be configured"
fi

test_case "FocusGained triggers file check"
if grep -q "FocusGained" "$AUTOCMDS_FILE"; then
  pass
else
  fail "FocusGained should trigger checktime"
fi

# =============================================================================
# TERMINAL CURSOR HANDLING
# =============================================================================

test_case "Terminal cursor is configured"
if grep -q "TermEnter\|TermLeave" "$AUTOCMDS_FILE"; then
  pass
else
  fail "Terminal cursor handling should be configured"
fi

test_case "guicursor is set for terminal mode"
if grep -q "guicursor" "$AUTOCMDS_FILE"; then
  pass
else
  fail "guicursor should be configured for terminal mode"
fi

# =============================================================================
# SKELETON FILE TEMPLATES
# =============================================================================

test_case "Skeleton file system is implemented"
if grep -q "skeleton" "$AUTOCMDS_FILE"; then
  pass
else
  fail "Skeleton file templates should be implemented"
fi

test_case "Python skeleton template exists"
if grep -q "python\|#!/usr/bin/env python" "$AUTOCMDS_FILE"; then
  pass
else
  fail "Python skeleton template should exist"
fi

test_case "Shell skeleton template exists"
if grep -q "#!/bin/bash\|#!/usr/bin/env bash" "$AUTOCMDS_FILE"; then
  pass
else
  fail "Shell skeleton template should exist"
fi

test_case "Skeleton uses BufNewFile event"
if grep -q "BufNewFile" "$AUTOCMDS_FILE"; then
  pass
else
  fail "Skeletons should trigger on BufNewFile"
fi

# =============================================================================
# MAKEFILE HANDLING
# =============================================================================

test_case "Makefiles preserve tabs"
if grep -q "make\|makefile" "$AUTOCMDS_FILE" && grep -q "noexpandtab" "$AUTOCMDS_FILE"; then
  pass
else
  fail "Makefiles should preserve tabs (noexpandtab)"
fi

# =============================================================================
# LSP HIGHLIGHT CONFIGURATION
# =============================================================================

test_case "LSP document highlight is configured"
if grep -q "LspReferenceText\|LspDocumentHighlight" "$AUTOCMDS_FILE"; then
  pass
else
  fail "LSP document highlight should be configured"
fi

test_case "LSP highlights are set on ColorScheme event"
if grep -q "ColorScheme" "$AUTOCMDS_FILE"; then
  pass
else
  fail "LSP highlights should update on ColorScheme change"
fi

# =============================================================================
# TREESITTER ERROR HANDLING
# =============================================================================

test_case "Treesitter error handling is implemented"
if grep -q "treesitter\|Treesitter" "$AUTOCMDS_FILE"; then
  pass
else
  fail "Treesitter error handling should be implemented"
fi

test_case "TSReset command exists"
if grep -q "TSReset" "$AUTOCMDS_FILE"; then
  pass
else
  fail "TSReset command should exist for manual recovery"
fi

# =============================================================================
# AUTOCOMMAND DESCRIPTIONS
# =============================================================================

test_case "Autocommands have descriptions"
desc_count=$(grep -c 'desc = "' "$AUTOCMDS_FILE")
if [[ $desc_count -ge 10 ]]; then
  pass
else
  fail "Autocommands should have descriptions for debugging"
fi

# Cleanup
cleanup_test

exit 0
