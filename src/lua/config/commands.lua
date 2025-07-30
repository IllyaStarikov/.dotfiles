--
-- config/commands.lua
-- Custom commands and utilities for enhanced productivity
--

local api = vim.api
local fn = vim.fn

-- =============================================================================
-- BUFFER UTILITIES
-- =============================================================================

-- Delete all buffers except current
api.nvim_create_user_command("BufOnly", function()
  local current = api.nvim_get_current_buf()
  for _, buf in ipairs(api.nvim_list_bufs()) do
    if buf ~= current and api.nvim_buf_is_valid(buf) and api.nvim_buf_get_option(buf, "buflisted") then
      api.nvim_buf_delete(buf, { force = false })
    end
  end
end, { desc = "Delete all buffers except current" })

-- Delete all unmodified buffers
api.nvim_create_user_command("BufClean", function()
  for _, buf in ipairs(api.nvim_list_bufs()) do
    if api.nvim_buf_is_valid(buf) 
       and api.nvim_buf_get_option(buf, "buflisted")
       and not api.nvim_buf_get_option(buf, "modified") then
      api.nvim_buf_delete(buf, { force = false })
    end
  end
end, { desc = "Delete all unmodified buffers" })

-- =============================================================================
-- FILE UTILITIES
-- =============================================================================

-- Copy current file path
api.nvim_create_user_command("CopyPath", function()
  local path = fn.expand("%:p")
  fn.setreg("+", path)
  vim.notify("Copied: " .. path)
end, { desc = "Copy full file path to clipboard" })

-- Copy relative file path
api.nvim_create_user_command("CopyRelPath", function()
  local path = fn.expand("%")
  fn.setreg("+", path)
  vim.notify("Copied: " .. path)
end, { desc = "Copy relative file path to clipboard" })

-- Copy file name only
api.nvim_create_user_command("CopyFileName", function()
  local name = fn.expand("%:t")
  fn.setreg("+", name)
  vim.notify("Copied: " .. name)
end, { desc = "Copy file name to clipboard" })

-- =============================================================================
-- SEARCH UTILITIES
-- =============================================================================

-- Search for word under cursor in project
api.nvim_create_user_command("SearchProject", function()
  local word = fn.expand("<cword>")
  require('telescope.builtin').grep_string({ search = word })
end, { desc = "Search word under cursor in project" })

-- Search for visual selection in project
api.nvim_create_user_command("SearchSelection", function()
  local selection = fn.getregion(fn.getpos("'<"), fn.getpos("'>"), { type = fn.mode() })
  require('telescope.builtin').grep_string({ search = table.concat(selection, "\n") })
end, { range = true, desc = "Search visual selection in project" })

-- =============================================================================
-- FORMATTING UTILITIES
-- =============================================================================

