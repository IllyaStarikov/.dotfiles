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
      
      -- Don't show virtual text for non-existent frontmatter
      show_virtual = false,
      
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
      
      -- Disable frontmatter rendering if not present
      frontmatter = {
        enable = false
      },
      
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
            repeat_amount = function()
              return vim.api.nvim_win_get_width(0) - 4
            end,
            
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
  
  -- Function to get theme-appropriate colors
  local function get_theme_colors()
    local config_file = vim.fn.expand("~/.config/theme-switcher/current-theme.sh")
    local is_light_theme = false
    
    if vim.fn.filereadable(config_file) == 1 then
      local theme_cmd = "source " .. config_file .. " && echo $MACOS_THEME"
      local background_cmd = "source " .. config_file .. " && echo $MACOS_BACKGROUND"
      local theme = vim.fn.system(theme_cmd):gsub('\n', '')
      local background = vim.fn.system(background_cmd):gsub('\n', '')
      
      -- Check if it's a light theme either by name or background setting
      if theme == "tokyonight_day" or background == "light" then
        is_light_theme = true
      end
    end
    
    if is_light_theme then
      -- TokyoNight Day colors
      return {
        bg = "#e1e2e7",  -- Light background
        heading1_bg = "#f52a65",
        heading2_bg = "#9854f1",
        heading3_bg = "#007197",
        heading4_bg = "#587539",
        heading5_bg = "#8c6c3e",
        heading6_bg = "#bf8040",
        list_minus = "#587539",
        list_plus = "#007197",
        list_star = "#8c6c3e",
        code_bg = "#d4d6e4",
        table_bg = "#d4d6e4",
        comment = "#848cb5",
        link = "#2e7de9",
      }
    else
      -- TokyoNight Moon colors (default dark)
      return {
        bg = "#222436",  -- Dark background
        heading1_bg = "#ff757f",
        heading2_bg = "#c099ff",
        heading3_bg = "#86e1fc",
        heading4_bg = "#c3e88d",
        heading5_bg = "#ffc777",
        heading6_bg = "#ff966c",
        list_minus = "#c3e88d",
        list_plus = "#86e1fc",
        list_star = "#ffc777",
        code_bg = "#2f334d",
        table_bg = "#1e2030",
        comment = "#636da6",
        link = "#82aaff",
      }
    end
  end
  
  -- Get current theme colors
  local colors = get_theme_colors()
  
  -- Set up highlight groups with dynamic colors
  local highlights = {
    -- Headings - use theme background for text color
    MarkviewHeading1 = { fg = colors.bg, bg = colors.heading1_bg, bold = true },
    MarkviewHeading1Sign = { fg = colors.bg, bg = colors.heading1_bg, bold = true },
    MarkviewHeading2 = { fg = colors.bg, bg = colors.heading2_bg, bold = true },
    MarkviewHeading2Sign = { fg = colors.bg, bg = colors.heading2_bg, bold = true },
    MarkviewHeading3 = { fg = colors.bg, bg = colors.heading3_bg, bold = true },
    MarkviewHeading3Sign = { fg = colors.bg, bg = colors.heading3_bg, bold = true },
    MarkviewHeading4 = { fg = colors.bg, bg = colors.heading4_bg, bold = true },
    MarkviewHeading4Sign = { fg = colors.bg, bg = colors.heading4_bg, bold = true },
    MarkviewHeading5 = { fg = colors.bg, bg = colors.heading5_bg, bold = true },
    MarkviewHeading5Sign = { fg = colors.bg, bg = colors.heading5_bg, bold = true },
    MarkviewHeading6 = { fg = colors.bg, bg = colors.heading6_bg, bold = true },
    MarkviewHeading6Sign = { fg = colors.bg, bg = colors.heading6_bg, bold = true },
    
    -- Setext headers and their underlines
    MarkviewSetextHeading1 = { fg = colors.bg, bg = colors.heading1_bg, bold = true },
    MarkviewSetextHeading2 = { fg = colors.bg, bg = colors.heading2_bg, bold = true },
    MarkviewSetext1 = { fg = colors.bg, bg = colors.heading1_bg, bold = true },
    MarkviewSetext2 = { fg = colors.bg, bg = colors.heading2_bg, bold = true },
    MarkviewSetextUnderline = { fg = colors.heading1_bg, bold = true },
    
    -- Lists
    MarkviewListItemMinus = { fg = colors.list_minus, bold = true },
    MarkviewListItemPlus = { fg = colors.list_plus, bold = true },
    MarkviewListItemStar = { fg = colors.list_star, bold = true },
    
    -- Code
    MarkviewCode = { bg = colors.code_bg },
    MarkviewInlineCode = { fg = colors.heading3_bg, bg = colors.code_bg },
    
    -- Tables
    MarkviewTable = { bg = colors.table_bg },
    MarkviewTableHeader = { fg = colors.heading2_bg, bg = colors.table_bg, bold = true },
    MarkviewTableBorder = { fg = colors.comment },
    
    -- Block quotes
    MarkviewBlockQuoteDefault = { fg = colors.comment, italic = true },
    MarkviewBlockQuoteNote = { fg = colors.heading3_bg, bg = colors.code_bg },
    MarkviewBlockQuoteOk = { fg = colors.heading4_bg, bg = colors.code_bg },
    MarkviewBlockQuoteSpecial = { fg = colors.heading2_bg, bg = colors.code_bg },
    MarkviewBlockQuoteWarn = { fg = colors.heading5_bg, bg = colors.code_bg },
    MarkviewBlockQuoteError = { fg = colors.heading1_bg, bg = colors.code_bg },
    
    -- Checkboxes
    MarkviewCheckboxChecked = { fg = colors.heading4_bg, bold = true },
    MarkviewCheckboxUnchecked = { fg = colors.heading1_bg },
    MarkviewCheckboxPending = { fg = colors.heading5_bg },
    MarkviewCheckboxProgress = { fg = colors.heading3_bg },
    MarkviewCheckboxCancelled = { fg = colors.comment, strikethrough = true },
    
    -- Text emphasis
    MarkviewBold = { bold = true },
    MarkviewItalic = { italic = true },
    MarkviewBoldItalic = { bold = true, italic = true },
    MarkviewStrikethrough = { strikethrough = true },
    
    -- Rules
    MarkviewRule = { fg = colors.comment },
    
    -- Links
    MarkviewLink = { fg = colors.link, underline = true },
    MarkviewHyperlink = { fg = colors.link, underline = true },
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
      
      -- Reapply highlights with current theme colors
      vim.schedule(function()
        local current_colors = get_theme_colors()
        local current_highlights = {
          -- Headings
          MarkviewHeading1 = { fg = current_colors.bg, bg = current_colors.heading1_bg, bold = true },
          MarkviewHeading1Sign = { fg = current_colors.bg, bg = current_colors.heading1_bg, bold = true },
          MarkviewHeading2 = { fg = current_colors.bg, bg = current_colors.heading2_bg, bold = true },
          MarkviewHeading2Sign = { fg = current_colors.bg, bg = current_colors.heading2_bg, bold = true },
          MarkviewHeading3 = { fg = current_colors.bg, bg = current_colors.heading3_bg, bold = true },
          MarkviewHeading3Sign = { fg = current_colors.bg, bg = current_colors.heading3_bg, bold = true },
          MarkviewHeading4 = { fg = current_colors.bg, bg = current_colors.heading4_bg, bold = true },
          MarkviewHeading4Sign = { fg = current_colors.bg, bg = current_colors.heading4_bg, bold = true },
          MarkviewHeading5 = { fg = current_colors.bg, bg = current_colors.heading5_bg, bold = true },
          MarkviewHeading5Sign = { fg = current_colors.bg, bg = current_colors.heading5_bg, bold = true },
          MarkviewHeading6 = { fg = current_colors.bg, bg = current_colors.heading6_bg, bold = true },
          MarkviewHeading6Sign = { fg = current_colors.bg, bg = current_colors.heading6_bg, bold = true },
          -- Setext
          MarkviewSetextHeading1 = { fg = current_colors.bg, bg = current_colors.heading1_bg, bold = true },
          MarkviewSetextHeading2 = { fg = current_colors.bg, bg = current_colors.heading2_bg, bold = true },
          MarkviewSetext1 = { fg = current_colors.bg, bg = current_colors.heading1_bg, bold = true },
          MarkviewSetext2 = { fg = current_colors.bg, bg = current_colors.heading2_bg, bold = true },
          MarkviewSetextUnderline = { fg = current_colors.heading1_bg, bold = true },
          -- Lists
          MarkviewListItemMinus = { fg = current_colors.list_minus, bold = true },
          MarkviewListItemPlus = { fg = current_colors.list_plus, bold = true },
          MarkviewListItemStar = { fg = current_colors.list_star, bold = true },
          -- Code
          MarkviewCode = { bg = current_colors.code_bg },
          MarkviewInlineCode = { fg = current_colors.heading3_bg, bg = current_colors.code_bg },
          -- Tables
          MarkviewTable = { bg = current_colors.table_bg },
          MarkviewTableHeader = { fg = current_colors.heading2_bg, bg = current_colors.table_bg, bold = true },
          MarkviewTableBorder = { fg = current_colors.comment },
          -- Block quotes
          MarkviewBlockQuoteDefault = { fg = current_colors.comment, italic = true },
          MarkviewBlockQuoteNote = { fg = current_colors.heading3_bg, bg = current_colors.code_bg },
          MarkviewBlockQuoteOk = { fg = current_colors.heading4_bg, bg = current_colors.code_bg },
          MarkviewBlockQuoteSpecial = { fg = current_colors.heading2_bg, bg = current_colors.code_bg },
          MarkviewBlockQuoteWarn = { fg = current_colors.heading5_bg, bg = current_colors.code_bg },
          MarkviewBlockQuoteError = { fg = current_colors.heading1_bg, bg = current_colors.code_bg },
          -- Checkboxes
          MarkviewCheckboxChecked = { fg = current_colors.heading4_bg, bold = true },
          MarkviewCheckboxUnchecked = { fg = current_colors.heading1_bg },
          MarkviewCheckboxPending = { fg = current_colors.heading5_bg },
          MarkviewCheckboxProgress = { fg = current_colors.heading3_bg },
          MarkviewCheckboxCancelled = { fg = current_colors.comment, strikethrough = true },
          -- Text emphasis
          MarkviewBold = { bold = true },
          MarkviewItalic = { italic = true },
          MarkviewBoldItalic = { bold = true, italic = true },
          MarkviewStrikethrough = { strikethrough = true },
          -- Rules
          MarkviewRule = { fg = current_colors.comment },
          -- Links
          MarkviewLink = { fg = current_colors.link, underline = true },
          MarkviewHyperlink = { fg = current_colors.link, underline = true },
        }
        for group, opts in pairs(current_highlights) do
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
  
  -- Auto-reload markview colors when theme config changes
  vim.api.nvim_create_autocmd("BufWritePost", {
    pattern = vim.fn.expand("~/.config/theme-switcher/current-theme.sh"),
    callback = function()
      -- Reapply markview colors with new theme
      vim.schedule(function()
        local new_colors = get_theme_colors()
        local new_highlights = {
          -- Headings
          MarkviewHeading1 = { fg = new_colors.bg, bg = new_colors.heading1_bg, bold = true },
          MarkviewHeading1Sign = { fg = new_colors.bg, bg = new_colors.heading1_bg, bold = true },
          MarkviewHeading2 = { fg = new_colors.bg, bg = new_colors.heading2_bg, bold = true },
          MarkviewHeading2Sign = { fg = new_colors.bg, bg = new_colors.heading2_bg, bold = true },
          MarkviewHeading3 = { fg = new_colors.bg, bg = new_colors.heading3_bg, bold = true },
          MarkviewHeading3Sign = { fg = new_colors.bg, bg = new_colors.heading3_bg, bold = true },
          MarkviewHeading4 = { fg = new_colors.bg, bg = new_colors.heading4_bg, bold = true },
          MarkviewHeading4Sign = { fg = new_colors.bg, bg = new_colors.heading4_bg, bold = true },
          MarkviewHeading5 = { fg = new_colors.bg, bg = new_colors.heading5_bg, bold = true },
          MarkviewHeading5Sign = { fg = new_colors.bg, bg = new_colors.heading5_bg, bold = true },
          MarkviewHeading6 = { fg = new_colors.bg, bg = new_colors.heading6_bg, bold = true },
          MarkviewHeading6Sign = { fg = new_colors.bg, bg = new_colors.heading6_bg, bold = true },
          -- Setext
          MarkviewSetextHeading1 = { fg = new_colors.bg, bg = new_colors.heading1_bg, bold = true },
          MarkviewSetextHeading2 = { fg = new_colors.bg, bg = new_colors.heading2_bg, bold = true },
          MarkviewSetext1 = { fg = new_colors.bg, bg = new_colors.heading1_bg, bold = true },
          MarkviewSetext2 = { fg = new_colors.bg, bg = new_colors.heading2_bg, bold = true },
          MarkviewSetextUnderline = { fg = new_colors.heading1_bg, bold = true },
          -- Lists
          MarkviewListItemMinus = { fg = new_colors.list_minus, bold = true },
          MarkviewListItemPlus = { fg = new_colors.list_plus, bold = true },
          MarkviewListItemStar = { fg = new_colors.list_star, bold = true },
          -- Code
          MarkviewCode = { bg = new_colors.code_bg },
          MarkviewInlineCode = { fg = new_colors.heading3_bg, bg = new_colors.code_bg },
          -- Tables
          MarkviewTable = { bg = new_colors.table_bg },
          MarkviewTableHeader = { fg = new_colors.heading2_bg, bg = new_colors.table_bg, bold = true },
          MarkviewTableBorder = { fg = new_colors.comment },
          -- Block quotes
          MarkviewBlockQuoteDefault = { fg = new_colors.comment, italic = true },
          MarkviewBlockQuoteNote = { fg = new_colors.heading3_bg, bg = new_colors.code_bg },
          MarkviewBlockQuoteOk = { fg = new_colors.heading4_bg, bg = new_colors.code_bg },
          MarkviewBlockQuoteSpecial = { fg = new_colors.heading2_bg, bg = new_colors.code_bg },
          MarkviewBlockQuoteWarn = { fg = new_colors.heading5_bg, bg = new_colors.code_bg },
          MarkviewBlockQuoteError = { fg = new_colors.heading1_bg, bg = new_colors.code_bg },
          -- Checkboxes
          MarkviewCheckboxChecked = { fg = new_colors.heading4_bg, bold = true },
          MarkviewCheckboxUnchecked = { fg = new_colors.heading1_bg },
          MarkviewCheckboxPending = { fg = new_colors.heading5_bg },
          MarkviewCheckboxProgress = { fg = new_colors.heading3_bg },
          MarkviewCheckboxCancelled = { fg = new_colors.comment, strikethrough = true },
          -- Text emphasis
          MarkviewBold = { bold = true },
          MarkviewItalic = { italic = true },
          MarkviewBoldItalic = { bold = true, italic = true },
          MarkviewStrikethrough = { strikethrough = true },
          -- Rules
          MarkviewRule = { fg = new_colors.comment },
          -- Links
          MarkviewLink = { fg = new_colors.link, underline = true },
          MarkviewHyperlink = { fg = new_colors.link, underline = true },
        }
        for group, opts in pairs(new_highlights) do
          vim.api.nvim_set_hl(0, group, opts)
        end
      end)
    end,
    group = vim.api.nvim_create_augroup("MarkviewThemeReload", { clear = true })
  })
end

return M