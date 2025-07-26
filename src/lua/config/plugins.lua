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
  -- FZF fuzzy finder
  {
    "junegunn/fzf",
    build = function()
      if vim.fn.has("macunix") == 1 then
        -- macOS - use system fzf
        return
      else
        -- Linux
        vim.fn.system("./install --all")
      end
    end
  },
  { "junegunn/fzf.vim" },

  -- UI/UX plugins
  { "airblade/vim-gitgutter" },
  { "dracula/vim", name = "dracula" },
  { "cocopon/iceberg.vim" },
  { "projekt0n/github-nvim-theme" },
  { "tpope/vim-fugitive" },
  { "vim-airline/vim-airline" },
  { "vim-airline/vim-airline-themes" },
  
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

  -- LSP and completion plugins
  { "neovim/nvim-lspconfig" },
  {
    "williamboman/mason.nvim",
    build = ":MasonUpdate"
  },
  { "williamboman/mason-lspconfig.nvim" },

  -- Autocompletion plugins (nvim-cmp ecosystem)
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-nvim-lsp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "L3MON4D3/LuaSnip" },
  { "saadparwaiz1/cmp_luasnip" },
  { "rafamadriz/friendly-snippets" },
  { "onsails/lspkind-nvim" },

  -- AI Code Companion
  {
    "olimorris/codecompanion.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
      "hrsh7th/nvim-cmp", -- Optional: For using slash commands and variables in the chat buffer
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
          "rust", "go", "c", "cpp", "java", "ruby", "php"
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

  -- Exploration
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

-- ALE
g.ale_completion_enabled = 1
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

-- FZF
g.fzf_action = {
  ['ctrl-t'] = 'tab split',
  ['ctrl-x'] = 'split',
  ['ctrl-v'] = 'vsplit'
}

g.fzf_layout = { down = '~40%' }

g.fzf_colors = {
  fg = {'fg', 'Normal'},
  bg = {'bg', 'Normal'},
  hl = {'fg', 'Comment'},
  ['fg+'] = {'fg', 'CursorLine', 'CursorColumn', 'Normal'},
  ['bg+'] = {'bg', 'CursorLine', 'CursorColumn'},
  ['hl+'] = {'fg', 'Statement'},
  info = {'fg', 'PreProc'},
  border = {'fg', 'Ignore'},
  prompt = {'fg', 'Conditional'},
  pointer = {'fg', 'Exception'},
  marker = {'fg', 'Keyword'},
  spinner = {'fg', 'Label'},
  header = {'fg', 'Comment'}
}

g.fzf_history_dir = '~/.local/share/fzf-history'

-- Dracula theme settings
g.dracula_italic = 1
g.dracula_bold = 1
