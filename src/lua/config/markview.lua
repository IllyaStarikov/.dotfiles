--
-- Markview.nvim configuration
-- Maximum compatibility configuration with rich features
--

local M = {}

function M.setup()
  -- Start with markview enabled for rich preview
  vim.g.markview_enable = 1
  
  -- Ensure font is set before markview loads
  if vim.fn.has('gui_running') == 1 or vim.g.neovide then
    vim.opt.guifont = "Lilex Nerd Font:h18"
  end
  
  -- Ensure UTF-8 encoding
  vim.opt.encoding = "utf-8"
  vim.opt.fileencoding = "utf-8"
  
  -- Tell Neovim we have nerd fonts
  vim.g.have_nerd_font = true
  
  local markview = require("markview")
  local presets = require("markview.presets")
  
  markview.setup({
    
    -- Preserve ligatures
    preserve_whitespace = true,
    
    -- Preview configuration (moved deprecated options here)
    preview = {
      -- Mode configuration - render in normal mode only
      modes = { "n", "no" },
      hybrid_modes = { "i" },
      
      -- Callbacks
      callbacks = {
        on_enable = {},
        on_disable = {},
        on_mode_change = {}
      },
      
      -- Buffer options
      ignore_buftypes = { "nofile" },
      debounce = 50,
      
      -- Filetypes
      filetypes = { "markdown", "quarto", "rmd" },
      
      -- Split options
      splitview_winopts = {},
      
      -- Icon provider - enable devicons for language icons
      icon_provider = "devicons",
    },
    
    -- Highlight groups
    highlight_groups = "dynamic",
    
    -- Main markdown configuration
    markdown = {
      enable = true,
      max_file_length = 1000,
      
      -- Headings with ligature-like symbols
      headings = {
        enable = true,
        shift_width = 0,
        
        heading_1 = {
          style = "label",
          padding_left = " ",
          padding_right = " ",
          icon = "❯ ",  -- Single chevron for H1
          hl = "MarkviewHeading1",
          icon_hl = "MarkviewHeading1",
          sign = false,
        },
        heading_2 = {
          style = "label", 
          padding_left = " ",
          padding_right = " ",
          icon = "❯❯ ",  -- Double chevron for H2
          hl = "MarkviewHeading2",
          icon_hl = "MarkviewHeading2",
          sign = false,
        },
        heading_3 = {
          style = "label",
          padding_left = " ",
          padding_right = " ",
          icon = "❯❯❯ ",  -- Triple chevron for H3
          hl = "MarkviewHeading3",
          icon_hl = "MarkviewHeading3",
          sign = false,
        },
        heading_4 = {
          style = "label",
          padding_left = " ",
          padding_right = " ",
          icon = "❯❯❯❯ ",  -- Quadruple chevron for H4
          hl = "MarkviewHeading4",
          icon_hl = "MarkviewHeading4",
          sign = false,
        },
        heading_5 = {
          style = "label",
          padding_left = " ",
          padding_right = " ",
          icon = "❯❯❯❯❯ ",  -- Quintuple chevron for H5
          hl = "MarkviewHeading5",
          icon_hl = "MarkviewHeading5",
          sign = false,
        },
        heading_6 = {
          style = "label",
          padding_left = " ",
          padding_right = " ",
          icon = "❯❯❯❯❯❯ ",  -- Sextuple chevron for H6
          hl = "MarkviewHeading6",
          icon_hl = "MarkviewHeading6",
          sign = false,
        },
        
        -- Setext headers (alternative headers with === and ---)
        setext_1 = {
          style = "simple",
          hl = "MarkviewHeading1",
          icon = "❯ ",  -- Single chevron for setext H1
          icon_hl = "MarkviewHeading1",
        },
        setext_2 = {
          style = "simple", 
          hl = "MarkviewHeading2",
          icon = "❯❯ ",  -- Double chevron for setext H2
          icon_hl = "MarkviewHeading2",
        },
      },
      
      -- Code blocks with language labels (no icons)
      code_blocks = {
        enable = true,
        style = "minimal",
        min_width = 70,
        pad_amount = 2,
        pad_char = " ",
        
        -- Language configuration
        language_names = {
          bash = "BASH",
          sh = "SHELL",
          python = "PYTHON",
          py = "PYTHON",
          javascript = "JS",
          js = "JS",
          typescript = "TS",
          ts = "TS",
          lua = "LUA",
          vim = "VIM",
          rust = "RUST",
          go = "GO",
          c = "C",
          cpp = "C++",
          java = "JAVA",
          ruby = "RUBY",
          rb = "RUBY",
          html = "HTML",
          css = "CSS",
          json = "JSON",
          yaml = "YAML",
          yml = "YAML",
          toml = "TOML",
          markdown = "MD",
          md = "MD",
        },
        
        -- Language direction
        language_direction = "right",
        
        -- Disable icons if they're not showing
        icons = false,
        sign = false,
        
        -- Default highlighting
        hl = "MarkviewCode",
      },
      
      -- Block quotes with simple ASCII
      block_quotes = {
        enable = true,
        default = {
          border_left = "┃",
          border_left_hl = "MarkviewBlockQuoteDefault",
          border_top_left = "",
          border_top = "",
          border_top_right = "",
          border_bottom_left = "",
          border_bottom = "",
          border_bottom_right = "",
          border_right = "",
          
          quote_char = "┃ ",
          quote_char_hl = "MarkviewBlockQuoteDefault",
        },
        
        -- Callouts without icons
        callouts = {
          {
            match_string = "NOTE",
            callout_preview = "ℹ️  NOTE",
            callout_preview_hl = "MarkviewBlockQuoteNote",
            custom_title = true,
            custom_icon = "ℹ️ ",
            border_left = "│",
            border_left_hl = "MarkviewBlockQuoteNote",
          },
          {
            match_string = "TIP",
            callout_preview = "💡 TIP",
            callout_preview_hl = "MarkviewBlockQuoteOk",
            custom_title = true,
            custom_icon = "💡",
            border_left = "│",
            border_left_hl = "MarkviewBlockQuoteOk",
          },
          {
            match_string = "IMPORTANT",
            callout_preview = "⭐ IMPORTANT",
            callout_preview_hl = "MarkviewBlockQuoteSpecial",
            custom_title = true,
            custom_icon = "⭐",
            border_left = "│",
            border_left_hl = "MarkviewBlockQuoteSpecial",
          },
          {
            match_string = "WARNING",
            callout_preview = "⚡ WARNING",
            callout_preview_hl = "MarkviewBlockQuoteWarn",
            custom_title = true,
            custom_icon = "⚡",
            border_left = "│",
            border_left_hl = "MarkviewBlockQuoteWarn",
          },
          {
            match_string = "CAUTION",
            callout_preview = "🚨 CAUTION",
            callout_preview_hl = "MarkviewBlockQuoteError",
            custom_title = true,
            custom_icon = "🚨",
            border_left = "│",
            border_left_hl = "MarkviewBlockQuoteError",
          },
        },
      },
      
      -- Horizontal rules with elegant line
      horizontal_rules = {
        enable = true,
        parts = {
          {
            type = "repeating",
            repeat_amount = vim.api.nvim_win_get_width,
            
            text = "─",
            hl = "MarkviewRule",
          },
        },
      },
      
      -- Enable list items with better Unicode symbols
      list_items = {
        enable = true,
        marker_plus = {
          text = "✦ ",  -- Four-pointed star for plus lists
          hl = "MarkviewListItemPlus"
        },
        marker_minus = {
          text = "▪ ",  -- Square bullet for minus lists
          hl = "MarkviewListItemMinus"  
        },
        marker_star = {
          text = "◆ ",  -- Diamond for star lists
          hl = "MarkviewListItemStar"
        }
      },
      
      -- Tables with ASCII borders
      tables = {
        enable = true,
        col_min_width = 10,
        block_decorator = true,
        use_virt_lines = false,
        
        -- Table parts with modern box drawing
        parts = {
          top = { "┌", "─", "┬", "─", "┐" },
          header = { "│", " ", "│", " ", "│" },
          separator = { "├", "─", "┼", "─", "┤" },
          row = { "│", " ", "│", " ", "│" },
          bottom = { "└", "─", "┴", "─", "┘" },
        },
        
        -- Alignment
        align_left = " ",
        align_right = " ",
        align_center = " ",
        
        -- Highlighting
        hl = {
          top = "MarkviewTableBorder",
          header = "MarkviewTableHeader",
          separator = "MarkviewTableBorder",
          row = "MarkviewTable",
          bottom = "MarkviewTableBorder",
        },
      },
    },
    
    -- Inline markdown features
    markdown_inline = {
      enable = true,
      
      -- Disable features that might interfere with ligatures
      escape = {
        enable = false  -- Don't process escape sequences
      },
      
      -- Enable checkboxes with modern symbols
      checkboxes = {
        enable = true,
        checked = { 
          text = "✓", 
          hl = "MarkviewCheckboxChecked" 
        },
        unchecked = { 
          text = "□", 
          hl = "MarkviewCheckboxUnchecked" 
        },
        pending = { 
          text = "◐", 
          hl = "MarkviewCheckboxPending" 
        },
      },
      
      -- Code spans
      code = {
        enable = true,
        corner_left = " ",
        corner_right = " ",
        
        hl = "MarkviewInlineCode",
      },
      
      -- Emphasis
      italic = {
        enable = true,
        corner_left = "",
        corner_right = "",
        hl = "MarkviewItalic",
      },
      bold = {
        enable = true,
        corner_left = "",
        corner_right = "",
        hl = "MarkviewBold",
      },
      bold_italic = {
        enable = true,
        corner_left = "",
        corner_right = "",
        hl = "MarkviewBoldItalic",
      },
      strikethrough = {
        enable = true,
        corner_left = "",
        corner_right = "",
        hl = "MarkviewStrikethrough",
      },
      
      -- Hyperlinks (for [text](url) style links)
      hyperlinks = { 
        enable = true,
        default = {
          icon = "◉ ",  -- Filled circle for hyperlinks
          hl = "MarkviewHyperlink",
        }
      },
      
      -- Images
      images = { 
        enable = false,
      },
      
      -- Email links
      emails = { 
        enable = false,
      },
    },
  })
  
  -- Set up highlight groups with TokyoNight Moon colors
  local highlights = {
    -- Headings - dark text on bright backgrounds for readability
    MarkviewHeading1 = { fg = "#222436", bg = "#ff757f", bold = true },
    MarkviewHeading1Sign = { fg = "#222436", bg = "#ff757f", bold = true },
    MarkviewHeading2 = { fg = "#222436", bg = "#c099ff", bold = true },
    MarkviewHeading2Sign = { fg = "#222436", bg = "#c099ff", bold = true },
    MarkviewHeading3 = { fg = "#222436", bg = "#86e1fc", bold = true },
    MarkviewHeading3Sign = { fg = "#222436", bg = "#86e1fc", bold = true },
    MarkviewHeading4 = { fg = "#222436", bg = "#c3e88d", bold = true },
    MarkviewHeading4Sign = { fg = "#222436", bg = "#c3e88d", bold = true },
    MarkviewHeading5 = { fg = "#222436", bg = "#ffc777", bold = true },
    MarkviewHeading5Sign = { fg = "#222436", bg = "#ffc777", bold = true },
    MarkviewHeading6 = { fg = "#222436", bg = "#ff966c", bold = true },
    MarkviewHeading6Sign = { fg = "#222436", bg = "#ff966c", bold = true },
    
    -- Setext headers and their underlines
    MarkviewSetextHeading1 = { fg = "#222436", bg = "#ff757f", bold = true },
    MarkviewSetextHeading2 = { fg = "#222436", bg = "#c099ff", bold = true },
    MarkviewSetext1 = { fg = "#222436", bg = "#ff757f", bold = true },
    MarkviewSetext2 = { fg = "#222436", bg = "#c099ff", bold = true },
    MarkviewSetextUnderline = { fg = "#ff757f", bold = true },
    
    -- Lists
    MarkviewListItemMinus = { fg = "#c3e88d", bold = true },
    MarkviewListItemPlus = { fg = "#86e1fc", bold = true },
    MarkviewListItemStar = { fg = "#ffc777", bold = true },
    
    -- Code
    MarkviewCode = { bg = "#2f334d" },
    MarkviewInlineCode = { fg = "#86e1fc", bg = "#2f334d" },
    
    -- Tables
    MarkviewTable = { bg = "#1e2030" },
    MarkviewTableHeader = { fg = "#c099ff", bg = "#1e2030", bold = true },
    MarkviewTableBorder = { fg = "#636da6" },
    
    -- Block quotes
    MarkviewBlockQuoteDefault = { fg = "#636da6", italic = true },
    MarkviewBlockQuoteNote = { fg = "#86e1fc", bg = "#2d3f4f" },
    MarkviewBlockQuoteOk = { fg = "#c3e88d", bg = "#2d3f2d" },
    MarkviewBlockQuoteSpecial = { fg = "#c099ff", bg = "#3d2d4f" },
    MarkviewBlockQuoteWarn = { fg = "#ffc777", bg = "#4f4f2d" },
    MarkviewBlockQuoteError = { fg = "#ff757f", bg = "#4f2d2d" },
    
    -- Checkboxes
    MarkviewCheckboxChecked = { fg = "#c3e88d", bold = true },
    MarkviewCheckboxUnchecked = { fg = "#ff757f" },
    MarkviewCheckboxPending = { fg = "#ffc777" },
    MarkviewCheckboxProgress = { fg = "#86e1fc" },
    MarkviewCheckboxCancelled = { fg = "#636da6", strikethrough = true },
    
    -- Text emphasis
    MarkviewBold = { bold = true },
    MarkviewItalic = { italic = true },
    MarkviewBoldItalic = { bold = true, italic = true },
    MarkviewStrikethrough = { strikethrough = true },
    
    -- Rules
    MarkviewRule = { fg = "#636da6" },
    
    -- Links
    MarkviewLink = { fg = "#82aaff", underline = true },
    MarkviewHyperlink = { fg = "#82aaff", underline = true },
  }
  
  -- Apply highlights with higher priority to ensure they override theme
  vim.schedule(function()
    for group, opts in pairs(highlights) do
      vim.api.nvim_set_hl(0, group, opts)
    end
  end)
  
  -- Configure Lilex Nerd Font ligatures for markview
  -- This ensures ligatures render properly in markdown preview
  vim.opt.guifont = "Lilex Nerd Font:h18"
  
  -- Lilex Nerd Font has excellent ligature support!
  
  -- Auto-enable for markdown files
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "markdown", "quarto", "rmd" },
    callback = function()
      -- Start with markview enabled (rich preview)
      vim.opt_local.conceallevel = 2
      vim.opt_local.concealcursor = ""
      vim.opt_local.list = false
      
      -- Create a buffer-local variable to track state
      vim.b.markview_enabled = true
      
      -- Reapply highlights to ensure they take effect
      vim.schedule(function()
        for group, opts in pairs(highlights) do
          vim.api.nvim_set_hl(0, group, opts)
        end
      end)
      
      -- Smart toggle between rich preview and ligatures
      vim.keymap.set("n", "<leader>mp", function()
        if vim.b.markview_enabled then
          vim.cmd("Markview disable")
          vim.opt_local.conceallevel = 0
          vim.b.markview_enabled = false
          vim.notify("Ligatures enabled ✓ (markview disabled)", vim.log.levels.INFO)
        else
          vim.cmd("Markview enable")
          vim.opt_local.conceallevel = 2
          vim.b.markview_enabled = true
          vim.notify("Rich preview enabled (ligatures disabled)", vim.log.levels.INFO)
        end
      end, { 
        buffer = true, 
        desc = "Toggle between rich preview and ligatures" 
      })
      
    end
  })
  
  -- Disable markview in insert mode, re-enable in normal mode
  vim.api.nvim_create_autocmd({"InsertEnter"}, {
    pattern = { "*.md", "*.markdown", "*.rmd", "*.qmd" },
    callback = function()
      if vim.b.markview_enabled then
        vim.cmd("Markview disable")
        vim.b.markview_insert_disabled = true
      end
    end
  })
  
  vim.api.nvim_create_autocmd({"InsertLeave"}, {
    pattern = { "*.md", "*.markdown", "*.rmd", "*.qmd" },
    callback = function()
      if vim.b.markview_insert_disabled then
        vim.cmd("Markview enable")
        vim.b.markview_insert_disabled = false
      end
    end
  })
  
  -- No longer need conflicting autocmds - toggle handles concealment
end

return M