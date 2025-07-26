--
-- config/snacks.lua
-- HIGH-PERFORMANCE snacks.nvim configuration
-- Fixed to use proper snacks.nvim API without format field conflicts
--

local M = {}

function M.setup()
  require("snacks").setup({
    -- ⚡ BIGFILE: Handle large files efficiently
    bigfile = { 
      enabled = true,
      size = 1024 * 1024, -- 1MB threshold
    },

    -- 🎯 PICKER: Fixed configuration using proper snacks API
    picker = {
      enabled = true,
      -- No custom format configurations - use defaults to avoid conflicts
      win = {
        style = "minimal",
        border = "rounded",
        title_pos = "center",
      },
      -- Use default layouts and sources without custom formatting
      layout = {
        preset = "ivy",  -- Use ivy preset instead of custom layout
      },
    },

    -- 🎯 DASHBOARD: Working dashboard with telescope fallbacks
    dashboard = {
      enabled = true,
      width = 60,
      sections = {
        { section = "header" },
        {
          section = "keys",
          gap = 1,
          padding = 1,
          keys = {
            -- Use telescope for file operations to avoid picker conflicts
            { icon = " ", key = "f", desc = "Find File", action = ":Telescope find_files" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":Telescope oldfiles" },
            { icon = " ", key = "g", desc = "Find Text", action = ":Telescope live_grep" },
            { icon = " ", key = "b", desc = "Buffers", action = ":Telescope buffers" },
            { icon = " ", key = "c", desc = "Config", action = function() require('telescope.builtin').find_files({ cwd = vim.fn.stdpath("config") }) end },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
        { section = "recent_files", limit = 8 },
        { section = "startup" },
      },
    },

    -- 🔥 INDENT: Beautiful indentation guides
    indent = {
      enabled = true,
      char = "│",
      scope = {
        enabled = true,
        char = "│",
        underline = false,
        hl = "SnacksIndentScope",
      },
      animate = {
        enabled = false, -- Disable for performance
      },
    },

    -- 📊 SCROLL: Smooth scrolling
    scroll = {
      enabled = true,
      animate = {
        duration = { step = 15, total = 150 },
        easing = "linear",
      },
    },

    -- 🎪 NOTIFIER: Elegant notifications
    notifier = {
      enabled = true,
      timeout = 3000,
      width = { min = 40, max = 0.4 },
      height = { min = 1, max = 0.6 },
      margin = { top = 0, right = 1, bottom = 0 },
      padding = true,
      sort = { "level", "added" },
      level = vim.log.levels.INFO,
      icons = {
        error = " ",
        warn = " ",
        info = " ",
        debug = " ",
        trace = " ",
      },
      style = "compact",
    },

    -- 📁 EXPLORER: Modern file tree
    explorer = {
      enabled = true,
      width = 30,
      autohide = true,
      auto_close = false,
    },

    -- ⚡ QUICKFILE: Fast file operations
    quickfile = {
      enabled = true,
    },

    -- 🎨 STATUSCOLUMN: Enhanced status column
    statuscolumn = {
      enabled = true,
      left = { "mark", "sign" },
      right = { "fold", "git" },
      folds = {
        open = false,
        git_hl = false,
      },
      git = {
        patterns = { "GitSign", "MiniDiffSign" },
      },
      refresh = 50,
    },

    -- 🌊 WORDS: Intelligent word highlighting
    words = {
      enabled = true,
      debounce = 100,
      notify_jump = false,
      notify_end = true,
      foldopen = true,
      jumplist = true,
      modes = { "n", "i", "c" },
    },

    -- 🎯 ZEN: Distraction-free coding
    zen = {
      enabled = true,
      toggles = {
        dim = true,
        git_signs = false,
        mini_diff_signs = false,
        diagnostics = false,
        inlay_hints = false,
      },
      zoom = {
        width = 120,
        height = 1,
      },
      show = {
        statusline = false,
        tabline = false,
      },
      win = {
        backdrop = 0.95,
        width = 120,
        height = 1,
        options = {
          signcolumn = "no",
          number = false,
          relativenumber = false,
          cursorline = false,
          cursorcolumn = false,
          foldcolumn = "0",
          list = false,
        },
      },
    },

    -- 🎬 ANIMATE: Subtle animations
    animate = {
      enabled = true,
      fps = 60,
      duration = 20,
    },

    -- 📱 TERMINAL: Terminal management
    terminal = {
      enabled = true,
      shell = vim.o.shell,
      win = {
        style = "terminal",
        position = "float",
        height = 0.8,
        width = 0.8,
        border = "rounded",
      },
    },

    -- 🔧 TOGGLE: Option toggling
    toggle = {
      enabled = true,
      which_key = true,
      notify = true,
      icon = {
        enabled = " ",
        disabled = " ",
      },
      color = {
        enabled = "green",
        disabled = "yellow",
      },
    },

    -- 🎮 INPUT: Enhanced input dialogs
    input = {
      enabled = true,
      icon = " ",
      icon_hl = "SnacksInputIcon",
      icon_pos = "left",
      prompt_pos = "title",
      win = { style = "input" },
      expand = true,
    },

    -- 🔍 SCOPE: Advanced scope navigation
    scope = {
      enabled = true,
      keys = {
        textobject = {
          ii = {
            min_size = 2,
            edge = false,
            cursor = false,
            treesitter = { "function.inner", "class.inner", "loop.inner" },
          },
          ai = {
            cursor = true,
            treesitter = { "function.outer", "class.outer", "loop.outer" },
          },
        },
      },
    },

    -- 🎨 GIT: Git integration
    git = {
      enabled = true,
    },

    -- ✏️ RENAME: File renaming
    rename = {
      enabled = true,
    },

    -- 🗂️ BUFDELETE: Smart buffer deletion
    bufdelete = {
      enabled = true,
    },

    -- 📝 SCRATCH: Scratch buffers
    scratch = {
      enabled = true,
    },

    -- 🚀 LAZYGIT: Git interface
    lazygit = {
      enabled = true,
    },

    -- 📊 PROFILER: Performance profiling
    profiler = {
      enabled = true,
    },

    -- 🐛 DEBUG: Debug utilities
    debug = {
      enabled = true,
    },

    -- 🎨 STYLES: Consistent styling
    styles = {
      notification = {
        wo = { wrap = true },
        border = "rounded",
      },
      input = {
        border = "rounded",
        title_pos = "center",
        icon_pos = "left",
      },
      terminal = {
        border = "rounded",
        title_pos = "center",
      },
    },
  })
end

return M