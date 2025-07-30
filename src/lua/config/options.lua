-- ══════════════════════════════════════════════════════════════════════════════════════════════════════════
-- 🎯 NEOVIM OPTIONS - Performance-Optimized Core Configuration
-- ══════════════════════════════════════════════════════════════════════════════════════════════════════════
-- Modern development environment optimized for:
-- • 2-space indentation standard across all languages
-- • Enhanced clipboard integration and navigation
-- • Optimized for large files and responsive editing
-- • Professional UI with consistent theming
-- • Security-focused with disabled unused providers
-- ══════════════════════════════════════════════════════════════════════════════════════════════════════════

local opt = vim.opt
local g = vim.g

-- ──────────────────────────────────────────────────────────────────────────────────────────────────────────
-- ⚙️ GENERAL SETTINGS
-- ──────────────────────────────────────────────────────────────────────────────────────────────────────────

opt.history = 1000                   -- Increased history size for better undo
opt.scrolloff = 8                    -- More context lines around cursor
opt.sidescrolloff = 8                -- Horizontal scroll context

-- Fast scrolling performance
opt.regexpengine = 1                 -- Use old regex engine for better performance

opt.clipboard = "unnamedplus"        -- Use system clipboard (modern approach)
opt.backspace = { "indent", "eol", "start" }  -- Proper backspace

opt.autoread = true                  -- Auto-reload changed files
opt.virtualedit = "block"            -- Freedom of movement in visual block mode
opt.updatetime = 300                 -- Faster completion (4s -> 300ms)
opt.timeoutlen = 500                 -- Faster which-key trigger

-- ──────────────────────────────────────────────────────────────────────────────────────────────────────────
-- 📐 INDENTATION
-- ──────────────────────────────────────────────────────────────────────────────────────────────────────────

opt.expandtab = true                 -- Convert tabs to spaces
opt.shiftwidth = 2                   -- 2 spaces for indentation
opt.tabstop = 2                      -- Tab width = 2 spaces
opt.softtabstop = 2                  -- Soft tab stop at 2 spaces
opt.smartindent = true               -- Smart autoindenting
opt.autoindent = true                -- Copy indent from current line

-- ──────────────────────────────────────────────────────────────────────────────────────────────────────────
-- 🖼️ DISPLAY & UI
-- ──────────────────────────────────────────────────────────────────────────────────────────────────────────

opt.linebreak = true                 -- Wrap lines at word boundaries

-- GUI font settings (for Neovide, VimR, etc.)
if vim.fn.has("gui_running") == 1 or vim.g.neovide then
  opt.guifont = "Lilex Nerd Font:h18"  -- Match Alacritty font size
end

-- Unicode and font encoding settings for proper glyph rendering
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"
opt.ambiwidth = "single"  -- For Western environments (Nerd Font compatibility)
opt.emoji = true  -- Enable emoji rendering (requires proper font support)

-- Ensure terminal supports unicode and has proper font
if vim.fn.has("multi_byte") == 1 then
  if vim.o.encoding ~= "utf-8" then
    vim.o.encoding = "utf-8"
  end
end

-- Tell Neovim we have a nerd font
g.have_nerd_font = true
opt.conceallevel = 0                 -- Don't conceal text (except markdown)
opt.list = true
opt.showbreak = "↪ "                 -- Show line continuation
opt.listchars = {
  tab = "→ ",
  nbsp = "·",
  trail = "·",
  extends = "›",
  precedes = "‹",
  eol = "¬"
}
opt.signcolumn = "yes"               -- Always show sign column
opt.colorcolumn = "100"              -- Visual line length guide

opt.number = true                    -- Show current line number
opt.relativenumber = true            -- Relative line numbers
opt.hlsearch = true                  -- Highlight searches

-- ──────────────────────────────────────────────────────────────────────────────────────────────────────────
-- 📁 FILE HANDLING
-- ──────────────────────────────────────────────────────────────────────────────────────────────────────────