-- Remove trailing whitespace
api.nvim_create_user_command("RemoveTrailingWhitespace", function()
  local save = fn.winsaveview()
  vim.cmd([[%s/\s\+$//e]])
  fn.winrestview(save)
  vim.notify("Removed trailing whitespace")
end, { desc = "Remove trailing whitespace from file" })

-- Convert tabs to spaces
api.nvim_create_user_command("TabsToSpaces", function()
  local save = fn.winsaveview()
  vim.cmd([[%s/\t/  /ge]])
  fn.winrestview(save)
  vim.notify("Converted tabs to spaces")
end, { desc = "Convert tabs to spaces" })

-- Format JSON
api.nvim_create_user_command("FormatJSON", function()
  vim.cmd("%!python3 -m json.tool")
end, { desc = "Format JSON file" })

-- =============================================================================
-- DIAGNOSTIC UTILITIES
-- =============================================================================

-- Toggle diagnostics
local diagnostics_active = true
api.nvim_create_user_command("DiagnosticsToggle", function()
  diagnostics_active = not diagnostics_active
  if diagnostics_active then
    vim.diagnostic.enable()
    vim.notify("Diagnostics enabled")
  else
    vim.diagnostic.disable()
    vim.notify("Diagnostics disabled")
  end
end, { desc = "Toggle diagnostics" })

-- =============================================================================
-- DIFF UTILITIES
-- =============================================================================

-- Diff with saved file
api.nvim_create_user_command("DiffSaved", function()
  local filetype = vim.bo.filetype
  vim.cmd("diffthis")
  vim.cmd("vnew | r # | normal! 1Gdd")
  vim.cmd("diffthis")
  vim.bo.filetype = filetype
  vim.bo.buftype = "nofile"
  vim.bo.bufhidden = "wipe"
  vim.bo.buflisted = false
  vim.bo.swapfile = false
  vim.bo.readonly = true
  api.nvim_buf_set_name(0, "Saved version")
end, { desc = "Show diff with saved file" })

-- =============================================================================
-- PROFILING UTILITIES
-- =============================================================================

-- Profile startup time
api.nvim_create_user_command("StartupTime", function()
  local start_time = fn.reltime()
  vim.cmd("runtime! plugin/**/*.vim")
  local elapsed = fn.reltimefloat(fn.reltime(start_time))
  vim.notify(string.format("Startup time: %.3f ms", elapsed * 1000))
end, { desc = "Measure startup time" })

-- =============================================================================
-- WORKSPACE UTILITIES
-- =============================================================================

-- Change to project root
api.nvim_create_user_command("ProjectRoot", function()
  local root_patterns = { ".git", "package.json", "Makefile", "go.mod", "Cargo.toml" }
  local root = vim.fs.find(root_patterns, {
    upward = true,
    path = vim.fn.expand("%:p:h"),
  })[1]
  
  if root then
    local dir = vim.fn.fnamemodify(root, ":h")
    vim.cmd("cd " .. dir)
    vim.notify("Changed to: " .. dir)
  else
    vim.notify("Project root not found", vim.log.levels.WARN)
  end
end, { desc = "Change to project root directory" })

-- =============================================================================
-- SCRATCH BUFFER
-- =============================================================================

-- Create a scratch buffer
api.nvim_create_user_command("Scratch", function(opts)
  local buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_option(buf, "buftype", "nofile")
  api.nvim_buf_set_option(buf, "bufhidden", "hide")
  api.nvim_buf_set_option(buf, "swapfile", false)
  
  if opts.args ~= "" then
    api.nvim_buf_set_option(buf, "filetype", opts.args)
  end
  
  api.nvim_set_current_buf(buf)
end, { nargs = "?", desc = "Create scratch buffer with optional filetype" })

-- =============================================================================
-- MESSAGES UTILITIES
-- =============================================================================

-- Clear messages
api.nvim_create_user_command("ClearMessages", function()
  vim.cmd("messages clear")
  vim.notify("Messages cleared")
end, { desc = "Clear command messages" })

-- Show messages in buffer
api.nvim_create_user_command("Messages", function()
  local messages = fn.execute("messages")
  local buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_lines(buf, 0, -1, false, vim.split(messages, "\n"))
  api.nvim_buf_set_option(buf, "buftype", "nofile")
  api.nvim_buf_set_option(buf, "bufhidden", "wipe")
  api.nvim_buf_set_option(buf, "filetype", "vim")
  api.nvim_buf_set_name(buf, "Messages")
  api.nvim_set_current_buf(buf)
end, { desc = "Show messages in buffer" })

-- =============================================================================
-- COMPLETION DEBUGGING
-- =============================================================================

-- Debug completion status
api.nvim_create_user_command("CompletionDebug", function()
  print("=== COMPLETION DEBUG ===")
  
  -- Check if blink.cmp is loaded
  local blink_ok, blink = pcall(require, "blink.cmp")
  if blink_ok then
    print("✓ blink.cmp module loaded")
    -- Try to check if it's initialized
    local status, err = pcall(function()
      if blink.show then
        print("  ✓ blink.show function exists")
      else
        print("  ✗ blink.show function NOT found")
      end
      if blink.hide then
        print("  ✓ blink.hide function exists")
      else
        print("  ✗ blink.hide function NOT found")
      end
    end)
    if not status then
      print("  Error checking blink functions: " .. tostring(err))
    end
  else
    print("✗ blink.cmp NOT loaded")
    print("  Error: " .. tostring(blink))
  end
  
  -- Check lazy.nvim status
  local lazy_ok, lazy = pcall(require, "lazy")
  if lazy_ok then
    local plugins = lazy.plugins()
    for _, plugin in pairs(plugins) do
      if plugin.name == "blink.cmp" then
        print("\n✓ blink.cmp in lazy.nvim:")
        print("  Loaded: " .. tostring(plugin._.loaded ~= nil))
        print("  Is local: " .. tostring(plugin._.is_local))
        print("  Dir: " .. (plugin.dir or "unknown"))
        break
      end
    end
  end
  
  -- Check if any LSP clients are attached
  print("\n=== LSP STATUS ===")
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients > 0 then
    print("✓ LSP clients attached: " .. #clients)
    for _, client in ipairs(clients) do
      print("  - " .. client.name)
      if client.server_capabilities.completionProvider then
        print("    ✓ Has completion provider")
      end
    end
  else
    print("✗ No LSP clients attached")
  end
  
  -- Check autocmd
  print("\n=== AUTOCMDS ===")
  print("InsertEnter autocmds: " .. vim.inspect(vim.api.nvim_get_autocmds({ event = "InsertEnter" })))
  
  print("\nTry :Lazy show blink.cmp to see plugin status")
end, { desc = "Debug completion setup" })

-- Force trigger completion
api.nvim_create_user_command("CompletionTest", function()
  -- Try different methods to trigger completion
  local methods = {
    function()
      -- Method 1: Try blink.show
      local ok, blink = pcall(require, "blink.cmp")
      if ok and blink.show then
        blink.show()
        return "Called blink.show()"
      end
      return "blink.show not available"
    end,
    function()
      -- Method 2: Try triggering via feedkeys
      vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-Space>", true, true, true), "n", false)
      return "Triggered via <C-Space>"
    end,
    function()
      -- Method 3: Try omnifunc
      if vim.bo.omnifunc ~= "" then
        vim.api.nvim_feedkeys(vim.api.nvim_replace_termcodes("<C-x><C-o>", true, true, true), "n", false)
        return "Triggered omnifunc"
      end
      return "No omnifunc set"
    end,
  }
  
  for i, method in ipairs(methods) do
    local result = method()
    print("Method " .. i .. ": " .. result)
  end
end, { desc = "Test completion triggering" })

-- Blink.cmp LSP Debug
api.nvim_create_user_command("BlinkLspDebug", function()
  local ok, blink = pcall(require, 'blink.cmp')
  if not ok then
    print("Blink.cmp is not loaded!")
    return
  end
  
  print("=== Blink.cmp LSP Debug ===")
  
  -- Check active LSP clients and their trigger characters
  print("\nActive LSP clients:")
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  for _, client in ipairs(clients) do
    local completion = client.server_capabilities.completionProvider
    if completion then
      print(string.format("  %s:", client.name))
      print(string.format("    - Has completion: true"))
      if completion.triggerCharacters then
        print(string.format("    - Trigger chars: %s", vim.inspect(completion.triggerCharacters)))
      else
        print("    - Trigger chars: none")
      end
    else
      print(string.format("  %s: No completion support", client.name))
    end
  end
  
  -- Check if we can get trigger characters from the LSP source
  local lsp_source_ok, lsp_source = pcall(require, 'blink.cmp.sources.lsp')
  if lsp_source_ok then
    local instance = lsp_source.new()
    local triggers = instance:get_trigger_characters()
    print(string.format("\nBlink LSP source trigger characters: %s", vim.inspect(triggers)))
  end
  
  -- Current configuration
  local config = require('blink.cmp.config')
  print("\nBlink trigger configuration:")
  print("  - show_on_trigger_character: " .. tostring(config.completion.trigger.show_on_trigger_character))
  print("  - show_on_blocked_trigger_characters: " .. vim.inspect(config.completion.trigger.show_on_blocked_trigger_characters))
  
  -- Current buffer info
  print(string.format("\nBuffer info: ft=%s", vim.bo.filetype))
end, { desc = "Show blink.cmp LSP debug information" })

-- =============================================================================
-- BLINK.CMP UTILITIES (from best practices guide)
-- =============================================================================

-- Check blink.cmp health and status
api.nvim_create_user_command("BlinkCheck", function()
  local blink = require('blink.cmp')
  print("=== Blink.cmp Status ===")
  print("Loaded:", blink ~= nil and "✅ Yes" or "❌ No")
  
  if blink then
    print("\nLSP Capabilities:", blink.get_lsp_capabilities() ~= nil and "✅ Available" or "❌ Not available")
    
    local config = require('blink.cmp.config')
    print("\nActive Sources:", vim.inspect(config.sources.default))
    
    -- Check if Rust fuzzy matcher is available
    local ok, _ = pcall(require, 'blink_cmp_fuzzy')
    print("\nRust Fuzzy Matcher:", ok and "✅ Available" or "⚠️  Using Lua fallback")
  end
end, { desc = "Check blink.cmp status" })

-- Test blink.cmp completion
api.nvim_create_user_command("BlinkTest", function()
  print("Testing blink.cmp completion...")
  
  -- Create a test buffer
  vim.cmd('new')
  vim.cmd('setfiletype lua')
  api.nvim_buf_set_lines(0, 0, -1, false, {
    "-- Test completion",
    "vim."
  })
  
  -- Position cursor after the dot
  api.nvim_win_set_cursor(0, {2, 4})
  
  -- Trigger completion
  vim.defer_fn(function()
    local blink = require('blink.cmp')
    if blink.show then
      blink.show()
      print("Completion triggered - check if menu appears")
    else
      print("❌ Could not trigger completion")
    end
  end, 100)
end, { desc = "Test blink.cmp completion" })

-- Load this module from init.lua with: require('config.commands')