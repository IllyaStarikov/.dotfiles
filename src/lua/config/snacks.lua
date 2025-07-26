--
-- config/snacks.lua
-- HIGH-PERFORMANCE snacks.nvim configuration
-- Fixed to use proper snacks.nvim API without format field conflicts
--

local M = {}

function M.setup()
  -- Use a very minimal snacks configuration to avoid picker conflicts
  require("snacks").setup({
    -- Only enable core modules that don't use the problematic picker
    bigfile = { enabled = true },
    picker = { enabled = false },   -- COMPLETELY DISABLE picker to prevent format errors
    
    -- Re-enable dashboard with safe configuration (uses Telescope instead of picker)
    dashboard = { 
      enabled = true,
      width = 60,
      sections = {
        { section = "header" },
        {
          section = "keys",
          gap = 1,
          padding = 1,
          keys = {
            -- Use telescope for all file operations to avoid picker conflicts
            { icon = " ", key = "f", desc = "Find File", action = ":Telescope find_files" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":Telescope oldfiles" },
            { icon = " ", key = "g", desc = "Find Text", action = ":Telescope live_grep" },
            { icon = " ", key = "b", desc = "Buffers", action = ":Telescope buffers" },
            { icon = " ", key = "c", desc = "Config", action = function() require('telescope.builtin').find_files({ cwd = vim.fn.stdpath("config") }) end },
            { icon = " ", key = ".", desc = "Browse Files", action = ":Oil" },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
        { section = "startup" },
      },
    },

    -- Enable only safe modules that don't use picker
    indent = { enabled = true },
    scroll = { enabled = true },
    notifier = { enabled = true },
    words = { enabled = true },
    terminal = { enabled = true },
    toggle = { enabled = true },
    input = { enabled = true },
    git = { enabled = true },
    rename = { enabled = true },
    bufdelete = { enabled = true },
    scratch = { enabled = true },
    lazygit = { enabled = true },
  })
end

return M