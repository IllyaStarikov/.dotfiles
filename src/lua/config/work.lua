--
-- config/work.lua
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
    if vim.fn.filereadable(path) == 1 then
      local ok, err = pcall(dofile, path)
      if not ok then
        error("Failed to load " .. path .. ": " .. tostring(err))
      end
    end
  end
  
  if type(profile) == "string" then
    -- Simple string profile - load from profile directory
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
  
  -- Log successful profile load
  vim.schedule(function()
    vim.notify("Work profile loaded: " .. vim.g.work_profile, vim.log.levels.INFO)
  end)
  
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

return M