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

  -- Writing and editing
  {
    "iamcco/markdown-preview.nvim",
    build = function() vim.fn["mkdp#util#install"]() end
  },
  {
    "nvim-treesitter/nvim-treesitter",
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
    "yelog/marklive.nvim",
    dependencies = { "nvim-treesitter/nvim-treesitter" },
    event = "VeryLazy",
    opts = {},
    config = function()
      local marklive = require("marklive")
      
      -- Load the full default config and maximize all features
      local config = require('marklive.config')
      
      -- Enable all features
      config.enable = true
      config.show_mode = 'normal-line' -- Show rendered content in normal mode
      config.filetype = { 'markdown', 'md', 'mkd', 'mkdn', 'mdwn', 'mdown', 'mdtxt', 'mdtext', 'rmd', 'wiki' }
      
      -- Enhanced highlight configuration with more vibrant colors
      config.highlight_config = vim.tbl_deep_extend("force", config.highlight_config or {}, {
        markdownBold = {
          highlight = { bold = true, fg = "#ff9b54" }
        },
        markdownItalic = {
          highlight = { italic = true, fg = "#ffd93d" }
        },
        markdownBoldItalic = {
          highlight = { bold = true, italic = true, fg = "#ff6bcb" }
        },
        markdownStrike = {
          highlight = { fg = "#6c757d", strikethrough = true }
        },
        markdownLinkText = {
          highlight = { fg = '#00b4d8', underline = true, bold = true }
        },
        markdownLinkTextDelimiter = {
          highlight = { fg = '#0077b6' }
        },
        markdownCode = {
          highlight = { fg = "#48cae4", bg = "#023e8a" }
        },
        markdownCodeDelimiter = {
          highlight = { fg = "#90e0ef", bg = "#023e8a" }
        },
        markdownBlockquote = {
          highlight = { fg = '#caf0f8', bg = '#03045e' }
        },
        markdownFootnote = {
          highlight = { fg = '#ff006e', bold = true }
        },
        markdownH1 = {
          highlight = { fg = '#ff006e', bold = true, bg = '#370617' }
        },
        markdownH1Delimiter = {
          highlight = { fg = '#ff006e', bold = true }
        },
        markdownH2 = {
          highlight = { fg = "#fb5607", bold = true }
        },
        markdownH2Delimiter = {
          highlight = { fg = "#fb5607", bold = true }
        },
        markdownH3 = {
          highlight = { fg = "#ffb700", bold = true }
        },
        markdownH3Delimiter = {
          highlight = { fg = "#ffb700", bold = true }
        },
        markdownH4 = {
          highlight = { fg = "#02c39a", bold = true }
        },
        markdownH4Delimiter = {
          highlight = { fg = "#02c39a", bold = true }
        },
        markdownH5 = {
          highlight = { fg = "#7209b7", bold = true }
        },
        markdownH5Delimiter = {
          highlight = { fg = "#7209b7", bold = true }
        },
        markdownH6 = {
          highlight = { fg = "#f72585", bold = true }
        },
        markdownH6Delimiter = {
          highlight = { fg = "#f72585", bold = true }
        },
        -- Extended highlights
        markliveMarkText = {
          matchadd = "\\v\\<mark\\>.*\\<\\/mark\\>",
          highlight = { bg = '#FFFF00', fg = '#000000', bold = true }
        },
        markliveTag = {
          matchadd = "\\v #[^# ]+",
          highlight = { fg = '#e0aaff', bg = '#10002b', bold = true }
        },
        markliveCalloutNote = {
          matchadd = "\\v> \\[!]NOTE\\]",
          highlight = { fg = '#00b4d8', bold = true }
        },
        markliveCalloutError = {
          matchadd = "\\v> \\[!]ERROR\\]",
          highlight = { fg = '#d00000', bold = true }
        },
        markliveCalloutTip = {
          matchadd = "\\v> \\[!]TIP\\]",
          highlight = { fg = '#06ffa5', bold = true }
        },
        markliveCalloutWarning = {
          matchadd = "\\v> \\[!]WARNING\\]",
          highlight = { fg = '#ffb700', bold = true }
        },
        markliveCalloutImportant = {
          matchadd = "\\v> \\[!]IMPORTANT\\]",
          highlight = { fg = '#ff006e', bold = true }
        },
        markliveCalloutCaution = {
          matchadd = "\\v> \\[!]CAUTION\\]",
          highlight = { fg = '#fb8500', bold = true }
        }
      })
      
      -- Enhanced render configuration with more icons and features
      config.render = vim.tbl_deep_extend("force", config.render or {}, {
        -- Task lists with more states
        task_list_marker_unchecked = {
          icon = "󰄱",
          highlight = { fg = "#ff006e" }
        },
        task_list_marker_checked = {
          icon = '󰄲',
          highlight = { fg = "#06ffa5" }
        },
        task_list_marker_indeterminate = {
          icon = '󰡖',
          highlight = { fg = '#ffb700' },
          regex = '(%[%-%])',
        },
        task_list_marker_cancelled = {
          icon = '󰰱',
          highlight = { fg = '#d00000' },
          regex = '(%[x%])',
        },
        -- Enhanced list markers
        list_marker_minus = {
          icon = '',
          highlight = { fg = '#ff9e00' },
          render = 'list'
        },
        list_marker_star = {
          icon = '',
          highlight = { fg = '#00f5ff' },
          render = 'list'
        },
        list_marker_plus = {
          icon = '',
          highlight = { fg = '#39ff14' },
          render = 'list'
        },
        -- Links and images with better icons
        link = {
          icon = { '󰌹' },
          regex = "[^!]%[[^%[%]]-%](%([^)]-%))",
          hl_group = 'markdownLinkText',
        },
        link_first = {
          icon = { '󰌹', '' },
          regex = "^%[[^%[%]]-%](%([^)]-%))",
          hl_group = 'markdownLinkText',
        },
        image = {
          icon = { '󰋩', '🖼️' },
          regex = "(!)%[[^%[%]]-%](%(.-%))",
          hl_group = 'markdownLinkText',
        },
        -- Enhanced code rendering
        inline_code = {
          icon = ' ',
          hl_group = "markdownCode",
          regex = '(`)[^`\n]+(`)',
        },
        -- Enhanced code blocks with clear visual borders
        code_block = {
          icon = "",
          query = { "(fenced_code_block) @code_block" },
          hl_fill = true,
          hl_group = 'MarkliveCodeBlock',
          highlight = { bg = "#161b22" }
        },
        -- Code fence delimiters
        fenced_code_block_delimiter = {
          icon = { "▶", " " },
          hl_group = 'MarkliveCodeFence',
          highlight = { fg = "#58a6ff", bold = true, bg = "#0d1117" },
          regex = "^```.*$"
        },
        -- Highlight info string (language)
        info_string = {
          icon = { " 󱅩 " },
          hl_group = 'MarkliveCodeLanguage', 
          highlight = { fg = "#ffa657", bg = "#0d1117", bold = true, italic = true }
        },
        -- Text formatting
        italic = {
          regex = "([*_])[^*`~]-([*_])",
        },
        bolder = {
          icon = '',
          regex = "(%*%*)[^%*]+(%*%*)",
        },
        strikethrough = {
          regex = "(~~)[^~]+(~~)",
        },
        underline = {
          regex = "(<u>).-(</u>)",
        },
        mark = {
          regex = "(<mark>).-(</mark>)",
        },
        -- Enhanced dividers
        thematic_break = {
          icon = '━',
          whole_line = true,
          hl_group = "markdownRule",
        },
        -- Enhanced blockquotes
        block_quote_marker = {
          icon = "▍",
          query = { 
            "(block_quote_marker) @block_quote_marker",
            "(block_quote (paragraph (inline (block_continuation) @block_quote_marker)))",
            "(block_quote (paragraph (block_continuation) @block_quote_marker))",
            "(block_quote (block_continuation) @block_quote_marker)" 
          },
          hl_group = 'markdownBlockquote'
        },
        -- Enhanced callouts with more types
        callout_note = {
          icon = { '󰋽', ' ', 'N', 'O', 'T', 'E', '' },
          regex = ">%s(%[)(!)(N)(O)(T)(E)(%])",
          hl_group = 'markliveCalloutNote',
        },
        callout_error = {
          icon = { '', ' ', 'E', 'R', 'R', 'O', 'R', '' },
          regex = ">%s(%[)(!)(E)(R)(R)(O)(R)(%])",
          hl_group = 'markliveCalloutError',
        },
        callout_tip = {
          icon = { '󰌶', ' ', 'T', 'I', 'P', '' },
          regex = ">%s(%[)(!)(T)(I)(P)(%])",
          hl_group = 'markliveCalloutTip',
        },
        callout_warning = {
          icon = { '', ' ', 'W', 'A', 'R', 'N', 'I', 'N', 'G', '' },
          regex = ">%s(%[)(!)(W)(A)(R)(N)(I)(N)(G)(%])",
          hl_group = 'markliveCalloutWarning',
        },
        callout_important = {
          icon = { '󰅾', ' ', 'I', 'M', 'P', 'O', 'R', 'T', 'A', 'N', 'T', '' },
          regex = ">%s(%[)(!)(I)(M)(P)(O)(R)(T)(A)(N)(T)(%])",
          hl_group = 'markliveCalloutImportant',
        },
        callout_caution = {
          icon = { '󰳦', ' ', 'C', 'A', 'U', 'T', 'I', 'O', 'N', '' },
          regex = ">%s(%[)(!)(C)(A)(U)(T)(I)(O)(N)(%])",
          hl_group = 'markliveCalloutCaution',
        },
        -- Enhanced headers with unique icons
        atx_h1_marker = {
          icon = "󰉫",
          hl_group = "markdownH1Delimiter",
        },
        atx_h2_marker = {
          icon = "󰉬",
          hl_group = "markdownH2Delimiter"
        },
        atx_h3_marker = {
          icon = "󰉭",
          hl_group = "markdownH3Delimiter"
        },
        atx_h4_marker = {
          icon = "󰉮",
          hl_group = "markdownH4Delimiter"
        },
        atx_h5_marker = {
          icon = "󰉯",
          hl_group = "markdownH5Delimiter"
        },
        atx_h6_marker = {
          icon = "󰉰",
          hl_group = "markdownH6Delimiter"
        },
        -- Tags with better icon
        tag = {
          icon = "󰓹",
          hl_group = "markliveTag",
          regex = " (#)[^# ]+",
        },
        -- Additional custom elements
        footnote = {
          icon = "󰇈",
          regex = "%[%^[^%]]+%]",
          hl_group = "markdownFootnote"
        },
        emoji = {
          icon = "",
          regex = ":[%w_%-]+:",
          highlight = { fg = "#ffd93d" }
        }
      })
      
      marklive.setup(config)
      
      -- Set up custom highlights for code blocks with clear visual separation
      vim.api.nvim_set_hl(0, 'MarkliveCodeBlock', { bg = '#161b22' })
      vim.api.nvim_set_hl(0, 'MarkliveCodeFence', { fg = '#58a6ff', bg = '#0d1117', bold = true })
      vim.api.nvim_set_hl(0, 'MarkliveCodeLanguage', { fg = '#ffa657', bg = '#0d1117', bold = true, italic = true })
      vim.api.nvim_set_hl(0, 'MarkliveCodeBorder', { fg = '#30363d' })
      
      -- Additional highlights for code block elements
      vim.api.nvim_set_hl(0, 'markdownCode', { fg = '#e6edf3', bg = '#161b22' })
      vim.api.nvim_set_hl(0, 'markdownCodeBlock', { bg = '#161b22' })
      
      -- Additional code block styling
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown", "md" },
        callback = function()
          -- Add visual separation for code blocks
          vim.cmd([[
            syn match markdownCodeDelimiter "^```.*$" contains=markdownCodeLang
            syn match markdownCodeLang "\v```\zs\w+" contained
            hi markdownCodeDelimiter guifg=#48cae4 gui=bold
            hi markdownCodeLang guifg=#ffa657 gui=bold,italic guibg=#161b22
            
            " Add box drawing characters around code blocks
            syn match markdownCodeBlockBorder "^│" contained
            hi markdownCodeBlockBorder guifg=#30363d
          ]])
        end
      })
      
      -- Auto-enable for markdown files
      vim.api.nvim_create_autocmd("FileType", {
        pattern = { "markdown", "md", "mkd", "mkdn", "mdwn", "mdown", "mdtxt", "mdtext", "rmd", "wiki" },
        callback = function()
          vim.cmd("MarkliveEnable")
          -- Enable syntax highlighting within markdown
          vim.opt_local.conceallevel = 2
          vim.opt_local.concealcursor = 'nc'
        end,
      })
    end
  },
  { "illyastarikov/vim-snippets" },
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