-- Performance optimizations

local opt = vim.opt
local g = vim.g

-- Performance settings
opt.updatecount = 500 -- Default: 200 (write swap file every 500 chars instead of 200, reduces I/O)
opt.redrawtime = 10000 -- Default: 2000ms (allow 10s for syntax highlighting complex files before giving up)
opt.ttimeoutlen = 10 -- Default: 50ms (wait only 10ms for key code sequences, makes Esc more responsive)

-- Large file optimizations
opt.synmaxcol = 4096 -- Default: 3000 (only syntax highlight first 4096 columns - handles long lines in minified files)
g.vimsyn_embed = "lPr" -- Only embed Lua, Python, Ruby syntax in vim files (not Perl, mzscheme, tcl, etc.)
opt.maxmempattern = 50000 -- Default: 1000KB (allow 50MB for pattern matching - needed for very complex regex)

-- Python host configuration
local python3_path = vim.fn.exepath("python3")
if python3_path ~= "" then
  g.python3_host_prog = python3_path
else
  g.loaded_python3_provider = 1
end

-- Disable unused providers
g.loaded_python_provider = 0
g.loaded_ruby_provider = 0
g.loaded_node_provider = 0
g.loaded_perl_provider = 0

-- Disable unused plugins
g.loaded_2html_plugin = 1
g.loaded_getscriptPlugin = 1
g.loaded_gzip = 1
g.loaded_logipat = 1
g.loaded_rrhelper = 1
g.loaded_spellfile_plugin = 1
g.loaded_tarPlugin = 1
g.loaded_vimballPlugin = 1
g.loaded_zipPlugin = 1

-- netrw settings (before potentially disabling)
g.netrw_browse_split = 0
g.netrw_banner = 0
g.netrw_winsize = 25
g.netrw_liststyle = 3
-- Configure netrw file deletion command
-- rm -rf: recursive deletion with force (no prompts)
-- Netrw validates paths before passing to this command
g.netrw_localrmdir = "rm -rf"

-- Matchit is handled by Neovim's built-in runtime/plugin/matchit.vim
-- No need to manually load it

-- No clipboard integration for better performance

-- Reduce LSP logging for performance
-- WARN level logs warnings and errors, but not info or debug messages
-- This significantly reduces disk I/O when multiple LSP servers are active
-- Default WARN level balances useful information with performance
vim.lsp.set_log_level("WARN")

-- Suppress startup messages and prevent vimlog.txt creation during normal operation
-- Only reset if not explicitly set via command line
---@diagnostic disable-next-line: undefined-field
if vim.v.verbose == 0 then
  vim.opt.verbose = 0
  vim.opt.verbosefile = ""
end

-- Clear startup messages after VimEnter
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.defer_fn(function()
      -- Clear messages and command line
      vim.cmd("silent! messages clear")
      vim.cmd("echo ''")
    end, 100)
  end,
  desc = "Clear startup messages",
})
