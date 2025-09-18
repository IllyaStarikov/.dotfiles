--
-- config/error-handler.lua
-- Global error handling for Neovim configuration
--

local M = {}
local compat = require("config.compat")

-- Store original notify function
local original_notify = vim.notify

-- Track error frequency to prevent spam
local error_counts = {}
local error_window = 60 -- seconds

-- Custom notify function with error throttling
function M.setup_notify()
  vim.notify = function(msg, level, opts)
    -- Convert level to number if it's not already
    level = level or vim.log.levels.INFO
    if type(level) == "string" then
      level = vim.log.levels[level:upper()] or vim.log.levels.INFO
    end

    -- Filter out known Google vim plugin errors that are harmless
    if type(msg) == "string" then
      -- Skip known harmless errors from Google vim plugins
      if msg:match("AutoFormatBuffer") and msg:match("Not an editor command") then
        -- AutoFormatBuffer not available yet, skip error
        return
      end
      if msg:match("ERROR%(NotFound%): plugin or package csimporter") then
        -- csimporter not available, skip error
        return
      end
      if msg:match("Error parsing Glug settings") then
        -- Glug parsing errors for comments, skip
        return
      end
    end

    -- For errors, check if we should throttle
    if level == vim.log.levels.ERROR then
      local now = os.time()
      local error_key = msg:sub(1, 50) -- Use first 50 chars as key

      if error_counts[error_key] then
        local last_time, count = error_counts[error_key].time, error_counts[error_key].count
        if now - last_time < error_window then
          error_counts[error_key].count = count + 1
          -- Only show every 5th occurrence within the window
          if count % 5 ~= 0 then
            return
          end
          msg = msg .. string.format(" (occurred %d times)", count)
        else
          -- Reset counter after window expires
          error_counts[error_key] = { time = now, count = 1 }
        end
      else
        error_counts[error_key] = { time = now, count = 1 }
      end
    end

    -- Call original notify
    original_notify(msg, level, opts)
  end
end

-- Setup global error handler
function M.setup_error_handler()
  -- Handle errors in scheduled callbacks
  local schedule_wrap = vim.schedule_wrap
  vim.schedule_wrap = function(fn)
    return schedule_wrap(function(...)
      local ok, err = pcall(fn, ...)
      if not ok then
        vim.notify(
          string.format("Error in scheduled callback:\n%s", err),
          vim.log.levels.ERROR,
          { title = "Async Error" }
        )
      end
    end)
  end

  -- Log startup errors
  compat.create_autocmd("VimEnter", {
    callback = function()
      -- Check for any startup errors
      local messages = compat.exec2("messages", { output = true })
      if messages.output:match("E%d+:") or messages.output:match("Error") then
        -- Save startup errors to a file for debugging
        local error_file = vim.fn.stdpath("state") .. "/startup_errors.log"
        local file = io.open(error_file, "a")
        if file then
          file:write(string.format("\n=== Startup Errors %s ===\n", os.date()))
          file:write(messages.output)
          file:write("\n")
          file:close()
        end
      end
    end,
  })
end

-- Safe execution wrapper for user commands
function M.safe_command(name, fn, opts)
  compat.create_user_command(name, function(...)
    local ok, err = pcall(fn, ...)
    if not ok then
      vim.notify(
        string.format("Error in command %s:\n%s", name, err),
        vim.log.levels.ERROR,
        { title = "Command Error" }
      )
    end
  end, opts or {})
end

-- Safe keymap wrapper
function M.safe_keymap(mode, lhs, rhs, opts)
  local wrapped_rhs = function()
    local ok, err = pcall(type(rhs) == "function" and rhs or function()
      vim.cmd(rhs)
    end)
    if not ok then
      vim.notify(
        string.format("Error in keymap %s:\n%s", lhs, err),
        vim.log.levels.ERROR,
        { title = "Keymap Error" }
      )
    end
  end

  vim.keymap.set(mode, lhs, wrapped_rhs, opts)
end

-- Initialize error handling
function M.init()
  M.setup_notify()
  M.setup_error_handler()

  -- Add command to view error log
  compat.create_user_command("ErrorLog", function()
    local error_file = vim.fn.stdpath("state") .. "/startup_errors.log"
    if vim.fn.filereadable(error_file) == 1 then
      vim.cmd("split " .. error_file)
    else
      vim.notify("No error log found", vim.log.levels.INFO)
    end
  end, { desc = "View startup error log" })

  -- Add command to clear error counts
  compat.create_user_command("ClearErrorCounts", function()
    error_counts = {}
    vim.notify("Error counts cleared", vim.log.levels.INFO)
  end, { desc = "Clear error throttling counts" })
end

return M
