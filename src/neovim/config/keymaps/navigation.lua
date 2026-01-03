--
-- config/keymaps/navigation.lua
-- Non-leader navigation keymaps (Ctrl, brackets, arrows)
--

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- ============================================================================
-- WINDOW NAVIGATION (Ctrl + hjkl)
-- ============================================================================
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)

-- Arrow keys also work
map("n", "<up>", "<C-w><up>", opts)
map("n", "<down>", "<C-w><down>", opts)
map("n", "<left>", "<C-w><left>", opts)
map("n", "<right>", "<C-w><right>", opts)

-- ============================================================================
-- WINDOW RESIZING (Ctrl + arrows)
-- ============================================================================
map("n", "<C-Up>", ":resize +2<CR>", opts)
map("n", "<C-Down>", ":resize -2<CR>", opts)
map("n", "<C-Left>", ":vertical resize -2<CR>", opts)
map("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- ============================================================================
-- BUFFER NAVIGATION (Tab, Shift+HL, brackets)
-- ============================================================================
map("n", "<Tab>", ":bnext<cr>", opts)
map("n", "<S-Tab>", ":bprevious<cr>", opts)
map("n", "<S-h>", ":bprevious<cr>", { desc = "Previous buffer" })
map("n", "<S-l>", ":bnext<cr>", { desc = "Next buffer" })
map("n", "[b", ":bprevious<cr>", { desc = "Previous buffer" })
map("n", "]b", ":bnext<cr>", { desc = "Next buffer" })

-- ============================================================================
-- TAB NAVIGATION (brackets)
-- ============================================================================
map("n", "[t", ":tabprevious<CR>", { desc = "Previous Tab" })
map("n", "]t", ":tabnext<CR>", { desc = "Next Tab" })

-- ============================================================================
-- QUICKFIX/LOCATION (brackets)
-- ============================================================================
map("n", "[q", ":cprevious<CR>", { desc = "Previous Quickfix" })
map("n", "]q", ":cnext<CR>", { desc = "Next Quickfix" })
map("n", "[l", ":lprevious<CR>", { desc = "Previous Location" })
map("n", "]l", ":lnext<CR>", { desc = "Next Location" })

-- ============================================================================
-- SCROLL CENTERING
-- ============================================================================
map("n", "<C-d>", "<C-d>zz", opts)
map("n", "<C-u>", "<C-u>zz", opts)
map("n", "n", "nzzzv", opts)
map("n", "N", "Nzzzv", opts)
map("n", "*", "*zz", opts)
map("n", "#", "#zz", opts)
map("n", "g*", "g*zz", opts)
map("n", "g#", "g#zz", opts)

-- ============================================================================
-- FILE NAVIGATION (gf enhanced with vim-fetch)
-- ============================================================================
map("n", "gf", "gF", { desc = "Go to file with line number support" })
map("n", "gw", "<C-w>gF", { desc = "Open file in new window" })
map("n", "gv", "<C-w>vgF", { desc = "Open file in vertical split" })
map("n", "gs", "<C-w>sgF", { desc = "Open file in horizontal split" })
map("n", "gt", "<C-w>gF<C-w>T", { desc = "Open file in new tab" })
