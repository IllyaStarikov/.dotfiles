-- Core Vim options and general settings
-- Configures fundamental Neovim behavior and performance optimizations

local opt = vim.opt
local g = vim.g

-- General settings
opt.history = 10000
opt.scrolloff = 8
opt.sidescrolloff = 8

-- Large file performance settings (redrawtime and maxmempattern are set in performance.lua)
opt.clipboard:append("unnamedplus")

-- Clipboard over SSH: OSC 52, so yanks land on the LOCAL machine's clipboard
-- (tmux passes the sequence through; see set-clipboard in src/tmux.conf).
-- COPY-ONLY on purpose: most terminals block OSC 52 reads, and a blocked read
-- hangs paste - so paste falls back to the unnamed register (terminal paste
-- via Cmd+V covers cross-machine paste). vim.ui.clipboard.osc52 is nvim
-- 0.10+; CI ubuntu runners ship 0.9, hence the version guard.
if vim.env.SSH_TTY and vim.fn.has("nvim-0.10") == 1 then
  local osc52 = require("vim.ui.clipboard.osc52")
  local function paste_fallback()
    return vim.split(vim.fn.getreg('"'), "\n")
  end
  vim.g.clipboard = {
    name = "OSC 52 (copy-only)",
    copy = { ["+"] = osc52.copy("+"), ["*"] = osc52.copy("*") },
    paste = { ["+"] = paste_fallback, ["*"] = paste_fallback },
  }
end
opt.virtualedit = "block"
opt.updatetime = 300 -- ms, for CursorHold and diagnostics
opt.timeoutlen = 500 -- ms, for which-key

-- Fix for table/box drawing characters
opt.fillchars = {
  vert = "│", -- Vertical separator
  horiz = "─", -- Horizontal separator
  horizup = "┴", -- Horizontal with up
  horizdown = "┬", -- Horizontal with down
  vertleft = "┤", -- Vertical with left
  vertright = "├", -- Vertical with right
  verthoriz = "┼", -- Cross
}

-- Wild menu (command-line completion)
opt.wildmode = { "longest:list", "full" }

-- Spell checking configuration
opt.spelllang = { "en_us" }
opt.spellfile = vim.g.dotfiles .. "/.dotfiles.private/config/spell/en.utf-8.add"

-- Recompile the personal dictionary when it is newer than its compiled .spl
-- (e.g. after a git pull in the private repo). Neovim only ever reads the
-- .spl, so a stale one silently flags dictionary words as typos.
local spell_add = vim.o.spellfile
if
  vim.fn.filereadable(spell_add) == 1
  and vim.fn.getftime(spell_add) > vim.fn.getftime(spell_add .. ".spl")
then
  vim.cmd("silent! mkspell! " .. vim.fn.fnameescape(spell_add))
end

-- Completion behavior
opt.completeopt = { "menu", "menuone", "noselect" }
opt.shortmess:append("c")

-- Production optimizations (reduce visual noise)
opt.shortmess:append("IcCsS")
opt.report = 9999
opt.showcmd = false
opt.ruler = false -- shown in statusline instead

-- Language-specific settings
g.tex_flavor = "latex"
