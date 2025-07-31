--
-- config/plugins.lua
-- Plugin configuration using lazy.nvim (modern plugin manager)
--

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
  local lazyrepo = "https://github.com/folke/lazy.nvim.git"
  local out = vim.fn.system({ "git", "clone", "--filter=blob:none", "--branch=stable", lazyrepo, lazypath })
  if vim.v.shell_error ~= 0 then
    vim.api.nvim_echo({
      { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
      { out, "WarningMsg" },
      { "\nPress any key to exit..." },
    }, true, {})
    vim.fn.getchar()
    os.exit(1)
  end
end
vim.opt.runtimepath:prepend(lazypath)

-- Plugin specifications
require("lazy").setup({
  -- Telescope fuzzy finder
  {
    "nvim-telescope/telescope.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      {
        "nvim-telescope/telescope-fzf-native.nvim",
        build = "make",
        cond = function()
          return vim.fn.executable("make") == 1
        end,
      },
    },
    config = function()
      require('config.telescope').setup()
    end,
    keys = {
      { "<C-p>", function() require('telescope.builtin').find_files() end, desc = "Find Files" },
      { "<leader>ff", function() require('telescope.builtin').find_files() end, desc = "Find Files" },
      { "<leader>fg", function() require('telescope.builtin').live_grep() end, desc = "Live Grep" },
      { "<leader>fb", function() require('telescope.builtin').buffers() end, desc = "Buffers" },
      { "<leader>fh", function() require('telescope.builtin').help_tags() end, desc = "Help Tags" },
      { "<leader>fr", function() require('telescope.builtin').oldfiles() end, desc = "Recent Files" },
      { "<leader>fc", function() require('telescope.builtin').commands() end, desc = "Commands" },
      { "<leader>fp", function() require("telescope.builtin").find_files({ cwd = require("lazy.core.config").options.root }) end, desc = "Find Plugin File" },
    },
  },

  -- snacks.nvim - Modern QoL suite for Neovim
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    config = function()
      require('config.snacks').setup()
    end,
  },
  
  -- Legacy configuration (will be replaced by config.snacks)
  --[[ {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    opts = {
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
        vim.opt_local.concealevel = 0
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
            { icon = " ", key = "f", desc = "Find File", action = ":Telescope find_files" },
            { icon = " ", key = "r", desc = "Recent Files", action = ":Telescope oldfiles" },
            { icon = " ", key = "g", desc = "Find Text", action = ":Telescope live_grep" },
            { icon = " ", key = "b", desc = "Buffers", action = ":Telescope buffers" },
            { icon = " ", key = "s", desc = "Restore Session", action = ":SessionRestore" },
            { icon = " ", key = "x", desc = "Lazy Extras", action = ":LazyExtras" },
            { icon = " ", key = "c", desc = "Config", action = function() require('telescope.builtin').find_files({ cwd = vim.fn.stdpath("config") }) end },
            { icon = " ", key = ".", desc = "Browse Files", action = ":Oil" },
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

    -- 🎬 SCROLL: Disabled for maximum performance
    scroll = {
      enabled = false,
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
  } --]]

  -- UI/UX plugins
  { 
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    -- Don't configure here, let theme.lua handle it dynamically
  },
  { "tpope/vim-fugitive" },
  -- Mini.nvim suite - Modern Neovim plugins
  {
    "echasnovski/mini.nvim",
    version = false,
    config = function()
      -- mini.statusline - Modern statusline
      require('mini.statusline').setup({
        use_icons = true,
        set_vim_settings = true,
      })
      
      -- mini.surround - Better surround operations
      require('mini.surround').setup({
        mappings = {
          add = 'ys',
          delete = 'ds',
          find = '',
          find_left = '',
          highlight = '',
          replace = 'cs',
          update_n_lines = '',
        },
      })
      
      -- mini.align - Easy alignment
      require('mini.align').setup({
        mappings = {
          start = 'ga',
          start_with_preview = 'gA',
        },
      })
      
      -- mini.ai - Enhanced text objects
      require('mini.ai').setup({
        n_lines = 500,
        custom_textobjects = {
          o = require('mini.ai').gen_spec.treesitter({
            a = { '@block.outer', '@conditional.outer', '@loop.outer' },
            i = { '@block.inner', '@conditional.inner', '@loop.inner' },
          }),
          f = require('mini.ai').gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }),
          c = require('mini.ai').gen_spec.treesitter({ a = '@class.outer', i = '@class.inner' }),
        },
      })
    end,
  },

  -- Git integration
  { "lewis6991/gitsigns.nvim", config = function() require('config.gitsigns').setup() end },
  { "sindrets/diffview.nvim", dependencies = { "nvim-lua/plenary.nvim" } },

  -- UI enhancements
  {
    "stevearc/dressing.nvim",
    lazy = true,
    init = function()
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.select = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.select(...)
      end
      ---@diagnostic disable-next-line: duplicate-set-field
      vim.ui.input = function(...)
        require("lazy").load({ plugins = { "dressing.nvim" } })
        return vim.ui.input(...)
      end
    end,
  },
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
      plugins = { spelling = true },
      defaults = {
        mode = { "n", "v" },
      },
    },
    config = function(_, opts)
      local wk = require("which-key")
      wk.setup(opts)
    end,
  },

  -- Trouble.nvim - Pretty diagnostics, references, quickfix, loclist
  {
    "folke/trouble.nvim",
    cmd = { "Trouble", "TroubleToggle" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      position = "bottom",
      height = 10,
      width = 50,
      icons = true,
      mode = "document_diagnostics",
      fold_open = "",
      fold_closed = "",
      group = true,
      padding = true,
      action_keys = {
        close = { "q", "<esc>" },
        cancel = "<c-e>",
        refresh = "r",
        jump = { "<cr>", "<tab>" },
        open_split = { "<c-x>" },
        open_vsplit = { "<c-v>" },
        open_tab = { "<c-t>" },
        jump_close = {"o"},
        toggle_mode = "m",
        toggle_preview = "P",
        hover = "K",
        preview = "p",
        close_folds = {"zM", "zm"},
        open_folds = {"zR", "zr"},
        toggle_fold = {"zA", "za"},
        previous = "k",
        next = "j"
      },
      indent_lines = true,
      auto_open = false,
      auto_close = false,
      auto_preview = true,
      auto_fold = false,
      auto_jump = {"lsp_definitions"},
      signs = {
        error = "",
        warning = "",
        hint = "",
        information = "",
        other = ""
      },
      use_diagnostic_signs = true
    },
    keys = {
      { "<leader>xx", "<cmd>TroubleToggle<cr>", desc = "Toggle Trouble" },
      { "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Workspace Diagnostics" },
      { "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "Document Diagnostics" },
      { "<leader>xq", "<cmd>TroubleToggle quickfix<cr>", desc = "Quickfix List" },
      { "<leader>xl", "<cmd>TroubleToggle loclist<cr>", desc = "Location List" },
      { "<leader>xr", "<cmd>TroubleToggle lsp_references<cr>", desc = "LSP References" },
      { "<leader>xt", "<cmd>TodoTrouble<cr>", desc = "Todo Comments" },
      { "gR", "<cmd>TroubleToggle lsp_references<cr>", desc = "LSP References" },
      { "[q", function() require("trouble").previous({skip_groups = true, jump = true}) end, desc = "Previous Trouble Item" },
      { "]q", function() require("trouble").next({skip_groups = true, jump = true}) end, desc = "Next Trouble Item" },
    },
  },

  -- Todo comments highlighting
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = { "BufReadPre", "BufNewFile" },
    opts = {
      signs = true,
      sign_priority = 8,
      keywords = {
        FIX = { icon = " ", color = "error", alt = { "FIXME", "BUG", "FIXIT", "ISSUE" } },
        TODO = { icon = " ", color = "info" },
        HACK = { icon = " ", color = "warning" },
        WARN = { icon = " ", color = "warning", alt = { "WARNING", "XXX" } },
        PERF = { icon = " ", alt = { "OPTIM", "PERFORMANCE", "OPTIMIZE" } },
        NOTE = { icon = " ", color = "hint", alt = { "INFO" } },
        TEST = { icon = "⏲ ", color = "test", alt = { "TESTING", "PASSED", "FAILED" } },
      },
      gui_style = {
        fg = "NONE",
        bg = "BOLD",
      },
      merge_keywords = true,
      highlight = {
        multiline = true,
        multiline_pattern = "^.",
        multiline_context = 10,
        before = "",
        keyword = "wide",
        after = "fg",
        pattern = [[.*<(KEYWORDS)\s*:]],
        comments_only = true,
        max_line_len = 400,
        exclude = {},
      },
      colors = {
        error = { "DiagnosticError", "ErrorMsg", "#DC2626" },
        warning = { "DiagnosticWarn", "WarningMsg", "#FBBF24" },
        info = { "DiagnosticInfo", "#2563EB" },
        hint = { "DiagnosticHint", "#10B981" },
        default = { "Identifier", "#7C3AED" },
        test = { "Identifier", "#FF00FF" }
      },
      search = {
        command = "rg",
        args = {
          "--color=never",
          "--no-heading",
          "--with-filename",
          "--line-number",
          "--column",
        },
        pattern = [[\b(KEYWORDS):]],
      },
    },
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next Todo Comment" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous Todo Comment" },
      { "<leader>st", "<cmd>TodoTelescope<cr>", desc = "Search Todo Comments" },
    },
  },

  -- Formatting
  {
    'stevearc/conform.nvim',
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    keys = {
      {
        -- Add a format command
        "<leader>f",
        function()
          require("conform").format({ async = true, lsp_fallback = true })
        end,
        mode = "",
        desc = "Format buffer",
      },
    },
    -- Everything in opts will be passed to setup()
    opts = {
      -- Define your formatters
      formatters_by_ft = {
        lua = { "stylua" },
        python = { "isort", "black" },
        javascript = { "prettierd", "prettier", stop_after_first = true },
        typescript = { "prettierd", "prettier", stop_after_first = true },
        html = { "prettierd", "prettier", stop_after_first = true },
        css = { "prettierd", "prettier", stop_after_first = true },
        json = { "prettierd", "prettier", stop_after_first = true },
        yaml = { "prettierd", "prettier", stop_after_first = true },
        markdown = { "prettierd", "prettier", stop_after_first = true },
      },
      -- Disable format-on-save (only manual :Format)
      format_on_save = false,
      -- Customize formatters
      formatters = {
        shfmt = {
          prepend_args = { "-i", "2" },
        },
      },
    },
  },

  
  -- nvzone plugins ecosystem
  { "nvzone/volt", lazy = true },
  { 
    "nvzone/menu", 
    lazy = true,
    dependencies = { "nvzone/volt" },
    config = function()
      require('config.menu').setup()
    end,
    keys = {
      { "<C-t>", desc = "Open Smart Menu" },
      { "<leader>m", desc = "Open Menu" },
      { "<leader>M", desc = "Open Context Menu" },
      { "<leader>mf", desc = "File Menu" },
      { "<leader>mg", desc = "Git Menu" },
      { "<leader>mc", desc = "Code Menu" },
      { "<leader>ma", desc = "AI Assistant Menu" },
      { "<leader>mF", desc = "File Management Menu" },
      { "<RightMouse>", mode = { "n", "v" }, desc = "Context Menu" },
    }
  },
  {
    "nvzone/typr",
    lazy = true,
    dependencies = { "nvzone/volt" },
    config = function()
      require('config.typr').setup()
    end,
    cmd = { "Typr", "TyprStats", "TyprQuick", "TyprLong", "TyprTimed", "TyprProgramming", "TyprHistory", "TyprDashboard", "TyprConfig" },
  },

  -- Aerial.nvim - Modern code outline window
  {
    "stevearc/aerial.nvim",
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons"
    },
    opts = {
      backends = { "treesitter", "lsp", "markdown", "man" },
      layout = {
        max_width = { 40, 0.2 },
        width = nil,
        min_width = 20,
        default_direction = "right",
        placement = "edge",
      },
      close_automatic_events = { "switch_buffer", "unsupported" },
      keymaps = {
        ["?"] = "actions.show_help",
        ["g?"] = "actions.show_help",
        ["<CR>"] = "actions.jump",
        ["<2-LeftMouse>"] = "actions.jump",
        ["<C-v>"] = "actions.jump_vsplit",
        ["<C-s>"] = "actions.jump_split",
        ["p"] = "actions.scroll",
        ["<C-j>"] = "actions.down_and_scroll",
        ["<C-k>"] = "actions.up_and_scroll",
        ["{"] = "actions.prev",
        ["}"] = "actions.next",
        ["[["] = "actions.prev_up",
        ["]]"] = "actions.next_up",
        ["q"] = "actions.close",
        ["o"] = "actions.tree_toggle",
        ["za"] = "actions.tree_toggle",
        ["O"] = "actions.tree_toggle_recursive",
        ["zA"] = "actions.tree_toggle_recursive",
        ["l"] = "actions.tree_open",
        ["zo"] = "actions.tree_open",
        ["L"] = "actions.tree_open_recursive",
        ["zO"] = "actions.tree_open_recursive",
        ["h"] = "actions.tree_close",
        ["zc"] = "actions.tree_close",
        ["H"] = "actions.tree_close_recursive",
        ["zC"] = "actions.tree_close_recursive",
        ["zr"] = "actions.tree_increase_fold_level",
        ["zR"] = "actions.tree_open_all",
        ["zm"] = "actions.tree_decrease_fold_level",
        ["zM"] = "actions.tree_close_all",
        ["zx"] = "actions.tree_sync_folds",
        ["zX"] = "actions.tree_sync_folds",
      },
      filter_kind = false,
      show_guides = true,
      guides = {
        mid_item = "├─",
        last_item = "└─",
        nested_top = "│ ",
        whitespace = "  ",
      },
    },
    cmd = { "AerialToggle", "AerialOpen", "AerialNavToggle" },
    keys = {
      { "<leader>T", "<cmd>AerialToggle<cr>", desc = "Toggle Aerial" },
      { "<leader>at", "<cmd>AerialToggle<cr>", desc = "Toggle Aerial" },
      { "<leader>an", "<cmd>AerialNavToggle<cr>", desc = "Aerial Nav Toggle" },
    },
  },

  -- Language specific
  { "justinmk/vim-syntax-extra" },
  { "keith/swift.vim", ft = "swift" },

  -- LaTeX support with vimtex
  {
    "lervag/vimtex",
    lazy = false,  -- Load immediately for LaTeX files
    ft = { "tex", "latex", "plaintex" },
    config = function()
      require('config.vimtex').setup()
    end,
    dependencies = {
      -- Optional: Add LaTeX snippets support
      "L3MON4D3/LuaSnip",
    },
  },

  -- Debug Adapter Protocol (DAP) support
  {
    "mfussenegger/nvim-dap",
    lazy = true,
    dependencies = {
      -- DAP UI for better debugging experience
      {
        "rcarriga/nvim-dap-ui",
        dependencies = {
          "nvim-neotest/nvim-nio"  -- Required for dap-ui
        },
      },
      -- Virtual text support for debugging
      "theHamsta/nvim-dap-virtual-text",
      -- Language-specific DAP adapters
      "jay-babu/mason-nvim-dap.nvim",  -- Auto-install debug adapters
    },
    config = function()
      require('config.dap').setup()
    end,
    keys = {
      { "<leader>db", desc = "Toggle Breakpoint" },
      { "<leader>dc", desc = "Continue" },
      { "<leader>ds", desc = "Step Over" },
      { "<leader>di", desc = "Step Into" },
      { "<leader>do", desc = "Step Out" },
      { "<leader>dr", desc = "Restart" },
      { "<leader>dt", desc = "Terminate" },
      { "<leader>du", desc = "Toggle DAP UI" },
      { "<leader>de", desc = "Evaluate Expression" },
    },
  },

  -- LSP and completion plugins
  { 
    "neovim/nvim-lspconfig",
    dependencies = { "saghen/blink.cmp" },
    config = function()
      require("config.lsp").setup()
    end,
  },
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {
      ensure_installed = {
        "stylua",
        "shfmt",
        "shellcheck",
      },
    },
    config = function(_, opts)
      require("mason").setup(opts)
      local mr = require("mason-registry")
      local function ensure_installed()
        for _, tool in ipairs(opts.ensure_installed) do
          local p = mr.get_package(tool)
          if not p:is_installed() then
            p:install()
          end
        end
      end
      if mr.refresh then
        mr.refresh(ensure_installed)
      else
        ensure_installed()
      end
    end,
  },
  { 
    "williamboman/mason-lspconfig.nvim",
    dependencies = { "williamboman/mason.nvim", "neovim/nvim-lspconfig" },
  },

  -- Snippet Engine
  {
    "L3MON4D3/LuaSnip",
    version = "v2.*",
    dependencies = {
      "rafamadriz/friendly-snippets", -- Preconfigured snippets
    },
    config = function()
      require('config.luasnip').setup()
    end,
    keys = {
      -- Tab/S-Tab handled by blink.cmp to avoid conflicts
      { "<C-j>", mode = {"i", "s"}, desc = "Next choice in snippet" },
      { "<C-k>", mode = {"i", "s"}, desc = "Previous choice in snippet" },
      { "<C-l>", mode = {"i", "s"}, desc = "Expand/Jump in snippet" },
      { "<C-h>", mode = {"i", "s"}, desc = "Jump back in snippet" },
      { "<leader>sl", desc = "Show available snippets" },
    },
  },

  -- Modern high-performance completion
  {
    "saghen/blink.cmp",
    lazy = false,
    priority = 1000,
    dependencies = {
      "rafamadriz/friendly-snippets",
      "L3MON4D3/LuaSnip",
    },
    version = "v1.*",  -- Use stable v1 series
    opts = function()
      return require('config.blink')
    end,
    -- Allow extending sources array
    opts_extend = { "sources.default" },
    config = function(_, opts)
      -- Setup blink.cmp
      require('blink.cmp').setup(opts)
    end,
  },

  -- AI Code Companion
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "saghen/blink.cmp", -- Modern completion for slash commands and variables
      "nvim-telescope/telescope.nvim", -- Optional: For using slash commands
      {
        "stevearc/dressing.nvim", -- Optional: Improves `vim.ui.select`
        opts = {},
      },
    },
    config = function()
      require('config.codecompanion').setup()
    end
  },

  -- Writing and editing
  {
    "iamcco/markdown-preview.nvim",
    build = function() vim.fn["mkdp#util#install"]() end
  },
  {
    "nvim-treesitter/nvim-treesitter",
    priority = 1000,  -- High priority to load first
    build = ":TSUpdate",
    config = function()
      require('nvim-treesitter.configs').setup({
        ensure_installed = {
          "markdown", "markdown_inline", "python", "javascript", "typescript",
          "lua", "vim", "bash", "html", "css", "json", "yaml", "toml",
          "rust", "go", "c", "cpp", "java", "ruby", "php", "latex", "bibtex"
        },
        auto_install = true,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = { "markdown" },
          -- Disable for large files
          disable = function(lang, buf)
            local max_filesize = 100 * 1024 -- 100 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
              return true
            end
          end,
        },
        indent = {
          enable = true,
          disable = function(lang, buf)
            local max_filesize = 100 * 1024 -- 100 KB
            local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(buf))
            if ok and stats and stats.size > max_filesize then
              return true
            end
          end,
        },
      })
    end
  },
  {
    "OXY2DEV/markview.nvim",
    lazy = false,
    priority = 500,  -- Lower priority than treesitter
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      {
        "nvim-tree/nvim-web-devicons",
        config = function()
          require('nvim-web-devicons').setup({
            -- Force override for better compatibility
            override = {},
            -- Ensure color icons are enabled
            color_icons = true,
            -- Use default icons
            default = true,
          })
        end
      }
    },
    config = function()
      -- FIRST: Load markview modules to ensure they're available
      local markview = require("markview")
      local spec = require("markview.spec")
      local filetypes = require("markview.filetypes")
      
      -- Remove all filetype icons
      for _, style in pairs(filetypes.styles) do
        style.icon = ""
        style.sign = ""
      end
      
      -- Directly modify the spec.default BEFORE any setup
      if spec.default and spec.default.markdown and spec.default.markdown.list_items then
        spec.default.markdown.list_items.marker_minus.text = "-"
        spec.default.markdown.list_items.marker_plus.text = "+"
        spec.default.markdown.list_items.marker_star.text = "*"
      end
      
      -- Create our configuration that will be merged
      local config = require('config.markview')
      
      -- Just run setup, no patches needed with FiraCode
      config.setup()
    end
  },
  { "skywind3000/asyncrun.vim" },
  { "tommcdo/vim-lion" },
  -- Comment.nvim - Smart commenting
  {
    "numToStr/Comment.nvim",
    event = "VeryLazy",
    config = function()
      require('Comment').setup({
        padding = true,
        sticky = true,
        mappings = {
          basic = true,
          extra = true,
        },
      })
    end,
  },


  -- File Management and Exploration
  {
    "stevearc/oil.nvim",
    lazy = false,  -- Load immediately to handle directory opening
    dependencies = { "nvim-tree/nvim-web-devicons" },
    config = function()
      require('config.oil').setup()
    end,
    keys = {
      { "<leader>o", function() require('oil').open() end, desc = "Open Oil File Manager" },
      { "<leader>O", function() require('oil').open_float() end, desc = "Open Oil in Float" },
      { "-", function() require('oil').open() end, desc = "Open Oil File Manager" },
    },
  },

}, {
  -- Lazy.nvim options
  ui = {
    icons = {
      cmd = "⌘",
      config = "🛠",
      event = "📅",
      ft = "📂",
      init = "⚙",
      keys = "🗝",
      plugin = "🔌",
      runtime = "💻",
      source = "📄",
      start = "🚀",
      task = "📌",
    },
  },
  checker = {
    enabled = true,  -- check for plugin updates periodically
    notify = false,  -- don't notify on update (less intrusive)
  },
  performance = {
    rtp = {
      -- disable some rtp plugins for faster startup
      disabled_plugins = {
        "gzip",
        -- "matchit",
        -- "matchparen",
        -- "netrwPlugin",
        "tarPlugin",
        "tohtml",
        "tutor",
        "zipPlugin",
      },
    },
  },
})

-- Plugin-specific configurations
local g = vim.g
local opt = vim.opt

-- Theme is set dynamically in config/theme.lua




-- Plugin configurations have been moved to their respective setup functions

-- Telescope is now configured in config/telescope.lua

-- Theme settings are handled in config/theme.lua
