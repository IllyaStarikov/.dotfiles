#!/usr/bin/env zsh
# Test: Neovim Plugin Configurations
#
# Tests plugin configuration validity from src/neovim/plugins/*.lua:
#   - ai.lua: AI integrations (Avante, CodeCompanion)
#   - completion.lua: Completion configuration (blink.cmp)
#   - snippets.lua: LuaSnip configuration
#   - snacks.lua: Snacks.nvim dashboard/utilities
#   - vimtex.lua: LaTeX integration
#   - render-markdown.lua: Markdown rendering
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

describe "Neovim Plugin Configurations Tests"

readonly PLUGINS_DIR="$DOTFILES_DIR/src/neovim/plugins"

# =============================================================================
# DIRECTORY STRUCTURE
# =============================================================================

test_case "Plugins directory exists"
if [[ -d "$PLUGINS_DIR" ]]; then
  pass
else
  fail "Missing: src/neovim/plugins/"
fi

test_case "Plugin configuration files exist"
plugin_files=(
  "init.lua"
  "ai.lua"
  "completion.lua"
  "snippets.lua"
  "snacks.lua"
)

all_exist=true
for file in "${plugin_files[@]}"; do
  if [[ ! -f "$PLUGINS_DIR/$file" ]]; then
    fail "Missing plugin config: $file"
    all_exist=false
  fi
done
if $all_exist; then
  pass
fi

# =============================================================================
# LUA SYNTAX VALIDATION
# =============================================================================

