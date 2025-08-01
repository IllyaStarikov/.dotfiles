-- Core Vim options and general settings

local opt = vim.opt
local g = vim.g

-- General settings
opt.history = 1000                   -- Increased history size for better undo
opt.scrolloff = 8                    -- More context lines around cursor
opt.sidescrolloff = 8                -- Horizontal scroll context
opt.regexpengine = 1                 -- Use old regex engine for better performance
opt.clipboard = "unnamedplus"        -- Use system clipboard (modern approach)
opt.backspace = { "indent", "eol", "start" }  -- Proper backspace
opt.autoread = true                  -- Auto-reload changed files
opt.virtualedit = "block"            -- Freedom of movement in visual block mode
opt.updatetime = 300                 -- Faster completion (4s -> 300ms)
opt.timeoutlen = 500                 -- Faster which-key trigger

-- File handling
opt.fileformats = { "unix", "dos", "mac" }
opt.hidden = true

-- Wild menu
opt.wildmode = { "longest:list", "full" }

-- Disable sounds
opt.belloff = "all"
opt.errorbells = false
opt.visualbell = false

-- Completion behavior
opt.completeopt = { "menu", "menuone", "noselect" }
opt.shortmess:append("c")

-- Production optimizations
opt.shortmess:append("IcCsS")
opt.report = 9999
opt.showcmd = false
opt.ruler = false

-- Mouse settings
opt.mouse = "a"
opt.mousescroll = "ver:3,hor:6"

-- Spell checking
opt.spell = false
opt.spelllang = "en_us"

-- Command and status lines
opt.cmdheight = 1
opt.showmode = true
-- opt.showtabline = 2  -- Now handled by bufferline.nvim plugin
opt.laststatus = 2

-- Language-specific settings
g.tex_flavor = "latex"