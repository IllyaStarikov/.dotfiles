--
-- config/options.lua
-- Neovim options (migrated from vimscript)
--

local opt = vim.opt
local g = vim.g

-- General settings
opt.history = 1000                   -- Increased history size for better undo
opt.scrolloff = 8                    -- More context lines around cursor
opt.sidescrolloff = 8                -- Horizontal scroll context
opt.clipboard = "unnamedplus"        -- Use system clipboard (modern approach)
opt.backspace = { "indent", "eol", "start" }  -- Proper backspace

opt.autoread = true                  -- Set to auto read when a file is changed from the outside
opt.virtualedit = "block"            -- freedom of movement
opt.updatetime = 300                 -- Faster completion (4s -> 300ms)
opt.timeoutlen = 500                 -- Faster which-key trigger

-- Indentation
opt.expandtab = true                 -- tabs => spaces
opt.shiftwidth = 2                   -- set number of spaces to 2
opt.tabstop = 2                      -- if i has to use tabs, make it look like 2 spaces
opt.softtabstop = 2                  -- same as above
opt.smartindent = true               -- autoindent on newlines
opt.autoindent = true                -- copy indentation from previous lines

-- Display
opt.linebreak = true                 -- word wrap like a sane human being
opt.conceallevel = 0                 -- don't try to conceal things (except for markdown)
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
opt.signcolumn = "yes"               -- Always show sign column to prevent layout shift
opt.colorcolumn = "100"              -- Visual line length guide

opt.number = true                    -- Show current line number
opt.relativenumber = true            -- Relative line numbers
opt.hlsearch = true                  -- Highlight searches

-- Files
opt.backup = false                   -- Turn backup off
opt.writebackup = false
opt.swapfile = false                 -- Disable swap files
opt.undofile = true                  -- Enable persistent undo
opt.undodir = os.getenv("HOME") .. "/.vim/undodir"  -- Undo directory

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
opt.lazyredraw = true                -- Don't redraw while executing macros
opt.synmaxcol = 240                  -- Don't syntax highlight long lines

-- Python host (for legacy plugins)
local python3_path = vim.fn.exepath('python3')
if python3_path ~= '' then
  g.python3_host_prog = python3_path
else
  g.python3_host_prog = '/usr/bin/python3'
end

-- Disable unused providers for faster startup
g.loaded_python_provider = 0
g.loaded_ruby_provider = 0
g.loaded_node_provider = 0
g.loaded_perl_provider = 0

-- LaTeX
g.tex_flavor = "latex"