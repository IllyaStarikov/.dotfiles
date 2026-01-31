-- Work initialization helper module
-- This module handles early initialization of work-specific configurations
-- with comprehensive error handling and fallback mechanisms

local M = {}

-- Cache the machine type detection result
local cached_machine_type = nil

-- Safe dofile with error handling
local function safe_dofile(path)
  if vim.fn.filereadable(path) == 1 then
    local ok, result = pcall(dofile, path)
    if ok then
      return result
    elseif vim.env.NVIM_DEBUG_WORK then
      vim.notify("Failed to load file: " .. path .. "\n" .. tostring(result), vim.log.levels.WARN)
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
  local private_dir = vim.g.dotfiles .. "/.dotfiles.private"
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

  -- Method 4: Check hosts.json patterns from private dotfiles
  -- Hostname patterns are stored in private dotfiles to avoid exposing work machine names
  local hosts_file = private_dir .. "/config/hosts.json"
  if vim.fn.filereadable(hosts_file) == 1 then
    local hostname = vim.fn.hostname()
    local ok, hosts_content = pcall(vim.fn.readfile, hosts_file)
    if ok and hosts_content then
      local json_str = table.concat(hosts_content, "\n")
      local decode_ok, hosts = pcall(vim.fn.json_decode, json_str)
      if decode_ok and hosts then
        for pattern, company in pairs(hosts) do
          -- Convert glob pattern to Lua pattern
          -- * -> .* (any chars), ? -> . (one char), . -> %.(literal dot)
          local lua_pattern = pattern:gsub("%.", "%%."):gsub("%*", ".*"):gsub("%?", ".")
          lua_pattern = "^" .. lua_pattern .. "$"
          if hostname:match(lua_pattern) then
            cached_machine_type = company
            vim.g.work_machine_type = cached_machine_type
            return cached_machine_type
          end
        end
      end
    end
  end

  -- Default to personal (no private dotfiles or no pattern match)
  cached_machine_type = "personal"
  vim.g.work_machine_type = cached_machine_type
  return cached_machine_type
end

-- Initialize work environment
function M.init()
  local machine_type = M.detect_machine_type()

  if vim.env.NVIM_DEBUG_WORK then
    vim.notify("Work init: Detected machine type: " .. machine_type, vim.log.levels.INFO)
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
  local work_init_path = vim.g.dotfiles .. "/.dotfiles.private/" .. machine_type .. "/init.lua"
  local work_init = safe_dofile(work_init_path)
  if work_init and work_init.setup then
    local ok, err = pcall(work_init.setup)
    if not ok and vim.env.NVIM_DEBUG_WORK then
      vim.notify("Work init setup failed: " .. tostring(err), vim.log.levels.WARN)
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
