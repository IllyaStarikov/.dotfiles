--
-- config/lsp.lua
-- LSP configuration with blink.cmp integration
--

-- LSP Setup with blink.cmp
local function setup_lsp()
  -- 1. Setup Mason (servers already installed via Homebrew)
  require("mason").setup()
  require("mason-lspconfig").setup({
    -- ensure_installed = { "pyright", "clangd", "marksman", "texlab", "lua_ls" }
    -- ^ commented out since servers are installed via Homebrew
  })

  -- 2. LSP server configurations
  local lspconfig = require("lspconfig")

  -- Capabilities for blink.cmp integration
  local blink_ok, blink = pcall(require, "blink.cmp")
  local capabilities
  if blink_ok then
    capabilities = blink.get_lsp_capabilities()
  else
    capabilities = vim.lsp.protocol.make_client_capabilities()
  end

  -- Optional: on_attach function to bind keys after LSP attaches to buffer
  local on_attach = function(client, bufnr)
    local buf = vim.lsp.buf    -- alias for convenience
    local map = function(mode, lhs, rhs, desc)
      if desc then desc = "[LSP] " .. desc end
      vim.keymap.set(mode, lhs, rhs, { 
        buffer = bufnr, 
        silent = true, 
        noremap = true, 
        desc = desc 
      })
    end
    
    -- Keybindings for LSP features:
    map("n", "gd", buf.definition, "Go to definition")
    map("n", "gD", buf.declaration, "Go to declaration")
    map("n", "gi", buf.implementation, "Go to implementation")
    map("n", "gr", buf.references, "Find references")
    map("n", "K", buf.hover, "Hover documentation")
    map("n", "<F2>", buf.rename, "Rename symbol")
    map("n", "<F4>", buf.code_action, "Code actions")
    map("n", "gl", vim.diagnostic.open_float, "Show diagnostics")    -- Show diagnostics in floating window
    map("n", "[d", vim.diagnostic.goto_prev, "Prev diagnostic")
    map("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")
  end

  -- Enable language servers only if they exist
  local servers = {
    pyright = {},
    clangd = {},
    marksman = {},
    texlab = {},
    lua_ls = {
      settings = {
        Lua = {
          diagnostics = { globals = {"vim"} },
          workspace = { 
            library = vim.api.nvim_list_runtime_paths(),
            checkThirdParty = false
          },
          telemetry = { enable = false }
        }
      }
    }
  }
  
  for server, config in pairs(servers) do
    if vim.fn.executable(server) == 1 or server == "lua_ls" then
      config.capabilities = capabilities
      config.on_attach = on_attach
      lspconfig[server].setup(config)
    end
  end
end

-- Custom Kwbd function (migrated from vimscript)
local function kwbd(stage)
  if stage == 1 then
    if not vim.fn.buflisted(vim.fn.winbufnr(0)) then
      vim.cmd("bd!")
      return
    end
    
    local kwbd_buf_num = vim.fn.bufnr("%")
    local kwbd_win_num = vim.fn.winnr()
    
    -- Save window layout and execute stage 2 on all windows
    vim.cmd("windo lua require('config.lsp').kwbd(2)")
    vim.cmd(kwbd_win_num .. "wincmd w")
    
    local buf_listed_left = 0
    local buf_final_jump = 0
    local n_bufs = vim.fn.bufnr("$")
    
    for i = 1, n_bufs do
      if i ~= kwbd_buf_num then
        if vim.fn.buflisted(i) == 1 then
          buf_listed_left = buf_listed_left + 1
        else
          if vim.fn.bufexists(i) == 1 and vim.fn.bufname(i) == "" and buf_final_jump == 0 then
            buf_final_jump = i
          end
        end
      end
    end
    
    if buf_listed_left == 0 then
      if buf_final_jump ~= 0 then
        vim.cmd("windo if buflisted(winbufnr(0)) | execute 'b! " .. buf_final_jump .. "' | endif")
      else
        vim.cmd("enew")
        local new_buf = vim.fn.bufnr("%")
        vim.cmd("windo if buflisted(winbufnr(0)) | execute 'b! " .. new_buf .. "' | endif")
      end
      vim.cmd(kwbd_win_num .. "wincmd w")
    end
    
    if vim.fn.buflisted(kwbd_buf_num) == 1 or kwbd_buf_num == vim.fn.bufnr("%") then
      vim.cmd("bd! " .. kwbd_buf_num)
    end
    
    if buf_listed_left == 0 then
      vim.opt_local.buflisted = true
      vim.opt_local.bufhidden = "delete"
      vim.opt_local.buftype = ""
      vim.opt_local.swapfile = false
    end
  else
    -- Stage 2
    local kwbd_buf_num = vim.g.kwbd_buf_num or vim.fn.bufnr("%")
    if vim.fn.bufnr("%") == kwbd_buf_num then
      local prevbufvar = vim.fn.bufnr("#")
      if prevbufvar > 0 and vim.fn.buflisted(prevbufvar) == 1 and prevbufvar ~= kwbd_buf_num then
        vim.cmd("b #")
      else
        vim.cmd("bn")
      end
    end
  end
end

-- Export the kwbd function for global access
local M = {}
M.kwbd = kwbd

-- Debug function to check LSP status
function M.check_lsp_status()
  local clients = vim.lsp.get_active_clients()
  if #clients == 0 then
    print("No active LSP clients")
  else
    print("Active LSP clients:")
    for _, client in ipairs(clients) do
      print(string.format("  - %s (id: %d)", client.name, client.id))
    end
  end
  
  -- Check blink.cmp status
  local blink_ok, blink = pcall(require, "blink.cmp")
  if blink_ok then
    print("blink.cmp is loaded")
  else
    print("blink.cmp is NOT loaded")
  end
end

-- Create user command for Kwbd
vim.api.nvim_create_user_command("Kwbd", function()
  kwbd(1)
end, {})

-- Create debug command
vim.api.nvim_create_user_command("LspStatus", function()
  M.check_lsp_status()
end, { desc = "Check LSP and completion status" })

-- Work-specific overrides
if vim.g.vimrc_type == 'work' then
  local work_config = vim.fn.expand("~/.vimrc.work")
  if vim.fn.filereadable(work_config) == 1 then
    vim.cmd("source " .. work_config)
  end
end

-- Export setup function
M.setup = setup_lsp

-- Setup LSP after plugins are loaded
vim.api.nvim_create_autocmd("User", {
  pattern = "VeryLazy",
  callback = function()
    -- Ensure ALE is disabled before setting up LSP
    vim.g.ale_disable_lsp = 1
    vim.g.ale_completion_enabled = 0
    setup_lsp()
  end,
})

return M