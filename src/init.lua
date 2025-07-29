-- Load core configuration modules
require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.plugins")
require("config.theme")

-- Load LSP after plugins are loaded
-- Using VimEnter to ensure all plugins are fully initialized
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    -- Ensure blink.cmp is loaded first
    local blink_ok = pcall(require, "blink.cmp")
    if not blink_ok then
      vim.notify("Warning: blink.cmp not loaded before LSP setup", vim.log.levels.WARN)
    end
    
    -- Load LSP configuration
    require("config.lsp").setup()
  end,
})