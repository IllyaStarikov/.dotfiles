--
-- Markview.nvim configuration
-- Maximum compatibility configuration with rich features
--

local M = {}

function M.setup()
  local markview = require("markview")
  local presets = require("markview.presets")
  
  markview.setup({
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
      
      -- Icon provider - set to empty string to disable all icons
      icon_provider = "",
    },
    
    -- Highlight groups
    highlight_groups = "dynamic",
    
    -- Main markdown configuration
    markdown = {
      enable = true,
      max_file_length = 1000,
      
      -- Headings with simple style (no icons)
      headings = {
        enable = true,
        shift_width = 0,
        
        heading_1 = {
          style = "label",
          padding_left = " ",
          padding_right = " ",
          hl = "MarkviewHeading1",
          sign = false,
        },
        heading_2 = {
          style = "label", 
          padding_left = " ",
          padding_right = " ",
          hl = "MarkviewHeading2",
          sign = false,
        },
        heading_3 = {
          style = "label",
          padding_left = " ",
          padding_right = " ",
          hl = "MarkviewHeading3",
          sign = false,
        },
        heading_4 = {
          style = "simple",
          hl = "MarkviewHeading4",
          sign = false,
        },
        heading_5 = {
          style = "simple",
          hl = "MarkviewHeading5",
          sign = false,
        },
        heading_6 = {
          style = "simple",
          hl = "MarkviewHeading6",
          sign = false,
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
        
        -- Disable icons completely
        icons = false,
        sign = false,
        
        -- Default highlighting
        hl = "MarkviewCode",
      },
      
      -- Block quotes with simple ASCII
      block_quotes = {
        enable = true,
        default = {
          border_left = "|",
          border_left_hl = "MarkviewBlockQuoteDefault",
          border_top_left = "",
          border_top = "",
          border_top_right = "",
          border_bottom_left = "",
          border_bottom = "",
          border_bottom_right = "",
          border_right = "",
          
          quote_char = ">",
          quote_char_hl = "MarkviewBlockQuoteDefault",
        },
        
        -- Callouts without icons
        callouts = {
          {
            match_string = "NOTE",
            callout_preview = "Note",
            callout_preview_hl = "MarkviewBlockQuoteNote",
            custom_title = true,
            custom_icon = "",
            border_left = "|",
            border_left_hl = "MarkviewBlockQuoteNote",
          },
          {
            match_string = "TIP",
            callout_preview = "Tip",
            callout_preview_hl = "MarkviewBlockQuoteOk",
            custom_title = true,
            custom_icon = "",
            border_left = "|",
            border_left_hl = "MarkviewBlockQuoteOk",
          },
          {
            match_string = "IMPORTANT",
            callout_preview = "Important",
            callout_preview_hl = "MarkviewBlockQuoteSpecial",
            custom_title = true,
            custom_icon = "",
            border_left = "|",
            border_left_hl = "MarkviewBlockQuoteSpecial",
          },
          {
            match_string = "WARNING",
            callout_preview = "Warning",
            callout_preview_hl = "MarkviewBlockQuoteWarn",
            custom_title = true,
            custom_icon = "",
            border_left = "|",
            border_left_hl = "MarkviewBlockQuoteWarn",
          },
          {
            match_string = "CAUTION",
            callout_preview = "Caution",
            callout_preview_hl = "MarkviewBlockQuoteError",
            custom_title = true,
            custom_icon = "",
            border_left = "|",
            border_left_hl = "MarkviewBlockQuoteError",
          },
        },
      },
      
      -- Horizontal rules with simple ASCII
      horizontal_rules = {
        enable = true,
        parts = {
          {
            type = "repeating",
            repeat_amount = vim.api.nvim_win_get_width,
            
            text = "-",
            hl = "MarkviewRule",
          },
        },
      },
      
      -- DISABLE list items entirely - they cause Unicode rendering and double-dash issues
      list_items = {
        enable = false
      },
      
      -- Tables with ASCII borders
      tables = {
        enable = true,
        col_min_width = 10,
        block_decorator = true,
        use_virt_lines = false,
        
        -- ASCII table parts
        parts = {
          top = { "+", "-", "+", "-", "+" },
          header = { "|", " ", "|", " ", "|" },
          separator = { "+", "=", "+", "=", "+" },
          row = { "|", " ", "|", " ", "|" },
          bottom = { "+", "-", "+", "-", "+" },
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
      
      -- COMPLETELY disable checkboxes to avoid Unicode symbols
      checkboxes = {
        enable = false
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
      
      -- Disable problematic features
      images = { enable = false },
      links = { enable = false },
      emails = { enable = false },
    },
  })
  
  -- Set up highlight groups with TokyoNight colors
  local highlights = {
    -- Headings
    MarkviewHeading1 = { fg = "#1a1b26", bg = "#ff79c6", bold = true },
    MarkviewHeading1Sign = { fg = "#ff79c6", bold = true },
    MarkviewHeading2 = { fg = "#1a1b26", bg = "#bd93f9", bold = true },
    MarkviewHeading2Sign = { fg = "#bd93f9", bold = true },
    MarkviewHeading3 = { fg = "#1a1b26", bg = "#8be9fd", bold = true },
    MarkviewHeading3Sign = { fg = "#8be9fd", bold = true },
    MarkviewHeading4 = { fg = "#50fa7b", bold = true },
    MarkviewHeading5 = { fg = "#f1fa8c", bold = true },
    MarkviewHeading6 = { fg = "#ffb86c", bold = true },
    
    -- Lists
    MarkviewListItemMinus = { fg = "#50fa7b", bold = true },
    MarkviewListItemPlus = { fg = "#8be9fd", bold = true },
    MarkviewListItemStar = { fg = "#f1fa8c", bold = true },
    
    -- Code
    MarkviewCode = { bg = "#2d2e3f" },
    MarkviewInlineCode = { fg = "#8be9fd", bg = "#2d2e3f" },
    
    -- Tables
    MarkviewTable = { bg = "#1e1f2e" },
    MarkviewTableHeader = { fg = "#bd93f9", bg = "#1e1f2e", bold = true },
    MarkviewTableBorder = { fg = "#6272a4" },
    
    -- Block quotes
    MarkviewBlockQuoteDefault = { fg = "#6272a4", italic = true },
    MarkviewBlockQuoteNote = { fg = "#8be9fd", bg = "#2d3f4f" },
    MarkviewBlockQuoteOk = { fg = "#50fa7b", bg = "#2d3f2d" },
    MarkviewBlockQuoteSpecial = { fg = "#bd93f9", bg = "#3d2d4f" },
    MarkviewBlockQuoteWarn = { fg = "#f1fa8c", bg = "#4f4f2d" },
    MarkviewBlockQuoteError = { fg = "#ff5555", bg = "#4f2d2d" },
    
    -- Checkboxes
    MarkviewCheckboxChecked = { fg = "#50fa7b", bold = true },
    MarkviewCheckboxUnchecked = { fg = "#ff5555" },
    MarkviewCheckboxPending = { fg = "#f1fa8c" },
    MarkviewCheckboxProgress = { fg = "#8be9fd" },
    MarkviewCheckboxCancelled = { fg = "#6272a4", strikethrough = true },
    
    -- Text emphasis
    MarkviewBold = { bold = true },
    MarkviewItalic = { italic = true },
    MarkviewBoldItalic = { bold = true, italic = true },
    MarkviewStrikethrough = { strikethrough = true },
    
    -- Rules
    MarkviewRule = { fg = "#6272a4" },
  }
  
  for group, opts in pairs(highlights) do
    vim.api.nvim_set_hl(0, group, opts)
  end
  
  -- Apply overrides immediately after setup
  local function apply_overrides()
    local success, _ = pcall(function()
        -- Override filetypes to remove ALL icons
        local filetypes = require("markview.filetypes")
        if filetypes and filetypes.styles then
          for lang, style in pairs(filetypes.styles) do
            style.icon = ""
            style.sign = ""
          end
        end
        
        -- Override link rendering to remove icons
        local links = require("markview.links")
        if links then
          -- Override the link icons
          if links.hyperlinks then
            links.hyperlinks.icon = ""
          end
          if links.images then
            links.images.icon = ""
          end
          if links.emails then
            links.emails.icon = ""
          end
        end
        
        -- Override spec configuration
        local spec = require("markview.spec")
        if spec then
          -- Override in spec.config
          if spec.config and spec.config.markdown and spec.config.markdown.list_items then
            local list_items = spec.config.markdown.list_items
            
            if list_items.marker_minus then
              list_items.marker_minus.text = "-"
              list_items.marker_minus.padding_left = ""
              list_items.marker_minus.padding_right = ""
            end
            if list_items.marker_plus then
              list_items.marker_plus.text = "+"
              list_items.marker_plus.padding_left = ""
              list_items.marker_plus.padding_right = ""
            end
            if list_items.marker_star then
              list_items.marker_star.text = "*"
              list_items.marker_star.padding_left = ""
              list_items.marker_star.padding_right = ""
            end
          end
          
          -- Override in spec.default
          if spec.default and spec.default.markdown and spec.default.markdown.list_items then
            local list_items = spec.default.markdown.list_items
            
            if list_items.marker_minus then
              list_items.marker_minus.text = "-"
              list_items.marker_minus.padding_left = ""
              list_items.marker_minus.padding_right = ""
            end
            if list_items.marker_plus then
              list_items.marker_plus.text = "+"
              list_items.marker_plus.padding_left = ""
              list_items.marker_plus.padding_right = ""
            end
            if list_items.marker_star then
              list_items.marker_star.text = "*"
              list_items.marker_star.padding_left = ""
              list_items.marker_star.padding_right = ""
            end
          end
          
          -- Override link configuration
          if spec.config and spec.config.markdown_inline and spec.config.markdown_inline.links then
            spec.config.markdown_inline.links.hyperlinks = { icon = "", hl = "MarkviewLink" }
            spec.config.markdown_inline.links.images = { icon = "", hl = "MarkviewImage" }
            spec.config.markdown_inline.links.emails = { icon = "", hl = "MarkviewEmail" }
          end
          
          -- Override hyperlinks configuration
          if spec.config and spec.config.markdown_inline and spec.config.markdown_inline.hyperlinks then
            if spec.config.markdown_inline.hyperlinks.default then
              spec.config.markdown_inline.hyperlinks.default.icon = ""
            end
            -- Override all pattern-based hyperlinks
            for pattern, config in pairs(spec.config.markdown_inline.hyperlinks) do
              if type(config) == "table" and config.icon then
                config.icon = ""
              end
            end
          end
          
          -- Override default link config
          if spec.default and spec.default.markdown_inline and spec.default.markdown_inline.links then
            spec.default.markdown_inline.links.hyperlinks = { icon = "", hl = "MarkviewLink" }
            spec.default.markdown_inline.links.images = { icon = "", hl = "MarkviewImage" }
            spec.default.markdown_inline.links.emails = { icon = "", hl = "MarkviewEmail" }
          end
          
          -- Override default hyperlinks configuration
          if spec.default and spec.default.markdown_inline and spec.default.markdown_inline.hyperlinks then
            if spec.default.markdown_inline.hyperlinks.default then
              spec.default.markdown_inline.hyperlinks.default.icon = ""
            end
            -- Override all pattern-based hyperlinks
            for pattern, config in pairs(spec.default.markdown_inline.hyperlinks) do
              if type(config) == "table" and config.icon then
                config.icon = ""
              end
            end
          end
        end
        
    end)
  end
  
  -- Apply overrides immediately
  apply_overrides()
  
  -- Create a more aggressive override that patches the renderer
  local function patch_list_renderer()
    local success, markdown_renderer = pcall(require, "markview.renderers.markdown")
    if success and markdown_renderer.list_item then
      local original_list_item = markdown_renderer.list_item
      markdown_renderer.list_item = function(buffer, item, config_table)
        -- Override the config to use ASCII bullets
        if config_table and config_table.marker_minus then
          config_table.marker_minus.text = "-"
        end
        if config_table and config_table.marker_plus then
          config_table.marker_plus.text = "+"
        end
        if config_table and config_table.marker_star then
          config_table.marker_star.text = "*"
        end
        -- Call the original function with our modified config
        return original_list_item(buffer, item, config_table)
      end
    end
  end
  
  -- Apply the patch
  patch_list_renderer()
  
  -- Auto-enable for markdown files
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "markdown", "quarto", "rmd" },
    callback = function()
      vim.opt_local.conceallevel = 2
      vim.opt_local.concealcursor = "nc"
      
      -- Re-apply overrides and patch to ensure they stick
      apply_overrides()
      patch_list_renderer()
    end
  })
  
  -- Also apply on BufRead to catch files loaded from command line
  vim.api.nvim_create_autocmd({"BufRead", "BufNewFile"}, {
    pattern = { "*.md", "*.markdown", "*.rmd", "*.qmd" },
    callback = function()
      -- Apply overrides immediately when file is read
      vim.schedule(apply_overrides)
    end
  })
  
  -- Add mode-specific handling for proper concealing
  vim.api.nvim_create_autocmd({"InsertEnter", "InsertLeave"}, {
    pattern = { "*.md", "*.markdown", "*.rmd", "*.qmd" },
    callback = function(args)
      if args.event == "InsertEnter" then
        -- In insert mode, show raw markdown
        vim.opt_local.conceallevel = 0
      else
        -- In normal mode, use concealing
        vim.opt_local.conceallevel = 2
      end
    end
  })
end

return M