opt.backup = false                   -- No backup files
opt.writebackup = false              -- No write backup
opt.swapfile = false                 -- No swap files
opt.undofile = true                  -- Persistent undo history
opt.undodir = vim.fn.stdpath("data") .. "/undo"  -- XDG-compliant undo directory

-- UI settings
opt.mouse = "a"                      -- Enable full mouse support
opt.syntax = "on"                    -- Syntax highlighting
opt.spell = true                     -- Enable spell checking
opt.spelllang = "en_us"              -- US English spelling
opt.termguicolors = true             -- 24-bit RGB colors
opt.cmdheight = 1                    -- Command line height
opt.showmode = true                  -- Show current mode

-- Status and tab lines
opt.showtabline = 2                  -- Always show tabline
opt.laststatus = 2                   -- Always show status line

opt.cursorline = true                -- Turn on the cursorline
-- Set cursor to be visible in all modes
opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"
  .. ",a:blinkwait700-blinkoff400-blinkon250"
  .. ",sm:block-blinkwait175-blinkoff150-blinkon175"

-- For regular expressions
opt.magic = true

-- File formats
opt.fileformats = { "unix", "dos", "mac" }  -- Use Unix as the standard file type

-- Wild menu
opt.wildmenu = true
opt.wildmode = { "longest:list", "full" }

opt.hidden = true                    -- Don't warn me about unsaved buffers

-- ──────────────────────────────────────────────────────────────────────────────────────────────────────────
-- 🔇 SOUND & ALERTS
-- ──────────────────────────────────────────────────────────────────────────────────────────────────────────

opt.errorbells = false               -- No error bells
opt.visualbell = false               -- No visual bells

-- ──────────────────────────────────────────────────────────────────────────────────────────────────────────
-- 🔍 COMPLETION
-- ──────────────────────────────────────────────────────────────────────────────────────────────────────────

opt.completeopt = { "menu", "menuone", "noselect" }
opt.shortmess:append("c")            -- Don't show completion messages

-- ──────────────────────────────────────────────────────────────────────────────────────────────────────────
-- ⚡ PERFORMANCE OPTIMIZATIONS
-- ──────────────────────────────────────────────────────────────────────────────────────────────────────────

opt.ttyfast = true                   -- Fast terminal connection
opt.lazyredraw = true                -- Don't redraw during macros

-- Timing optimizations
opt.updatecount = 100                -- Swap file update frequency
opt.redrawtime = 1500                -- Max time for syntax highlighting
opt.ttimeout = true                  -- Terminal code timeout
opt.ttimeoutlen = 0                  -- Instant escape sequence

-- Large file optimizations
opt.maxmempattern = 2000             -- Pattern matching memory limit
opt.synmaxcol = 500                  -- Max column for syntax highlighting

-- Mouse optimizations
opt.mousescroll = "ver:3,hor:6"      -- Faster mouse scrolling

-- ──────────────────────────────────────────────────────────────────────────────────────────────────────────
-- 🚀 PROVIDER OPTIMIZATION
-- ──────────────────────────────────────────────────────────────────────────────────────────────────────────

-- Python host configuration
local python3_path = vim.fn.exepath('python3')
if python3_path ~= '' then
  g.python3_host_prog = python3_path
else
  -- Fallback for systems without python3 in PATH
  g.python3_host_prog = '/usr/bin/python3'
end

-- Disable unused providers for faster startup
g.loaded_python_provider = 0         -- Python 2 (deprecated)
g.loaded_ruby_provider = 0           -- Ruby provider
g.loaded_node_provider = 0           -- Node.js provider
g.loaded_perl_provider = 0           -- Perl provider

-- ──────────────────────────────────────────────────────────────────────────────────────────────────────────
-- 📚 LANGUAGE-SPECIFIC SETTINGS
-- ──────────────────────────────────────────────────────────────────────────────────────────────────────────

-- LaTeX
g.tex_flavor = "latex"               -- Default TeX flavor