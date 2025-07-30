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
  { "airblade/vim-gitgutter" },
  { "dracula/vim", name = "dracula", lazy = false, priority = 1000 },
  { "cocopon/iceberg.vim" },
  { "projekt0n/github-nvim-theme" },
  { 
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("tokyonight").setup({
        style = "moon", -- default style
        transparent = false,
        styles = {
          comments = { italic = true },
          keywords = { italic = true },
        },
      })
      -- Also set the vim global for compatibility
      vim.g.tokyonight_style = "moon"
    end
  },
  { "tpope/vim-fugitive" },
  { 
    "vim-airline/vim-airline",
    lazy = false,
    priority = 999,
    dependencies = { "vim-airline/vim-airline-themes" },
    init = function()
      -- Set powerline fonts BEFORE airline loads
      vim.g.airline_powerline_fonts = 1
      -- Disable problematic tabline autocommands
      vim.g["airline#extensions#tabline#disable_refresh"] = 1
      -- Performance optimizations
      vim.g.airline_focuslost_inactive = 0
      vim.g.airline_inactive_collapse = 1
      vim.g.airline_skip_empty_sections = 1
      vim.g.airline_highlighting_cache = 1
      -- Disable extensions that trigger frequent updates
      vim.g["airline#extensions#branch#enabled"] = 1  -- Keep git branch
      vim.g["airline#extensions#hunks#enabled"] = 0   -- Disable git hunks (performance)
      vim.g["airline#extensions#nvimlsp#enabled"] = 1 -- Keep LSP status
      vim.g["airline#extensions#wordcount#enabled"] = 0 -- Disable word count
      vim.g["airline#extensions#searchcount#enabled"] = 0 -- Disable search count
    end,
    config = function()
      -- Set all airline settings here
      vim.g["airline#extensions#whitespace#enabled"] = 0
      vim.g["airline#extensions#ale#enabled"] = 0
      vim.g.airline_detect_spell = 0
      vim.g["airline#extensions#tabline#enabled"] = 1
      vim.g["airline#extensions#tabline#fnamemod"] = ':t'
      vim.g["airline#extensions#tabline#tab_nr_type"] = 2
      vim.g["airline#extensions#tabline#show_buffers"] = 1
      vim.g["airline#extensions#tabline#show_tabs"] = 0
      vim.g["airline#extensions#tabline#buffer_idx_mode"] = 1
      vim.g["airline#extensions#tabline#formatter"] = 'unique_tail_improved'
      vim.g["airline#extensions#tabline#show_close_button"] = 0
      vim.g["airline#extensions#tabline#show_tab_type"] = 0
      vim.g["airline#extensions#tabline#buffer_nr_show"] = 0
      vim.g["airline#extensions#tabline#buffer_nr_format"] = '%s:'
      vim.g.airline_theme = 'dracula'
      
      -- Force refresh after settings
      vim.defer_fn(function()
        if vim.fn.exists(":AirlineRefresh") == 2 then
          vim.cmd("AirlineRefresh")
        end
      end, 100)
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
        javascript = { { "prettierd", "prettier" } },
        typescript = { { "prettierd", "prettier" } },
        html = { { "prettierd", "prettier" } },
        css = { { "prettierd", "prettier" } },
        json = { { "prettierd", "prettier" } },
        yaml = { { "prettierd", "prettier" } },
        markdown = { { "prettierd", "prettier" } },
      },
      -- Set up format-on-save
      format_on_save = { timeout_ms = 500, lsp_fallback = true },
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

  -- Language specific
  { "illyastarikov/skeleton-files" },
  { "justinmk/vim-syntax-extra" },
  { "keith/swift.vim", ft = "swift" },
  { "vim-pandoc/vim-pandoc-syntax" },

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
  { "junegunn/vim-easy-align" },
  { "skywind3000/asyncrun.vim" },
  { "tommcdo/vim-lion" },
  { "tpope/vim-commentary" },
  { "tpope/vim-surround" },
  { "wellle/targets.vim" },


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
  { "majutsushi/tagbar" },
  { "mhinz/vim-grepper" },
  {
    "scrooloose/nerdtree",
    cmd = "NERDTreeToggle"
  },
  { "xuyuanp/nerdtree-git-plugin" },

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


-- NERDTree
g.NERDTreeWinPos = "right"
g.NERDTreeMapOpenInTab = '\r'
g.NERDTreeGitStatusWithFlags = 1


-- Airline configuration moved to plugin definition above

-- Grepper
g.grepper = {
  grep = {
    grepprg = 'grep -Rn --color --exclude=*.{o,exe,out,dll,obj} --exclude-dir=bin $*'
  }
}

-- Telescope is now configured in config/telescope.lua

-- Theme settings are handled in config/theme.lua
