--
-- config/plugins.lua
-- Plugin configuration using lazy.nvim (modern plugin manager)
--

-- Bootstrap lazy.nvim
local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  vim.fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable", -- latest stable release
    lazypath,
  })
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
    },
  },

  -- Modern QoL collection - replaces many individual plugins
  {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    config = function()
      require('config.snacks').setup()
    end,
  },

  -- UI/UX plugins
  { "airblade/vim-gitgutter" },
  { "dracula/vim", name = "dracula" },
  { "cocopon/iceberg.vim" },
  { "projekt0n/github-nvim-theme" },
  { "tpope/vim-fugitive" },
  { "vim-airline/vim-airline" },
  { "vim-airline/vim-airline-themes" },

  -- Noice for a better UI experience
  {
    "folke/noice.nvim",
    event = "VeryLazy",
    dependencies = {
      "MunifTanjim/nui.nvim",
      "rcarriga/nvim-notify",
    },
    config = function()
      require('config.noice').setup()
    end,
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
      { "<leader>md", desc = "Debug Menu" },
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
  { "neovim/nvim-lspconfig" },
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate"
  },
  { "williamboman/mason-lspconfig.nvim" },

  -- Modern high-performance completion
  {
    "saghen/blink.cmp",
    lazy = false, -- lazy loading handled internally
    dependencies = { 
      "rafamadriz/friendly-snippets",
      "L3MON4D3/LuaSnip", -- Snippet engine
      -- Optional: add icon support
      { "saghen/blink.compat", opts = {} }
    },
    version = "v0.*",
    -- Optional: build the Rust binary for better performance (requires Rust nightly)
    -- Commented out due to nightly requirement, using Lua fallback instead
    -- build = "cargo build --release",
    config = function()
      require('config.blink').setup()
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
        },
        indent = {
          enable = true,
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
      "nvim-tree/nvim-web-devicons"
    },
    config = function()
      require('config.markview').setup()
    end
  },
  { "junegunn/vim-easy-align" },
  { "skywind3000/asyncrun.vim" },
  { "tommcdo/vim-lion" },
  { "tpope/vim-commentary" },
  { "tpope/vim-surround" },
  { "wellle/targets.vim" },

  -- Linting
  { "dense-analysis/ale" },

  -- File Management and Exploration
  {
    "stevearc/oil.nvim",
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
})

-- Plugin-specific configurations
local g = vim.g
local opt = vim.opt

-- NERDTree
g.NERDTreeWinPos = "right"
g.NERDTreeMapOpenInTab = '\r'
g.NERDTreeGitStatusWithFlags = 1

-- ALE (disable completion since we use blink.cmp)
g.ale_completion_enabled = 0
g.ale_python_pyls_executable = "pylsp"
g.ale_python_flake8_options = "--max-line-length=200"
g.ale_python_pylint_options = "--max-line-length=200 --errors-only"
g.ale_sign_error = '>>'
g.ale_sign_warning = '>'
g.ale_echo_msg_error_str = 'E'
g.ale_echo_msg_warning_str = 'W'
g.ale_echo_msg_format = '[%linter% | %severity%][%code%] %s'

-- Airline
g["airline#extensions#whitespace#enabled"] = 0
g.airline_symbols_ascii = 1
g["airline#extensions#ale#enabled"] = 1
g.airline_detect_spell = 0
g["airline#extensions#tabline#enabled"] = 1
g["airline#extensions#tabline#fnamemod"] = ':t'
g["airline#extensions#tabline#tab_nr_type"] = 2

-- Grepper
g.grepper = {
  grep = {
    grepprg = 'grep -Rn --color --exclude=*.{o,exe,out,dll,obj} --exclude-dir=bin $*'
  }
}

-- Telescope is now configured in config/telescope.lua

-- Dracula theme settings
g.dracula_italic = 1
g.dracula_bold = 1
