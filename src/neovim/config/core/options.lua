-- Core Vim options and general settings
-- Configures fundamental Neovim behavior and performance optimizations

local opt = vim.opt
local g = vim.g

-- General settings
opt.history = 10000
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Large file performance settings
opt.maxmempattern = 50000 -- KB
opt.redrawtime = 20000 -- ms
opt.clipboard:append("unnamedplus")
opt.virtualedit = "block"
opt.updatetime = 300 -- ms, for CursorHold and diagnostics
opt.timeoutlen = 500 -- ms, for which-key

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

-- Force proper rendering of box-drawing characters
if vim.fn.has("multi_byte") == 1 then
	vim.opt.listchars = {
		tab = "▸ ",
		trail = "·",
		extends = "❯",
		precedes = "❮",
	}
end

-- Wild menu (command-line completion)
opt.wildmode = { "longest:list", "full" }

-- Spell checking configuration
opt.spelllang = { "en_us" }
opt.spellfile = vim.fn.expand("~/.dotfiles/.dotfiles.private/config/spell/en.utf-8.add")

-- Completion behavior
opt.completeopt = { "menu", "menuone", "noselect" }
opt.shortmess:append("c")

-- Production optimizations (reduce visual noise)
opt.shortmess:append("IcCsS")
opt.report = 9999
opt.showcmd = false
opt.ruler = false -- shown in statusline instead

-- Language-specific settings
g.tex_flavor = "latex"
