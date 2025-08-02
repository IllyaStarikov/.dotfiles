--
-- LuaSnip Configuration
-- Advanced snippet engine setup with custom snippets
--
-- IMPORTANT: We exclude languages from friendly-snippets where we have custom
-- snippets to avoid duplicates. Custom snippets take priority and are more
-- tailored to our workflow and Google Style Guide compliance.
--

local M = {}

function M.setup()
  local ok, luasnip = pcall(require, "luasnip")
  if not ok then
    vim.notify("LuaSnip not found", vim.log.levels.ERROR)
    return
  end

  -- Setup jsregexp for transform snippets (if available)
  -- Load jsregexp module (for snippet transformations)
  local jsregexp_ok = pcall(function()
    luasnip.setup_jsregexp()
  end)
  if not jsregexp_ok then
    -- Try alternate method if first fails
    pcall(require, "luasnip.jsregexp")
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
    region_check_events = "CursorMoved"
  })

  -- Load snippets from friendly-snippets
  -- Exclude languages where we have custom snippets to avoid duplicates
  require("luasnip.loaders.from_vscode").lazy_load({
    exclude = { "python", "cpp", "c", "java", "javascript", "html", "sh", "markdown", "tex", "todo" }
  })
  
  -- Load custom snippets
  local snippet_path = vim.fn.stdpath("config") .. "/snippets"
  
  -- Load Lua snippets (these take priority over VSCode snippets)
  require("luasnip.loaders.from_lua").lazy_load({
    paths = { snippet_path }
  })
  
  -- Keymaps for snippet navigation
  -- NOTE: Tab/S-Tab are now handled by blink.cmp to avoid conflicts
  -- Blink.cmp will call LuaSnip for snippet expansion/jumping automatically
  
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