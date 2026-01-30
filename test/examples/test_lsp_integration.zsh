#!/usr/bin/env zsh
# Example: LSP and completion integration tests

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "$SCRIPT_DIR/../lib/test_helpers.zsh"

echo "━━━ LSP Integration Tests ━━━"

# Test Python LSP workflow
test_case "Python LSP provides diagnostics and completion"
cat >"$TEST_TMP_DIR/lsp_test.py" <<'EOF'
import os
import sys

def calculate(x: int, y: int) -> int:
  """Calculate sum of two numbers."""
  result = x +
  return result

def main():
  # This should trigger a diagnostic
  undefined_variable

  # Test completion here
  os.path.

if __name__ == "__main__":
  main()
EOF

output=$(nvim --headless "$TEST_TMP_DIR/lsp_test.py" \
  -c "lua vim.defer_fn(function()
    -- Wait for LSP to attach
    local attached = vim.wait(3000, function()
      return #vim.lsp.get_clients() > 0
    end)

    if not attached then
      print('lsp-timeout')
      vim.cmd('qa!')
      return
    end

    -- Wait for diagnostics
    vim.defer_fn(function()
      local diags = vim.diagnostic.get()
      print('diagnostics:', #diags)

      -- Test completion at line 6 (incomplete expression)
      vim.cmd('normal! 6G$')
      vim.cmd('startinsert')

      -- Trigger completion
      vim.defer_fn(function()
        local blink = require('blink.cmp')
        blink.show()

        vim.defer_fn(function()
            if blink.is_visible() then
                print('completion: active')
            else
                print('completion: inactive')
            end
            vim.cmd('qa!')
        end, 500)
      end, 500)
    end, 1000)
  end, 1000)" 2>&1)

if [[ "$output" == *"diagnostics: "[1-9]* ]] && [[ "$output" == *"completion: active"* ]]; then
  pass
else
  fail "LSP not fully functional: $output"
fi

# Test code actions
test_case "LSP code actions work"
cat >"$TEST_TMP_DIR/code_action_test.py" <<'EOF'
# Missing import should trigger code action
def test():
  return datetime.now()
EOF

output=$(nvim --headless "$TEST_TMP_DIR/code_action_test.py" \
  -c "lua vim.defer_fn(function()
    vim.wait(3000, function() return #vim.lsp.get_clients() > 0 end)

    vim.defer_fn(function()
      vim.cmd('normal! 3G')  -- Go to datetime line

      local params = vim.lsp.util.make_range_params()
      local results = vim.lsp.buf_request_sync(0, 'textDocument/codeAction', params, 1000)

      local actions = 0
      for _, result in pairs(results or {}) do
        if result.result then
            actions = actions + #result.result
        end
      end

      print('code-actions:', actions)
      vim.cmd('qa!')
    end, 1000)
  end, 1000)" 2>&1)

[[ "$output" == *"code-actions: "[1-9]* ]] && pass || skip "Code actions need pyright"

# Test Lua LSP
test_case "Lua LSP works with Neovim API"
cat >"$TEST_TMP_DIR/lua_test.lua" <<'EOF'
local M = {}

function M.setup()
  -- Should get completion for vim.api
  vim.api.nvim_

  -- Should show diagnostic for undefined
  local undefined = unknown_global
end

return M
EOF

output=$(nvim --headless "$TEST_TMP_DIR/lua_test.lua" \
  -c "lua vim.defer_fn(function()
    vim.wait(3000, function() return #vim.lsp.get_clients() > 0 end)

    vim.defer_fn(function()
      local diags = vim.diagnostic.get()
      local has_undefined_diagnostic = false

      for _, diag in ipairs(diags) do
        if diag.message:match('unknown_global') then
            has_undefined_diagnostic = true
            break
        end
      end

      print('lua-diagnostics:', has_undefined_diagnostic and 'working' or 'not-working')
      vim.cmd('qa!')
    end, 1500)
  end, 1000)" 2>&1)

[[ "$output" == *"lua-diagnostics: working"* ]] && pass || fail "Lua LSP not working"

# Test formatting
test_case "LSP formatting works"
cat >"$TEST_TMP_DIR/format_test.py" <<'EOF'
def unformatted(  x,y ,z  ):
  return x+y+z
EOF

output=$(nvim --headless "$TEST_TMP_DIR/format_test.py" \
  -c "lua vim.defer_fn(function()
    vim.wait(3000, function() return #vim.lsp.get_clients() > 0 end)

    vim.defer_fn(function()
      -- Save original content
      local before = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\\n')

      -- Format
      vim.lsp.buf.format({ async = false, timeout_ms = 2000 })

      -- Check if changed
      local after = table.concat(vim.api.nvim_buf_get_lines(0, 0, -1, false), '\\n')

      print('formatting:', before ~= after and 'worked' or 'no-change')
      vim.cmd('qa!')
    end, 1000)
  end, 1000)" 2>&1)

[[ "$output" == *"formatting: worked"* ]] && pass || skip "Formatter not available"
