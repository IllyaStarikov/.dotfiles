--
-- config/plugins-optimized.lua
-- Optimized plugin configuration with proper lazy loading
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

-- Key optimizations applied:
-- 1. All plugins have explicit lazy loading conditions
-- 2. Heavy plugins load on specific commands/keys only
-- 3. UI plugins defer loading until needed
-- 4. Priority set only for essential startup plugins

require("lazy").setup({
  -- Core theme (needs to load early)
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

  -- Telescope (load on demand)
  {
    "nvim-telescope/telescope.nvim",
    cmd = "Telescope",
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
      { "<C-p>", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find Files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live Grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help Tags" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent Files" },
      { "<leader>fc", "<cmd>Telescope commands<cr>", desc = "Commands" },
    },
  },

  -- Git (load on git commands)
  { 
    "tpope/vim-fugitive",
    cmd = { "Git", "G", "Gstatus", "Gblame", "Gpush", "Gpull", "Gcommit", "Glog", "Gdiff" },
    keys = {
      { "<leader>gs", "<cmd>Git<cr>", desc = "Git status" },
      { "<leader>gb", "<cmd>Git blame<cr>", desc = "Git blame" },
      { "<leader>gd", "<cmd>Gdiff<cr>", desc = "Git diff" },
    },
  },

  -- Git signs (load on git files)
  { 
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPre", "BufNewFile" },
    config = function() 
      local utils = require("config.utils")
      utils.load_config('config.gitsigns')
    end,
  },

  -- Diffview (load on command)
  { 
    "sindrets/diffview.nvim",
    cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewToggleFiles", "DiffviewFocusFiles" },
    dependencies = { "nvim-lua/plenary.nvim" },
  },

  -- Snacks.nvim (QoL features - load selectively)
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false, -- Keep for dashboard/essential features
    config = function()
      local utils = require("config.utils")
      utils.load_config('config.plugins.snacks')
    end,
  },

  -- Mini.nvim (load modules on demand)
  {
    "echasnovski/mini.nvim",
    version = false,
    event = "VeryLazy",
    config = function()
      local utils = require("config.utils")
      
      -- Defer non-essential modules
      vim.defer_fn(function()
        -- mini.statusline
        utils.setup_plugin('mini.statusline', {
          use_icons = true,
          set_vim_settings = true,
        })
        
        -- mini.surround
        utils.setup_plugin('mini.surround', {
          mappings = {
            add = 'ys',
            delete = 'ds',
            replace = 'cs',
          },
        })
        
        -- mini.align
        utils.setup_plugin('mini.align', {
          mappings = {
            start = 'ga',
            start_with_preview = 'gA',
          },
        })
        
        -- mini.ai (enhanced text objects)
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
      end, 50)
    end,
  },

  -- Bufferline (load after UI is ready)
  {
    'akinsho/bufferline.nvim',
    version = "*",
    dependencies = 'nvim-tree/nvim-web-devicons',
    event = { "BufReadPost", "BufNewFile" },
    config = function()
      -- Defer setup to avoid blocking
      vim.defer_fn(function()
        require("config.plugins.bufferline").setup()
      end, 100)
    end,
    keys = {
      { "<S-h>", "<cmd>BufferLineCyclePrev<cr>", desc = "Previous Buffer" },
      { "<S-l>", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
      { "[b", "<cmd>BufferLineCyclePrev<cr>", desc = "Previous Buffer" },
      { "]b", "<cmd>BufferLineCycleNext<cr>", desc = "Next Buffer" },
    },
  },

  -- UI enhancements (lazy load)
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

  -- Which-key (load on first keypress)
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    init = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
    end,
    opts = {
      plugins = { spelling = true },
    },
  },

  -- Trouble (load on command)
  {
    "folke/trouble.nvim",
    cmd = { "Trouble", "TroubleToggle" },
    dependencies = { "nvim-tree/nvim-web-devicons" },
    opts = {
      auto_open = false,
      auto_close = false,
    },
    keys = {
      { "<leader>xx", "<cmd>TroubleToggle<cr>", desc = "Toggle Trouble" },
      { "<leader>xw", "<cmd>TroubleToggle workspace_diagnostics<cr>", desc = "Workspace Diagnostics" },
      { "<leader>xd", "<cmd>TroubleToggle document_diagnostics<cr>", desc = "Document Diagnostics" },
    },
  },

  -- Todo comments (load on file read)
  {
    "folke/todo-comments.nvim",
    dependencies = { "nvim-lua/plenary.nvim" },
    event = { "BufReadPost", "BufNewFile" },
    opts = {
      signs = false, -- Disable signs for performance
    },
    keys = {
      { "]t", function() require("todo-comments").jump_next() end, desc = "Next Todo" },
      { "[t", function() require("todo-comments").jump_prev() end, desc = "Previous Todo" },
      { "<leader>xt", "<cmd>TodoTrouble<cr>", desc = "Todo Comments" },
    },
  },

  -- Conform (load on save or command)
  {
    "stevearc/conform.nvim",
    event = { "BufWritePre" },
    cmd = { "ConformInfo" },
    config = function()
      local utils = require("config.utils")
      utils.load_config('config.conform')
    end,
    keys = {
      { "<leader>cF", function() require("conform").format({ formatters = { "injected" } }) end, desc = "Format Injected" },
    },
  },

  -- Copilot (load on insert)
  {
    "github/copilot.vim",
    event = "InsertEnter",
    config = function()
      vim.g.copilot_filetypes = {
        ["*"] = true,
        ["neo-tree"] = false,
        ["TelescopePrompt"] = false,
      }
    end,
  },

  -- VimTeX (only for LaTeX files)
  {
    'lervag/vimtex',
    ft = { 'tex', 'latex', 'bib' },
    config = function()
      local utils = require("config.utils")
      utils.load_config('config.vimtex')
    end,
  },

  -- Mason (load on command)
  {
    "williamboman/mason.nvim",
    cmd = { "Mason", "MasonInstall", "MasonUpdate" },
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗"
        }
      }
    },
  },

  -- Treesitter (essential, but optimize config)
  {
    "nvim-treesitter/nvim-treesitter",
    build = ":TSUpdate",
    event = { "BufReadPost", "BufNewFile" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter-textobjects",
    },
    config = function()
      local utils = require("config.utils")
      -- Defer non-essential parsers
      vim.defer_fn(function()
        utils.load_config('config.treesitter')
      end, 50)
    end,
  },

  -- CodeCompanion (load on command)
  {
    "olimorris/codecompanion.nvim",
    cmd = { "CodeCompanion", "CodeCompanionChat", "CodeCompanionToggle", "CodeCompanionAdd" },
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
    config = function()
      local utils = require("config.utils")
      utils.load_config('config.codecompanion')
    end,
    keys = {
      { "<C-a>", "<cmd>CodeCompanionToggle<cr>", mode = { "n", "v" }, desc = "Toggle CodeCompanion" },
      { "ga", "<cmd>CodeCompanionAdd<cr>", mode = { "v" }, desc = "Add to CodeCompanion" },
      { "<leader>a", "<cmd>CodeCompanionToggle<cr>", desc = "Toggle CodeCompanion" },
    },
  },

  -- Aerial (load on command)
  {
    "stevearc/aerial.nvim",
    cmd = { "AerialToggle", "AerialOpen", "AerialNavToggle" },
    dependencies = {
      "nvim-treesitter/nvim-treesitter",
      "nvim-tree/nvim-web-devicons"
    },
    opts = {
      on_attach = function(bufnr)
        vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
        vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
      end,
    },
    keys = {
      { "<leader>co", "<cmd>AerialToggle!<CR>", desc = "Toggle Aerial" },
    },
  },

  -- nvzone/menu (load on keypress)
  {
    "nvzone/menu",
    event = "VeryLazy",
    dependencies = { "nvzone/volt" },
  },

  -- Blink completion (defer loading)
  {
    'saghen/blink.cmp',
    event = { "InsertEnter", "CmdlineEnter" },
    dependencies = 'rafamadriz/friendly-snippets',
    version = 'v0.*',
    config = function()
      local utils = require("config.utils")
      utils.load_config('config.blink')
    end,
  },

  -- LuaSnip (load with completion)
  {
    "L3MON4D3/LuaSnip",
    event = "InsertEnter",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local utils = require("config.utils")
      utils.load_config('config.luasnip')
    end,
  },

  -- File browser (load on command)
  {
    "nvim-telescope/telescope-file-browser.nvim",
    cmd = "Telescope file_browser",
    dependencies = { "nvim-telescope/telescope.nvim", "nvim-lua/plenary.nvim" },
    config = function()
      require("telescope").load_extension("file_browser")
    end,
    keys = {
      { "<leader>fe", "<cmd>Telescope file_browser<cr>", desc = "File Browser" },
    },
  },

  -- LSP configuration (essential, optimize loading)
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "williamboman/mason-lspconfig.nvim",
    },
    config = function()
      -- Defer LSP setup to avoid blocking
      vim.defer_fn(function()
        local utils = require("config.utils")
        utils.safe_require("config.lsp")
      end, 100)
    end,
  },
}, {
  -- Lazy.nvim configuration
  defaults = {
    lazy = true, -- Default all plugins to lazy
  },
  performance = {
    rtp = {
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
  checker = {
    enabled = true,
    notify = false,
  },
  change_detection = {
    notify = false,
  },
})