test_case "All plugin Lua files have valid syntax"
syntax_ok=true
for file in "$PLUGINS_DIR"/*.lua; do
  if [[ -f "$file" ]]; then
    if ! luac -p "$file" 2>/dev/null; then
      fail "Syntax error in: $(basename $file)"
      syntax_ok=false
    fi
  fi
done
if $syntax_ok; then
  pass
fi

# =============================================================================
# AI PLUGINS CONFIGURATION
# =============================================================================

test_case "AI plugins config exists and is valid"
ai_file="$PLUGINS_DIR/ai.lua"
if [[ -f "$ai_file" ]]; then
  if luac -p "$ai_file" 2>/dev/null; then
    pass
  else
    fail "Syntax error in ai.lua"
  fi
else
  skip "ai.lua not found"
fi

test_case "AI plugins include Avante or CodeCompanion"
ai_file="$PLUGINS_DIR/ai.lua"
if [[ -f "$ai_file" ]]; then
  if grep -q "avante\|codecompanion\|CodeCompanion" "$ai_file"; then
    pass
  else
    fail "AI plugins should include Avante or CodeCompanion"
  fi
else
  skip "ai.lua not found"
fi

# =============================================================================
# COMPLETION CONFIGURATION
# =============================================================================

test_case "Completion config exists and is valid"
completion_file="$PLUGINS_DIR/completion.lua"
if [[ -f "$completion_file" ]]; then
  if luac -p "$completion_file" 2>/dev/null; then
    pass
  else
    fail "Syntax error in completion.lua"
  fi
else
  skip "completion.lua not found"
fi

test_case "Completion uses blink.cmp"
completion_file="$PLUGINS_DIR/completion.lua"
if [[ -f "$completion_file" ]]; then
  if grep -q "blink" "$completion_file"; then
    pass
  else
    fail "Completion should use blink.cmp"
  fi
else
  skip "completion.lua not found"
fi

# =============================================================================
# SNIPPETS CONFIGURATION
# =============================================================================

test_case "Snippets config exists and is valid"
snippets_file="$PLUGINS_DIR/snippets.lua"
if [[ -f "$snippets_file" ]]; then
  if luac -p "$snippets_file" 2>/dev/null; then
    pass
  else
    fail "Syntax error in snippets.lua"
  fi
else
  skip "snippets.lua not found"
fi

test_case "Snippets directory exists"
if [[ -d "$DOTFILES_DIR/src/neovim/snippets" ]]; then
  pass
else
  fail "Missing snippets directory"
fi

test_case "Snippet files have valid Lua syntax"
snippets_dir="$DOTFILES_DIR/src/neovim/snippets"
if [[ -d "$snippets_dir" ]]; then
  syntax_ok=true
  for file in "$snippets_dir"/*.lua; do
    if [[ -f "$file" ]]; then
      if ! luac -p "$file" 2>/dev/null; then
        fail "Syntax error in snippet: $(basename $file)"
        syntax_ok=false
      fi
    fi
  done
  if $syntax_ok; then
    pass
  fi
else
  skip "Snippets directory not found"
fi

# =============================================================================
# SNACKS.NVIM CONFIGURATION
# =============================================================================

test_case "Snacks config exists and is valid"
snacks_file="$PLUGINS_DIR/snacks.lua"
if [[ -f "$snacks_file" ]]; then
  if luac -p "$snacks_file" 2>/dev/null; then
    pass
  else
    fail "Syntax error in snacks.lua"
  fi
else
  skip "snacks.lua not found"
fi

# =============================================================================
# MAIN PLUGINS.LUA FILE
# =============================================================================

test_case "Main plugins.lua exists"
if [[ -f "$DOTFILES_DIR/src/neovim/plugins.lua" ]]; then
  pass
else
  fail "Missing main plugins.lua"
fi

test_case "Main plugins.lua has valid syntax"
if luac -p "$DOTFILES_DIR/src/neovim/plugins.lua" 2>/dev/null; then
  pass
else
  fail "Syntax error in plugins.lua"
fi

test_case "Main plugins.lua returns a table"
plugins_file="$DOTFILES_DIR/src/neovim/plugins.lua"
if grep -q "^return" "$plugins_file"; then
  pass
else
  fail "plugins.lua should return a table"
fi

# =============================================================================
# LSP CONFIGURATION
# =============================================================================

test_case "LSP configuration exists"
if [[ -f "$DOTFILES_DIR/src/neovim/lsp.lua" ]]; then
  pass
else
  fail "Missing lsp.lua configuration"
fi

test_case "LSP config has valid syntax"
if luac -p "$DOTFILES_DIR/src/neovim/lsp.lua" 2>/dev/null; then
  pass
else
  fail "Syntax error in lsp.lua"
fi

# =============================================================================
# UI CONFIGURATION
# =============================================================================

test_case "UI configuration exists"
if [[ -f "$DOTFILES_DIR/src/neovim/ui.lua" ]]; then
  pass
else
  fail "Missing ui.lua configuration"
fi

test_case "UI config has valid syntax"
if luac -p "$DOTFILES_DIR/src/neovim/ui.lua" 2>/dev/null; then
  pass
else
  fail "Syntax error in ui.lua"
fi

# =============================================================================
# FIXY CONFIGURATION
# =============================================================================

test_case "Fixy configuration exists"
if [[ -f "$DOTFILES_DIR/src/neovim/fixy.lua" ]]; then
  pass
else
  fail "Missing fixy.lua formatter integration"
fi

test_case "Fixy config has valid syntax"
if luac -p "$DOTFILES_DIR/src/neovim/fixy.lua" 2>/dev/null; then
  pass
else
  fail "Syntax error in fixy.lua"
fi

# =============================================================================
# GITSIGNS CONFIGURATION
# =============================================================================

test_case "Gitsigns configuration exists"
if [[ -f "$DOTFILES_DIR/src/neovim/gitsigns.lua" ]]; then
  pass
else
  fail "Missing gitsigns.lua"
fi

test_case "Gitsigns config has valid syntax"
if luac -p "$DOTFILES_DIR/src/neovim/gitsigns.lua" 2>/dev/null; then
  pass
else
  fail "Syntax error in gitsigns.lua"
fi

# =============================================================================
# TELESCOPE CONFIGURATION
# =============================================================================

test_case "Telescope configuration exists"
if [[ -f "$DOTFILES_DIR/src/neovim/telescope.lua" ]]; then
  pass
else
  fail "Missing telescope.lua"
fi

test_case "Telescope config has valid syntax"
if luac -p "$DOTFILES_DIR/src/neovim/telescope.lua" 2>/dev/null; then
  pass
else
  fail "Syntax error in telescope.lua"
fi

# =============================================================================
# DAP (DEBUG ADAPTER) CONFIGURATION
# =============================================================================

test_case "DAP configuration exists"
if [[ -f "$DOTFILES_DIR/src/neovim/dap.lua" ]]; then
  pass
else
  fail "Missing dap.lua debug configuration"
fi

test_case "DAP config has valid syntax"
if luac -p "$DOTFILES_DIR/src/neovim/dap.lua" 2>/dev/null; then
  pass
else
  fail "Syntax error in dap.lua"
fi

# Cleanup
cleanup_test

exit 0
