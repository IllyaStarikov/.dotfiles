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

-- Load this module from init.lua with: require('config.commands')
