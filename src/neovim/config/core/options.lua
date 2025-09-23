-- Core Vim options and general settings
-- Configures fundamental Neovim behavior and performance optimizations

local opt = vim.opt
local g = vim.g

-- General settings
opt.history = 10000 -- Default: 1000 - store more command/search history for better recall
opt.scrolloff = 8 -- Default: 0 - keep 8 lines visible above/below cursor when scrolling
opt.sidescrolloff = 8 -- Default: 0 - keep 8 columns visible when scrolling horizontally

-- Large file performance settings
opt.maxmempattern = 50000 -- Default: 1000 - increase memory for pattern matching (KB)
opt.redrawtime = 20000 -- Default: 2000 - allow more time for syntax highlighting (ms)
-- NOTE: synmaxcol handled per-filetype in autocmds for better performance tuning
opt.clipboard:append("unnamedplus") -- Use system clipboard for all yank/delete/paste operations
opt.virtualedit = "block" -- Default: "" - allow cursor to move freely in visual block mode
opt.updatetime = 300 -- Default: 4000 - faster CursorHold events and diagnostic updates (ms)
opt.timeoutlen = 500 -- Default: 1000 - faster key sequence timeout for which-key (ms)

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

-- Character width handling for Unicode
-- ambiwidth is already "single" by default (correct for most cases)

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
-- fileformats default is already "unix,dos"
-- hidden removed - already true by default in Neovim

-- Wild menu (command-line completion)
opt.wildmode = { "longest:list", "full" } -- Default: "full" - first tab shows list, second tab cycles

-- Disable sounds
-- belloff "all" is already default in Neovim

-- Spell checking configuration
-- spell false is default
opt.spelllang = { "en_us" } -- Default: "en" (US English specifically)
opt.spellfile = vim.fn.expand("~/.dotfiles/.dotfiles.private/spell/en.utf-8.add") -- Custom spell file
-- errorbells false is default in Neovim
-- visualbell doesn't exist in Neovim

-- Completion behavior
opt.completeopt = { "menu", "menuone", "noselect" }
opt.shortmess:append("c")

-- Production optimizations (reduce visual noise)
opt.shortmess:append("IcCsS") -- Suppress: intro screen (I), completion messages (cC), search wrap (s), search count (S)
opt.report = 9999 -- Default: 2 - suppress "N lines changed" messages for smoother experience
opt.showcmd = false -- Default: true - hide partial command display in bottom-right
opt.ruler = false -- Default: true - hide line/column display (shown in statusline instead)

-- Mouse settings
-- mouse "a" is already default in Neovim
-- mousescroll removed - default is already "ver:3,hor:6"

-- Duplicate spell checking section removed

-- Command and status lines
-- cmdheight 1 is default
-- showmode true is default
-- showtabline handled by bufferline.nvim plugin
-- laststatus 2 is default in Neovim

-- Language-specific settings
g.tex_flavor = "latex" -- Default: "plain" - treat .tex files as LaTeX instead of plain TeX
