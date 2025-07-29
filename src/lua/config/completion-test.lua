-- Test file to debug completion issues
local M = {}

function M.test()
  -- Create a test buffer
  local buf = vim.api.nvim_create_buf(false, true)
  vim.api.nvim_set_current_buf(buf)
  vim.bo[buf].filetype = 'cpp'
  
  -- Insert test code
  vim.api.nvim_buf_set_lines(buf, 0, -1, false, {
    '#include <vector>',
    '',
    'struct Test {',
    '    int x, y;',
    '    void foo() {}',
    '};',
    '',
    'int main() {',
    '    Test t;',
    '    t.',  -- Cursor will be placed here
    '}'
  })
  
  -- Place cursor after the dot
  vim.api.nvim_win_set_cursor(0, {10, 6})
  
  -- Wait a bit then check status
  vim.defer_fn(function()
    print("\n=== Completion Debug Info ===")
    
    -- Check if blink.cmp is loaded
    local blink_ok, blink = pcall(require, 'blink.cmp')
    print("blink.cmp loaded: " .. tostring(blink_ok))
    
    -- Check LSP status
    local clients = vim.lsp.get_active_clients({ bufnr = buf })
    print("Active LSP clients: " .. #clients)
    for _, client in ipairs(clients) do
      print("  - " .. client.name)
      if client.server_capabilities.completionProvider then
        print("    ✓ Completion enabled")
        if client.server_capabilities.completionProvider.triggerCharacters then
          print("    Triggers: " .. vim.inspect(client.server_capabilities.completionProvider.triggerCharacters))
        end
      end
    end
    
    -- Try to manually trigger completion
    print("\nTrying to manually trigger completion...")
    if blink_ok then
      -- Check if we can access the trigger module
      local trigger_ok, trigger = pcall(require, 'blink.cmp.trigger.completion')
      if trigger_ok and trigger.show then
        trigger.show({ force = true })
        print("Called trigger.show()")
      else
        print("Could not find trigger.show()")
      end
      
      -- Try the main show function
      if blink.show then
        blink.show()
        print("Called blink.show()")
      end
    end
    
    print("\nNow try typing a character after the dot to see if completion appears.")
    print("You can also try pressing Ctrl+Space to manually trigger.")
  end, 500)
end

-- Create command
vim.api.nvim_create_user_command('TestDotCompletion', M.test, {
  desc = "Test dot completion for C++"
})

-- Also create a simpler inline test
vim.api.nvim_create_user_command('TestInline', function()
  -- Get current position
  local line = vim.api.nvim_get_current_line()
  local col = vim.api.nvim_win_get_cursor(0)[2]
  
  print("Current line: " .. line)
  print("Cursor position: " .. col)
  print("Character before cursor: " .. (col > 0 and line:sub(col, col) or "none"))
  
  -- Check if LSP would trigger
  local clients = vim.lsp.get_active_clients({ bufnr = 0 })
  for _, client in ipairs(clients) do
    if client.server_capabilities.completionProvider and 
       client.server_capabilities.completionProvider.triggerCharacters then
      local triggers = client.server_capabilities.completionProvider.triggerCharacters
      local char_before = col > 0 and line:sub(col, col) or ""
      local is_trigger = vim.tbl_contains(triggers, char_before)
      print(client.name .. " should trigger on '" .. char_before .. "': " .. tostring(is_trigger))
    end
  end
end, { desc = "Test completion at current position" })

return M