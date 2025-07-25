--
-- config/options.lua
-- Neovim options (migrated from vimscript)
--

local opt = vim.opt
local g = vim.g

-- General settings
opt.history = 250                    -- Sets how many lines of history VIM has to remember
opt.scrolloff = 7                    -- Set 7 lines to the cursor - when moving vertically using j/k
opt.clipboard = "unnamed"            -- Yank to system clipboard by default
opt.backspace = { "indent", "eol", "start" }  -- Proper backspace

opt.autoread = true                  -- Set to auto read when a file is changed from the outside
opt.virtualedit = "block"            -- freedom of movement

-- Indentation
opt.expandtab = true                 -- tabs => spaces
opt.shiftwidth = 2                   -- set number of spaces to 2
opt.tabstop = 2                      -- if i has to use tabs, make it look like 2 spaces
opt.softtabstop = 2                  -- same as above
opt.smartindent = true               -- autoindent on newlines
opt.autoindent = true                -- copy indentation from previous lines

-- Display
opt.linebreak = true                 -- word wrap like a sane human being
opt.conceallevel = 0                 -- don't try to conceal things
opt.list = true
opt.showbreak = "↪\\"
opt.listchars = {
  tab = "→ ",
  eol = "↲",
  nbsp = "␣",
  trail = "•",
  extends = "⟩",
  precedes = "⟨"
}

opt.number = true                    -- Show current line number
opt.relativenumber = true            -- Relative line numbers
opt.hlsearch = true                  -- Highlight searches

-- Files
opt.backup = false                   -- Turn backup off
opt.writebackup = false

-- UI
opt.mouse = "a"                      -- Enable mouse support
opt.syntax = "on"                    -- Syntax highlighting
opt.spell = true
opt.spelllang = "en_us"              -- set english as standard language
opt.termguicolors = true             -- 24-bit RGB colors

opt.cursorline = true                -- Turn on the cursorline
opt.guicursor = ""

-- For regular expressions
opt.magic = true

-- File formats
opt.fileformats = { "unix", "dos", "mac" }  -- Use Unix as the standard file type

-- Wild menu
opt.wildmenu = true
opt.wildmode = { "longest:list", "full" }

opt.hidden = true                    -- Don't warn me about unsaved buffers

-- No annoying sounds
opt.errorbells = false
opt.visualbell = false

-- Completion
opt.completeopt = { "menu", "menuone", "noselect" }
opt.shortmess:append("c")

-- Performance
opt.ttyfast = true

-- Python host (for legacy plugins)
g.python3_host_prog = '/usr/bin/python3'

-- LaTeX
g.tex_flavor = "latex"