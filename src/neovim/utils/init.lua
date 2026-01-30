--
-- utils/init.lua
-- Utility functions for error handling and common operations
--

local M = {}

-- Safe require with error handling
-- Returns the module and a success boolean
-- Usage: local module, ok = utils.safe_require("module_name")
function M.safe_require(module_name)
  local ok, module = pcall(require, module_name)
  if not ok then
    vim.notify(
      string.format("Failed to load module: %s\n%s", module_name, module),
      vim.log.levels.ERROR,
      { title = "Module Load Error" }
    )
    return nil, false
  end
  return module, true
end

-- Silent require (no error notification)
-- Useful for optional modules
function M.silent_require(module_name)
  local ok, module = pcall(require, module_name)
  if ok then
    return module, true
  end
  return nil, false
end

-- Protected function call with error notification
-- Usage: utils.protected_call(fn, "Description", arg1, arg2, ...)
function M.protected_call(fn, description, ...)
  local ok, result = pcall(fn, ...)
  if not ok then
    vim.notify(
      string.format("Error in %s:\n%s", description or "function call", result),
      vim.log.levels.ERROR,
      { title = "Runtime Error" }
    )
    return nil, false
  end
  return result, true
end

-- Setup plugin with error handling
-- Usage: utils.setup_plugin("plugin_name", config_table)
function M.setup_plugin(plugin_name, config)
  local plugin, ok = M.safe_require(plugin_name)
  if ok and plugin and plugin.setup then
    local setup_ok = M.protected_call(plugin.setup, plugin_name .. ".setup", config)
    if setup_ok then
      return plugin, true
    end
  end
  return nil, false
end

-- Try multiple module names (for plugins with different module paths)
-- Usage: utils.try_require({"telescope", "telescope.nvim"})
function M.try_require(module_names)
  for _, name in ipairs(module_names) do
    local module, ok = M.silent_require(name)
    if ok then
      return module, true
    end
  end
  vim.notify(
    string.format("Failed to load any of: %s", table.concat(module_names, ", ")),
    vim.log.levels.ERROR,
    { title = "Module Load Error" }
  )
  return nil, false
end

-- Create a protected keymap that checks if plugin exists
-- Usage: utils.safe_keymap("n", "<leader>ff", "telescope.builtin", "find_files", { desc = "Find Files" })
function M.safe_keymap(mode, lhs, module_name, method_name, opts)
  vim.keymap.set(mode, lhs, function()
    local module, ok = M.silent_require(module_name)
    if ok and module and module[method_name] then
      module[method_name](opts and opts.args or {})
    else
      vim.notify(
        string.format("Plugin not available: %s", module_name),
        vim.log.levels.WARN,
        { title = "Keymap Error" }
      )
    end
  end, opts or {})
end

-- Load config module with fallback
-- Usage: utils.load_config("plugins.telescope", fallback_function)
function M.load_config(module_name, fallback)
  local module, ok = M.safe_require(module_name)
  if ok then
    if type(module) == "table" and module.setup then
      return module.setup()
    elseif type(module) == "function" then
      return module()
    end
    return module
  elseif fallback then
    return fallback()
  end
  return nil
end

-- Batch require with error collection
-- Returns loaded modules and any errors
function M.batch_require(module_names)
  local loaded = {}
  local errors = {}

  for _, name in ipairs(module_names) do
    local module, ok = M.silent_require(name)
    if ok then
      loaded[name] = module
    else
      table.insert(errors, name)
    end
  end

  if #errors > 0 then
    vim.notify(
      string.format("Failed to load modules:\n%s", table.concat(errors, "\n")),
      vim.log.levels.WARN,
      { title = "Module Load Errors" }
    )
  end

  return loaded, errors
end

return M
