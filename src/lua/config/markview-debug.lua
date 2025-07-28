-- Debug script to check what's rendering the Unicode symbols
local M = {}

function M.debug_symbols()
  -- Get current buffer
  local buf = vim.api.nvim_get_current_buf()
  
  -- Check if markview is loaded
  local has_markview, markview = pcall(require, "markview")
  if has_markview then
    print("Markview is loaded")
    
    -- Try to get current configuration
    local config = markview.configuration
    if config then
      print("Markview config found")
      print(vim.inspect(config.markdown and config.markdown.list_items))
    end
  end
  
  -- Check for extmarks in the buffer
  local ns_id = vim.api.nvim_get_namespaces()["markview"]
  if ns_id then
    print("Markview namespace ID:", ns_id)
    local extmarks = vim.api.nvim_buf_get_extmarks(buf, ns_id, 0, -1, {details = true})
    for _, mark in ipairs(extmarks) do
      local row, col, details = mark[2], mark[3], mark[4]
      if details.virt_text then
        for _, text in ipairs(details.virt_text) do
          if text[1]:match("[●◈◇]") then
            print(string.format("Found Unicode symbol at line %d, col %d: %s", row + 1, col, text[1]))
          end
        end
      end
    end
  end
  
  -- Check concealed text
  local lines = vim.api.nvim_buf_get_lines(buf, 0, -1, false)
  for i, line in ipairs(lines) do
    if line:match("^[%-%*%+]%s") or line:match("^%d+%.%s") then
      print(string.format("List item at line %d: %s", i, line))
    end
  end
end

-- Create command to run debug
vim.api.nvim_create_user_command('MarkviewDebug', function()
  M.debug_symbols()
end, {})

return M