-- Debug logging system for Neovim configuration
-- Provides comprehensive logging for troubleshooting work environment issues

local M = {}

-- Log levels
M.levels = {
  TRACE = 0,
  DEBUG = 1,
  INFO = 2,
  WARN = 3,
  ERROR = 4,
  FATAL = 5,
}

-- Current log level (set by environment variable or default)
M.current_level = M.levels[vim.env.NVIM_LOG_LEVEL or "INFO"]

-- Log file path
M.log_file = vim.fn.expand("~/.local/state/nvim/work-debug.log")

-- Ensure log directory exists
local log_dir = vim.fn.fnamemodify(M.log_file, ":h")
if vim.fn.isdirectory(log_dir) == 0 then
  vim.fn.mkdir(log_dir, "p")
end

-- Format log message with timestamp and level
local function format_message(level, module, message)
  local timestamp = os.date("%Y-%m-%d %H:%M:%S")
  local level_name = ""
  for name, value in pairs(M.levels) do
    if value == level then
      level_name = name
      break
    end
  end
  return string.format("[%s] [%s] [%s] %s", timestamp, level_name, module or "GENERAL", message)
end

-- Write to log file
local function write_to_file(message)
  local file = io.open(M.log_file, "a")
  if file then
    file:write(message .. "\n")
    file:close()
  end
end

-- Main logging function
function M.log(level, module, message)
  -- Skip if below current log level
  if level < M.current_level then
    return
  end

  -- Format the message
  local formatted = format_message(level, module, message)

  -- Write to file if debug mode is enabled
  if vim.env.NVIM_DEBUG_WORK or vim.env.NVIM_DEBUG then
    write_to_file(formatted)
  end

  -- Also show in Neovim if it's a warning or error
  if level >= M.levels.WARN then
    local vim_level = vim.log.levels.INFO
    if level == M.levels.WARN then
      vim_level = vim.log.levels.WARN
    elseif level >= M.levels.ERROR then
      vim_level = vim.log.levels.ERROR
    end
    vim.notify(message, vim_level, { title = module or "Debug" })
  end
end

-- Convenience functions for different log levels
function M.trace(module, message)
  M.log(M.levels.TRACE, module, message)
end

function M.debug(module, message)
  M.log(M.levels.DEBUG, module, message)
end

function M.info(module, message)
  M.log(M.levels.INFO, module, message)
end

function M.warn(module, message)
  M.log(M.levels.WARN, module, message)
end

function M.error(module, message)
  M.log(M.levels.ERROR, module, message)
end

function M.fatal(module, message)
  M.log(M.levels.FATAL, module, message)
end

-- Log table/object for debugging
function M.inspect(module, label, object)
  M.debug(module, label .. ":\n" .. vim.inspect(object))
end

-- Check if debug mode is enabled
function M.is_debug_enabled()
  return vim.env.NVIM_DEBUG_WORK ~= nil or vim.env.NVIM_DEBUG ~= nil
end

-- Log work environment detection results
function M.log_work_detection()
  local work_init = require("work-init")
  local machine_type = work_init.detect_machine_type()
  local profile = work_init.get_profile()

  M.info("WORK-DETECTION", "Machine type: " .. machine_type)
  M.debug("WORK-DETECTION", "Work profile: " .. vim.inspect(profile))

  -- Log environment variables
  local env_vars = {
    "NVIM_DEBUG_WORK",
    "NVIM_DEBUG",
    "NVIM_LOG_LEVEL",
    "HOME",
    "USER",
    "HOSTNAME",
  }

  for _, var in ipairs(env_vars) do
    local value = vim.env[var] or "not set"
    M.debug("ENV", var .. " = " .. value)
  end

  -- Log package path
  M.debug("LUA", "package.path (first 500 chars):\n" .. package.path:sub(1, 500))

  -- Log vim globals related to work
  local work_globals = {
    "work_machine_type",
    "work_profile",
    "work_lsp_override",
    "google_lsp_active",
    "disable_standard_lsp",
  }

  for _, global in ipairs(work_globals) do
    local value = vim.g[global]
    if value ~= nil then
      M.debug("VIM-GLOBAL", "vim.g." .. global .. " = " .. tostring(value))
    end
  end
end

-- Log LSP configuration state
function M.log_lsp_state()
  M.info("LSP", "Logging LSP configuration state")

  -- Check if lspconfig is available
  local ok, lspconfig = pcall(require, "lspconfig")
  if not ok then
    M.error("LSP", "lspconfig not available: " .. tostring(lspconfig))
    return
  end

  -- Log available configs
  local configs = require("lspconfig.configs")
  local server_names = {}
  for name, _ in pairs(configs) do
    table.insert(server_names, name)
  end
  M.debug("LSP", "Available servers: " .. table.concat(server_names, ", "))

  -- Log active clients
  vim.defer_fn(function()
    local clients = vim.lsp.get_clients()
    if #clients == 0 then
      M.info("LSP", "No active LSP clients")
    else
      for _, client in ipairs(clients) do
        M.info("LSP", string.format("Active client: %s (id: %d)", client.name, client.id))
      end
    end
  end, 1000)
end

-- Clear the debug log
function M.clear_log()
  local file = io.open(M.log_file, "w")
  if file then
    file:close()
    M.info("DEBUG", "Log file cleared")
  end
end

-- View the debug log
function M.view_log()
  if vim.fn.filereadable(M.log_file) == 1 then
    vim.cmd("split " .. M.log_file)
    vim.cmd("setlocal autoread")
    vim.cmd("normal G")
  else
    vim.notify("No debug log found", vim.log.levels.WARN)
  end
end

-- Create user commands for debugging
function M.setup_commands()
  vim.api.nvim_create_user_command("DebugWork", function()
    M.log_work_detection()
    M.log_lsp_state()
    vim.notify("Work debugging information logged to " .. M.log_file, vim.log.levels.INFO)
  end, { desc = "Log work environment debugging information" })

  vim.api.nvim_create_user_command("DebugViewLog", function()
    M.view_log()
  end, { desc = "View the debug log file" })

  vim.api.nvim_create_user_command("DebugClearLog", function()
    M.clear_log()
  end, { desc = "Clear the debug log file" })

  vim.api.nvim_create_user_command("DebugLevel", function(opts)
    local level = opts.args:upper()
    if M.levels[level] then
      M.current_level = M.levels[level]
      vim.notify("Debug level set to " .. level, vim.log.levels.INFO)
    else
      vim.notify(
        "Invalid level. Use: TRACE, DEBUG, INFO, WARN, ERROR, or FATAL",
        vim.log.levels.ERROR
      )
    end
  end, {
    nargs = 1,
    complete = function()
      return { "TRACE", "DEBUG", "INFO", "WARN", "ERROR", "FATAL" }
    end,
    desc = "Set debug log level",
  })
end

-- Initialize the debug system
function M.init()
  -- Set up commands
  M.setup_commands()

  -- Log initialization if debug mode is enabled
  if M.is_debug_enabled() then
    M.info("DEBUG", "Debug logging system initialized")
    M.info("DEBUG", "Log file: " .. M.log_file)
    M.info("DEBUG", "Log level: " .. (vim.env.NVIM_LOG_LEVEL or "INFO"))

    -- Log initial work detection
    vim.defer_fn(function()
      M.log_work_detection()
    end, 100)
  end
end

return M
