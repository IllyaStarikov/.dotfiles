--
-- Completion Debug Helper
-- Helps diagnose C++ completion issues
--

local M = {}

function M.check_completion_status()
  print("=== Completion Debug Info ===")
  
  -- Check LSP clients
  local clients = vim.lsp.get_active_clients()
  if #clients == 0 then
    print("❌ No active LSP clients")
  else
    print("✓ Active LSP clients:")
    for _, client in ipairs(clients) do
      print(string.format("  - %s (id: %d)", client.name, client.id))
      
      -- Check completion provider
      if client.server_capabilities.completionProvider then
        print("    ✓ Completion provider enabled")
        
        -- Check trigger characters
        local triggers = client.server_capabilities.completionProvider.triggerCharacters
        if triggers then
          print("    ✓ Trigger characters: " .. vim.inspect(triggers))
          if vim.tbl_contains(triggers, '.') then
            print("    ✓ Dot (.) is a trigger character")
          else
            print("    ❌ Dot (.) is NOT a trigger character")
          end
        else
          print("    ❌ No trigger characters defined")
        end
      else
        print("    ❌ Completion provider NOT enabled")
      end
    end
  end
  
  -- Check blink.cmp
  local ok, blink = pcall(require, 'blink.cmp')
  if ok then
    print("\n✓ blink.cmp loaded")
    
    -- Try to get config
    local config_ok, config = pcall(function()
      return blink.config or {}
    end)
    
    if config_ok and config.completion then
      print("  ✓ Completion config found")
      if config.completion.trigger then
        print("  ✓ Trigger settings:")
        print("    - show_on_trigger_character: " .. tostring(config.completion.trigger.show_on_trigger_character))
      end
    end
  else
    print("\n❌ blink.cmp NOT loaded: " .. tostring(blink))
  end
  
  -- Check current buffer
  print("\n=== Current Buffer Info ===")
  print("Filetype: " .. vim.bo.filetype)
  print("Buffer: " .. vim.api.nvim_get_current_buf())
  
  -- Check if in C++ file
  if vim.bo.filetype == "cpp" or vim.bo.filetype == "c" then
    print("✓ In C/C++ file")
    
    -- Test completion at cursor
    local line = vim.api.nvim_get_current_line()
    local col = vim.api.nvim_win_get_cursor(0)[2]
    print("Current line: " .. line)
    print("Cursor position: " .. col)
    
    -- Check if cursor is after a dot
    if col > 0 and line:sub(col, col) == "." then
      print("✓ Cursor is after a dot")
    end
  end
end

-- Create commands
vim.api.nvim_create_user_command("CompletionDebug", function()
  M.check_completion_status()
end, { desc = "Debug completion setup" })

-- Auto-command to log when completion is triggered
vim.api.nvim_create_autocmd("CompleteChanged", {
  callback = function()
    vim.notify("Completion triggered!", vim.log.levels.DEBUG)
  end,
})

return M