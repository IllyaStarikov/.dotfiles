-- Fix for BufWipeout E495 error
local M = {}

function M.setup()
  -- First, try to clear problematic autocommands
  vim.schedule(function()
    M.clear_problematic_autocmds()
  end)
  
  -- Override problematic autocommands that use <afile> incorrectly
  local group = vim.api.nvim_create_augroup("FixBufWipeout", { clear = true })
  
  -- Create a safer BufWipeout handler
  vim.api.nvim_create_autocmd("BufWipeout", {
    group = group,
    pattern = "*",
    callback = function(args)
      -- Safely handle buffer wipeout without using <afile>
      local bufnr = args.buf
      local bufname = vim.api.nvim_buf_get_name(bufnr)
      
      -- Only process if we have a valid buffer name
      if bufname and bufname ~= "" then
        -- Trigger any necessary cleanup here
        vim.schedule(function()
          -- Refresh components that might need updating
          if vim.fn.exists(":AirlineRefresh") == 2 then
            pcall(vim.cmd, "AirlineRefresh")
          end
        end)
      end
    end,
    desc = "Safe BufWipeout handler"
  })
  
  -- Also patch VimScript autocommands that might use <afile>
  vim.cmd([[
    " Override any VimScript BufWipeout that uses <afile>
    augroup FixBufWipeoutVim
      autocmd!
      " Create a safe wrapper for BufWipeout
      autocmd BufWipeout * ++nested if expand('<afile>') != '' | silent! doautocmd User BufWipeoutSafe | endif
    augroup END
  ]])
  
  -- Create command to diagnose BufWipeout issues
  vim.api.nvim_create_user_command("DiagnoseBufWipeout", function()
    print("=== BufWipeout Autocommands ===")
    local autocmds = vim.api.nvim_get_autocmds({ event = "BufWipeout" })
    
    for i, autocmd in ipairs(autocmds) do
      print(string.format("\n%d. Group: %s", i, autocmd.group_name or "unnamed"))
      if autocmd.pattern then
        print("   Pattern: " .. autocmd.pattern)
      end
      if autocmd.command then
        print("   Command: " .. autocmd.command)
        -- Check if command uses <afile>
        if autocmd.command:match("<afile>") then
          print("   ⚠️  WARNING: Uses <afile> which can cause E495 errors")
        end
      end
      if autocmd.callback then
        print("   Callback: function")
      end
    end
  end, { desc = "Diagnose BufWipeout autocommands" })
end

-- Temporary fix: Clear problematic BufWipeout autocommands
function M.clear_problematic_autocmds()
  -- Get all BufWipeout autocommands
  local autocmds = vim.api.nvim_get_autocmds({ event = "BufWipeout" })
  
  for _, autocmd in ipairs(autocmds) do
    -- Check if the command uses <afile>
    if autocmd.command and autocmd.command:match("<afile>") then
      -- Try to clear this specific autocommand
      if autocmd.group_name then
        pcall(function()
          vim.api.nvim_create_augroup(autocmd.group_name, { clear = true })
        end)
      end
    end
  end
end

return M