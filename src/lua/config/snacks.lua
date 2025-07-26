--
-- config/snacks.lua
-- HIGH-PERFORMANCE snacks.nvim configuration optimized for speed and power users
-- 
-- Performance Strategy:
-- - Aggressive caching and async operations
-- - Minimal UI overhead with smart debouncing
-- - Optimized matchers and finders for large codebases
-- - Lightning-fast animations with reduced motion where appropriate
-- - Power user workflows with extensive customization
--

local M = {}

function M.setup()
  require("snacks").setup({
    -- ⚡ BIGFILE: Optimized for massive files (>1MB)
    bigfile = { 
      enabled = true,
      size = 1024 * 1024, -- 1MB threshold
      -- Auto-disable heavy features for large files
      setup = function(ctx)
        vim.opt_local.wrap = false
        vim.opt_local.colorcolumn = ""
        vim.opt_local.foldmethod = "manual"
        vim.opt_local.spell = false
        vim.opt_local.conceallevel = 0
        vim.schedule(function()
          vim.bo[ctx.buf].syntax = ""
        end)
      end,
    },

    -- 🚀 PICKER: Lightning-fast fuzzy finder
    picker = {
      enabled = true,
      -- Performance optimizations
      limit = 1000,        -- Limit results for speed
      live = true,         -- Live search as you type
      auto_close = true,   -- Close when losing focus
      focus = "input",     -- Start in input mode
      
      -- Advanced matcher configuration for speed
      matcher = {
        -- Use fast fuzzy matching algorithm
        frecency = true,    -- Boost recently/frequently used items
        sort_empty = false, -- Don't sort when no query
      },
      
      -- Optimized window configuration
      win = {
        input = {
          keys = {
            -- Lightning-fast navigation
            ["<C-j>"] = "list_down",
            ["<C-k>"] = "list_up", 
            ["<C-d>"] = "list_down_page",
            ["<C-u>"] = "list_up_page",
            ["<C-g>"] = "list_top",
            ["<C-G>"] = "list_bottom",
            -- Advanced selection
            ["<C-a>"] = "select_all",
            ["<C-q>"] = "select_and_close",
            ["<C-x>"] = "delete_selected",
            -- Smart preview toggle
            ["<C-p>"] = "toggle_preview",
            -- Multi-select power
            ["<Tab>"] = "select_and_next",
            ["<S-Tab>"] = "select_and_prev",
          },
        },
      },
      
      -- Layout optimized for speed and screen real estate
      layout = {
        preset = "select",
        backdrop = false,    -- No backdrop for speed
        cycle = true,        -- Cycle through results
        box = "single",      -- Minimal border
        height = 0.6,        -- 60% of screen height
        width = 0.8,         -- 80% of screen width
        row = 0.2,           -- Position from top
        col = 0.1,           -- Position from left
      },
      
      -- Source-specific optimizations
      sources = {
        files = {
          -- Blazing fast file finding
          finder = "files",
          format = "path",
          follow = true,        -- Follow symlinks
          hidden = false,       -- Skip hidden files for speed
          ignore_case = true,   -- Case insensitive
          -- Exclude patterns for performance
          cwd_only = true,
          fd_args = {
            "--type", "f",
            "--strip-cwd-prefix",
            "--exclude", ".git",
            "--exclude", "node_modules", 
            "--exclude", "*.cache",
            "--exclude", "*.log",
            "--exclude", "build",
            "--exclude", "dist",
            "--exclude", ".next",
            "--exclude", ".vscode",
            "--exclude", "__pycache__",
          },
        },
        
        buffers = {
          -- Lightning buffer switching
          format = "file",
          sort = { "lastused", "alpha" },
          current = false,      -- Exclude current buffer
        },
        
        grep = {
          -- High-performance live grep
          format = "path,line,text",
          live = true,
          limit = 500,          -- Limit for performance
          -- Use ripgrep for maximum speed
          finder = "grep",
          args = {
            "--hidden",
            "--smart-case",
            "--line-number",
            "--column",
            "--no-heading",
            "--color=never",
            "--max-columns=200",
            "--max-filesize=1M",
            "--type-not=binary",
            "-g", "!.git/",
            "-g", "!node_modules/",
            "-g", "!*.cache",
            "-g", "!*.log",
          },
        },
        
        recent = {
          -- Fast recent file access
          format = "path",
          limit = 100,
          transform = function(item)
            -- Only show files that still exist
            return vim.fn.filereadable(item.file) == 1 and item or nil
          end,
        },
        
        help = {
          -- Optimized help search
          format = "help",
          limit = 200,
        },
        
        keymaps = {
          -- Quick keymap lookup
          format = "keymap",
          modes = { "n", "v", "i", "o" },
        },
      },
      
      -- Smart previewers with lazy loading
      previewers = {
        file = {
          treesitter = true,    -- Use treesitter for syntax highlighting
          wrap = false,         -- No wrapping for performance
          max_size = 1024 * 100, -- 100KB preview limit
        },
        help = {
          treesitter = true,
        },
      },
      
      -- Performance formatters
      formatters = {
        file = {
          filename_first = true, -- Show filename first for quick recognition
        },
        path = {
          relative = "cwd",     -- Show relative paths
          strip_cwd = true,     -- Clean paths
        },
      },
    },

    -- 🎯 DASHBOARD: Lightning-fast startup screen
    dashboard = {
      enabled = true,
      width = 60,
      row = nil,        -- Center vertically
      col = nil,        -- Center horizontally
      pane_gap = 4,     -- Gap between panes
      autokeys = "1234567890abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ",
      
      -- Custom high-performance sections
      sections = {
        -- Minimal header for speed
        { section = "header" },
        
        -- Lightning-fast key bindings
        {
          pane = 2,
          section = "keys",
          gap = 1,
          padding = 1,
          title = "🚀 Quick Actions",
          keys = {
            { icon = " ", key = "f", desc = "Find File", action = function() Snacks.picker.files() end },
            { icon = " ", key = "r", desc = "Recent Files", action = function() Snacks.picker.recent() end },
            { icon = " ", key = "g", desc = "Find Text", action = function() Snacks.picker.grep() end },
            { icon = " ", key = "b", desc = "Buffers", action = function() Snacks.picker.buffers() end },
            { icon = " ", key = "s", desc = "Restore Session", action = ":SessionRestore" },
            { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
            { icon = " ", key = "c", desc = "Config", action = function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end },
            { icon = " ", key = ".", desc = "Browse Files", action = function() Snacks.explorer() end },
            { icon = " ", key = "q", desc = "Quit", action = ":qa" },
          },
        },
        
        -- Recent files using vim's built-in oldfiles
        function()
          local items = {}
          local count = 0
          for _, file in ipairs(vim.v.oldfiles or {}) do
            -- Limit to 8 files and only show readable files
            if count >= 8 then break end
            if vim.fn.filereadable(file) == 1 then
              table.insert(items, {
                icon = " ",
                key = tostring(count + 1),
                desc = vim.fn.fnamemodify(file, ":t"),
                action = "edit " .. vim.fn.fnameescape(file),
              })
              count = count + 1
            end
          end
          return {
            pane = 2,
            section = "keys",
            title = "📂 Recent Files",
            padding = 1,
            keys = items,
          }
        end,
        
        -- Cached startup time
        { section = "startup" },
      },
    },

    -- 🎬 SCROLL: Ultra-smooth, performance-optimized scrolling
    scroll = {
      enabled = false,
      -- Aggressive performance tuning
      animate = {
        duration = { step = 8, total = 120 },  -- Faster than default
        easing = "outQuart",                   -- Smooth but snappy
      },
      -- Even faster for repeated scrolling
      animate_repeat = {
        delay = 50,                           -- Quick repeat detection
        duration = { step = 4, total = 60 }, -- Lightning fast repeats
        easing = "linear",
      },
      -- Smart buffer filtering for performance
      filter = function(buf)
        local bt = vim.bo[buf].buftype
        local ft = vim.bo[buf].filetype
        -- Skip heavy buffer types
        return vim.g.snacks_scroll ~= false 
          and vim.b[buf].snacks_scroll ~= false 
          and bt ~= "terminal" 
          and bt ~= "quickfix"
          and bt ~= "prompt"
          and ft ~= "lazy"
          and ft ~= "mason"
          and vim.api.nvim_buf_line_count(buf) < 10000  -- Skip huge files
      end,
    },

    -- 🎨 STATUSCOLUMN: Lightning-fast, minimal status column
    statuscolumn = {
      enabled = true,
      left = { "mark", "sign" },   -- Essential signs only
      right = { "fold", "git" },   -- Git and folds on right
      folds = {
        open = false,              -- No open fold icons for speed
        git_hl = false,           -- No git highlights for performance
      },
      git = {
        patterns = { "GitSign", "MiniDiffSign" },
      },
      refresh = 100,              -- Refresh every 100ms (balanced)
    },

    -- 🏃 WORDS: Hyper-fast LSP reference highlighting
    words = {
      enabled = true,
      debounce = 100,             -- Fast debounce (100ms)
      notify_jump = false,        -- No notifications for speed
      notify_end = false,         -- No end notifications
      foldopen = true,            -- Auto-open folds
      jumplist = true,            -- Add to jumplist
      modes = { "n" },            -- Normal mode only for performance
    },

    -- 🧘 ZEN: Distraction-free coding
    zen = {
      enabled = true,
      toggles = {
        dim = true,
        git_signs = false,
        mini_diff_signs = false,
        diagnostics = false,
        inlay_hints = false,
      },
      show = {
        statusline = false,
        tabline = false,
      },
      win = {
        width = 120,              -- Optimal coding width
        height = 1,               -- Full height
      },
      -- Zen mode keybindings
      on_open = function()
        vim.opt.scrolloff = 999   -- Center cursor
      end,
      on_close = function()
        vim.opt.scrolloff = 8     -- Restore scrolloff
      end,
    },

    -- 💨 QUICKFILE: Instant file opening
    quickfile = { 
      enabled = true,
      -- Skip these patterns for instant opening
      exclude = { "gitcommit", "diff", "scratch" },
    },

    -- 🚀 TERMINAL: High-performance terminal
    terminal = {
      enabled = true,
      win = {
        style = "terminal",
        backdrop = false,         -- No backdrop for speed
        keys = {
          -- Lightning-fast terminal navigation
          ["<C-q>"] = "hide",
          ["<C-z>"] = "hide", 
          ["<C-c>"] = { "<C-c>", mode = "t" },
          ["<C-\\>"] = { "<C-\\><C-n>", mode = "t" },
        },
      },
      -- Performance optimizations
      bo = {
        filetype = "snacks_terminal",
      },
      wo = {},
      keys = {
        -- Quick terminal commands
        term_normal = "<C-\\><C-n>",
      },
    },

    -- 📋 SCRATCH: Lightning-fast scratch buffers
    scratch = {
      enabled = true,
      name = "scratch",
      -- Dynamic filetype detection
      ft = function()
        if vim.bo.buftype == "" and vim.bo.filetype == "" then
          return "markdown"       -- Default to markdown
        end
        return vim.bo.filetype
      end,
      -- Performance settings
      win = {
        width = 100,
        height = 30,
        backdrop = false,         -- No backdrop
      },
    },

    -- 🔍 EXPLORER: Ultra-fast file browser
    explorer = {
      enabled = true,
      -- Performance-focused configuration
      win = {
        width = 40,
        backdrop = false,         -- No backdrop for speed
      },
      -- Fast navigation keys
      keys = {
        ["<CR>"] = "open",
        ["<C-v>"] = "open_vsplit",
        ["<C-x>"] = "open_split", 
        ["<C-t>"] = "open_tab",
        ["h"] = "parent",
        ["l"] = "open",
        ["H"] = "root",
        ["g"] = "top",
        ["G"] = "bottom",
        ["."] = "toggle_hidden",  -- Toggle hidden files
        ["R"] = "refresh",        -- Quick refresh
        ["q"] = "close",
      },
    },

    -- 🎯 SCOPE: Intelligent scope detection
    scope = {
      enabled = true,
      -- Optimized treesitter scope detection
      keys = {
        textobject = {
          ii = { min_size = 2, edge = false },   -- Inner scope
          ai = { min_size = 2, edge = true },    -- Around scope
        },
        jump = {
          ["[s"] = { min_size = 1, bottom = false, edge = true },
          ["]s"] = { min_size = 1, bottom = true, edge = true },
        },
      },
    },

    -- 🔔 NOTIFIER: Fast, minimal notifications
    notifier = {
      enabled = true,
      timeout = 2000,           -- 2 second timeout
      width = { min = 40, max = 0.4 },
      height = { min = 1, max = 0.6 },
      -- Position for minimal distraction
      top_down = false,         -- Bottom up notifications
      sort = { "level", "added" },
      -- Performance styles
      style = "minimal",
      icons = {
        error = " ",
        warn = " ",
        info = " ",
        debug = " ",
        trace = " ",
      },
    },

    -- 🔄 RENAME: Fast LSP-integrated renaming
    rename = { 
      enabled = true,
      -- Performance notification
      notify = true,
    },

    -- 🎨 INDENT: Minimal, fast indent guides
    indent = {
      enabled = true,
      indent = {
        char = "│",             -- Simple character
        blank = " ",            -- Blank line character
      },
      scope = {
        char = "│",             -- Scope character
        underline = false,      -- No underline for performance
      },
      -- Performance filter
      filter = function(buf)
        return vim.bo[buf].buftype == ""
          and vim.bo[buf].filetype ~= ""
          and vim.api.nvim_buf_line_count(buf) < 5000  -- Skip huge files
      end,
    },

    -- 🎭 DIM: Subtle focus dimming
    dim = { 
      enabled = true,
      -- Minimal dimming for performance
      scope = {
        min_size = 5,           -- Minimum lines to dim
        max_size = 50,          -- Maximum for performance
      },
    },

    -- 🔄 TOGGLE: Smart option toggles
    toggle = { 
      enabled = true,
      -- Performance-optimized toggles
      notify = true,
      which_key = true,         -- which-key integration
    },

    -- 🚀 LAZY GIT: Optimized git integration
    lazygit = {
      enabled = true,
      configure = true,         -- Auto-configure theme
      theme_path = vim.fs.joinpath(vim.fn.stdpath("cache"), "lazygit-theme.yml"),
      theme = {
        [241]                   = { fg = "Special" },
        activeBorderColor       = { fg = "MatchParen", bold = true },
        cherryPickedCommitBgColor = { fg = "Identifier" },
        cherryPickedCommitFgColor = { fg = "Function" },
        defaultFgColor          = { fg = "Normal" },
        inactiveBorderColor     = { fg = "FloatBorder" },
        optionsTextColor        = { fg = "Function" },
        searchingActiveBorderColor = { fg = "MatchParen", bold = true },
        selectedLineBgColor     = { bg = "Visual" },
        unstagedChangesColor    = { fg = "DiagnosticError" },
      },
      win = {
        style = "lazygit",
        backdrop = false,       -- No backdrop for performance
      },
    },

    -- 🔧 INPUT: Enhanced vim.ui.input
    input = { 
      enabled = true,
      -- Fast input configuration
      win = {
        style = "input",
        backdrop = false,       -- No backdrop
      },
    },

    -- 🎯 GIT: Fast git utilities
    git = { 
      enabled = true,
    },

    -- 🌐 GITBROWSE: Quick git browsing
    gitbrowse = { 
      enabled = true,
      notify = false,           -- No notifications for speed
    },

    -- ⚡ NOTIFY: Fast notification utilities
    notify = { 
      enabled = true,
    },

    -- 🎥 ANIMATE: Optimized animations library
    animate = { 
      enabled = true,
      -- Default fast settings for all animations
      duration = 150,           -- Short duration
      easing = "outQuart",      -- Smooth but fast
      fps = 60,                 -- Smooth 60fps
    },
  })
end

return M