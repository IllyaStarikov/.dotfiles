-- Disable verbose logging early to prevent vimlog.txt during normal operation
-- This won't affect explicit -V flag usage
if vim.fn.has('vim_starting') == 1 and vim.v.verbose == 0 then
  vim.opt.verbose = 0
  vim.opt.verbosefile = ""
end

-- Enable automatic LSP detection
-- This must be set before any plugins are loaded
vim.g.lsp_autostart = true

-- Initialize error handling first
require("config.error-handler").init()

-- Load utils for protected requires
local utils = require("config.utils")

-- Load core configuration modules with error protection
local modules = {
  "config.core",       -- Core Vim options and settings
  "config.ui",         -- UI-related settings and appearance
  "config.keymaps",    -- Key mappings
  "config.autocmds",   -- Autocommands
  "config.plugins",    -- Plugin management with lazy.nvim
  "config.commands",   -- Custom commands
}

for _, module in ipairs(modules) do
  utils.safe_require(module)
end

-- Load theme after plugins are available
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyVimStarted",
  callback = function()
    utils.safe_require("config.ui.theme")
  end,
})

-- Apply work-specific overrides if available
-- This should happen after base config but before LSP setup
local work = utils.safe_require("config.work")
if work and work.apply_overrides then
  work.apply_overrides()
end

-- LSP setup is now handled by lazy.nvim after all plugins are loaded
-- See plugins.lua for the setup timing