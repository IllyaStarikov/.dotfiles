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
    -- Default keymap preset includes:
    -- <Tab> / <S-Tab> - navigate items
    -- <CR> - accept
    -- <C-e> - hide
    -- <C-space> - show
    keymap = { preset = 'default' },
    
    -- Sources - use all defaults
    sources = {
      default = { 'lsp', 'path', 'buffer', 'snippets' },
    },
    
    -- Enable in all modes except specific filetypes
    enabled = function()
      return not vim.tbl_contains(
        { "TelescopePrompt", "oil" },
        vim.bo.filetype
      )
    end,
  })
end

return M