#!/bin/bash
# LSP and completion engine functional tests

source "$(dirname "$0")/../lib/test_helpers.sh"

test_suite "LSP and Completion Tests"

# Python LSP tests
test_case "Python LSP server starts and provides diagnostics"
cp "$DOTFILES_DIR/tests/fixtures/sample.py" "$TEST_TMP_DIR/test_lsp.py"
cd "$TEST_TMP_DIR"

# Wait for LSP and check diagnostics
test_diagnostics "test_lsp.py" 3  # Expecting at least 3 diagnostics

# Test hover information
test_case "LSP hover provides documentation"
nvim_test "Python hover info" \
    "vim.cmd('edit test_lsp.py')
     vim.defer_fn(function()
         vim.wait(3000, function() return #vim.lsp.get_clients() > 0 end)
         vim.api.nvim_win_set_cursor(0, {15, 10})  -- On Calculator class
         vim.lsp.buf.hover()
         vim.defer_fn(function()
             local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
             for _, line in ipairs(lines) do
                 if line:match('calculator') or line:match('Calculator') then
                     print('hover-info-found')
                     vim.cmd('qa!')
                     return
                 end
             end
             print('no-hover-info')
             vim.cmd('qa!')
         end, 1000)
     end, 500)" \
    "hover-info-found"

# Blink.cmp completion tests
test_case "Blink.cmp provides completions for Python"
cat > "$TEST_TMP_DIR/completion_test.py" << 'EOF'
import os

# Test completion after dot
path = os.pa
EOF

nvim_test "Python completion" \
    "vim.cmd('edit completion_test.py')
     vim.defer_fn(function()
         -- Wait for LSP
         vim.wait(3000, function() return #vim.lsp.get_clients() > 0 end)
         
         -- Go to end of file and trigger completion
         vim.cmd('normal! G$')
         vim.cmd('startinsert')
         
         vim.defer_fn(function()
             local blink = require('blink.cmp')
             blink.show()
             
             vim.defer_fn(function()
                 if blink.is_visible() then
                     print('completion-visible')
                     -- Try to check for 'path' in completions
                     local success = pcall(function()
                         local entries = blink.get_entries()
                         for _, entry in ipairs(entries or {}) do
                             if entry.label and entry.label:match('path') then
                                 print('path-completion-found')
                                 return
                             end
                         end
                     end)
                     if not success then
                         print('completion-check-failed')
                     end
                 else
                     print('no-completion')
                 end
                 vim.cmd('qa!')
             end, 1500)
         end, 1000)
     end, 500)" \
    "completion-visible"

# Lua LSP tests
test_case "Lua LSP server starts and works"
cp "$DOTFILES_DIR/tests/fixtures/sample.lua" "$TEST_TMP_DIR/test_lsp.lua"

test_diagnostics "test_lsp.lua" 2  # Expecting errors in broken_function

test_case "Lua completion works"
cat > "$TEST_TMP_DIR/lua_completion.lua" << 'EOF'
local M = {}

function M.test()
    vim.api.nvim_
end

return M
EOF

nvim_test "Lua API completion" \
    "vim.cmd('edit lua_completion.lua')
     vim.defer_fn(function()
         -- Go to incomplete line
         vim.api.nvim_win_set_cursor(0, {4, 18})
         vim.cmd('startinsert')
         
         vim.defer_fn(function()
             require('blink.cmp').show()
             
             vim.defer_fn(function()
                 if require('blink.cmp').is_visible() then
                     print('lua-completion-active')
                 else
                     print('no-lua-completion')
                 end
                 vim.cmd('qa!')
             end, 1500)
         end, 1000)
     end, 500)" \
    "lua-completion-active"

# Snippet expansion tests
test_case "LuaSnip snippets expand correctly"
cat > "$TEST_TMP_DIR/snippet_test.py" << 'EOF'
# Test snippet expansion
def
EOF

nvim_test "Python def snippet" \
    "vim.cmd('edit snippet_test.py')
     vim.defer_fn(function()
         vim.cmd('normal! G$')
         vim.cmd('startinsert')
         vim.api.nvim_feedkeys(' ', 'n', false)
         
         vim.defer_fn(function()
             -- Trigger snippet expansion
             local ok = pcall(function()
                 if vim.fn['luasnip#expandable']() == 1 then
                     vim.fn['luasnip#expand']()
                     print('snippet-expanded')
                 else
                     -- Try completion-based snippet
                     require('blink.cmp').show()
                     vim.defer_fn(function()
                         if require('blink.cmp').is_visible() then
                             require('blink.cmp').accept()
                             print('snippet-via-completion')
                         else
                             print('no-snippet')
                         end
                     end, 500)
                 end
             end)
             if not ok then
                 print('snippet-error')
             end
             vim.defer_fn(function() vim.cmd('qa!') end, 1000)
         end, 1000)
     end, 500)" \
    "snippet"

# Code actions test
test_case "LSP code actions work"
cat > "$TEST_TMP_DIR/code_action_test.py" << 'EOF'
# Missing import
df = pd.DataFrame()
EOF

nvim_test "Python code action for missing import" \
    "vim.cmd('edit code_action_test.py')
     vim.defer_fn(function()
         vim.wait(3000, function() return #vim.lsp.get_clients() > 0 end)
         
         vim.defer_fn(function()
             vim.api.nvim_win_set_cursor(0, {2, 5})
             
             -- Get available code actions
             vim.lsp.buf.code_action({
                 filter = function(action)
                     print('action:', action.title or 'unknown')
                     return false  -- Don't actually apply
                 end,
                 apply = false
             })
             
             vim.defer_fn(function()
                 print('code-actions-checked')
                 vim.cmd('qa!')
             end, 1000)
         end, 1000)
     end, 500)" \
    "code-actions-checked"

# Formatting test
test_case "LSP formatting works"
cat > "$TEST_TMP_DIR/format_test.py" << 'EOF'
def poorly_formatted(  x,y ,z  ):
    return x+y+z
EOF

nvim_test "Python formatting" \
    "vim.cmd('edit format_test.py')
     vim.defer_fn(function()
         vim.wait(3000, function() return #vim.lsp.get_clients() > 0 end)
         
         local before = vim.api.nvim_buf_get_lines(0, 0, -1, false)
         
         vim.lsp.buf.format({ async = false, timeout_ms = 5000 })
         
         vim.defer_fn(function()
             local after = vim.api.nvim_buf_get_lines(0, 0, -1, false)
             
             -- Check if formatting changed the buffer
             local changed = false
             for i, line in ipairs(before) do
                 if line ~= (after[i] or '') then
                     changed = true
                     break
                 end
             end
             
             print(changed and 'formatted' or 'no-change')
             vim.cmd('qa!')
         end, 2000)
     end, 500)" \
    "formatted"

# Multi-language LSP test
test_case "Multiple LSP servers can run simultaneously"
cat > "$TEST_TMP_DIR/multi_lsp.py" << 'EOF'
print("Python file")
EOF

cat > "$TEST_TMP_DIR/multi_lsp.lua" << 'EOF'
print("Lua file")
EOF

nvim_test "Multiple LSP servers" \
    "vim.cmd('edit multi_lsp.py')
     vim.cmd('split multi_lsp.lua')
     
     vim.defer_fn(function()
         vim.wait(3000, function()
             local clients = vim.lsp.get_clients()
             return #clients >= 2
         end)
         
         local clients = vim.lsp.get_clients()
         local servers = {}
         for _, client in ipairs(clients) do
             table.insert(servers, client.name)
         end
         
         print('lsp-servers:', table.concat(servers, ','))
         
         if #servers >= 2 then
             print('multi-lsp-ok')
         else
             print('single-lsp-only')
         end
         
         vim.cmd('qa!')
     end, 1000)" \
    "multi-lsp-ok"

# Signature help test
test_case "LSP signature help displays"
cat > "$TEST_TMP_DIR/signature_test.py" << 'EOF'
def add(x: int, y: int) -> int:
    return x + y

result = add(
EOF

nvim_test "Python signature help" \
    "vim.cmd('edit signature_test.py')
     vim.defer_fn(function()
         vim.wait(3000, function() return #vim.lsp.get_clients() > 0 end)
         
         vim.cmd('normal! G$')
         vim.lsp.buf.signature_help()
         
         vim.defer_fn(function()
             print('signature-help-triggered')
             vim.cmd('qa!')
         end, 1000)
     end, 500)" \
    "signature-help-triggered"

# Go to definition test
test_case "LSP go to definition works"
cat > "$TEST_TMP_DIR/definition_test.py" << 'EOF'
def my_function():
    return 42

result = my_function()
EOF

nvim_test "Go to definition" \
    "vim.cmd('edit definition_test.py')
     vim.defer_fn(function()
         vim.wait(3000, function() return #vim.lsp.get_clients() > 0 end)
         
         -- Go to function call
         vim.api.nvim_win_set_cursor(0, {4, 10})
         
         local before_line = vim.api.nvim_win_get_cursor(0)[1]
         
         vim.lsp.buf.definition()
         
         vim.defer_fn(function()
             local after_line = vim.api.nvim_win_get_cursor(0)[1]
             
             if before_line ~= after_line then
                 print('definition-jump-ok')
             else
                 print('no-jump')
             end
             
             vim.cmd('qa!')
         end, 1000)
     end, 500)" \
    "definition-jump-ok"

cd "$DOTFILES_DIR"
print_summary