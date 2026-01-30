--
-- vimtex.lua
-- Comprehensive VimTeX configuration for LaTeX editing
--

local M = {}

function M.setup()
  -- ⚡ PERFORMANCE SETTINGS
  -- Enable faster syntax highlighting
  vim.g.vimtex_syntax_enabled = 1
  vim.g.vimtex_syntax_conceal_disable = 0

  -- Disable unused features for better performance
  vim.g.vimtex_mappings_disable = {
    -- Keep essential mappings, disable others for performance
    -- We'll define custom mappings below
  }

  -- 🔧 COMPILER CONFIGURATION
  -- Use latexmk as the default compiler (most reliable)
  vim.g.vimtex_compiler_method = "latexmk"

  -- Advanced latexmk configuration
  vim.g.vimtex_compiler_latexmk = {
    aux_dir = "", -- Keep aux files in same directory
    out_dir = "", -- Keep output files in same directory
    callback = 1,
    continuous = 1, -- Enable continuous compilation
    executable = "/Library/TeX/texbin/latexmk",
    options = {
      "-verbose",
      "-file-line-error",
      "-synctex=1",
      "-interaction=nonstopmode",
      "-shell-escape", -- Enable shell escape for advanced packages
    },
  }

  -- Alternative: Use tectonic for faster compilation (if available)
  -- vim.g.vimtex_compiler_method = 'tectonic'
  -- vim.g.vimtex_compiler_tectonic = {
  --   build_dir = '',
  --   options = {
  --     '--synctex',
  --     '--keep-logs',
  --   },
  -- }

  -- 🖥️ VIEWER CONFIGURATION
  -- Detect and configure the best available PDF viewer
  local function setup_viewer()
    -- macOS: Use native Preview or Skim
    if vim.fn.has("mac") == 1 then
      if vim.fn.executable("skim") == 1 then
        vim.g.vimtex_view_method = "skim"
        vim.g.vimtex_view_skim_sync = 1
        vim.g.vimtex_view_skim_activate = 1
      else
        vim.g.vimtex_view_method = "general"
        vim.g.vimtex_view_general_viewer = "open"
        vim.g.vimtex_view_general_options = "-a Preview"
      end
    -- Linux: Use zathura or evince
    elseif vim.fn.has("unix") == 1 then
      if vim.fn.executable("zathura") == 1 then
        vim.g.vimtex_view_method = "zathura"
        vim.g.vimtex_view_zathura_options = "-reuse-instance"
      elseif vim.fn.executable("evince") == 1 then
        vim.g.vimtex_view_method = "general"
        vim.g.vimtex_view_general_viewer = "evince"
      else
        vim.g.vimtex_view_method = "general"
        vim.g.vimtex_view_general_viewer = "xdg-open"
      end
    -- Windows: Use SumatraPDF
    elseif vim.fn.has("win32") == 1 then
      vim.g.vimtex_view_method = "general"
      vim.g.vimtex_view_general_viewer = "SumatraPDF"
      vim.g.vimtex_view_general_options =
        '-reuse-instance -inverse-search "nvim --headless -c "VimtexInverseSearch %l \'%f\'""'
    end
  end

  setup_viewer()

  -- ✨ FEATURES CONFIGURATION
  -- Enable quickfix window for errors
  vim.g.vimtex_quickfix_mode = 2 -- Open quickfix automatically, but don't focus it
  vim.g.vimtex_quickfix_autoclose_after_keystrokes = 3

  -- Configure completion
  vim.g.vimtex_complete_enabled = 1
  vim.g.vimtex_complete_close_braces = 1
  vim.g.vimtex_complete_ignore_case = 1
  vim.g.vimtex_complete_smart_case = 1

  -- Citation completion (for bibliography)
  vim.g.vimtex_complete_bib = {
    simple = 0, -- Don't use simple completion
    menu_fmt = "@key @type @author_short @title_short (@year)",
  }

  -- 🎨 SYNTAX AND CONCEALMENT
  -- Enable syntax concealment for a cleaner look
  vim.g.vimtex_syntax_conceal = {
    accents = 1,
    ligatures = 1,
    cites = 1,
    fancy = 1,
    spacing = 0, -- Keep spacing visible for precision
    greek = 1,
    math_bounds = 1,
    math_delimiters = 1,
    math_fracs = 1,
    math_super_sub = 1,
    math_symbols = 1,
    sections = 1,
    styles = 1,
  }

  -- 📁 FILE DETECTION AND FORMATS
  -- Recognize additional LaTeX file types
  vim.g.vimtex_filetypes = { "tex", "latex", "plaintex" }

  -- Enable subfile support for large documents
  vim.g.vimtex_subfile_start_local = 1

  -- 🔍 SEARCH AND NAVIGATION
  -- Configure include search
  vim.g.vimtex_include_search_enabled = 1

  -- TOC (Table of Contents) configuration
  vim.g.vimtex_toc_config = {
    name = "TOC",
    layers = { "content", "todo", "include" },
    split_width = 30,
    todo_sorted = 0,
    show_help = 1,
    show_numbers = 1,
    mode = 2, -- Show context
  }

  -- 🚫 DISABLE UNWANTED FEATURES
  -- Disable default imaps (we'll use snippets instead)
  vim.g.vimtex_imaps_enabled = 0

  -- Disable default text objects (we'll define custom ones)
  vim.g.vimtex_text_obj_enabled = 1

  -- Disable matchparen for performance
  vim.g.vimtex_matchparen_enabled = 0

  -- 🎯 INTEGRATION SETTINGS
  -- Configure for use with modern completion engines
  vim.g.vimtex_compiler_progname = "nvim"

  -- Set up format options for LaTeX
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "tex", "latex", "plaintex" },
    callback = function()
      -- Set local options for LaTeX files
      vim.opt_local.wrap = true
      vim.opt_local.linebreak = true
      vim.opt_local.textwidth = 100
      vim.opt_local.colorcolumn = "101"
      vim.opt_local.conceallevel = 2 -- Enable concealment
      vim.opt_local.concealcursor = "" -- Don't conceal under cursor
      vim.opt_local.spell = true
      vim.opt_local.spelllang = "en_us"

      -- Set indentation for LaTeX
      vim.opt_local.shiftwidth = 2
      vim.opt_local.tabstop = 2
      vim.opt_local.softtabstop = 2
      vim.opt_local.expandtab = true

      -- Enable folding based on LaTeX structure but start unfolded
      vim.opt_local.foldmethod = "expr"
      vim.opt_local.foldexpr = "vimtex#fold#level(v:lnum)"
      vim.opt_local.foldtext = "vimtex#fold#text()"
      vim.opt_local.fillchars:append("fold: ")
      vim.opt_local.foldlevel = 99 -- Start with all folds open
      vim.opt_local.foldlevelstart = 99 -- Always start unfolded
    end,
  })

  -- 🎨 CUSTOM SYNTAX HIGHLIGHTING
  -- Enhance syntax highlighting for common LaTeX packages
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "tex", "latex", "plaintex" },
    callback = function()
      -- Additional syntax groups for popular packages
      vim.cmd([[
        " Highlight TODO comments
        syntax match texTodo /TODO\|FIXME\|NOTE\|XXX/ containedin=texComment
        highlight link texTodo Todo

        " Highlight custom commands
        syntax match texUserCommand /\\[a-zA-Z@]\+/ containedin=ALL
        highlight link texUserCommand Function

        " Highlight equation labels
        syntax match texLabel /\\label{[^}]*}/ containedin=ALL
        highlight link texLabel Label

        " Highlight references
        syntax match texRef /\\[a-zA-Z]*ref{[^}]*}/ containedin=ALL
        highlight link texRef PreProc
      ]])
    end,
  })

  -- 📝 CUSTOM COMMANDS
  -- Define useful LaTeX commands
  vim.api.nvim_create_user_command("VimtexCompileToggle", function()
    vim.cmd("VimtexCompile")
  end, { desc = "Toggle LaTeX compilation" })

  vim.api.nvim_create_user_command("VimtexCleanAll", function()
    vim.cmd("VimtexClean!")
  end, { desc = "Clean all LaTeX auxiliary files" })

  vim.api.nvim_create_user_command("VimtexStatus", function()
    vim.cmd("VimtexInfo")
  end, { desc = "Show VimTeX status information" })

  -- 🔧 ERROR HANDLING
  -- Configure error handling and quickfix behavior
  vim.g.vimtex_quickfix_ignore_filters = {
    "Underfull \\hbox",
    "Overfull \\hbox",
    "LaTeX Warning: .\\+ float specifier changed to",
    "LaTeX hooks Warning",
    'Package siunitx Warning: Detected the "physics" package:',
    "Package hyperref Warning: Token not allowed in a PDF string",
  }

  -- 🎵 NOTIFICATIONS
  -- Set up compilation notifications
  if vim.fn.executable("notify-send") == 1 then
    vim.g.vimtex_compiler_latexmk.callback_hooks = {
      function(status)
        if status == 0 then
          vim.fn.system('notify-send "LaTeX" "Compilation successful"')
        else
          vim.fn.system('notify-send "LaTeX" "Compilation failed"')
        end
      end,
    }
  end

  -- 📊 PERFORMANCE OPTIMIZATION
  -- Optimize for large documents
  vim.g.vimtex_cache_root = vim.fn.stdpath("cache") .. "/vimtex"
  vim.g.vimtex_cache_persistent = 1

  -- Set up buffer-local completion for blink.cmp integration
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "tex", "latex", "plaintex" },
    callback = function()
      -- Configure blink.cmp sources for LaTeX
      local ok, blink = pcall(require, "blink.cmp")
      if ok and blink.setup then
        -- Add vimtex-specific completion sources
        vim.b.blink_cmp_sources = { "lsp", "path", "buffer", "vimtex" }
      end
    end,
  })
end

return M
