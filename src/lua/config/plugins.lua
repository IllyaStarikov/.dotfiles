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
      local utils = require("config.utils")
      utils.load_config('config.telescope')
    end,
    keys = {
      { "<C-p>", function() 
        local ok, builtin = pcall(require, 'telescope.builtin')
        if ok then builtin.find_files() end
      end, desc = "Find Files" },
      { "<leader>ff", function() 
        local ok, builtin = pcall(require, 'telescope.builtin')
        if ok then builtin.find_files() end
      end, desc = "Find Files" },
      { "<leader>fg", function() 
        local ok, builtin = pcall(require, 'telescope.builtin')
        if ok then builtin.live_grep() end
      end, desc = "Live Grep" },
      { "<leader>fb", function() 
        local ok, builtin = pcall(require, 'telescope.builtin')
        if ok then builtin.buffers() end
      end, desc = "Buffers" },
      { "<leader>fh", function() 
        local ok, builtin = pcall(require, 'telescope.builtin')
        if ok then builtin.help_tags() end
      end, desc = "Help Tags" },
      { "<leader>fr", function() 
        local ok, builtin = pcall(require, 'telescope.builtin')
        if ok then builtin.oldfiles() end
      end, desc = "Recent Files" },
      { "<leader>fc", function() 
        local ok, builtin = pcall(require, 'telescope.builtin')
        if ok then builtin.commands() end
      end, desc = "Commands" },
      { "<leader>fp", function() 
        local ok, builtin = pcall(require, "telescope.builtin")
        local config_ok, lazy_config = pcall(require, "lazy.core.config")
        if ok and config_ok then 
          builtin.find_files({ cwd = lazy_config.options.root }) 
        end
      end, desc = "Find Plugin File" },
    },
  },

  -- snacks.nvim - Modern QoL suite for Neovim
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    config = function()
      local utils = require("config.utils")
      utils.load_config('config.plugins.snacks')
    end,
  },
  

  -- UI/UX plugins
  { 
    "folke/tokyonight.nvim",
    lazy = false,
    priority = 1000,
    opts = {
      integrations = {
        bufferline = true,
      },
    },
  },
  { 
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gstatus", "Gblame", "Gpush", "Gpull", "Gcommit", "Glog", "Gdiff" },
    keys = {
      { "<leader>gs", "<cmd>Git<cr>", desc = "Git status" },
      { "<leader>gb", "<cmd>Git blame<cr>", desc = "Git blame" },
      { "<leader>gd", "<cmd>Gdiff<cr>", desc = "Git diff" },
    },
  },
  -- Mini.nvim suite - Modern Neovim plugins
  {
    "echasnovski/mini.nvim",
    version = false,
    event = "VeryLazy",
    config = function()
      local utils = require("config.utils")
      
      -- mini.statusline - Modern statusline
      utils.setup_plugin('mini.statusline', {
        use_icons = true,
        set_vim_settings = true,
      })
      
      -- mini.surround - Better surround operations
      utils.setup_plugin('mini.surround', {
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
      utils.setup_plugin('mini.align', {
        mappings = {
          start = 'ga',
          start_with_preview = 'gA',
        },
      })
      
      -- mini.ai - Enhanced text objects
      local ai_ok, ai = pcall(require, 'mini.ai')
      if ai_ok then
        utils.setup_plugin('mini.ai', {
          n_lines = 500,
          custom_textobjects = {
            o = ai.gen_spec.treesitter({
              a = { '@block.outer', '@conditional.outer', '@loop.outer' },
              i = { '@block.inner', '@conditional.inner', '@loop.inner' },
            }),
            f = ai.gen_spec.treesitter({ a = '@function.outer', i = '@function.inner' }),
            c = ai.gen_spec.treesitter({ a = '@class.outer', i = '@class.inner' }),
          },
        })
      end
    end,
  },
  
  -- Bufferline - Better buffer management
  {
    'akinsho/bufferline.nvim',
    version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons',
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      -- Function to get Tokyo Night colors
      local function get_tokyonight_colors()
        local colors = {}
        local has_tokyonight, tokyonight_colors = pcall(require, "tokyonight.colors")
        
        if has_tokyonight then
          colors = tokyonight_colors.setup()
        else
          -- Default fallback colors
          colors = {
            bg = "#1a1b26",
            bg_dark = "#16161e",
            bg_highlight = "#292e42",
            fg = "#c0caf5",
            fg_dark = "#a9b1d6",
            blue = "#7aa2f7",
          }
        end
        
        return colors
      end
      
      -- Setup bufferline with dynamic colors
      local function setup_bufferline()
        local colors = get_tokyonight_colors()
        
        require("bufferline").setup({
          options = {
            mode = "buffers",
            separator_style = "slant",
            always_show_bufferline = false,
            show_buffer_close_icons = false,
            show_close_icon = false,
            color_icons = true,
            themable = true,
            indicator = {
              style = 'icon',
              icon = '▎',
            },
            modified_icon = '●',
            left_trunc_marker = '',
            right_trunc_marker = '',
            offsets = {
              {
                filetype = "neo-tree",
                text = "File Explorer",
                text_align = "center",
                separator = true,
              }
            },
          },
          highlights = {
            fill = {
              bg = colors.bg_dark,
            },
            background = {
              fg = colors.fg_dark,
              bg = colors.bg_dark,
            },
            buffer_visible = {
              fg = colors.fg_dark,
              bg = colors.bg_dark,
            },
            buffer_selected = {
              fg = colors.fg,
              bg = colors.bg,
              bold = true,
              italic = false,
            },
            separator = {
              fg = colors.bg_dark,
              bg = colors.bg_dark,
            },
            separator_visible = {
              fg = colors.bg_dark,
              bg = colors.bg_dark,
            },
            separator_selected = {
              fg = colors.bg_dark,
              bg = colors.bg,
            },
            indicator_selected = {
              fg = colors.blue,
              bg = colors.bg,
            },
            modified = {
              fg = colors.yellow or colors.fg,
              bg = colors.bg_dark,
            },
            modified_selected = {
              fg = colors.yellow or colors.fg,
              bg = colors.bg,
            },
          }
        })
      end
      
      -- Initial setup
      vim.defer_fn(setup_bufferline, 100)
      
      -- Reload on colorscheme change
      vim.api.nvim_create_autocmd("ColorScheme", {
        pattern = "tokyonight*",
        callback = function()
          vim.defer_fn(setup_bufferline, 100)
        end,
      })
    end,
    keys = {
      { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Previous Buffer" },
      { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
      { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Previous Buffer" },
      { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
      { "<leader>bp", "<cmd>BufferLineTogglePin<cr>", desc = "Pin Buffer" },
      { "<leader>bP", "<cmd>BufferLineGroupClose ungrouped<cr>", desc = "Close Unpinned Buffers" },
      { "<leader>bo", "<cmd>BufferLineCloseOthers<cr>", desc = "Close Other Buffers" },
      { "<leader>br", "<cmd>BufferLineCloseRight<cr>", desc = "Close Buffers to Right" },
      { "<leader>bl", "<cmd>BufferLineCloseLeft<cr>", desc = "Close Buffers to Left" },
      { "<S-Tab>", "<cmd>BufferLineCyclePrev<cr>", desc = "Previous Buffer" },
      { "<Tab>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
    },
  },

  -- Git integration
  { 
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function() 
      local utils = require("config.utils")
      utils.load_config('config.gitsigns')
    end 
  },
  { 
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
    dependencies = { "nvim-lua/plenary.nvim" }
  },

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
      require('config.plugins.typr').setup()
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
      
      -- Markdown-specific settings
      markdown = {
        include_yaml_front_matter = false,
      },
      
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
      require('config.plugins.vimtex').setup()
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
      require("config.lsp.servers").setup()
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
      require('config.plugins.snippets').setup()
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
      return require('config.plugins.completion')
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
      require('config.plugins.ai').setup()
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
          "rust", "go", "c", "cpp", "java", "ruby", "php", "latex", "bibtex",
          "comment", "vimdoc", "regex", "diff", "gitignore", "query"
        },
        auto_install = true,
        sync_install = false,  -- Don't download parsers synchronously
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
      local config = require('config.plugins.markview')
      
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



}, {
  -- Lazy.nvim options
  defaults = {
    lazy = false, -- Default to not lazy for now, until all plugins are properly configured
  },
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
  change_detection = {
    notify = false, -- Don't notify about config changes
  },
  performance = {
    cache = {
      enabled = true,
    },
    reset_packpath = true, -- reset the package path to improve startup time
    rtp = {
      reset = true, -- reset the runtime path to improve startup time
      -- disable some rtp plugins for faster startup
      disabled_plugins = {
        "gzip",
        "matchit",
        "matchparen",
        "netrwPlugin",
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
