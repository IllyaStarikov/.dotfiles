--
-- config/blink-simple.lua  
-- Minimal blink.cmp configuration
--

local M = {}

function M.setup()
  local ok, blink = pcall(require, 'blink.cmp')
  if not ok then
    vim.notify("blink.cmp not found", vim.log.levels.ERROR)
    return
  end
  
  -- Minimal setup - let blink.cmp use its smart defaults
  blink.setup({
    -- Just use all defaults - blink.cmp works out of the box
    keymap = { preset = 'default' },
    
    -- Fuzzy matching - skip binary download
    fuzzy = {
      prebuilt_binaries = {
        download = false,
      },
    },
  })
end

return M