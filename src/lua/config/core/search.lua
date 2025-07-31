-- Search and pattern matching settings

local opt = vim.opt

-- Search settings
opt.ignorecase = true
opt.smartcase = true
opt.hlsearch = true   -- Highlight searches
opt.incsearch = true
opt.showmatch = true
opt.gdefault = true   -- Global flag by default

-- Pattern matching
opt.matchtime = 2
opt.matchpairs:append("<:>")