-- Sample Lua file for LSP testing

local M = {}

-- Simple function with documentation
---@param x number First number
---@param y number Second number
---@return number result The sum of x and y
function M.add(x, y)
    return x + y
end

-- Function with table parameter
---@param config table Configuration options
---@field name string The name
---@field enabled boolean Whether enabled
---@return boolean success
function M.configure(config)
    if not config.name then
        return false
    end

    -- Incomplete line for completion testing
    local result = config.

    return config.enabled or false
end

-- Class-like structure
---@class Calculator
---@field value number Current value
local Calculator = {}
Calculator.__index = Calculator

---@return Calculator
function Calculator.new()
    local self = setmetatable({}, Calculator)
    self.value = 0
    return self
end

---@param amount number
function Calculator:add(amount)
    self.value = self.value + amount
end

-- Intentional errors for diagnostic testing
function M.broken_function()
    local undefined_var = unknown_global

    -- Type mismatch
    local str = "hello"
    local num = str + 5  -- Error: attempt to perform arithmetic on string

    -- Missing 'then'
    if true
        print("missing then")
    end
end

-- Table with methods for completion testing
M.utils = {
    format = function(str) return string.format("%s", str) end,
    split = function(str, sep)
        -- Incomplete for testing
        return vim.
    end,
}

-- Test requiring another module
local status_ok, telescope = pcall(require, "telescope")
if status_ok then
    -- Test telescope completion
    telescope.
end

return M
