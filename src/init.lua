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

-- LSP setup is now handled by lazy.nvim after all plugins are loaded
-- See plugins.lua for the setup timing