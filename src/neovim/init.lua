-- Add the config directory to the Lua package path
local config_path = vim.fn.stdpath("config") or vim.fn.expand("~/.config/nvim")
-- Support both regular nvim config and dotfiles structure
local dotfiles_config = vim.fn.expand("~/.dotfiles/src/neovim")
if vim.fn.isdirectory(dotfiles_config) == 1 then
  package.path = package.path .. ";" .. dotfiles_config .. "/?.lua"
  package.path = package.path .. ";" .. dotfiles_config .. "/?/init.lua"
elseif vim.fn.isdirectory(config_path) == 1 then
  package.path = package.path .. ";" .. config_path .. "/?.lua"
  package.path = package.path .. ";" .. config_path .. "/?/init.lua"
end

-- Disable verbose logging for normal operation
-- Only disable if not already set via command line
if vim.opt.verbose:get() == 0 then
  vim.opt.verbose = 0
  vim.opt.verbosefile = ""
end

-- Fix for treesitter markdown code fence errors
-- This must be done very early before any plugins load
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "markdown", "markdown.pandoc" },
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()
    
    -- Set up autocmd to detect problematic edits
    vim.api.nvim_create_autocmd({ "TextChanged", "TextChangedI" }, {
      buffer = bufnr,
      callback = function()
        local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
        local fence_count = 0
        
        -- Count code fences
        for _, line in ipairs(lines) do
          if line:match("^```") then
            fence_count = fence_count + 1
          end
        end
        
        -- If odd number of fences, temporarily disable treesitter
        if fence_count % 2 == 1 then
          vim.b[bufnr].ts_disable_markdown = true
          -- Force treesitter to update
          vim.cmd("silent! TSBufDisable highlight")
          
          -- Re-enable after a short delay
          vim.defer_fn(function()
            vim.b[bufnr].ts_disable_markdown = false
            vim.cmd("silent! TSBufEnable highlight")
          end, 200)
        end
      end,
    })
  end,
  desc = "Workaround for treesitter markdown errors"
})

-- Enable automatic LSP detection
-- This must be set before any plugins are loaded
vim.g.lsp_autostart = true

-- Initialize error handling first (with pcall for safety)
local ok, error_handler = pcall(require, "config.error-handler")
if ok then
  error_handler.init()
end

-- Load utils for protected requires
local utils_ok, utils = pcall(require, "config.utils")
if not utils_ok then
  -- Fallback if utils not available
  utils = { safe_require = function(module) return pcall(require, module) end }
end

-- Load core configuration modules with error protection and fallback
local modules = {
  "config.core",       -- Core Vim options and settings
  "config.ui",         -- UI-related settings and appearance
  "config.keymaps",    -- Key mappings
  "config.autocmds",   -- Autocommands
  "config.plugins",    -- Plugin management with lazy.nvim
  "config.commands",   -- Custom commands
}

for _, module in ipairs(modules) do
  local ok, err = pcall(require, module)
  if not ok then
    vim.notify("Failed to load " .. module .. ": " .. tostring(err), vim.log.levels.ERROR)
    -- Continue loading other modules
  end
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