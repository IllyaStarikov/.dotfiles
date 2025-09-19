--
-- config/keymaps/lsp.lua
-- LSP and diagnostic mappings
--

local map = vim.keymap.set

-- Diagnostic navigation (using new vim.diagnostic.jump API)
map("n", "[W", function()
  vim.diagnostic.jump({ count = -1, severity = vim.diagnostic.severity.ERROR, float = true })
end, { desc = "Go to previous error" })
map("n", "[w", function()
  vim.diagnostic.jump({ count = -1, float = true })
end, { desc = "Go to previous diagnostic" })
map("n", "]w", function()
  vim.diagnostic.jump({ count = 1, float = true })
end, { desc = "Go to next diagnostic" })
map("n", "]W", function()
  vim.diagnostic.jump({ count = 1, severity = vim.diagnostic.severity.ERROR, float = true })
end, { desc = "Go to next error" })

-- LSP functionality
map("n", "<C-]>", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "<C-\\>", vim.lsp.buf.references, { desc = "Find references" })
map("n", "<C-[>", vim.lsp.buf.hover, { desc = "Show hover information" })

-- LSP rename
map("n", "<leader>re", vim.lsp.buf.rename, { desc = "LSP Rename Symbol" })
