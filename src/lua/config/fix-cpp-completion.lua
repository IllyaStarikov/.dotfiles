--
-- Comprehensive fix for C++ completion issues
--

local M = {}

function M.apply_fix()
  -- 1. Ensure blink.cmp is properly configured for C++
  local blink_ok, blink = pcall(require, 'blink.cmp')
  if not blink_ok then
    vim.notify("blink.cmp not loaded!", vim.log.levels.ERROR)
    return
  end
  
  -- 2. Force reload LSP configuration with proper settings
  local lspconfig = require('lspconfig')
  
  -- Stop any existing clangd clients
  local clients = vim.lsp.get_active_clients({ name = "clangd" })
  for _, client in ipairs(clients) do
    vim.lsp.stop_client(client.id)
  end
  
  -- 3. Setup clangd with explicit configuration
  lspconfig.clangd.setup({
    cmd = {
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
      "--completion-parse=auto",
      "--pch-storage=memory"
    },
    capabilities = require('blink.cmp').get_lsp_capabilities(),
    on_attach = function(client, bufnr)
      -- Ensure omnifunc is set
      vim.bo[bufnr].omnifunc = 'v:lua.vim.lsp.omnifunc'
      
      -- Log attachment
      vim.notify("Clangd reattached to buffer " .. bufnr, vim.log.levels.INFO)
      
      -- Check trigger characters
      if client.server_capabilities.completionProvider then
        local triggers = client.server_capabilities.completionProvider.triggerCharacters
        if triggers and vim.tbl_contains(triggers, '.') then
          vim.notify("✓ Dot completion should work!", vim.log.levels.INFO)
        else
          vim.notify("❌ Dot is not a trigger character!", vim.log.levels.WARN)
        end
      end
    end,
    init_options = {
      usePlaceholders = true,
      completeUnimported = true,
      clangdFileStatus = true
    },
  })
  
  -- 4. Add autocmd to ensure completion works in C++ files
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "c", "cpp", "cc", "cxx", "h", "hpp" },
    callback = function(ev)
      -- Ensure buffer has proper settings
      vim.bo[ev.buf].omnifunc = 'v:lua.vim.lsp.omnifunc'
      
      -- Add manual completion trigger on dot
      vim.keymap.set('i', '.', function()
        -- Insert the dot
        vim.api.nvim_feedkeys('.', 'n', false)
        -- Trigger completion after a short delay
        vim.defer_fn(function()
          if vim.fn.mode() == 'i' then
            require('blink.cmp').show({ force = true })
          end
        end, 50)
      end, { buffer = ev.buf, desc = "Insert dot and trigger completion" })
      
      vim.notify("C++ completion fix applied to buffer", vim.log.levels.DEBUG)
    end,
  })
  
  -- 5. Restart LSP for current buffer if it's C++
  local ft = vim.bo.filetype
  if ft == "c" or ft == "cpp" or ft == "cc" or ft == "cxx" then
    vim.cmd("LspRestart")
    vim.notify("LSP restarted for C++ file", vim.log.levels.INFO)
  end
  
  vim.notify("C++ completion fix applied successfully!", vim.log.levels.INFO)
end

-- Create command
vim.api.nvim_create_user_command("FixCppCompletion", function()
  M.apply_fix()
end, { desc = "Apply comprehensive C++ completion fix" })

-- Auto-apply fix on startup for C++ files
vim.api.nvim_create_autocmd("VimEnter", {
  callback = function()
    vim.defer_fn(function()
      local ft = vim.bo.filetype
      if ft == "c" or ft == "cpp" or ft == "cc" or ft == "cxx" then
        M.apply_fix()
      end
    end, 500)
  end,
})

return M