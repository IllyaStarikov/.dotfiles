-- Work initialization helper module
-- This module handles early initialization of work-specific configurations
-- with comprehensive error handling and fallback mechanisms

local M = {}

-- Cache the machine type detection result
local cached_machine_type = nil

-- Check if a module can be loaded
local function can_require(module_name)
  local ok = pcall(require, module_name)
  return ok
end

-- Safe dofile with error handling
local function safe_dofile(path)
  if vim.fn.filereadable(path) == 1 then
    local ok, result = pcall(dofile, path)
    if ok then
      return result
    elseif vim.env.NVIM_DEBUG_WORK then
      vim.notify(
        "Failed to load file: " .. path .. "\n" .. tostring(result),
        vim.log.levels.WARN
      )
    end
  end
  return nil
end

-- Detect machine type with multiple fallback mechanisms
function M.detect_machine_type()
  -- Return cached result if available
  if cached_machine_type then
    return cached_machine_type
  end

  -- Method 1: Check vim.g.work_machine_type (may be set by private init)
  if vim.g.work_machine_type then
    cached_machine_type = vim.g.work_machine_type
    return cached_machine_type
  end

  -- Method 2: Try to load machine-detection module
  local private_dir = vim.fn.expand("~/.dotfiles/.dotfiles.private")
  package.path = package.path .. ";" .. private_dir .. "/?.lua"

  local ok, detection = pcall(require, "machine-detection")
  if ok and detection and detection.get_machine_type then
    cached_machine_type = detection.get_machine_type()
    vim.g.work_machine_type = cached_machine_type
    return cached_machine_type
  end

  -- Method 3: Try to run check-machine.sh script
  local check_script = private_dir .. "/check-machine.sh"
  if vim.fn.executable(check_script) == 1 then
    local result = vim.fn.system(check_script)
    if vim.v.shell_error == 0 then
      cached_machine_type = vim.fn.trim(result)
      vim.g.work_machine_type = cached_machine_type
      return cached_machine_type
    end
  end

  -- Method 4: Check hostname patterns directly
  local hostname = vim.fn.hostname()
  if
    hostname:match("%.corp%.google%.com$")
    or hostname:match("%.c%.googlers%.com$")
    or hostname:match("^cloudtop%-")
  then
    cached_machine_type = "google"
    vim.g.work_machine_type = cached_machine_type
    return cached_machine_type
  elseif
    hostname:match("DELL%-PRECISION")
    or hostname:match("%.garmin%.com$")
  then
    cached_machine_type = "garmin"
    vim.g.work_machine_type = cached_machine_type
    return cached_machine_type
  end

  -- Default to personal
  cached_machine_type = "personal"
  vim.g.work_machine_type = cached_machine_type
  return cached_machine_type
end

-- Initialize work environment
function M.init()
  local machine_type = M.detect_machine_type()

  if vim.env.NVIM_DEBUG_WORK then
    vim.notify(
      "Work init: Detected machine type: " .. machine_type,
      vim.log.levels.INFO
    )
  end

  -- Skip if personal machine
  if machine_type == "personal" then
    return false
  end

  -- Set work environment flags
  vim.g.work_machine_type = machine_type
  vim.g.work_profile = machine_type
  vim.g.work_lsp_override = true

  -- Load work-specific init if available
  local work_init_path = vim.fn.expand(
    "~/.dotfiles/.dotfiles.private/" .. machine_type .. "/init.lua"
  )
  local work_init = safe_dofile(work_init_path)
  if work_init and work_init.setup then
    local ok, err = pcall(work_init.setup)
    if not ok and vim.env.NVIM_DEBUG_WORK then
      vim.notify(
        "Work init setup failed: " .. tostring(err),
        vim.log.levels.WARN
      )
    end
  end

  return true
end

-- Check if we're in a work environment
function M.is_work_env()
  local machine_type = M.detect_machine_type()
  return machine_type ~= "personal" and machine_type ~= "unknown"
end

-- Get the current work profile
function M.get_profile()
  if M.is_work_env() then
    return {
      type = M.detect_machine_type(),
      active = true,
      lsp_override = vim.g.work_lsp_override,
    }
  end
  return {
    type = "personal",
    active = false,
    lsp_override = false,
  }
end

return M
