--
-- Minimal completion test to verify C++ dot completion
--

local M = {}

function M.test_minimal_setup()
  -- First, let's try to manually trigger completion after a dot
  vim.api.nvim_create_autocmd("InsertCharPre", {
    pattern = "*.cpp,*.c,*.cc,*.cxx,*.h,*.hpp",
    callback = function()
      local char = vim.v.char
      if char == "." then
        -- Schedule completion trigger after the dot is inserted
        vim.schedule(function()
          -- Force completion menu to show
          local ok, blink = pcall(require, 'blink.cmp')
          if ok and blink.show then
            blink.show()
            vim.notify("Manually triggered completion after dot", vim.log.levels.DEBUG)
          else
            -- Fallback to native completion
            vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-x><C-o>", true, false, true), 'n', false)
            vim.notify("Triggered native completion", vim.log.levels.DEBUG)
          end
        end)
      end
    end,
  })
  
  print("Minimal completion test loaded - try typing a dot after an object in a C++ file")
end

-- Create a command to enable the test
vim.api.nvim_create_user_command("TestMinimalCompletion", function()
  M.test_minimal_setup()
end, { desc = "Test minimal completion setup" })

return M