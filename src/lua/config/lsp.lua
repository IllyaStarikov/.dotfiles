--
-- config/lsp.lua
-- LSP configuration with blink.cmp integration
--

-- LSP Setup with blink.cmp
local function setup_lsp()
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
    -- Ensure these servers are installed (only the essential ones)
    ensure_installed = { 
      "pyright",     -- Python
      "clangd",      -- C/C++
      "lua_ls",      -- Lua
    },
    -- Don't automatically install to avoid failures
    automatic_installation = false,
  })
  
  -- Try to install additional servers but don't fail if they can't be installed
  local additional_servers = {
    "marksman",      -- Markdown
    "texlab",        -- LaTeX  
    "tsserver",      -- TypeScript/JavaScript
    "rust_analyzer", -- Rust
    "gopls",         -- Go
  }
  
  -- Attempt to install additional servers without blocking
  vim.defer_fn(function()
    local registry = require("mason-registry")
    for _, server in ipairs(additional_servers) do
      local ok, pkg = pcall(registry.get_package, server)
      if ok and not pkg:is_installed() then
        pkg:install():on("closed", function()
          -- Silent install, no notifications
        end)
      end
    end
  end, 1000)

  -- 2. LSP server configurations
  local lspconfig = require("lspconfig")

  -- Capabilities for blink.cmp integration
  local capabilities = vim.lsp.protocol.make_client_capabilities()
  
  -- Try to get blink.cmp capabilities
  local blink_ok, blink = pcall(require, "blink.cmp")
  if blink_ok then
    -- Try the get_lsp_capabilities function if it exists
    if blink.get_lsp_capabilities then
      local blink_caps = blink.get_lsp_capabilities()
      if blink_caps then
        capabilities = blink_caps
        -- Successfully using blink.cmp capabilities
      end
    else
      -- Fallback: manually ensure completion capabilities are set
    end
  else
    -- blink.cmp not loaded when setting up LSP
  end
  
  -- Ensure completion capability is set
  capabilities.textDocument.completion = capabilities.textDocument.completion or {
    completionItem = {
      snippetSupport = true,
      commitCharactersSupport = true,
      deprecatedSupport = true,
      preselectSupport = true,
      tagSupport = {
        valueSet = { 1 }
      },
      insertReplaceSupport = true,
      resolveSupport = {
        properties = {
          "documentation",
          "detail",
          "additionalTextEdits",
        },
      },
      insertTextModeSupport = {
        valueSet = { 1, 2 }
      },
      labelDetailsSupport = true,
    },
    contextSupport = true,
    insertTextMode = 1,
    completionList = {
      itemDefaults = {
        'commitCharacters',
        'editRange',
        'insertTextFormat',
        'insertTextMode',
        'data',
      }
    }
  }

  -- Optional: on_attach function to bind keys after LSP attaches to buffer
  local on_attach = function(client, bufnr)
    -- Ensure completion is working for C++ dot operator
    if client.name == "clangd" then
      -- Ensure semantic tokens are enabled for better highlighting
      client.server_capabilities.semanticTokensProvider = nil
      
      -- Ensure completion provider is properly configured
      if client.server_capabilities.completionProvider then
        vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
      end
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
          },
        },
      },
    },
    clangd = {
      cmd = {
        -- Use Homebrew LLVM clangd for better C++ support
        "/opt/homebrew/opt/llvm/bin/clangd",
        "--background-index",
        "--clang-tidy",
        "--header-insertion=iwyu",
        "--completion-style=detailed",
        "--function-arg-placeholders",
        "--fallback-style=llvm",
        "--header-insertion-decorators",
        "--suggest-missing-includes",
        "--cross-file-rename",
        "--enable-config",
        -- Ensure proper completion triggers
        "--completion-parse=auto",
        "--pch-storage=memory"
      },
      init_options = {
        usePlaceholders = true,
        completeUnimported = true,
        clangdFileStatus = true
      },
      filetypes = { "c", "cpp", "objc", "objcpp", "cuda", "proto" },
      root_dir = lspconfig.util.root_pattern(
        '.clangd',
        '.clang-tidy',
        '.clang-format',
        'compile_commands.json',
        'compile_flags.txt',
        'configure.ac',
        '.git'
      ),
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
    tsserver = {
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
    -- Special handling for clangd to use LLVM version
    if server == "clangd" then
      -- Check for LLVM clangd first, fallback to system clangd
      if vim.fn.executable("/opt/homebrew/opt/llvm/bin/clangd") == 1 then
        -- Use LLVM clangd (already configured in cmd)
      elseif vim.fn.executable("clangd") == 1 then
        -- Fallback to system clangd
        config.cmd = { "clangd" }
      else
        -- Skip if no clangd found
        goto continue
      end
    end
    
    -- Setup the server
    config.capabilities = capabilities
    config.on_attach = on_attach
    
    -- Use pcall to handle servers that might not be installed
    local ok, err = pcall(function()
      lspconfig[server].setup(config)
    end)
    
    if not ok then
      -- Only show warning for essential servers
      if server == "pyright" or server == "clangd" or server == "lua_ls" then
        vim.notify("Failed to setup " .. server .. ": " .. tostring(err), vim.log.levels.WARN)
      end
    end
    
    ::continue::
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

-- Create LSP management commands
vim.api.nvim_create_user_command("LspStatus", function()
  M.check_lsp_status()
end, { desc = "Check LSP and completion status" })

vim.api.nvim_create_user_command("LspInstallEssential", function()
  vim.cmd("MasonInstall pyright clangd lua-language-server")
end, { desc = "Install essential LSP servers" })

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