--
-- keymaps/lsp.lua
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

-- LSP functionality (Ctrl shortcuts)
-- No <C-[> mapping: a plain terminal sends 0x1B for Ctrl+[, which Neovim
-- decodes as <Esc>, so it only ever fired under CSI-u terminals. K hovers.
map("n", "<C-]>", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "<C-\\>", vim.lsp.buf.references, { desc = "Find references" })
