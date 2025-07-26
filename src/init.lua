--
-- init.lua
-- Modern Neovim configuration in Lua
-- Migrated from vimscript vimrc
--
-- Created by Illya Starikov on March 5th, 2017
-- Migrated to Lua on July 25th, 2025
-- Copyright 2017-2025. Illya Starikov. All rights reserved.
--

-- Set configuration type (work/personal)
vim.g.vimrc_type = 'personal'

-- Core configuration modules
require('config.options')
require('config.keymaps')
require('config.autocmds')
require('config.plugins')
require('config.theme')
require('config.lsp')
require('config.noice')
require('config.gitsigns')
require('config.conform')
require('config.which-key')