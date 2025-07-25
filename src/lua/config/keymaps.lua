--
-- config/keymaps.lua
-- Key mappings (migrated from vimscript)
--

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Set leader key
vim.g.mapleader = " "

-- Commands for common typos
vim.api.nvim_create_user_command("W", "w", {})
vim.api.nvim_create_user_command("Q", "q", {})
vim.api.nvim_create_user_command("Wq", "wq", {})

-- Go up and down properly on wrapped text
map("n", "<Down>", "gj", opts)
map("n", "<Up>", "gk", opts)
map("v", "<Down>", "gj", opts)
map("v", "<Up>", "gk", opts)
map("i", "<Down>", "<C-o>gj", opts)
map("i", "<Up>", "<C-o>gk", opts)

-- Word wrap navigation
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map("n", "0", "g0", { buffer = true, silent = true })
map("n", "$", "g$", { buffer = true, silent = true })

-- Window navigation using arrow keys
map("n", "<up>", "<C-w><up>", opts)
map("n", "<down>", "<C-w><down>", opts)
map("n", "<left>", "<C-w><left>", opts)
map("n", "<right>", "<C-w><right>", opts)

-- Buffer navigation
map("n", "<Tab>", ":bnext<cr>", opts)
map("n", "<S-Tab>", ":bprevious<cr>", opts)

-- ALE Error navigation
map("n", "[W", "<Plug>(ale_first)", { silent = true })
map("n", "[w", "<Plug>(ale_previous)", { silent = true })
map("n", "]w", "<Plug>(ale_next)", { silent = true })
map("n", "]W", "<Plug>(ale_last)", { silent = true })

-- ALE functionality
map("n", "<C-]>", ":ALEGoToDefinition<CR>", opts)
map("n", "<C-\\>", ":ALEFindReferences<CR>", opts)
map("n", "<C-[>", ":ALEHover<CR>", opts)

-- Copy filename
map("n", ",cs", ":let @+=expand('%')<CR>", opts)
map("n", ",cl", ":let @+=expand('%:p')<CR>", opts)

-- Leader key mappings
map("n", "<leader>w", ":w<cr>", opts)
map("n", "<leader>q", ":q<cr>", opts)
map("n", "<leader>c", ":Kwbd<cr>", opts)
map("n", "<leader>x", ":x<cr>", opts)
map("n", "<leader>s", "<C-Z>", opts)
map("n", "<leader>d", '"_d', opts)

map("n", "<leader>n", ":NERDTreeToggle<cr>", opts)
map("n", "<leader>f", ":Files<cr>", opts)
map("n", "<leader>b", ":Buffers<cr>", opts)
map("n", "<leader>T", ":Tagbar<cr>", opts)
map("n", "<leader>g", ":Grepper -tool grep<cr>", opts)
map("n", "<leader><leader>", "v$h", opts)

-- EasyAlign
map("n", "ga", "<Plug>(EasyAlign)", {})
map("x", "ga", "<Plug>(EasyAlign)", {})

-- Copy full path
map("n", "<Leader>p", ":let @+=expand('%:p')<CR>", opts)

-- Terminal
map("n", "<leader>t", ":terminal<cr>", opts)
map("t", "<Esc>", "<C-\\><C-n>", opts)