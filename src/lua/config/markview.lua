--
-- Markview.nvim configuration
-- Enhanced markdown rendering with all features enabled
--

local M = {}

function M.setup()
  local markview = require("markview")
  local presets = require("markview.presets")
  
  markview.setup({
    -- Core configuration
    experimental = {
      file_open_command = "open", -- macOS
      check_rtp = false, -- Disable runtime path check since we've fixed load order
    },
    
    preview = {
      filetypes = { "markdown", "md", "mkd", "mkdn", "mdwn", "mdown", "mdtxt", "mdtext", "rmd", "wiki" },
      
      -- Enable hybrid mode - show rendered and raw content
      hybrid_modes = { "n" },
      
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
            preview = "󰌶 Tip",
            title = true,
            icon = "󰌶",
          },
          ["IMPORTANT"] = {
            hl = "MarkviewBlockQuoteSpecial",
            preview = "󰅾 Important", 
            title = true,
            icon = "󰅾",
          },
          ["WARNING"] = {
            hl = "MarkviewBlockQuoteWarn",
            preview = " Warning",
            title = true,
            icon = "",
          },
          ["CAUTION"] = {
            hl = "MarkviewBlockQuoteError",
            preview = "󰳦 Caution",
            title = true,
            icon = "󰳦",
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
      
      -- Enhanced headings with glow-like styling
      headings = vim.tbl_deep_extend("force", presets.headings.glow, {
        shift_width = 0,
      }),
      
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
      checkboxes = vim.tbl_deep_extend("force", presets.checkboxes.nerd, {
        -- Additional custom checkboxes
        custom = {
          {
            match_string = "~",
            text = "",
            hl = "MarkviewCheckboxProgress"
          },
          {
            match_string = "!",
            text = "",
            hl = "MarkviewCheckboxImportant"
          }
        }
      }),
      
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
          icon = "󰌹 ",
          hl = "MarkviewLink"
        },
        
        images = {
          icon = "󰋩 ",
          hl = "MarkviewImage"
        },
        
        emails = {
          icon = "󰇮 ",
          hl = "MarkviewEmail"
        }
      },
      
      -- Text emphasis
      emphasis = {
        enable = true,
        
        bold = {
          icon = "󰖿 ",
          hl = "MarkviewBold"
        },
        
        italic = {
          icon = "󰗀 ",
          hl = "MarkviewItalic"
        },
        
        strikethrough = {
          icon = "󰗁 ",
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
end

return M