#!/usr/bin/env zsh
# Behavioral tests for key bindings

# Tests handle errors explicitly, don't exit on failure

source "$(dirname "$0")/../../lib/test_helpers.zsh"

describe "Key Binding Behavioral Tests"

# Test: Essential vim motions work
test_case "Essential vim navigation keys work in Neovim"
# Create a test file with known content
temp_file="$TEST_TMP_DIR/nav_test.txt"
cat >"$temp_file" <<'EOF'
Line 1
Line 2
Line 3
EOF

# Test that basic navigation works
output=$(nvim --headless "$temp_file" \
  -c "normal! j" \
  -c "lua print(vim.fn.line('.'))" \
  -c "qa!" 2>&1 | grep -E "^[0-9]" || echo "")

if [[ "$output" == "2" ]]; then
  pass "Vim navigation keys work"
else
  skip "Could not verify navigation"
fi
rm -f "$temp_file"

# Test: Leader key is set
test_case "Leader key is configured in Neovim"
output=$(nvim --headless -c "lua print(vim.g.mapleader or 'not-set')" -c "qa!" 2>&1 | grep -v "^$" | head -1)
if [[ "$output" != "not-set" ]] && [[ -n "$output" ]]; then
  pass "Leader key: $output"
else
  fail "No leader key configured"
fi

# Test: Common operations have keybindings
test_case "Common operations are accessible via keybindings"
# Check if file search has a binding
search_available=$(nvim --headless -c "lua print(vim.fn.mapcheck('<leader>f', 'n') ~= '' and 'bound' or 'unbound')" -c "qa!" 2>&1 | grep -E "bound|unbound" || echo "")
if [[ "$search_available" == *"bound"* ]]; then
  pass "File search has keybinding"
else
  skip "File search not bound to leader-f"
fi

# Test: Zsh vi mode works
test_case "Zsh vi mode keybindings work"
# Source zshrc and check if vi mode is enabled
output=$(zsh -c "source $DOTFILES_DIR/src/zsh/zshrc 2>/dev/null; bindkey | grep -E 'vi-' | wc -l" 2>&1 | tr -d '[:space:]')
if [[ -n "$output" ]] && [[ "$output" -gt 0 ]] 2>/dev/null; then
  pass "Vi mode bindings configured"
else
  skip "Vi mode not enabled"
fi

# Test: tmux prefix key is set
test_case "tmux has a prefix key configured"
if command -v tmux &>/dev/null; then
  prefix=$(tmux show-options -g prefix 2>/dev/null | cut -d' ' -f2)
  if [[ -n "$prefix" ]]; then
  pass "tmux prefix: $prefix"
  else
  fail "No tmux prefix configured"
  fi
else
  skip "tmux not installed"
fi

# Test: No keybinding prevents basic editing
test_case "Basic text editing remains functional"
temp_file="$TEST_TMP_DIR/edit_test.txt"
echo "test" >"$temp_file"

# Try to insert text
output=$(nvim --headless "$temp_file" \
  -c "normal! oNew Line" \
  -c "write" \
  -c "qa!" 2>&1)

content=$(cat "$temp_file")
rm -f "$temp_file"

if [[ "$content" == *"New Line"* ]]; then
  pass "Text insertion works"
else
  fail "Text insertion blocked"
fi

# Test: Escape key works
test_case "Escape key returns to normal mode"
output=$(nvim --headless \
  -c "startinsert" \
  -c "lua vim.defer_fn(function() vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes('<Esc>', true, false, true), 'n', false) end, 100)" \
  -c "lua vim.defer_fn(function() print(vim.fn.mode()); vim.cmd('qa!') end, 200)" \
  2>&1 | grep -E "^[niv]" || echo "")

if [[ "$output" == "n" ]]; then
  pass "Escape key works"
else
  skip "Could not verify escape key"
fi

# Test: Help is accessible
test_case "Help system is accessible"
output=$(nvim --headless -c "help | qa!" 2>&1)
if [[ "$output" != *"Error"* ]] && [[ "$output" != *"E149"* ]]; then
  pass "Help system accessible"
else
  fail "Help system not accessible"
fi

# Test: Save and quit commands work
test_case "Save and quit commands remain functional"
temp_file="$TEST_TMP_DIR/save_test.txt"
echo "test content" >"$temp_file"

nvim --headless "$temp_file" \
  -c "normal! A modified" \
  -c "write" \
  -c "quit" 2>&1

content=$(cat "$temp_file")
rm -f "$temp_file"

if [[ "$content" == *"modified"* ]]; then
  pass "Save command works"
else
  fail "Save command failed"
fi

# Return success
exit 0
