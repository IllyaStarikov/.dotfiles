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

-- Show a one-column fold gutter (deliberate choice; no fold plugin in use)
opt.foldcolumn = "1"

-- Global folding options
-- markdown_folding=1 makes the runtime markdown ftplugin install its own
-- per-heading foldexpr (MarkdownFold), overriding the global treesitter
-- foldexpr above in markdown buffers. Intentional: heading folds beat
-- treesitter's node folds for prose.
g.markdown_folding = 1
