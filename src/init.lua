-- Enable automatic LSP detection
-- This must be set before any plugins are loaded
vim.g.lsp_autostart = true

-- Load core configuration modules
require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.plugins")
require("config.theme")
require("config.commands")

-- Apply work-specific overrides if available
-- This should happen after base config but before LSP setup
local work = require("config.work")
work.apply_overrides()

-- LSP setup is now handled by lazy.nvim after all plugins are loaded
-- See plugins.lua for the setup timing