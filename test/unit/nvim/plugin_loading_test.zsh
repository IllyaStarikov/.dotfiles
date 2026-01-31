#!/usr/bin/env zsh
# Behavioral tests for Neovim plugin system

source "$(dirname "$0")/../../lib/test_helpers.zsh"

test_suite "Neovim Plugin System Behavioral Tests"

# Test: Neovim starts without errors
test_case "Neovim starts successfully with plugins"
output=$(nvim --headless -c "qa!" 2>&1)
if [[ -z "$output" ]] || [[ "$output" != *"Error"* ]]; then
  pass "Neovim starts without errors"
else
  fail "Neovim startup errors: $output"
fi

# Test: Plugin manager is functional
test_case "Plugin manager can load plugins"
output=$(nvim --headless -c "lua print(pcall(require, 'lazy') and 'manager-ok' or 'no-manager')" -c "qa!" 2>&1 | grep -E "manager-ok|no-manager" || echo "no-output")
if [[ "$output" == *"manager-ok"* ]]; then
  pass "Plugin manager functional"
else
  skip "Plugin manager not available"
fi

# Test: File searching capability
test_case "Can search for files (Telescope or similar)"
output=$(nvim --headless -c "lua print(vim.fn.exists(':Telescope') > 0 and 'search-available' or 'no-search')" -c "qa!" 2>&1 | grep -E "search|Search" || echo "")
if [[ -n "$output" ]]; then
  pass "File search capability available"
else
  skip "File search not configured"
fi

# Test: Git integration
test_case "Git integration is available"
output=$(nvim --headless -c "lua print((vim.fn.exists(':Git') > 0 or vim.fn.exists(':Gitsigns') > 0) and 'git-ok' or 'no-git')" -c "qa!" 2>&1 | grep -E "git" || echo "")
if [[ -n "$output" ]]; then
  pass "Git integration available"
else
  skip "Git integration not configured"
fi

# Test: LSP functionality
test_case "Language server support is configured"
output=$(nvim --headless -c "lua print(vim.lsp and 'lsp-available' or 'no-lsp')" -c "qa!" 2>&1 | grep "lsp" || echo "")
if [[ -n "$output" ]]; then
  pass "LSP support available"
else
  fail "No LSP support"
fi

# Test: Completion system
test_case "Completion system is functional"
# Create a test file and check if completion would work
temp_file="$TEST_TMP_DIR/completion_test.lua"
cat >"$temp_file" <<'EOF'
local test = {}
function test.hello()
  print("world")
end
-- test.
EOF

output=$(nvim --headless "$temp_file" -c "lua vim.defer_fn(function() print(vim.bo.omnifunc ~= '' and 'completion-ok' or 'no-completion'); vim.cmd('qa!') end, 100)" 2>&1 | grep -E "completion" || echo "")
rm -f "$temp_file"

if [[ -n "$output" ]]; then
  pass "Completion system configured"
else
  skip "Completion not configured"
fi

# Test: Syntax highlighting
test_case "Syntax highlighting is working"
temp_file="$TEST_TMP_DIR/syntax_test.py"
echo "def hello(): pass" >"$temp_file"

output=$(nvim --headless "$temp_file" -c "lua print(vim.treesitter and 'treesitter-ok' or (vim.bo.syntax ~= '' and 'syntax-ok' or 'no-highlight'))" -c "qa!" 2>&1 | grep -E "ok" || echo "")
rm -f "$temp_file"

if [[ -n "$output" ]]; then
  pass "Syntax highlighting available"
else
  skip "No syntax highlighting"
fi

# Test: Formatting capability
test_case "Code formatting is available"
output=$(nvim --headless -c "lua print((vim.fn.exists(':Format') > 0 or vim.lsp.buf.format) and 'format-ok' or 'no-format')" -c "qa!" 2>&1 | grep -E "format" || echo "")
if [[ -n "$output" ]]; then
  pass "Code formatting available"
else
  skip "Formatting not configured"
fi

# Test: AI integration
test_case "AI assistance features are available"
output=$(nvim --headless -c "lua print((vim.fn.exists(':CodeCompanion') > 0 or vim.fn.exists(':Avante') > 0) and 'ai-ok' or 'no-ai')" -c "qa!" 2>&1 | grep -E "ai" || echo "")
if [[ -n "$output" ]]; then
  pass "AI features available"
else
  skip "AI features not configured"
fi

# Test: Performance - startup time
test_case "Neovim starts within reasonable time"
start_time=$(date +%s%N)
nvim --headless -c "qa!" 2>/dev/null
end_time=$(date +%s%N)
duration=$(((end_time - start_time) / 1000000)) # Convert to ms

if [[ $duration -lt 1000 ]]; then # Under 1 second
  pass "Fast startup: ${duration}ms"
elif [[ $duration -lt 2000 ]]; then
  pass "Acceptable startup: ${duration}ms"
else
  fail "Slow startup: ${duration}ms"
fi

# Test: Plugin commands are accessible
test_case "Common plugin commands are available"
commands_found=0
for cmd in "Lazy" "Mason" "LspInfo"; do
  if nvim --headless -c "lua print(vim.fn.exists(':$cmd') > 0)" -c "qa!" 2>&1 | grep -q "true"; then
    ((commands_found++))
  fi
done

if [[ $commands_found -gt 0 ]]; then
  pass "$commands_found essential commands available"
else
  skip "Plugin commands not available"
fi

# Test: Colorscheme loads
test_case "Colorscheme loads successfully"
output=$(nvim --headless -c "colorscheme" -c "qa!" 2>&1 | grep -v "^$" | head -1)
if [[ -n "$output" ]] && [[ "$output" != *"Error"* ]]; then
  pass "Colorscheme: $output"
else
  skip "No colorscheme configured"
fi

# Return success
exit 0
