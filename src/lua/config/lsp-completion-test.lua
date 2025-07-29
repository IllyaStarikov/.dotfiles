--
-- LSP Completion Test
-- Test if clangd is actually providing completions
--

local M = {}

function M.test_lsp_completion()
  -- Get current position
  local bufnr = vim.api.nvim_get_current_buf()
  local cursor = vim.api.nvim_win_get_cursor(0)
  local line = cursor[1] - 1
  local col = cursor[2]
  
  -- Create completion params
  local params = vim.lsp.util.make_position_params()
  
  -- Check if LSP client is attached
  local clients = vim.lsp.get_active_clients({ bufnr = bufnr })
  if #clients == 0 then
    print("No LSP clients attached to buffer")
    return
  end
  
  -- Try to get completions from each client
  for _, client in ipairs(clients) do
    if client.server_capabilities.completionProvider then
      print("Testing completion with " .. client.name)
      
      -- Request completions
      client.request('textDocument/completion', params, function(err, result)
        if err then
          print("Error from " .. client.name .. ": " .. vim.inspect(err))
        elseif result then
          if result.items and #result.items > 0 then
            print(client.name .. " returned " .. #result.items .. " completion items")
            -- Show first few items
            for i = 1, math.min(5, #result.items) do
              local item = result.items[i]
              print("  " .. i .. ": " .. (item.label or "no label") .. " (" .. (item.kind or "?") .. ")")
            end
          elseif result.isIncomplete ~= nil then
            print(client.name .. " returned incomplete results")
          else
            print(client.name .. " returned empty completion list")
          end
        else
          print(client.name .. " returned nil")
        end
      end, bufnr)
    else
      print(client.name .. " does not support completion")
    end
  end
end

-- Test manual completion trigger
function M.force_show_completion()
  -- Try different methods to show completion
  
  -- Method 1: Try blink.cmp
  local ok, blink = pcall(require, 'blink.cmp')
  if ok then
    if blink.show then
      blink.show()
      print("Called blink.cmp.show()")
    elseif blink.trigger and blink.trigger.show then
      blink.trigger.show()
      print("Called blink.cmp.trigger.show()")
    else
      print("blink.cmp loaded but no show method found")
    end
  else
    print("blink.cmp not loaded")
  end
  
  -- Method 2: Try native omnifunc
  vim.schedule(function()
    vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-x><C-o>", true, false, true), 'n', false)
    print("Triggered native omnifunc")
  end)
end

-- Create commands
vim.api.nvim_create_user_command("TestLspCompletion", function()
  M.test_lsp_completion()
end, { desc = "Test if LSP is providing completions" })

vim.api.nvim_create_user_command("ForceShowCompletion", function()
  M.force_show_completion()
end, { desc = "Force show completion menu" })

return M