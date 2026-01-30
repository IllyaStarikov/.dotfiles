--
-- snacks.lua
-- HIGH-PERFORMANCE snacks.nvim configuration
-- Comprehensive productivity and quality-of-life features
--

local M = {}

function M.setup()
  -- Enable Snacks.nvim with file explorer support
  local ok, snacks = pcall(require, "snacks")
  if not ok then
    vim.notify("Failed to load snacks.nvim", vim.log.levels.WARN)
    return
  end

  ---@diagnostic disable-next-line: redundant-parameter
  snacks.setup({
    -- Core modules
    bigfile = { enabled = true },

    -- Picker configuration with vim.ui overrides
    picker = {
      enabled = true,
    },

    explorer = {
      enabled = true,
      replace_netrw = true, -- Replace netrw with Snacks explorer
    },

    -- Dashboard configuration with proper setup
    dashboard = {
      enabled = true,
      width = 60,
      preset = {
        keys = {
          { icon = "\u{f15b}", key = "n", desc = "New File", action = ":enew" },
          {
            icon = "\u{f0f6}",
            key = "x",
            desc = "Scratch",
            action = function()
              Snacks.scratch()
            end,
          },
          {
            icon = "\u{f120}",
            key = "p",
            desc = "Scratchpad",
            action = function()
              vim.ui.input({ prompt = "Extension: " }, function(ext)
                if ext and ext ~= "" then
                  local filename = "/tmp/scratch-" .. os.time() .. "." .. ext
                  vim.cmd("edit " .. filename)
                end
              end)
            end,
          },
          {
            icon = "\u{f1da}",
            key = "s",
            desc = "Restore Session",
            action = function()
              require("persistence").load()
            end,
          },
          { icon = "\u{f487}", key = "l", desc = "Lazy", action = ":Lazy" },
        },
      },
      sections = {
        { section = "header" },
        { section = "keys", gap = 1, padding = 1 },
        {
          icon = " ",
          title = "Recent Files",
          section = "recent_files",
          limit = 9,
          padding = 1,
        },
        {
          icon = " ",
          title = "Projects",
          section = "projects",
          limit = 5,
          padding = 1,
        },
        { icon = "\u{f135} ", section = "startup" },
      },
    },

    -- Enable only safe modules that don't use picker
    indent = { enabled = true },
    scroll = { enabled = false }, -- Disabled for instant scrolling
    notifier = { enabled = true },
    words = { enabled = true },
    terminal = { enabled = true },
    toggle = { enabled = true },

    -- Input with vim.ui.input override
    input = {
      enabled = true,
    },

    git = { enabled = true },
    rename = { enabled = true },
    bufdelete = { enabled = true },
    scratch = { enabled = true },
    lazygit = { enabled = false }, -- Disable until lazygit is installed

    -- Git browse - open files in GitHub/GitLab
    gitbrowse = { enabled = true },

    -- Dim inactive code scopes for focus
    dim = { enabled = true },

    -- Scope detection with text objects and navigation
    scope = { enabled = true },

    -- Fast file rendering before plugins load
    quickfile = { enabled = true },

    -- Image display in terminal (WezTerm supports Kitty protocol)
    image = { enabled = true },

    -- Zen mode for distraction-free writing (iA Writer-style)
    zen = {
      enabled = true,
      toggles = {
        dim = true,
        git_signs = false,
        mini_diff_signs = false,
        diagnostics = false,
        inlay_hints = false,
      },
      center = true,
      show = {
        statusline = true,
        tabline = true,
      },
      win = {
        style = "zen",
        width = 100, -- 100 column centered width for writing
      },
    },
  })

  -- Set up vim.ui overrides after setup (dressing.nvim is now disabled)
  -- Set directly to Snacks modules (required for healthcheck to pass)
  vim.ui.select = snacks.picker.select
  -- Snacks.input is a callable that returns the input handler
  vim.ui.input = require("snacks").input
end

return M
