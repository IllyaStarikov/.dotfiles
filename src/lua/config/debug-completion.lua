-- Debug completion triggers
local M = {}

function M.setup()
  -- Create an autocmd to debug completion triggers
  vim.api.nvim_create_autocmd("TextChangedI", {
    pattern = "*.cpp,*.c,*.cc,*.cxx,*.h,*.hpp",
    callback = function()
      local line = vim.api.nvim_get_current_line()
      local col = vim.api.nvim_win_get_cursor(0)[2]
      
      -- Check if we just typed a dot or arrow
      if col > 0 then
        local char = line:sub(col, col)
        local prev_char = col > 1 and line:sub(col-1, col-1) or ""
        
        if char == "." or (prev_char == "-" and char == ">") then
          -- Force completion to trigger
          vim.defer_fn(function()
            -- Try multiple methods to trigger completion
            local ok, blink = pcall(require, 'blink.cmp')
            if ok then
              -- Try to show completion
              if blink.show then
                blink.show()
              end
            end
            
            -- Also try vim.lsp.buf.completion
            if vim.lsp.buf.completion then
              vim.lsp.buf.completion()
            end
          end, 50)
        end
      end
    end
  })
  
  -- Add a manual trigger command
  vim.api.nvim_create_user_command('TriggerCompletion', function()
    local ok, blink = pcall(require, 'blink.cmp')
    if ok and blink.show then
      blink.show()
      print("Manually triggered blink.cmp completion")
    else
      print("Could not trigger blink.cmp completion")
    end
  end, { desc = "Manually trigger completion" })
end

-- Setup immediately
M.setup()

return M