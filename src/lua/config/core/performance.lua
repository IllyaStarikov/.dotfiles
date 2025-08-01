-- Performance optimizations

local opt = vim.opt
local g = vim.g

-- Performance settings
opt.lazyredraw = false
opt.updatecount = 100
opt.redrawtime = 1500
opt.ttimeoutlen = 0

-- Large file optimizations
opt.synmaxcol = 1000
g.vimsyn_embed = "lPr"
opt.maxmempattern = 2000

-- Python host configuration
local python3_path = vim.fn.exepath('python3')
if python3_path ~= '' then
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
g.netrw_localrmdir = "rm -r"

-- Matchit is handled by Neovim's built-in runtime/plugin/matchit.vim
-- No need to manually load it

-- Optimize clipboard on macOS
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

-- Suppress startup messages and prevent vimlog.txt creation
vim.opt.verbose = 0
vim.opt.verbosefile = ""
-- Force disable verbose even if set elsewhere
vim.cmd("set verbose=0")
vim.cmd("set verbosefile=")

-- Clear startup messages after VimEnter
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.defer_fn(function()
      -- Clear messages and command line
      vim.cmd("silent! messages clear")
      vim.cmd("echo ''")
    end, 100)
  end,
  desc = "Clear startup messages"
})