--
-- config/lsp-new.lua
-- Simplified LSP configuration with blink.cmp integration
--

local M = {}

function M.setup()
  -- Setup Mason
  require("mason").setup()
  require("mason-lspconfig").setup()

  -- Get lspconfig
  local lspconfig = require("lspconfig")
  
  -- Setup on_attach
  local on_attach = function(client, bufnr)
    -- Enable completion triggered by <c-x><c-o>
    vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
    
    -- Mappings
    local opts = { buffer = bufnr, noremap = true, silent = true }
    vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, opts)
    vim.keymap.set('n', 'gd', vim.lsp.buf.definition, opts)
    vim.keymap.set('n', 'K', vim.lsp.buf.hover, opts)
    vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, opts)
    vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, opts)
    vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, opts)
    vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, opts)
    vim.keymap.set('n', '<space>wl', function()
      print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
    end, opts)
    vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, opts)
    vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, opts)
    vim.keymap.set({ 'n', 'v' }, '<space>ca', vim.lsp.buf.code_action, opts)
    vim.keymap.set('n', 'gr', vim.lsp.buf.references, opts)
    vim.keymap.set('n', '<space>f', function()
      vim.lsp.buf.format { async = true }
    end, opts)
  end
  
  -- Get capabilities from blink.cmp
  local capabilities = require('blink.cmp').get_lsp_capabilities()
  
  -- Setup servers
  local servers = {
    pyright = {},
    lua_ls = {
      settings = {
        Lua = {
          diagnostics = {
            globals = { 'vim' }
          },
          workspace = {
            library = vim.api.nvim_get_runtime_file("", true),
            checkThirdParty = false,
          },
          telemetry = {
            enable = false,
          },
        },
      },
    },
    clangd = {},
    marksman = {},
    texlab = {},
  }
  
  -- Setup each server
  for server, config in pairs(servers) do
    config.on_attach = on_attach
    config.capabilities = capabilities
    
    -- Only setup if the server is available
    if vim.fn.executable(server) == 1 or server == "lua_ls" then
      lspconfig[server].setup(config)
    end
  end
end

-- Debug function
function M.debug()
  print("=== LSP Debug Info ===")
  
  -- Check blink.cmp
  local ok, blink = pcall(require, 'blink.cmp')
  if ok then
    print("✓ blink.cmp loaded")
    local caps = blink.get_lsp_capabilities()
    print("✓ LSP capabilities:", caps and "Available" or "Not available")
    if caps and caps.textDocument and caps.textDocument.completion then
      print("✓ Completion capability present")
    else
      print("✗ Completion capability missing")
    end
  else
    print("✗ blink.cmp not loaded")
  end
  
  -- Check LSP clients
  local clients = vim.lsp.get_active_clients()
  print("\nActive LSP clients:", #clients)
  for _, client in ipairs(clients) do
    print("  -", client.name)
    if client.server_capabilities.completionProvider then
      print("    ✓ Completion provider enabled")
    else
      print("    ✗ Completion provider disabled")
    end
  end
  
  print("\nBuffer filetype:", vim.bo.filetype)
end

-- Create debug command
vim.api.nvim_create_user_command('LspDebug', M.debug, {})

return M