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
    -- Custom keymap that works with LuaSnip
    keymap = {
      preset = 'enter',
      ['<C-space>'] = { 'show', 'show_documentation', 'hide_documentation' },
      ['<C-e>'] = { 'hide' },
      ['<C-p>'] = { 'select_prev', 'fallback' },
      ['<C-n>'] = { 'select_next', 'fallback' },
      ['<C-k>'] = { 'select_prev', 'fallback' },
      ['<C-j>'] = { 'select_next', 'fallback' },
      ['<C-u>'] = { 'scroll_documentation_up', 'fallback' },
      ['<C-d>'] = { 'scroll_documentation_down', 'fallback' },
      -- Tab accepts completion when menu is visible
      ['<Tab>'] = { 'accept', 'fallback' },
      ['<S-Tab>'] = { 'select_prev', 'fallback' },
    },
    
    -- Enable snippets
    sources = {
      default = { 'lsp', 'path', 'snippets', 'buffer' },
      providers = {
        snippets = {
          module = 'blink.cmp.sources.snippets',
          score_offset = -3,
        },
      },
    },
    
    -- Fuzzy matching - skip binary download
    fuzzy = {
      prebuilt_binaries = {
        download = false,
        ignore_version_mismatch = true,
      },
    },
  })
end

return M