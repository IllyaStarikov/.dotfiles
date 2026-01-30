--
-- work.lua
-- Work-specific override system using .dotfiles.private repository
--

local M = {}

-- Work config path - uses the private repo
local WORK_CONFIG_PATH = vim.fn.expand("~/.dotfiles/.dotfiles.private")

-- Load HOSTS configuration from private repo
local function load_hosts_config()
  local hosts_file = WORK_CONFIG_PATH .. "/HOSTS"
  if vim.fn.filereadable(hosts_file) == 0 then
    return nil
  end

  local ok, content = pcall(vim.fn.readfile, hosts_file)
  if not ok then
    return nil
  end

  local json_str = table.concat(content, "\n")
  local ok_json, hosts = pcall(vim.json.decode, json_str)
  if not ok_json then
    -- Skip on parse errors (no notification to avoid noise on missing private repo)
    return nil
  end

  return hosts
end

-- Get work profile based on hostname
local function get_work_profile()
  -- Check HOSTS file for profile mapping
  local hosts = load_hosts_config()
  if not hosts then
    return nil
  end

  local hostname = vim.fn.hostname()

  -- Direct hostname match
  if hosts[hostname] then
    return hosts[hostname]
  end

  -- Try pattern matching for wildcards
  for pattern, profile in pairs(hosts) do
    -- Convert simple wildcards to Lua patterns
    local lua_pattern = pattern:gsub("*", ".*")
    if hostname:match("^" .. lua_pattern .. "$") then
      return profile
    end
  end

  return nil
end

-- Load work-specific vim configuration
local function load_work_vimrc(profile)
  local function safe_dofile(path)
    -- Validate path is within the expected directory
    local resolved_path = vim.fn.resolve(path)
    local expected_base = vim.fn.resolve(WORK_CONFIG_PATH)

    -- Security check: ensure the file is within the work config directory
    if not vim.startswith(resolved_path, expected_base) then
      error("Security violation: Attempted to load file outside work config directory")
    end

    if vim.fn.filereadable(path) == 1 then
      local ok, err = pcall(dofile, path)
      if not ok then
        error("Failed to load " .. path .. ": " .. tostring(err))
      end
    end
  end

  if type(profile) == "string" then
    -- Simple string profile - load from profile directory
    -- Try work_nvim.lua first (preferred naming)
    local work_nvim_path = WORK_CONFIG_PATH .. "/" .. profile .. "/work_nvim.lua"
    if vim.fn.filereadable(work_nvim_path) == 1 then
      local ok, work_config = pcall(dofile, work_nvim_path)
      if ok and work_config and work_config.setup then
        work_config.setup()
        return
      end
    end

    -- Fall back to vimrc.lua (legacy naming)
    local vimrc_path = WORK_CONFIG_PATH .. "/" .. profile .. "/vimrc.lua"
    safe_dofile(vimrc_path)
  elseif type(profile) == "table" then
    -- Complex profile with specific settings
    if profile.vimrc then
      local vimrc_path = WORK_CONFIG_PATH .. "/" .. profile.vimrc
      safe_dofile(vimrc_path)
    end

    -- Load additional modules if specified
    if profile.modules then
      for _, module in ipairs(profile.modules) do
        local module_path = WORK_CONFIG_PATH .. "/" .. module
        safe_dofile(module_path)
      end
    end
  end
end

-- Apply work-specific overrides
function M.apply_overrides()
  -- Check if private repo exists
  if vim.fn.isdirectory(WORK_CONFIG_PATH) == 0 then
    -- Silently return - private repo is optional
    return
  end

  local profile = get_work_profile()
  if not profile then
    -- No profile matches this hostname
    return
  end

  -- Set global indicators
  vim.g.work_profile = type(profile) == "table" and profile.name or profile
  vim.g.work_config_dir = WORK_CONFIG_PATH

  -- Load work-specific configurations with error handling
  local ok, err = pcall(load_work_vimrc, profile)
  if not ok then
    vim.notify("Failed to load work profile: " .. tostring(err), vim.log.levels.ERROR)
    return
  end

  -- Don't log here - the work_nvim.lua will handle the notification

  -- Source shell aliases if they exist
  local aliases_path
  if type(profile) == "string" then
    aliases_path = WORK_CONFIG_PATH .. "/" .. profile .. "/aliases.sh"
  elseif type(profile) == "table" and profile.aliases then
    aliases_path = WORK_CONFIG_PATH .. "/" .. profile.aliases
  end

  if aliases_path and vim.fn.filereadable(aliases_path) == 1 then
    vim.g.work_aliases_path = aliases_path
  end
end

-- Get current work profile info
function M.get_profile()
  return {
    profile = vim.g.work_profile,
    config_dir = vim.g.work_config_dir,
    aliases_path = vim.g.work_aliases_path,
  }
end

-- Check if running in work environment
function M.is_work_env()
  return vim.g.work_profile ~= nil
end

-- Force reload work configuration (useful for debugging)
function M.reload()
  -- Clear existing work indicators
  vim.g.work_profile = nil
  vim.g.work_config_dir = nil
  vim.g.work_aliases_path = nil
  vim.g.work_lsp_override = nil

  -- Reapply overrides
  M.apply_overrides()

  if M.is_work_env() then
    vim.notify("Work configuration reloaded: " .. vim.g.work_profile, vim.log.levels.INFO)
  else
    vim.notify("No work profile detected for this machine", vim.log.levels.WARN)
  end
end

-- Create user command for easy reloading
vim.api.nvim_create_user_command("WorkReload", function()
  M.reload()
end, { desc = "Reload work-specific configuration" })

-- Create user command to check work status
vim.api.nvim_create_user_command("WorkStatus", function()
  if M.is_work_env() then
    local info = M.get_profile()
    vim.notify(
      string.format(
        "Work Profile: %s\nConfig Dir: %s\nAliases: %s\nLSP Override: %s",
        info.profile or "none",
        info.config_dir or "none",
        info.aliases_path or "none",
        vim.g.work_lsp_override and "active" or "inactive"
      ),
      vim.log.levels.INFO,
      { title = "Work Environment Status" }
    )
  else
    vim.notify("No work environment detected", vim.log.levels.INFO)
  end
end, { desc = "Show work environment status" })

return M
