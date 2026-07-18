-- Search and pattern matching settings
-- Controls how text search and pattern matching work in the editor

local opt = vim.opt

-- Search settings
opt.ignorecase = true -- Default: false - case-insensitive search
opt.smartcase = true -- Default: false - case-sensitive if search contains uppercase
opt.hlsearch = true -- Default: true - highlight all search matches
opt.incsearch = true -- Default: true - show matches while typing search
opt.showmatch = true -- Default: false - briefly jump to matching bracket
-- gdefault deliberately NOT set: it inverts the meaning of every explicit /g
-- flag (ours and plugins'), silently turning global substitutes into
-- first-match-per-line ones. Write /g where you want it instead.

-- Pattern matching
opt.matchtime = 2 -- Default: 5 - tenths of second to show matching bracket (200ms)
opt.matchpairs:append("<:>") -- Add angle brackets to matched pairs (default: "(:),{:},[:]")
