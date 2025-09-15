--
-- config/keymaps/lsp.lua
-- LSP and diagnostic mappings
--

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Diagnostic navigation
map("n", "[W", function()
  vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Go to first error" })
map("n", "[w", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
map("n", "]w", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
map("n", "]W", function()
  vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR })
end, { desc = "Go to last error" })

-- LSP functionality
map("n", "<C-]>", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "<C-\\>", vim.lsp.buf.references, { desc = "Find references" })
map("n", "<C-[>", vim.lsp.buf.hover, { desc = "Show hover information" })

-- LSP rename
map("n", "<leader>re", function()
  vim.lsp.buf.rename()
end, { desc = "LSP Rename Symbol" })
