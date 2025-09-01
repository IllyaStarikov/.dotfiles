-- Fixy formatter integration for Neovim
-- Provides async formatting with the fixy script

local M = {}

-- Configuration
local config = {
  enabled = true, -- Auto-format enabled by default
  cmd = vim.fn.expand("~/.dotfiles/src/scripts/fixy"),
  timeout = 5000, -- 5 seconds timeout
  notifications = true,
}

-- Check if fixy command exists
local function fixy_exists()
  return vim.fn.executable(config.cmd) == 1
end

-- Format the current buffer with fixy
function M.format_buffer()
  if not fixy_exists() then
    if config.notifications then
      vim.notify("Fixy not found at: " .. config.cmd, vim.log.levels.ERROR)
    end
    return
  end

  local filepath = vim.fn.expand("%:p")
  if filepath == "" then
    if config.notifications then
      vim.notify("No file to format", vim.log.levels.WARN)
    end
    return
  end

  -- Save cursor position and view
  local cursor = vim.api.nvim_win_get_cursor(0)
  local view = vim.fn.winsaveview()

  -- Run fixy asynchronously
  local job_id = vim.fn.jobstart({config.cmd, filepath}, {
    on_exit = function(_, exit_code, _)
      vim.schedule(function()
        if exit_code == 0 then
          -- Reload the buffer to get the formatted content
          -- Use silent to avoid messages
          vim.cmd("silent! checktime")
          vim.cmd("silent! edit!")
          
          -- Restore cursor position and view
          pcall(vim.fn.winrestview, view)
          pcall(vim.api.nvim_win_set_cursor, 0, cursor)
          
          if config.notifications then
            vim.notify("Formatted with fixy", vim.log.levels.INFO)
          end
        else
          if config.notifications then
            vim.notify("Fixy formatting failed (exit code: " .. exit_code .. ")", vim.log.levels.ERROR)
          end
        end
      end)
    end,
    on_stderr = function(_, data, _)
      if data and #data > 0 and data[1] ~= "" then
        vim.schedule(function()
          if config.notifications then
            vim.notify("Fixy error: " .. table.concat(data, "\n"), vim.log.levels.ERROR)
          end
        end)
      end
    end,
  })

  if job_id <= 0 then
    if config.notifications then
      vim.notify("Failed to start fixy", vim.log.levels.ERROR)
    end
  end
end

-- Format on save if auto-format is enabled
function M.format_on_save()
  if config.enabled then
    M.format_buffer()
  end
end

-- Toggle auto-formatting
function M.toggle_auto()
  config.enabled = not config.enabled
  local status = config.enabled and "enabled" or "disabled"
  vim.notify("Fixy auto-format " .. status, vim.log.levels.INFO)
end

-- Enable auto-formatting
function M.enable_auto()
  config.enabled = true
  vim.notify("Fixy auto-format enabled", vim.log.levels.INFO)
end

-- Disable auto-formatting
function M.disable_auto()
  config.enabled = false
  vim.notify("Fixy auto-format disabled", vim.log.levels.INFO)
end

-- Get current status
function M.status()
  return config.enabled
end

-- Setup function to initialize fixy integration
function M.setup(opts)
  opts = opts or {}
  
  -- Merge user config
  config = vim.tbl_deep_extend("force", config, opts)
  
  -- Create commands
  vim.api.nvim_create_user_command("Fixy", function()
    M.format_buffer()
  end, { desc = "Format current file with fixy" })
  
  vim.api.nvim_create_user_command("FixyAuto", function()
    M.toggle_auto()
  end, { desc = "Toggle fixy auto-format on save" })
  
  vim.api.nvim_create_user_command("FixyAutoOn", function()
    M.enable_auto()
  end, { desc = "Enable fixy auto-format on save" })
  
  vim.api.nvim_create_user_command("FixyAutoOff", function()
    M.disable_auto()
  end, { desc = "Disable fixy auto-format on save" })
  
  vim.api.nvim_create_user_command("FixyStatus", function()
    local status = config.enabled and "enabled" or "disabled"
    vim.notify("Fixy auto-format is " .. status, vim.log.levels.INFO)
  end, { desc = "Show fixy auto-format status" })
  
  -- Set up autocommand for format on save
  local augroup = vim.api.nvim_create_augroup("FixyAutoFormat", { clear = true })
  
  vim.api.nvim_create_autocmd("BufWritePost", {
    group = augroup,
    pattern = "*",
    callback = function()
      -- Skip certain file types and special buffers
      local ft = vim.bo.filetype
      local buftype = vim.bo.buftype
      
      -- Skip special buffers
      if buftype ~= "" then
        return
      end
      
      -- Skip certain filetypes (you can customize this list)
      local skip_filetypes = {
        "gitcommit",
        "gitrebase",
        "svn",
        "hgcommit",
        "oil",
        "TelescopePrompt",
        "TelescopeResults",
        "dashboard",
        "alpha",
        "NvimTree",
        "neo-tree",
      }
      
      for _, skip_ft in ipairs(skip_filetypes) do
        if ft == skip_ft then
          return
        end
      end
      
      -- Format the file
      M.format_on_save()
    end,
    desc = "Auto-format with fixy on save",
  })
  
  -- Optionally set up keybinding
  vim.keymap.set("n", "<leader>cf", M.format_buffer, { desc = "Format with fixy" })
end

-- Auto-initialize on module load
M.setup()

return M