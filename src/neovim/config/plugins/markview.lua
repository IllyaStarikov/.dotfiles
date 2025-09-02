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
    vim.opt.guifont = "JetBrainsMono Nerd Font:h18"
  end
  
  -- Defer setting encoding options to avoid modifiable errors
  vim.schedule(function()
    -- Ensure UTF-8 encoding
    pcall(function() vim.opt.encoding = "utf-8" end)
    pcall(function() vim.opt.fileencoding = "utf-8" end)
  end)
  
  -- Tell Neovim we have nerd fonts
  vim.g.have_nerd_font = true
  
  local markview = require("markview")
  local presets = require("markview.presets")
  
  markview.setup({
    
    -- Preserve ligatures
    preserve_whitespace = true,
    
    -- Disable all sign column modifications
    signs = false,
    disable_signs = true,
    disable_folds = true,
    
    -- Performance optimizations
    lazy_rendering = true,
    
    -- Preview configuration (moved deprecated options here)
    preview = {
      -- Draw range for performance (lines before and after cursor)
      draw_range = { 100, 100 },
      -- Mode configuration - enable preview in these modes
      modes = { "n", "no", "v", "V", "i" },
      -- Show raw markdown on cursor line/selection in these modes (hybrid mode)
      -- Modes in hybrid_modes show raw markdown on cursor line
      hybrid_modes = { "n", "v", "V", "i" },
      
      -- Don't show virtual text for non-existent frontmatter
      show_virtual = false,
      
      -- Ignore certain buffer types (moved from deprecated buf_ignore)
      ignore_buftypes = { "help", "nofile", "terminal" },
      
      -- Callbacks
      callbacks = {
        on_enable = {},
        on_disable = {},
        on_mode_change = {}
      },
      
      -- Buffer options - increase debounce to reduce autocommand frequency
      debounce = 150,
      
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
        style = "language",  -- Use 'language' style to preserve syntax highlighting
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
      
      -- Tables configuration
      tables = {
        enable = true,
        use_virt_lines = false,  -- Set to true if you want virtual lines for borders
      },
    },
    
    -- Inline markdown features
    markdown_inline = {
      enable = true,
      
      -- Enable pipe tables (GFM tables)
      pipe_table = {
        enable = true,
      },
      
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
    
    -- HTML configuration for details/summary elements
    html = {
      enable = true,
      
      -- HTML tags configuration
      tags = {
        enable = true,
        
        -- Configure details elements to be folded by default
        default = {
          conceal = true,
        },
        
        -- Custom configurations for specific tags
        configs = {
          -- Details tag configuration
          details = {
            conceal = true,
            
            -- Render as a folded block
            block = {
              text = "▶ ",  -- Folded indicator
              hl = "MarkviewListItemPlus",
              
              -- When expanded (not supported directly, but we can style it)
              text_open = "▼ ",
              hl_open = "MarkviewListItemMinus",
            }
          },
          
          -- Summary tag configuration  
          summary = {
            conceal = false,  -- Show summary content
            hl = "MarkviewBold",
          },
          
          -- Other common HTML tags
          b = { hl = "MarkviewBold" },
          strong = { hl = "MarkviewBold" },
          i = { hl = "MarkviewItalic" },
          em = { hl = "MarkviewItalic" },
          code = { hl = "MarkviewInlineCode" },
        }
      }
    },
  })
  
  -- Function to get theme-appropriate colors
  local function get_theme_colors()
    local config_file = vim.fn.expand("~/.config/theme-switcher/current-theme.sh")
    local is_light_theme = false
    
    if vim.fn.filereadable(config_file) == 1 then
      local theme_cmd = "source " .. config_file .. " && echo $MACOS_THEME"
      local background_cmd = "source " .. config_file .. " && echo $MACOS_VARIANT"
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
  
  -- Create a single function to apply highlights to avoid repetition
  local function apply_markview_highlights()
    local colors = get_theme_colors()
    local highlights = {
      -- Headings
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
      -- Setext
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
    for group, opts in pairs(highlights) do
      vim.api.nvim_set_hl(0, group, opts)
    end
  end
  
  -- Apply initial highlights
  vim.defer_fn(apply_markview_highlights, 50)
  
  -- JetBrainsMono Nerd Font has excellent ligature support!
  
  -- Auto-enable for markdown files
  local markdown_augroup = vim.api.nvim_create_augroup("MarkviewMarkdown", { clear = true })
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "markdown", "quarto", "rmd" },
    group = markdown_augroup,
    callback = function()
      -- Start with markview enabled (rich preview)
      -- Markview will handle conceallevel and concealcursor based on modes/hybrid_modes config
      vim.opt_local.list = false
      
      -- Create a buffer-local variable to track state
      vim.b.markview_enabled = true
      
      -- Apply highlights only once after a delay
      vim.defer_fn(apply_markview_highlights, 100)
      
      -- Smart toggle between rich preview and ligatures
      vim.keymap.set("n", "<leader>mp", function()
        if vim.b.markview_enabled then
          vim.cmd("Markview disable")
          vim.b.markview_enabled = false
          vim.notify("Ligatures enabled ✓ (markview disabled)", vim.log.levels.INFO)
        else
          vim.cmd("Markview enable")
          vim.b.markview_enabled = true
          vim.notify("Rich preview enabled (ligatures disabled)", vim.log.levels.INFO)
        end
      end, { 
        buffer = true, 
        desc = "Toggle between rich preview and ligatures" 
      })
      
      -- Keybindings for details/summary folding
      vim.keymap.set("n", "za", function()
        -- Toggle fold under cursor
        vim.cmd("normal! za")
      end, { buffer = true, desc = "Toggle details fold" })
      
      vim.keymap.set("n", "zM", function()
        -- Close all details folds
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        for i, line in ipairs(lines) do
          if line:match("^<details>") then
            vim.cmd(i .. "foldclose")
          end
        end
      end, { buffer = true, desc = "Close all details folds" })
      
      vim.keymap.set("n", "zR", function()
        -- Open all details folds
        vim.cmd("normal! zR")
      end, { buffer = true, desc = "Open all details folds" })
      
      -- Additional keybinding to toggle fold visibility globally
      vim.keymap.set("n", "<leader>mf", function()
        vim.opt_local.foldenable = not vim.opt_local.foldenable:get()
        local state = vim.opt_local.foldenable:get() and "enabled" or "disabled"
        vim.notify("Folding " .. state, vim.log.levels.INFO)
      end, { buffer = true, desc = "Toggle folding on/off" })
      
      -- Auto-expand fold when cursor enters it
      vim.keymap.set("n", "<leader>me", function()
        if vim.b.auto_expand_folds == nil then
          vim.b.auto_expand_folds = false
        end
        vim.b.auto_expand_folds = not vim.b.auto_expand_folds
        
        if vim.b.auto_expand_folds then
          -- Enable auto-expand
          vim.api.nvim_create_autocmd("CursorMoved", {
            buffer = 0,
            group = vim.api.nvim_create_augroup("MarkviewAutoExpand" .. vim.fn.bufnr(), { clear = true }),
            callback = function()
              -- Check if cursor is on a folded line
              local fold_level = vim.fn.foldlevel(".")
              if fold_level > 0 and vim.fn.foldclosed(".") ~= -1 then
                vim.cmd("normal! zo")
              end
            end
          })
          vim.notify("Auto-expand folds enabled", vim.log.levels.INFO)
        else
          -- Disable auto-expand
          vim.api.nvim_clear_autocmds({ 
            group = "MarkviewAutoExpand" .. vim.fn.bufnr(),
            buffer = 0 
          })
          vim.notify("Auto-expand folds disabled", vim.log.levels.INFO)
        end
      end, { buffer = true, desc = "Toggle auto-expand folds on cursor" })
      
    end
  })
  
  -- Handle folding behavior for insert/normal mode transitions
  local augroup = vim.api.nvim_create_augroup("MarkviewInsertMode", { clear = true })
  
  vim.api.nvim_create_autocmd({"InsertEnter"}, {
    pattern = { "*.md", "*.markdown", "*.rmd", "*.qmd" },
    group = augroup,
    callback = function()
      -- Store current fold state and unfold all when entering insert mode
      vim.b.fold_state_before_insert = vim.opt_local.foldenable:get()
      if vim.b.fold_state_before_insert then
        -- Unfold all details blocks
        vim.opt_local.foldenable = false
      end
      
      -- Also disable markview in insert mode
      if vim.b.markview_enabled then
        vim.cmd("Markview disable")
        vim.b.markview_insert_disabled = true
      end
    end
  })
  
  vim.api.nvim_create_autocmd({"InsertLeave"}, {
    pattern = { "*.md", "*.markdown", "*.rmd", "*.qmd" },
    group = augroup,
    callback = function()
      -- Restore fold state when leaving insert mode
      if vim.b.fold_state_before_insert then
        vim.opt_local.foldenable = true
      end
      
      -- Re-enable markview
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
      -- Reapply markview colors when theme changes
      vim.defer_fn(apply_markview_highlights, 100)
    end,
    group = vim.api.nvim_create_augroup("MarkviewThemeReload", { clear = true })
  })
  
  -- Custom handling for <details> elements
  -- Create folds for details blocks
  vim.api.nvim_create_autocmd({"BufEnter", "BufWinEnter"}, {
    pattern = { "*.md", "*.markdown" },
    callback = function()
      -- Set up folding for details elements
      vim.opt_local.foldmethod = "expr"
      vim.opt_local.foldexpr = "v:lua.markview_details_fold()"
      vim.opt_local.foldtext = "v:lua.markview_details_foldtext()"
      vim.opt_local.fillchars = "fold: "
      vim.opt_local.foldlevel = 99  -- Start with all folds open
      
      -- Auto-close details blocks on load
      vim.defer_fn(function()
        -- Find and fold all <details> blocks
        local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
        for i, line in ipairs(lines) do
          if line:match("^<details>") then
            vim.cmd(i .. "foldclose")
          end
        end
      end, 100)
    end,
    group = vim.api.nvim_create_augroup("MarkviewDetailsFold", { clear = true })
  })
end

-- Global functions for folding <details> elements
function _G.markview_details_fold()
  local line = vim.fn.getline(vim.v.lnum)
  if line:match("^<details>") then
    return "a1"  -- Start a fold
  elseif line:match("^</details>") then
    return "s1"  -- End a fold
  else
    return "="   -- Use previous fold level
  end
end

function _G.markview_details_foldtext()
  local line = vim.fn.getline(vim.v.foldstart)
  local summary_line = vim.fn.getline(vim.v.foldstart + 1)
  
  -- Extract summary text if available
  local summary_text = summary_line:match("<summary>(.-)</summary>") or 
                      summary_line:match("<summary>%s*<b>(.-)</b>%s*</summary>") or
                      "Details"
  
  -- Create fold text with arrow indicator
  local fold_text = "▶ " .. summary_text .. " "
  
  -- Add fold size indicator
  local fold_size = vim.v.foldend - vim.v.foldstart + 1
  local suffix = " [" .. fold_size .. " lines]"
  
  return fold_text .. suffix
end

return M