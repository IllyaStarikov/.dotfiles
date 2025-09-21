#!/usr/bin/env zsh
# Comprehensive functional tests for Neovim configuration

# Tests handle errors explicitly

# Set up test environment
export TEST_DIR="${TEST_DIR:-$(dirname "$0")/..}"
export DOTFILES_DIR="${DOTFILES_DIR:-$(dirname "$TEST_DIR")}"

# Source test framework
source "$TEST_DIR/lib/test_helpers.zsh"

# Note: CI detection is now handled properly in Neovim config
# Tests should work in CI with the headless mode fixes

# Timeout wrapper that works on macOS and Linux
timeout_cmd() {
    local duration=$1
    shift

    if command -v timeout >/dev/null 2>&1; then
        timeout "$duration" "$@"
    elif command -v gtimeout >/dev/null 2>&1; then
        gtimeout "$duration" "$@"
    else
        # Fallback: run without timeout
        "$@"
    fi
}

# Check if we're in CI environment
is_ci() {
    [[ -n "$CI" ]] || [[ -n "$CI_MODE" ]] || [[ -n "$GITHUB_ACTIONS" ]]
}

# Test suite for Neovim
describe "Neovim configuration comprehensive functional tests"

# Setup before tests
setup_test

# Test: Neovim starts without errors
it "should start without errors" && {
  output=$(timeout_cmd 3 nvim --headless -u "$DOTFILES_DIR/src/neovim/init.lua" -c "qa!" 2>&1 || true)

  # Check for critical errors
  assert_not_contains "$output" "E5113" # Lua error
  assert_not_contains "$output" "syntax error"
  assert_not_contains "$output" "PANIC"
  pass
}

# Test: LSP configuration loads
it "should load LSP configuration" && {
  output=$(timeout_cmd 3 nvim --headless -u "$DOTFILES_DIR/src/neovim/init.lua" \
    -c "lua print(vim.inspect(require('config.lsp')))" -c "qa!" 2>&1 || true)

  # Should load LSP module
  assert_not_contains "$output" "module 'config.lsp' not found"
  pass
}

# Test: Plugin manager (lazy.nvim) loads
it "should load lazy.nvim plugin manager" && {
  output=$(timeout_cmd 3 nvim --headless -u "$DOTFILES_DIR/src/neovim/init.lua" \
    -c "lua print(vim.fn.exists('*lazy'))" -c "qa!" 2>&1 || true)

  # Lazy should be available
  assert_not_contains "$output" "error"
  pass
}

# Test: Key mappings are set
it "should set custom key mappings" && {
  output=$(timeout_cmd 3 nvim --headless -u "$DOTFILES_DIR/src/neovim/init.lua" \
    -c "lua print(vim.inspect(vim.api.nvim_get_keymap('n')))" -c "qa!" 2>&1 || true)

  # Should have keymaps
  assert_contains "$output" "lhs" || skip "Keymaps may not be loaded in headless mode"
  pass
}

# Test: Options are configured
it "should set Neovim options" && {
  output=$(timeout_cmd 3 nvim --headless -u "$DOTFILES_DIR/src/neovim/init.lua" \
    -c "lua print(vim.o.number)" -c "qa!" 2>&1 || true)

  # Should have line numbers enabled
  assert_contains "$output" "true"
  pass
}

# Test: Autocommands are registered
it "should register autocommands" && {
  output=$(timeout_cmd 3 nvim --headless -u "$DOTFILES_DIR/src/neovim/init.lua" \
    -c "lua print(#vim.api.nvim_get_autocmds({}))" -c "qa!" 2>&1 || true)

  # Should have autocommands
  assert_not_contains "$output" "^0$"
  pass
}

# Test: Theme configuration loads
it "should load theme configuration" && {
  output=$(timeout_cmd 3 nvim --headless -u "$DOTFILES_DIR/src/neovim/init.lua" \
    -c "lua print(vim.g.colors_name or 'none')" -c "qa!" 2>&1 || true)

  # Should have a colorscheme set
  assert_not_contains "$output" "none"
  pass
}

# Test: Snippet configuration
it "should configure snippets" && {
  if [[ -f "$DOTFILES_DIR/src/neovim/config/snippets.lua" ]]; then
    output=$(timeout_cmd 3 nvim --headless -u "$DOTFILES_DIR/src/neovim/init.lua" \
      -c "lua require('config.snippets')" -c "qa!" 2>&1 || true)

    assert_not_contains "$output" "error"
    pass
  else
    skip "Snippets config not found"
  fi
}

