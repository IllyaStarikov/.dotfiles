--
-- config/lsp.lua
-- LSP configuration with blink.cmp integration
--

-- LSP Setup with blink.cmp
local function setup_lsp()
  local lspconfig = require("lspconfig")
  -- 1. Setup Mason for LSP management
  require("mason").setup({
    ui = {
      border = "rounded",
      icons = {
        package_installed = "✓",
        package_pending = "➜",
        package_uninstalled = "✗"
      }
    }
  })
  
  require("mason-lspconfig").setup({
    -- Ensure these servers are installed
    ensure_installed = { 
      "pyright",     -- Python
      "clangd",      -- C/C++
      "lua_ls",      -- Lua
      "marksman",    -- Markdown
      "texlab",      -- LaTeX
      "ts_ls",       -- TypeScript/JavaScript
      "rust_analyzer", -- Rust
      "gopls",       -- Go
    },
    automatic_installation = true,
    -- Disable automatic server setup to prevent duplicates
    automatic_enable = false,
    handlers = nil,
  })

  -- 2. LSP server configurations
  -- lspconfig already required above

  -- Capabilities for blink.cmp integration
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  
  -- Get blink.cmp capabilities using the correct API
  local blink_ok, blink = pcall(require, "blink.cmp")
  if blink_ok then
    capabilities = blink.get_lsp_capabilities()
  else
    vim.notify("blink.cmp not available, using default capabilities", vim.log.levels.WARN)
  end

  -- Simple on_attach function for LSP keybindings
  local on_attach = function(client, bufnr)
    -- Disable semantic tokens for clangd (performance)
    if client.name == "clangd" then
      client.server_capabilities.semanticTokensProvider = nil
    end
    
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
    pyright = {
      settings = {
        python = {
          analysis = {
            autoSearchPaths = true,
            useLibraryCodeForTypes = true,
            diagnosticMode = "workspace",
            typeCheckingMode = "basic",
            -- Add completion-specific settings
            autoImportCompletions = true,
            completeFunctionParens = true,
          },
        },
      },
    },
    clangd = {
      -- Minimal configuration for clangd
      cmd = {
        "clangd",
        "--background-index",
        "--completion-style=detailed",
        "--header-insertion=iwyu",
        "--clang-tidy=false",  -- Disable clang-tidy for better performance
      },
      filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
      -- Add root directory detection to prevent multiple instances
      root_dir = function(fname)
        local root = lspconfig.util.root_pattern(
          '.clangd',
          '.clang-tidy',
          '.clang-format',
          'compile_commands.json',
          'compile_flags.txt',
          'configure.ac',
          '.git'
        )(fname)
        -- If no root found, use the file's directory
        return root or lspconfig.util.path.dirname(fname)
      end,
      single_file_support = true,
      -- Prevent multiple instances
      autostart = false,  -- Disable autostart, we'll start it manually
    },
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
    },
    ts_ls = {
      settings = {
        typescript = {
          inlayHints = {
            includeInlayParameterNameHints = 'all',
            includeInlayParameterNameHintsWhenArgumentMatchesName = false,
            includeInlayFunctionParameterTypeHints = true,
            includeInlayVariableTypeHints = true,
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
            includeInlayEnumMemberValueHints = true,
          }
        }
      }
    },
    rust_analyzer = {
      settings = {
        ["rust-analyzer"] = {
          checkOnSave = {
            command = "clippy",
          },
        },
      },
    },
    gopls = {
      settings = {
        gopls = {
          analyses = {
            unusedparams = true,
          },
          staticcheck = true,
        },
      },
    },
  }
  
  -- Setup all configured servers
  for server, config in pairs(servers) do
    -- Setup the server
    config.capabilities = capabilities
    config.on_attach = on_attach
    
    -- Debug: log server setup
    -- vim.notify("Setting up " .. server .. " LSP server", vim.log.levels.INFO)
    
    -- Use pcall to handle servers that might not be installed
    local ok, err = pcall(function()
      lspconfig[server].setup(config)
    end)
    
    if not ok then
      vim.notify("Failed to setup " .. server .. ": " .. tostring(err), vim.log.levels.WARN)
    else
      -- vim.notify("Successfully setup " .. server, vim.log.levels.INFO)
    end
  end
  
  -- For clangd, we need to manually start it to avoid duplicates
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
    callback = function()
      -- Check if clangd is already running for this buffer
      local clients = vim.lsp.get_clients({ bufnr = 0, name = "clangd" })
      if #clients == 0 then
        -- No clangd running, start it
        vim.cmd("LspStart clangd")
      end
    end,
    desc = "Manually start clangd to prevent duplicates"
  })
  
  -- Note: We're manually configuring servers above, so we don't need
  -- mason-lspconfig handlers which could cause duplicate setup
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
  local clients = vim.lsp.get_clients()
  if #clients == 0 then
    print("No active LSP clients")
  else
    print("Active LSP clients:")
    for _, client in ipairs(clients) do
      print(string.format("  - %s (id: %d)", client.name, client.id))
      -- Check if client has completion capability
      if client.server_capabilities.completionProvider then
        print("    ✓ Completion provider enabled")
      else
        print("    ✗ Completion provider NOT enabled")
      end
    end
  end
  
  -- Check blink.cmp status
  local blink_ok, blink = pcall(require, "blink.cmp")
  if blink_ok then
    print("\nblink.cmp is loaded")
    if blink.get_lsp_capabilities then
      print("  ✓ get_lsp_capabilities function exists")
    else
      print("  ✗ get_lsp_capabilities function NOT found")
    end
  else
    print("\nblink.cmp is NOT loaded")
  end
  
  -- Check current buffer's filetype
  print("\nCurrent buffer filetype: " .. vim.bo.filetype)
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

-- Don't setup LSP immediately - let init.lua handle it after plugins are loaded
-- setup_lsp()

return M