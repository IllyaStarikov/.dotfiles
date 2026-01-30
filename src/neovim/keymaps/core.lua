--
-- keymaps/core.lua
-- Essential mappings and system fixes
--

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Ensure VIMRUNTIME is properly set for health checks
if not vim.env.VIMRUNTIME or vim.env.VIMRUNTIME == "" then
  local runtime_path = vim.fn.fnamemodify(vim.v.progpath, ":h:h") .. "/share/nvim/runtime"
  if vim.fn.isdirectory(runtime_path) == 1 then
    vim.env.VIMRUNTIME = runtime_path
  end
end

-- Commands for common typos
vim.api.nvim_create_user_command("W", "w", {})
vim.api.nvim_create_user_command("Q", "q", {})
vim.api.nvim_create_user_command("Wq", "wq", {})

-- Quick save
map("n", "<C-s>", ":w<CR>", opts)
map("i", "<C-s>", "<Esc>:w<CR>a", opts)
map("v", "<C-s>", "<Esc>:w<CR>", opts)

-- Select all
map("n", "<C-a>", "ggVG", opts)

-- Clear search highlight
map("n", "<Esc>", ":noh<CR>", opts)

-- Delete without yanking
map("n", "<leader>d", '"_d', opts)
map("v", "<leader>d", '"_d', opts)

-- System clipboard - next greatest remap ever : asbjornHaland
map("n", "<leader>y", [["+y]], { desc = "Yank to clipboard" })
map("v", "<leader>y", [["+y]], { desc = "Yank to clipboard" })
map("n", "<leader>Y", [["+Y]], { desc = "Yank line to clipboard" })

-- Greatest remap ever - paste without losing register
map("x", "<leader>p", [["_dP]], { desc = "Paste without yanking" })

-- macOS-style copy/paste
map({ "n", "v" }, "<D-c>", [["+y]], { desc = "Copy (Cmd+C)" })
map("n", "<D-v>", [["+p]], { desc = "Paste (Cmd+V)" })
map("i", "<D-v>", "<C-r>+", { desc = "Paste (Cmd+V)" })
map("c", "<D-v>", "<C-r>+", { desc = "Paste (Cmd+V)" })

-- Fix visual mode yank to be instant (no waiting for additional keys)
-- This must be set to override any plugin mappings
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.defer_fn(function()
      -- Ensure visual mode 'y' is a direct yank
      vim.keymap.set({ "v", "x" }, "y", "y", {
        noremap = true,
        silent = true,
        desc = "Yank selection (instant)",
      })
    end, 100)
  end,
  desc = "Ensure visual yank is instant",
})

-- Better line joins
map("n", "J", "mzJ`z", opts)

-- Wrapped line navigation
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map("n", "0", "g0", opts)
map("n", "$", "g$", opts)

-- Quick macro playback
map("n", "Q", "@q", { desc = "Play macro q" })
map("v", "Q", ":norm @q<CR>", { desc = "Play macro q on selection" })

-- Terminal escape
map("t", "<Esc>", "<C-\\><C-n>", opts)

-- Copy filename/path
map("n", ",cs", ":let @+=expand('%')<CR>", { desc = "Copy relative path" })
map("n", ",cl", ":let @+=expand('%:p')<CR>", { desc = "Copy absolute path" })
map("n", "<Leader>cp", ":let @+=expand('%:p')<CR>", { desc = "Copy full path" })

-- Replace word under cursor
map(
  "n",
  "<leader>sw",
  [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]],
  { desc = "Replace word under cursor" }
)
