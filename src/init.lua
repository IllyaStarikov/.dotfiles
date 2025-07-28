--
-- init.lua
-- Modern Neovim Configuration in Lua
--
-- A comprehensive, performance-optimized Neovim setup featuring:
-- • Skeleton file system for rapid development
-- • Python development with 2-space indentation enforcement  
-- • Dynamic theme switching with macOS integration
-- • Modern LSP, completion, and fuzzy finding
-- • AI-powered coding assistance with CodeCompanion
-- • Professional LaTeX authoring environment
-- • Integrated file management and terminal workflows
--
-- Created by Illya Starikov on March 5th, 2017
-- Migrated to Lua on July 25th, 2025
-- Copyright 2017-2025. Illya Starikov. All rights reserved.
--

-- =============================================================================
-- CONFIGURATION INITIALIZATION
-- =============================================================================

-- Set configuration type for conditional loading
vim.g.vimrc_type = 'personal'

-- Performance: disable unused builtin plugins for faster startup
local disabled_built_ins = {
  'gzip', 'tar', 'tarPlugin', 'zip', 'zipPlugin',
  'getscript', 'getscriptPlugin', 'vimball', 'vimballPlugin',
  'matchit', 'matchparen', '2html_plugin', 'logiPat', 'rrhelper',
  'netrw', 'netrwPlugin', 'netrwSettings', 'netrwFileHandlers'
}

for _, plugin in pairs(disabled_built_ins) do
  vim.g['loaded_' .. plugin] = 1
end

-- =============================================================================
-- CORE CONFIGURATION MODULES
-- =============================================================================
-- Load configuration in optimized order for fastest startup

-- 1. Foundation: Basic Neovim behavior and options
require('config.options')     -- Core vim options and behavior
require('config.keymaps')     -- Key mappings and shortcuts  
require('config.autocmds')    -- Autocommands and skeleton system

-- 2. Plugin System: Load plugins first
require('config.plugins')     -- Plugin specifications (lazy.nvim)

-- 3. UI and Theme: Visual configuration
require('config.theme')       -- Dynamic theme system with macOS integration

-- 4. Language Support: LSP and completion
-- Note: LSP is loaded after plugins are initialized via lazy.nvim
-- The actual LSP setup happens in the lsp.lua module

-- 5. Enhanced UI: Modern interface improvements
require('config.snacks')      -- High-performance QoL suite

-- 6. Development Tools: Git, formatting, help
require('config.gitsigns')    -- Git integration and signs
require('config.conform')     -- Code formatting
require('config.which-key')   -- Interactive keybinding help

-- =============================================================================
-- POST-INITIALIZATION
-- =============================================================================

-- Final optimizations after all modules are loaded
vim.schedule(function()
  -- Trigger initial theme setup
  vim.cmd('doautocmd ColorScheme')
  
  -- Force reload the theme to ensure it's properly applied
  -- This handles cases where plugins might override theme settings
  vim.defer_fn(function()
    require('config.theme')
  end, 100)
  
  -- Clear startup messages for clean interface
  vim.cmd('echo ""')
end)