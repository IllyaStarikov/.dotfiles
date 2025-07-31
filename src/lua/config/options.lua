-- ══════════════════════════════════════════════════════════════════════════════════════════════════════════
-- 🎯 NEOVIM OPTIONS - Performance-Optimized Core Configuration
-- ══════════════════════════════════════════════════════════════════════════════════════════════════════════
-- Modern development environment optimized for:
-- • 2-space indentation (4 spaces for Python per Google Style Guide)
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
opt.spell = false                    -- Disable global spell check (enable per-buffer as needed)
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

-- File formats
opt.fileformats = { "unix", "dos", "mac" }  -- Use Unix as the standard file type

-- Wild menu
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

opt.lazyredraw = false               -- Smoother visual feedback (modern terminals handle this well)

-- Timing optimizations
opt.updatecount = 100                -- Swap file update frequency
opt.redrawtime = 1500                -- Max time for syntax highlighting
opt.ttimeoutlen = 0                  -- Instant escape sequence

-- Large file optimizations
opt.maxmempattern = 2000             -- Pattern matching memory limit
opt.synmaxcol = 1000                 -- Reasonable limit for syntax highlighting

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
  -- If Python 3 is not found, disable the provider
  -- This is safer than hardcoding a path that might not exist
  g.loaded_python3_provider = 1
end

-- Disable unused providers for faster startup
g.loaded_python_provider = 0         -- Python 2 (deprecated)
g.loaded_ruby_provider = 0           -- Ruby provider
g.loaded_node_provider = 0           -- Node.js provider
g.loaded_perl_provider = 0           -- Perl provider

-- ──────────────────────────────────────────────────────────────────────────────────────────────────────────
-- 🔇 PRODUCTION OPTIMIZATIONS
-- ──────────────────────────────────────────────────────────────────────────────────────────────────────────

-- Reduce startup verbosity
opt.shortmess:append("IcCsS")        -- No intro, completion messages, search messages
opt.report = 9999                    -- Don't report changes unless 9999 lines changed
opt.showcmd = false                  -- Don't show partial commands (statusline handles this)
opt.ruler = false                    -- Don't show cursor position (statusline handles this)

-- Disable unused built-in plugins for faster startup
g.loaded_2html_plugin = 1
g.loaded_getscriptPlugin = 1
g.loaded_gzip = 1
g.loaded_logipat = 1
g.loaded_rrhelper = 1
g.loaded_spellfile_plugin = 1
g.loaded_tarPlugin = 1
g.loaded_vimballPlugin = 1
g.loaded_zipPlugin = 1

-- Ensure required directories exist
local data_dir = vim.fn.stdpath("data")
local config_dir = vim.fn.stdpath("config")
local required_dirs = {
  data_dir .. "/undo",
  data_dir .. "/backup",
  data_dir .. "/swap",
  data_dir .. "/sessions",
  config_dir .. "/spell",
}

for _, dir in ipairs(required_dirs) do
  if vim.fn.isdirectory(dir) == 0 then
    vim.fn.mkdir(dir, "p")
  end
end

-- Fix matchit loading (prevents "not found in packpath" warning)
vim.cmd([[
  if !exists('g:loaded_matchit')
    runtime! macros/matchit.vim
  endif
]])

-- Optimize clipboard operations on macOS
if vim.fn.has("mac") == 1 then
  g.clipboard = {
    name = "macOS-clipboard",
    copy = {
      ["+"] = "pbcopy",
      ["*"] = "pbcopy",
    },
    paste = {
      ["+"] = "pbpaste",
      ["*"] = "pbpaste",
    },
    cache_enabled = 1,
  }
end

-- Reduce LSP logging
vim.lsp.set_log_level("ERROR")

-- Clear startup messages after VimEnter
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.defer_fn(function()
      vim.cmd("silent! messages clear")
    end, 50)
  end,
  desc = "Clear startup messages"
})

-- ──────────────────────────────────────────────────────────────────────────────────────────────────────────
-- 📚 LANGUAGE-SPECIFIC SETTINGS
-- ──────────────────────────────────────────────────────────────────────────────────────────────────────────

-- LaTeX
g.tex_flavor = "latex"               -- Default TeX flavor