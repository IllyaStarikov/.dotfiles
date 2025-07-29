-- Load core configuration modules
require("config.options")
require("config.keymaps")
require("config.autocmds")
require("config.plugins")
require("config.theme")

-- Load LSP after plugins are loaded
-- Using BufEnter instead of VeryLazy to ensure LSP loads for the first buffer
vim.api.nvim_create_autocmd({"BufEnter", "BufNewFile"}, {
  pattern = "*",
  once = true,  -- Only run once
  callback = function()
    -- Small delay to ensure plugins are fully loaded
    vim.defer_fn(function()
      -- Load LSP configuration
      require("config.lsp").setup()
      
      -- Load debug/test modules (can be removed later)
      require("config.debug-lsp")
      require("config.test-completion")
      require("config.debug-completion")
      require("config.completion-test")
    end, 100)
  end,
})