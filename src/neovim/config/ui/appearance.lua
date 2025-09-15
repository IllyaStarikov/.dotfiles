-- UI and appearance settings

local opt = vim.opt
local g = vim.g

-- Display settings
opt.linebreak = true
opt.wrap = true
opt.textwidth = 0
opt.wrapmargin = 0
opt.formatoptions:remove("t")

-- GUI font settings with ligature support
if vim.fn.has("gui_running") == 1 or vim.g.neovide then
  opt.guifont = "JetBrainsMono Nerd Font:h18"
  -- Enable ligatures in Neovide
  if vim.g.neovide then
    vim.g.neovide_ligatures = true
  end
end

-- Unicode and encoding
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"
opt.ambiwidth = "single"
opt.emoji = true

-- Ensure terminal supports unicode
if vim.fn.has("multi_byte") == 1 then
  if vim.o.encoding ~= "utf-8" then
    vim.o.encoding = "utf-8"
  end
end

-- Tell Neovim we have a nerd font
g.have_nerd_font = true

-- UI elements
opt.number = true -- Show current line number
opt.relativenumber = true -- Relative line numbers
opt.signcolumn = "yes" -- Always show sign column
opt.cursorline = true -- Turn on the cursorline
opt.colorcolumn = "100" -- Visual line length guide
opt.termguicolors = true -- 24-bit RGB colors
opt.pumheight = 10
opt.splitbelow = true
opt.splitright = true
opt.splitkeep = "screen"

-- Text display
opt.conceallevel = 0
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
opt.showmatch = true -- Highlight matching brackets
opt.matchtime = 2 -- Tenths of a second to show match

-- Cursor behavior
opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"
  .. ",a:blinkwait700-blinkoff400-blinkon250"
  .. ",sm:block-blinkwait175-blinkoff150-blinkon175"