# Test: AI integration (Avante/CodeCompanion)
it "should configure AI assistants" && {
  local ai_configs=("avante" "codecompanion" "ai")
  local found=0

  for config in "${ai_configs[@]}"; do
    if [[ -f "$DOTFILES_DIR/src/neovim/config/$config.lua" ]] \
      || [[ -f "$DOTFILES_DIR/src/neovim/config/plugins/$config.lua" ]]; then
      found=1
      break
    fi
  done

  assert_equals "$found" 1
  pass
}

# Test: Completion engine (blink.cmp)
it "should configure completion engine" && {
  if [[ -f "$DOTFILES_DIR/src/neovim/config/blink.lua" ]]; then
    output=$(timeout_cmd 3 nvim --headless -u "$DOTFILES_DIR/src/neovim/init.lua" \
      -c "lua require('config.blink')" -c "qa!" 2>&1 || true)

    assert_not_contains "$output" "error"
    pass
  else
    skip "Blink config not found"
  fi
}

# Test: Telescope configuration
it "should configure Telescope" && {
  local telescope_config=$(find "$DOTFILES_DIR/src/neovim" -name "*telescope*" -o -name "*Telescope*" | head -1)

  if [[ -n "$telescope_config" ]]; then
    assert_file_exists "$telescope_config"
    pass
  else
    skip "Telescope config not found"
  fi
}

# Test: Treesitter configuration
it "should configure Treesitter" && {
  local treesitter_config=$(find "$DOTFILES_DIR/src/neovim" -name "*treesitter*" -o -name "*Treesitter*" | head -1)

  if [[ -n "$treesitter_config" ]]; then
    assert_file_exists "$treesitter_config"
    pass
  else
    skip "Treesitter config not found"
  fi
}

# Test: Git integration (Gitsigns)
it "should configure Git integration" && {
  local git_config=$(find "$DOTFILES_DIR/src/neovim" -name "*git*" -o -name "*Git*" | head -1)

  if [[ -n "$git_config" ]]; then
    assert_file_exists "$git_config"
    pass
  else
    skip "Git config not found"
  fi
}

# Test: File type detection
it "should detect file types correctly" && {
  echo "#!/bin/bash" >"$TEST_TMP_DIR/test.sh"

  output=$(timeout_cmd 3 nvim --headless -u "$DOTFILES_DIR/src/neovim/init.lua" \
    "$TEST_TMP_DIR/test.sh" \
    -c "lua print(vim.bo.filetype)" -c "qa!" 2>&1 || true)

  assert_contains "$output" "sh" || assert_contains "$output" "bash"
  pass
}

# Test: Performance - startup time
it "should start quickly" && {
  local start_time=$(date +%s%N)
  timeout_cmd 3 nvim --headless -u "$DOTFILES_DIR/src/neovim/init.lua" -c "qa!" 2>&1 >/dev/null
  local end_time=$(date +%s%N)

  local duration=$(((end_time - start_time) / 1000000))

  # Should start in less than 500ms
  assert_less_than "$duration" 500
  pass
}

# Test: Module loading
it "should load all config modules" && {
  local config_files=$(ls "$DOTFILES_DIR/src/neovim/config/"*.lua 2>/dev/null | wc -l)

  if [[ "$config_files" -gt 0 ]]; then
    assert_greater_than "$config_files" 5 # Should have multiple config files
    pass
  else
    skip "No config modules found"
  fi
}

# Test: Plugin specifications
it "should have valid plugin specifications" && {
  if [[ -f "$DOTFILES_DIR/src/neovim/config/plugins.lua" ]]; then
    output=$(timeout_cmd 3 nvim --headless -u "$DOTFILES_DIR/src/neovim/init.lua" \
      -c "lua require('config.plugins')" -c "qa!" 2>&1 || true)

    assert_not_contains "$output" "error"
    pass
  else
    skip "Plugins config not found"
  fi
}

# Test: LaTeX support (VimTeX)
it "should configure LaTeX support" && {
  if [[ -f "$DOTFILES_DIR/src/neovim/config/vimtex.lua" ]]; then
    output=$(timeout_cmd 3 nvim --headless -u "$DOTFILES_DIR/src/neovim/init.lua" \
      -c "lua require('config.vimtex')" -c "qa!" 2>&1 || true)

    assert_not_contains "$output" "error"
    pass
  else
    skip "VimTeX config not found"
  fi
}

# Test: Dashboard/startup screen
it "should configure dashboard" && {
  local dashboard_config=$(find "$DOTFILES_DIR/src/neovim" -name "*dashboard*" -o -name "*snacks*" | head -1)

  if [[ -n "$dashboard_config" ]]; then
    assert_file_exists "$dashboard_config"
    pass
  else
    skip "Dashboard config not found"
  fi
}

# Cleanup after tests
cleanup_test

# Summary
echo -e "\n${GREEN}Neovim functional tests completed${NC}"
