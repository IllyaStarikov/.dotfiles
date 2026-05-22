-- Folding configuration
-- Controls how code blocks can be collapsed/expanded for better navigation

local opt = vim.opt
local g = vim.g

-- Folding settings
opt.foldenable = true -- Default: true - enable folding functionality
opt.foldmethod = "expr" -- Default: "manual" - use expression-based folding (treesitter)
opt.foldexpr = "v:lua.vim.treesitter.foldexpr()" -- Use built-in Neovim treesitter folding (0.10+)
opt.foldlevelstart = 99 -- Default: -1 - start with all folds open (99 = effectively all open)
opt.foldminlines = 1 -- Default: 1 - minimum lines needed to create a fold
opt.foldnestmax = 10 -- Default: 20 - maximum nesting depth for folds (10 is plenty)

-- UFO plugin settings
opt.foldcolumn = "1"
-- Note: fillchars for folding are set by UFO plugin

-- Global folding options
g.markdown_folding = 1
