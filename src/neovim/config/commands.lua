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
end, { desc = "Copy full file path to clipboard" })

-- Copy relative file path
api.nvim_create_user_command("CopyRelPath", function()
  local path = fn.expand("%")
  fn.setreg("+", path)
end, { desc = "Copy relative file path to clipboard" })

-- Copy file name only
api.nvim_create_user_command("CopyFileName", function()
  local name = fn.expand("%:t")
  fn.setreg("+", name)
end, { desc = "Copy file name to clipboard" })

-- =============================================================================
-- SEARCH UTILITIES
-- =============================================================================

-- Search for word under cursor in project
api.nvim_create_user_command("SearchProject", function()
  local word = fn.expand("<cword>")
  local ok, builtin = pcall(require, 'telescope.builtin')
  if ok then
    builtin.grep_string({ search = word })
  else
    vim.notify("Telescope not available", vim.log.levels.WARN)
  end
end, { desc = "Search word under cursor in project" })

-- Search for visual selection in project
api.nvim_create_user_command("SearchSelection", function()
  local selection = fn.getregion(fn.getpos("'<"), fn.getpos("'>"), { type = fn.mode() })
  local ok, builtin = pcall(require, 'telescope.builtin')
  if ok then
    builtin.grep_string({ search = table.concat(selection, "\n") })
  else
    vim.notify("Telescope not available", vim.log.levels.WARN)
  end
end, { range = true, desc = "Search visual selection in project" })

-- =============================================================================
-- HEALTH CHECK
-- =============================================================================

-- Load health check module
pcall(require, "config.health")

-- =============================================================================
-- FORMATTING UTILITIES
-- =============================================================================

