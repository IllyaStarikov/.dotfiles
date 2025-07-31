-- Enable automatic LSP detection
-- This must be set before any plugins are loaded
vim.g.lsp_autostart = true

-- Load core configuration modules
require("config.core")
require("config.ui")
require("config.keymaps")
require("config.autocmds")
require("config.plugins")
require("config.commands")

-- Load theme after plugins are available
vim.api.nvim_create_autocmd("User", {
  pattern = "LazyVimStarted",
  callback = function()
    require("config.ui.theme")
  end,
})

-- Apply work-specific overrides if available
-- This should happen after base config but before LSP setup
local work = require("config.work")
work.apply_overrides()

-- LSP setup is now handled by lazy.nvim after all plugins are loaded
-- See plugins.lua for the setup timing