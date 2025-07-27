--
-- Markview.nvim configuration
-- Enhanced markdown rendering with all features enabled
--

local M = {}

function M.setup()
  local markview = require("markview")
  local presets = require("markview.presets")
  
  -- Set up highlight groups for markview
  vim.api.nvim_set_hl(0, "MarkviewCheckboxChecked", { fg = "#50fa7b", bold = true })
  vim.api.nvim_set_hl(0, "MarkviewCheckboxUnchecked", { fg = "#ff5555" })
  vim.api.nvim_set_hl(0, "MarkviewCheckboxPending", { fg = "#f1fa8c" })
  vim.api.nvim_set_hl(0, "MarkviewCheckboxProgress", { fg = "#8be9fd" })
  vim.api.nvim_set_hl(0, "MarkviewCheckboxCancelled", { fg = "#6272a4", strikethrough = true })
  vim.api.nvim_set_hl(0, "MarkviewCheckboxImportant", { fg = "#ff79c6", bold = true })
  
  -- Heading highlights
  vim.api.nvim_set_hl(0, "MarkviewHeading1", { fg = "#ff79c6", bg = "#44475a", bold = true })
  vim.api.nvim_set_hl(0, "MarkviewHeading1Sign", { fg = "#ff79c6", bold = true })
  vim.api.nvim_set_hl(0, "MarkviewHeading2", { fg = "#bd93f9", bg = "#44475a", bold = true })
  vim.api.nvim_set_hl(0, "MarkviewHeading2Sign", { fg = "#bd93f9", bold = true })
  vim.api.nvim_set_hl(0, "MarkviewHeading3", { fg = "#8be9fd", bg = "#44475a", bold = true })
  vim.api.nvim_set_hl(0, "MarkviewHeading3Sign", { fg = "#8be9fd", bold = true })
  vim.api.nvim_set_hl(0, "MarkviewHeading4", { fg = "#50fa7b", bold = true })
  vim.api.nvim_set_hl(0, "MarkviewHeading4Sign", { fg = "#50fa7b", bold = true })
  vim.api.nvim_set_hl(0, "MarkviewHeading5", { fg = "#f1fa8c", bold = true })
  vim.api.nvim_set_hl(0, "MarkviewHeading5Sign", { fg = "#f1fa8c", bold = true })
  vim.api.nvim_set_hl(0, "MarkviewHeading6", { fg = "#ffb86c", bold = true })
  vim.api.nvim_set_hl(0, "MarkviewHeading6Sign", { fg = "#ffb86c", bold = true })
  
  markview.setup({
    -- Core configuration
    experimental = {
      file_open_command = "open", -- macOS
      check_rtp = false, -- Disable runtime path check since we've fixed load order
    },
    
    -- Icons configuration - force nerd fonts
    icons = "nerd",
    max_length = 99999,
    
    preview = {
      filetypes = { "markdown", "md", "mkd", "mkdn", "mdwn", "mdown", "mdtxt", "mdtext", "rmd", "wiki" },
      
      -- Enable hybrid mode - show rendered and raw content
      hybrid_modes = { "n" },
      
      -- Font and rendering settings (moved to preview section)
      ignore_buftypes = {},
      
      -- Enhanced rendering options  
      modes = { "n", "i", "c" }, 
      
      -- Debounce for performance
      debounce = 50,
    },
    
    -- Markdown configuration with all features
    markdown = {
      enable = true,
      
      -- Enhanced blockquotes with callout support
      block_quotes = {
        enable = true,
        
        default = {
          border_left = "▍",
          border_left_hl = "MarkviewBlockQuoteDefault",
          hl = "MarkviewBlockQuoteDefault"
        },
        
        -- GitHub-style callouts
        callouts = {
          ["NOTE"] = {
            hl = "MarkviewBlockQuoteNote",
            preview = " Note",
            title = true,
            icon = "",
          },
          ["TIP"] = {
            hl = "MarkviewBlockQuoteOk", 
            preview = " Tip",
            title = true,
            icon = "",
          },
          ["IMPORTANT"] = {
            hl = "MarkviewBlockQuoteSpecial",
            preview = " Important", 
            title = true,
            icon = "",
          },
          ["WARNING"] = {
            hl = "MarkviewBlockQuoteWarn",
            preview = " Warning",
            title = true,
            icon = "",
          },
          ["CAUTION"] = {
            hl = "MarkviewBlockQuoteError",
            preview = " Caution",
            title = true,
            icon = "",
          }
        }
      },
      
      -- Enhanced code blocks with syntax highlighting
      code_blocks = {
        enable = true,
        style = "language",
        
        -- Icons for different styles
        icons = "mini",
        
        -- Padding and styling
        min_width = 60,
        pad_amount = 3,
        pad_char = " ",
        
        -- Sign column
        sign = true,
        
        -- Language label positioning
        label_direction = "right",
        
        -- Highlight groups
        border_hl = "MarkviewCodeBorder",
        info_hl = "MarkviewCodeInfo",
        
        -- Default styling for all languages
        default = {
          block_hl = "MarkviewCode",
          pad_hl = "MarkviewCode"
        },
        
        -- Special handling for diff blocks
        ["diff"] = {
          block_hl = function(_, line)
            if line:match("^%+") then
              return "MarkviewDiffAdd"
            elseif line:match("^%-") then
              return "MarkviewDiffDelete"
            else
              return "MarkviewCode"
            end
          end,
          pad_hl = "MarkviewCode"
        }
      },
      
      -- Enhanced headings with simple ASCII markers
      headings = {
        enable = true,
        shift_width = 0,
        heading_1 = {
          style = "simple",
          hl = "MarkviewHeading1",
        },
        heading_2 = {
          style = "simple", 
          hl = "MarkviewHeading2",
        },
        heading_3 = {
          style = "simple",
          hl = "MarkviewHeading3",
        },
        heading_4 = {
          style = "simple",
          hl = "MarkviewHeading4",
        },
        heading_5 = {
          style = "simple",
          hl = "MarkviewHeading5",
        },
        heading_6 = {
          style = "simple",
          hl = "MarkviewHeading6",
        },
      },
      
      -- Horizontal rules
      horizontal_rules = {
        enable = true,
        
        parts = {
          {
            type = "repeating",
            text = "━",
            hl = "MarkviewRule",
            repeat_amount = function()
              return math.max(vim.api.nvim_win_get_width(0) - 10, 40)
            end
          }
        }
      },
      
      -- Enhanced list items with proper bullet visibility
      list_items = {
        enable = true,
        wrap = true,
        
        indent_size = function(buffer)
          if type(buffer) ~= "number" then
            return vim.bo.shiftwidth or 4
          end
          return vim.bo[buffer].shiftwidth or 4
        end,
        shift_width = 2,
        
        -- Bullet markers with distinct icons and colors
        marker_minus = {
          add_padding = true,
          text = "●", -- Solid bullet for better visibility
          hl = "MarkviewListItemMinus"
        },
        
        marker_plus = {
          add_padding = true, 
          text = "◆", -- Diamond for plus items
          hl = "MarkviewListItemPlus"
        },
        
        marker_star = {
          add_padding = true,
          text = "▸", -- Triangle for star items
          hl = "MarkviewListItemStar"
        },
        
        -- Ordered list markers
        marker_dot = {
          enable = true,
          add_padding = true
        },
        
        marker_parenthesis = {
          enable = true,
          add_padding = true
        }
      },
      
      -- Enhanced tables with better styling
      tables = {
        enable = true,
        use_virt_lines = true,
        
        block_hl = "MarkviewTable",
        border_hl = "MarkviewTableBorder",
        
        -- Table parts styling
        parts = {
          top = { "╭", "─", "┬", "─", "╮" },
          header_sep = { "├", "─", "┼", "─", "┤" },
          sep = { "├", "─", "┼", "─", "┤" },
          bottom = { "╰", "─", "┴", "─", "╯" },
          overlap = { "┃", " ", "┃", " ", "┃" },
          row = { "┃", " ", "┃", " ", "┃" }
        }
      }
    },
    
    -- Markdown inline features (for inline elements)
    markdown_inline = {
      enable = true,
      
      -- Checkboxes with nerd font icons
      checkboxes = presets.checkboxes.nerd,
      
      -- Enhanced inline code styling
      inline_codes = {
        enable = true,
        
        corner_left = " ",
        corner_right = " ",
        padding_left = " ",
        padding_right = " ",
        
        hl = "MarkviewInlineCode"
      },
      
      -- Enhanced links with icons
      links = {
        enable = true,
        
        hyperlinks = {
          icon = " ",
          hl = "MarkviewLink"
        },
        
        images = {
          icon = " ",
          hl = "MarkviewImage"
        },
        
        emails = {
          icon = " ",
          hl = "MarkviewEmail"
        }
      },
      
      -- Text emphasis
      emphasis = {
        enable = true,
        
        bold = {
          icon = " ",
          hl = "MarkviewBold"
        },
        
        italic = {
          icon = " ",
          hl = "MarkviewItalic"
        },
        
        strikethrough = {
          icon = " ",
          hl = "MarkviewStrikethrough"
        }
      },
      
      -- HTML entities support
      entities = {
        enable = true
      }
    }
  })
  
  -- Auto-enable for markdown files with proper concealment settings
  vim.api.nvim_create_autocmd("FileType", {
    pattern = { "markdown", "md", "mkd", "mkdn", "mdwn", "mdown", "mdtxt", "mdtext", "rmd", "wiki" },
    callback = function()
      -- Optimal concealment settings for markview
      vim.opt_local.conceallevel = 2
      vim.opt_local.concealcursor = 'nc'
      
      -- Enable markview for this buffer
      vim.cmd("Markview enable")
    end
  })
  
  -- Debug commands for glyph issues
  vim.api.nvim_create_user_command("MarkviewDebug", function()
    local ok, icons = pcall(require, "nvim-web-devicons")
    print("nvim-web-devicons loaded:", ok)
    print("Have nerd font:", vim.g.have_nerd_font)
    print("Terminal:", vim.env.TERM)
    print("Encoding:", vim.o.encoding)
    print("GUI font:", vim.o.guifont)
    print("Conceallevel:", vim.o.conceallevel)
    print("Concealcursor:", vim.o.concealcursor)
    
    -- Test rendering some glyphs
    print("\nTest glyphs:")
    print("Checkbox unchecked: ")
    print("Checkbox checked: ")
    print("H1 icon: 󰼏")
    print("H2 icon: 󰎨")
    print("H3 icon: 󰼑")
    print("H1 sign: 󰌕")
    print("H2 sign: 󰌖")
    
    -- Check markview config
    local mv_ok, mv = pcall(require, "markview")
    if mv_ok then
      print("\nMarkview loaded successfully")
    end
  end, { desc = "Debug markview glyph rendering" })
  
  -- Command to test different heading styles
  vim.api.nvim_create_user_command("MarkviewHeadingStyle", function(opts)
    local style = opts.args
    local markview = require("markview")
    local presets = require("markview.presets")
    
    if style == "glow" then
      markview.configuration.markdown.headings = presets.headings.glow
    elseif style == "marker" then
      markview.configuration.markdown.headings = presets.headings.marker
    elseif style == "simple" then
      markview.configuration.markdown.headings = presets.headings.simple
    elseif style == "slanted" then
      markview.configuration.markdown.headings = presets.headings.slanted
    elseif style == "arrowed" then
      markview.configuration.markdown.headings = presets.headings.arrowed
    elseif style == "none" then
      markview.configuration.markdown.headings = {
        enable = false
      }
    else
      print("Available styles: glow, marker, simple, slanted, arrowed, none")
      return
    end
    
    -- Refresh markview
    vim.cmd("Markview disable")
    vim.cmd("Markview enable")
    print("Switched to " .. style .. " heading style")
  end, {
    nargs = 1,
    complete = function()
      return { "glow", "marker", "simple", "slanted", "arrowed", "none" }
    end,
    desc = "Switch markview heading style"
  })
end

return M