-- Remove trailing whitespace
api.nvim_create_user_command("RemoveTrailingWhitespace", function()
  local save = fn.winsaveview()
  vim.cmd([[%s/\s\+$//e]])
  fn.winrestview(save)
end, { desc = "Remove trailing whitespace from file" })

-- Convert tabs to spaces
api.nvim_create_user_command("TabsToSpaces", function()
  local save = fn.winsaveview()
  vim.cmd([[%s/\t/  /ge]])
  fn.winrestview(save)
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
  else
    vim.diagnostic.disable()
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
  print(string.format("Startup time: %.3f ms", elapsed * 1000))
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
-- MANUAL FORMATTING
-- =============================================================================

-- Unified format command using external script
api.nvim_create_user_command("Format", function(opts)
  -- Save current view
  local save = fn.winsaveview()
  
  -- Save the file first to ensure script operates on latest content
  vim.cmd("silent! write")
  
  -- Build command
  local format_script = vim.fn.expand("~/.dotfiles/src/scripts/fixy")
  local current_file = vim.fn.expand("%:p")
  local cmd = { format_script }
  
  -- Parse arguments to convert to script flags
  local args = opts.args
  if args ~= "" then
    if args:find("trailing") then table.insert(cmd, "-t") end
    if args:find("tabs") then table.insert(cmd, "-T") end
    if args:find("quotes") then table.insert(cmd, "-q") end
    if args:find("formatters") then table.insert(cmd, "-f") end
    if args:find("all") then table.insert(cmd, "-a") end
  else
    -- Default to all operations
    table.insert(cmd, "-a")
  end
  
  -- Add the current file
  table.insert(cmd, current_file)
  
  -- Execute the format script
  local output = vim.fn.system(table.concat(cmd, " "))
  local exit_code = vim.v.shell_error
  
  -- Reload the buffer to show changes
  vim.cmd("silent! edit!")
  
  -- Restore view
  fn.winrestview(save)
  
  -- Show output
  if exit_code == 0 then
    print("Format: completed successfully")
  else
    print("Format: " .. output)
  end
end, { 
  nargs = "?",
  desc = "Format buffer with external script: trailing, tabs, quotes, formatters, all (default: all)",
  complete = function()
    return { "all", "trailing", "tabs", "quotes", "formatters" }
  end
})

-- =============================================================================
-- CLIPBOARD UTILITIES
-- =============================================================================

-- Debug clipboard settings
api.nvim_create_user_command("ClipboardInfo", function()
  print("Clipboard setting: " .. vim.o.clipboard)
  print("Has clipboard: " .. tostring(vim.fn.has("clipboard") == 1))
  print("Has unnamedplus: " .. tostring(vim.fn.has("unnamedplus") == 1))
  print("Clipboard global: " .. tostring(vim.g.clipboard))
  print("Loaded clipboard provider: " .. tostring(vim.g.loaded_clipboard_provider))
end, { desc = "Show clipboard configuration info" })

-- Debug yank performance
api.nvim_create_user_command("YankDebug", function()
  -- Test internal yank
  local start = vim.loop.hrtime()
  vim.cmd("normal! yy")
  local internal_time = (vim.loop.hrtime() - start) / 1e6
  
  print(string.format("Internal yank took: %.2fms", internal_time))
  print("Clipboard: " .. vim.o.clipboard)
  print("Timeout settings: timeout=" .. tostring(vim.o.timeout) .. " timeoutlen=" .. vim.o.timeoutlen .. " ttimeoutlen=" .. vim.o.ttimeoutlen)
end, { desc = "Debug yank performance" })

-- =============================================================================
-- CODE EXECUTION
-- =============================================================================

-- Run current file
api.nvim_create_user_command("RunFile", function()
  local ft = vim.bo.filetype
  local filename = vim.fn.expand("%")
  local cmd = ""
  
  -- Determine command based on filetype
  if ft == "python" then
    cmd = "python3 " .. vim.fn.shellescape(filename)
  elseif ft == "javascript" then
    cmd = "node " .. vim.fn.shellescape(filename)
  elseif ft == "typescript" then
    cmd = "ts-node " .. vim.fn.shellescape(filename)
  elseif ft == "lua" then
    cmd = "lua " .. vim.fn.shellescape(filename)
  elseif ft == "sh" or ft == "bash" then
    cmd = "bash " .. vim.fn.shellescape(filename)
  elseif ft == "c" then
    local output = vim.fn.tempname()
    cmd = string.format("gcc %s -o %s && %s", vim.fn.shellescape(filename), output, output)
  elseif ft == "cpp" then
    local output = vim.fn.tempname()
    cmd = string.format("g++ %s -o %s && %s", vim.fn.shellescape(filename), output, output)
  elseif ft == "rust" then
    cmd = "cargo run"
  elseif ft == "go" then
    cmd = "go run " .. vim.fn.shellescape(filename)
  elseif ft == "java" then
    local class_name = vim.fn.expand("%:t:r")
    cmd = string.format("javac %s && java %s", vim.fn.shellescape(filename), class_name)
  else
    vim.notify("No run command configured for filetype: " .. ft, vim.log.levels.WARN)
    return
  end
  
  -- Save and run
  vim.cmd("write")
  
  -- Create terminal in bottom split
  vim.cmd("botright new")
  vim.cmd("resize 15")
  vim.cmd("terminal " .. cmd)
  vim.cmd("startinsert")
end, { desc = "Run current file" })

-- =============================================================================
-- MESSAGES UTILITIES
-- =============================================================================

-- Clear messages
api.nvim_create_user_command("ClearMessages", function()
  vim.cmd("messages clear")
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

-- Tabline debugging is now handled by bufferline.nvim plugin
-- Use :BufferLineDebug for buffer line debugging

-- Bufferline refresh command
api.nvim_create_user_command("BufferLineRefresh", function()
  -- Force reload bufferline with current theme colors
  local ok, bufferline = pcall(require, "bufferline")
  if ok then
    -- Get fresh colors
    local colors = {}
    local theme_ok, theme = pcall(require, "tokyonight.colors")
    if theme_ok then
      colors = theme.setup()
      -- Force re-setup
      vim.schedule(function()
        vim.cmd("Lazy reload bufferline.nvim")
      end)
    end
    vim.notify("Bufferline refreshed with current theme")
  else
    vim.notify("Bufferline not loaded", vim.log.levels.WARN)
  end
end, { desc = "Refresh bufferline with current theme colors" })

-- Load this module from init.lua with: require('config.commands')
