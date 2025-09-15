--
-- config/keymaps.lua
-- Modular key mappings system
--

-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Load core keymaps modules
local modules = {
  "core", -- Essential mappings and fixes
  "navigation", -- Buffer, window, and file navigation
  "editing", -- Text editing enhancements
  "lsp", -- LSP and diagnostic mappings
  "plugins", -- Plugin-specific mappings
  "debug", -- DAP debugging mappings
}

-- Load each module
for _, module in ipairs(modules) do
  local ok, err = pcall(require, "config.keymaps." .. module)
  if not ok then
    vim.notify(
      "Failed to load keymaps." .. module .. ": " .. err,
      vim.log.levels.ERROR
    )
  end
end
