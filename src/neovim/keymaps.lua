-- Keymaps Configuration - Modular key mappings system
-- Loads keybinding modules in order: core → navigation → editing → LSP → plugins → debug
-- Documentation: https://neovim.io/doc/user/map.html

-- Leader key configuration
-- Space is used as leader for its accessibility and availability in normal mode
-- mapleader: Global custom mappings (default: backslash)
-- maplocalleader: Buffer-local mappings in ftplugins (default: backslash)
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
  local ok, err = pcall(require, "keymaps." .. module)
  if not ok then
    vim.notify("Failed to load keymaps." .. module .. ": " .. err, vim.log.levels.ERROR)
  end
end
