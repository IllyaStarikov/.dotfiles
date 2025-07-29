--
-- LuaSnip Configuration
-- Advanced snippet engine setup with custom snippets
--

local M = {}

function M.setup()
  local ok, luasnip = pcall(require, "luasnip")
  if not ok then
    vim.notify("LuaSnip not found", vim.log.levels.ERROR)
    return
  end

  -- Configure LuaSnip
  luasnip.config.set_config({
    -- Keep snippets around after leaving snippet region
    history = true,
    
    -- Dynamic snippets update as you type
    updateevents = "TextChanged,TextChangedI",
    
    -- Autosnippets
    enable_autosnippets = true,
    
    -- Use Tab to expand and jump in snippets
    region_check_events = "CursorMoved",
  })

  -- Load snippets from friendly-snippets
  require("luasnip.loaders.from_vscode").lazy_load()
  
  -- Load custom snippets
  local snippet_path = vim.fn.stdpath("config") .. "/snippets"
  
  -- Load Lua snippets
  require("luasnip.loaders.from_lua").lazy_load({
    paths = { snippet_path }
  })
  
  -- Keymaps for snippet navigation
  -- Tab handling: blink.cmp takes priority, then falls back to LuaSnip
  vim.keymap.set({"i", "s"}, "<Tab>", function()
    -- If we can expand or jump in a snippet, do that
    if luasnip.expand_or_jumpable() then
      luasnip.expand_or_jump()
    else
      -- Otherwise, let blink.cmp handle it (fallback)
      return "<Tab>"
    end
  end, { expr = true, silent = true })
  
  vim.keymap.set({"i", "s"}, "<S-Tab>", function()
    if luasnip.jumpable(-1) then
      luasnip.jump(-1)
    else
      return "<S-Tab>"
    end
  end, { expr = true, silent = true })
  
  -- Alternative keys for snippet navigation
  vim.keymap.set({"i", "s"}, "<C-l>", function()
    if luasnip.expand_or_jumpable() then
      luasnip.expand_or_jump()
    end
  end, { silent = true, desc = "Expand snippet or jump forward" })
  
  vim.keymap.set({"i", "s"}, "<C-h>", function()
    if luasnip.jumpable(-1) then
      luasnip.jump(-1)
    end
  end, { silent = true, desc = "Jump backward in snippet" })
  
  -- Choice selection
  vim.keymap.set({"i", "s"}, "<C-j>", function()
    if luasnip.choice_active() then
      luasnip.change_choice(1)
    end
  end, { silent = true })
  
  vim.keymap.set({"i", "s"}, "<C-k>", function()
    if luasnip.choice_active() then
      luasnip.change_choice(-1)
    end
  end, { silent = true })
  
  -- Snippet list
  vim.keymap.set("n", "<leader>sl", function()
    require("telescope").extensions.luasnip.luasnip()
  end, { desc = "Show available snippets" })
end

return M