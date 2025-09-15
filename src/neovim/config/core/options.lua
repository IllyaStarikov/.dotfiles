-- Core Vim options and general settings

local opt = vim.opt
local g = vim.g

-- General settings
opt.history = 1000 -- Increased history size for better undo
opt.scrolloff = 8 -- More context lines around cursor
opt.sidescrolloff = 8 -- Horizontal scroll context
opt.regexpengine = 1 -- Use regex engine v1 for better performance
opt.clipboard:append("unnamedplus") -- Use system clipboard
opt.backspace = { "indent", "eol", "start" } -- Proper backspace
opt.autoread = true -- Auto-reload changed files
opt.virtualedit = "block" -- Freedom of movement in visual block mode
opt.updatetime = 300 -- Faster completion (4s -> 300ms)
opt.timeoutlen = 500 -- Faster which-key trigger

-- Fix for table/box drawing characters
opt.fillchars = {
  vert = "│", -- Vertical separator
  horiz = "─", -- Horizontal separator
  horizup = "┴", -- Horizontal with up
  horizdown = "┬", -- Horizontal with down
  vertleft = "┤", -- Vertical with left
  vertright = "├", -- Vertical with right
  verthoriz = "┼", -- Cross
}

-- Ensure proper character width handling
opt.ambiwidth = "single" -- Treat ambiguous width chars as single width

-- Force proper rendering of box-drawing characters
if vim.fn.has("multi_byte") == 1 then
  vim.opt.listchars = {
    tab = "▸ ",
    trail = "·",
    extends = "❯",
    precedes = "❮",
  }
end

-- File handling
opt.fileformats = { "unix", "dos", "mac" }
opt.hidden = true

-- Wild menu
opt.wildmode = { "longest:list", "full" }

-- Disable sounds
opt.belloff = "all"

-- Spell checking configuration
opt.spell = false -- Spell checking off by default (toggle with F5)
opt.spelllang = { "en_us" } -- English US spell checking
opt.spellfile =
  vim.fn.expand("~/.dotfiles/.dotfiles.private/spell/en.utf-8.add") -- Custom spell file in private dotfiles
opt.errorbells = false
opt.visualbell = false

-- Completion behavior
opt.completeopt = { "menu", "menuone", "noselect" }
opt.shortmess:append("c")

-- Production optimizations
opt.shortmess:append("IcCsS")
opt.report = 9999
opt.showcmd = false
opt.ruler = false

-- Mouse settings
opt.mouse = "a"
opt.mousescroll = "ver:3,hor:6"

-- Spell checking
opt.spell = false
opt.spelllang = "en_us"

-- Command and status lines
opt.cmdheight = 1
opt.showmode = true
-- opt.showtabline = 2  -- Now handled by bufferline.nvim plugin
opt.laststatus = 2

-- Language-specific settings
g.tex_flavor = "latex"
