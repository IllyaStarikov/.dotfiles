-- Core Vim options and general settings
-- Configures fundamental Neovim behavior and performance optimizations

local opt = vim.opt
local g = vim.g

-- General settings
opt.history = 10000 -- Default: 1000 (more command history)
opt.scrolloff = 8 -- Default: 0 (keep cursor centered)
opt.sidescrolloff = 8 -- Default: 0 (horizontal scrolling context)
-- regexpengine removed - default 0 is already automatic

-- Large file performance settings
opt.maxmempattern = 50000 -- Default: 1000 (needed for large files)
opt.redrawtime = 20000 -- Default: 2000 (prevent timeouts on large files)
-- NOTE: synmaxcol removed - we handle it per-filetype in autocmds
opt.clipboard:append("unnamedplus") -- Use system clipboard
-- backspace default is already "indent,eol,start" in Neovim
-- autoread removed - already true by default in Neovim
opt.virtualedit = "block" -- Default: "" (better visual block editing)
opt.updatetime = 300 -- Default: 4000 (faster CursorHold & completion)
opt.timeoutlen = 500 -- Default: 1000 (faster which-key trigger)

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
-- fileformats default is already "unix,dos"
-- hidden removed - already true by default in Neovim

-- Wild menu
opt.wildmode = { "longest:list", "full" } -- Default: "full" (better completion)

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

-- Production optimizations
opt.shortmess:append("IcCsS") -- I=no intro, c=no completion msg, C=no scan msg, s=no search wrap, S=no search count
opt.report = 9999 -- Default: 2 (suppress "N lines changed" messages)
opt.showcmd = false -- Default: true (hide partial commands)
opt.ruler = false -- Default: true (hide cursor position)

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
g.tex_flavor = "latex"
