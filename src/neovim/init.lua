--------------------------------------------------------------------------------
-- init.lua - Neovim configuration entry point
--
-- DESCRIPTION:
--   Main entry point for Neovim configuration. Sets up module paths,
--   loads work-specific overrides, and initializes the configuration system.
--
-- LOADING ORDER:
--   1. Package path setup (support dotfiles structure)
--   2. Work-specific early initialization (if present)
--   3. Core configuration (lazy.nvim, options, keymaps)
--   4. Plugin loading
--   5. Work-specific late overrides
--
-- STRUCTURE:
--   config/           - Configuration modules
--   ├── core/        - Core settings (options, performance)
--   ├── keymaps/     - Key bindings by category
--   ├── lsp/         - Language server configurations
--   ├── plugins/     - Plugin specifications
--   └── ui/          - UI and theme settings
--
-- USAGE:
--   Symlinked to ~/.config/nvim/init.lua
--   or loaded directly from ~/.dotfiles/src/neovim/
--
-- FEATURES:
--   - Supports running from dotfiles or standard location
--   - Work-specific overrides for Google/Garmin environments
--   - Lazy loading with lazy.nvim
--   - Modern Lua configuration
--   - Comprehensive error handling
--------------------------------------------------------------------------------

-- Add the config directory to the Lua package path
-- This ensures modules can be found regardless of how nvim is invoked
local config_path = vim.fn.stdpath("config") or vim.fn.expand("~/.config/nvim")

-- Detect if we're running from dotfiles or standard config
local init_file = debug.getinfo(1, "S").source:sub(2)  -- Remove @ prefix
local init_dir = vim.fn.fnamemodify(init_file, ":h")

-- Add the directory containing init.lua to the package path
package.path = package.path .. ";" .. init_dir .. "/?.lua"
package.path = package.path .. ";" .. init_dir .. "/?/init.lua"

-- Also add standard config path if different
if init_dir ~= config_path then
  package.path = package.path .. ";" .. config_path .. "/?.lua"
  package.path = package.path .. ";" .. config_path .. "/?/init.lua"
end

-- Support dotfiles structure explicitly
local dotfiles_config = vim.fn.expand("~/.dotfiles/src/neovim")
if vim.fn.isdirectory(dotfiles_config) == 1 and dotfiles_config ~= init_dir then
  package.path = package.path .. ";" .. dotfiles_config .. "/?.lua"
  package.path = package.path .. ";" .. dotfiles_config .. "/?/init.lua"
end

-- Load work-specific early initialization if available
-- This must happen before ANY other configuration
-- First try the new work-init module, then fallback to private init
local work_init_ok, work_init = pcall(require, "config.work-init")
if work_init_ok and work_init then
	work_init.init()
else
	-- Fallback to the old private init method
	local private_init_path = vim.fn.expand("~/.dotfiles/.dotfiles.private/init.lua")
	if vim.fn.filereadable(private_init_path) == 1 then
		local ok, private_init = pcall(dofile, private_init_path)
		if ok and private_init and private_init.init then
			-- Initialize work configuration with error handling
			local init_ok, init_err = pcall(private_init.init)
			if not init_ok and vim.env.NVIM_DEBUG_WORK then
				vim.notify("Private init failed: " .. tostring(init_err), vim.log.levels.WARN)
			end
		elseif not ok and vim.env.NVIM_DEBUG_WORK then
			vim.notify("Failed to load private init: " .. tostring(private_init), vim.log.levels.WARN)
		end
	end
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

-- Initialize debug logging system if in debug mode
if vim.env.NVIM_DEBUG_WORK or vim.env.NVIM_DEBUG then
	local debug_ok, debug_system = pcall(require, "config.debug")
	if debug_ok then
		debug_system.init()
	end
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
  "config.fixy",       -- Fixy formatter integration
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