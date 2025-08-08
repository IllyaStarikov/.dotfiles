-- Folding configuration

local opt = vim.opt
local g = vim.g

-- Folding settings
opt.foldenable = true
opt.foldmethod = "expr"
opt.foldexpr = "nvim_treesitter#foldexpr()"
opt.foldlevelstart = 99
opt.foldminlines = 1
opt.foldnestmax = 10

-- UFO plugin settings
opt.foldcolumn = "1"
-- Note: fillchars for folding are set by UFO plugin

-- Global folding options
g.markdown_folding = 1