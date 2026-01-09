-- UI and appearance settings

local opt = vim.opt
local g = vim.g

-- Display settings
opt.linebreak = true -- wrap at word boundaries
opt.formatoptions:remove("t") -- Don't auto-wrap text

-- GUI font settings with ligature support
if vim.fn.has("gui_running") == 1 or vim.g.neovide then
	opt.guifont = "JetBrainsMono Nerd Font:h18"
	-- Enable ligatures in Neovide
	if vim.g.neovide then
		vim.g.neovide_ligatures = true
	end
end

-- Unicode and encoding
opt.fileencoding = "utf-8"

-- Ensure terminal supports unicode
if vim.fn.has("multi_byte") == 1 then
	if vim.o.encoding ~= "utf-8" then
		vim.o.encoding = "utf-8"
	end
end

-- Tell Neovim we have a nerd font
g.have_nerd_font = true

-- UI elements
opt.number = true
opt.relativenumber = true
opt.signcolumn = "yes" -- always show to avoid text shifting
opt.cursorline = true
opt.colorcolumn = "100"
opt.termguicolors = true
opt.pumheight = 10
opt.splitbelow = true
opt.splitright = true
opt.splitkeep = "screen" -- keep screen position on split

-- Text display
opt.showbreak = "↪ "

-- Whitespace visibility
opt.list = true
opt.listchars = {
	tab = "→ ",
	nbsp = "·",
	trail = "·",
	extends = "›",
	precedes = "‹",
	eol = "¬",
}

-- Bracket/parenthesis matching
opt.showmatch = true
opt.matchtime = 2 -- tenths of a second

-- Cursor behavior
opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"
	.. ",a:blinkwait700-blinkoff400-blinkon250"
	.. ",sm:block-blinkwait175-blinkoff150-blinkon175"
