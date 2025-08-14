--
-- config/telescope.lua
-- Telescope fuzzy finder configuration - modern replacement for FZF
--

local M = {}

function M.setup()
  local telescope_ok, telescope = pcall(require, 'telescope')
  if not telescope_ok then
    return
  end
  
  local actions_ok, actions = pcall(require, 'telescope.actions')
  local state_ok, action_state = pcall(require, 'telescope.actions.state')
  
  if not actions_ok or not state_ok then
    return
  end
  
  
  -- ⚡ PERFORMANCE & UI SETTINGS
  telescope.setup({
    defaults = {
      -- UI Configuration
      prompt_prefix = "🔍 ",
      selection_caret = "▶ ",
      entry_prefix = "  ",
      initial_mode = "insert",
      selection_strategy = "reset",
      sorting_strategy = "descending",
      layout_strategy = "horizontal",
      
      -- Performance optimizations
      file_sorter = require('telescope.sorters').get_fuzzy_file,
      file_ignore_patterns = {
        "node_modules/",
        ".git/",
        ".DS_Store",
        "*.o",
        "*.exe",
        "*.dll",
        "*.so",
        "*.dylib",
        "__pycache__/",
        "*.pyc",
        ".venv/",
        "venv/",
        ".env",
        "build/",
        "dist/",
        "target/",
        "*.jpg",
        "*.jpeg",
        "*.png",
        "*.gif",
        "*.pdf",
        "*.zip",
        "*.tar.gz",
      },
      
      -- Layout configuration
      layout_config = {
        horizontal = {
          mirror = false,
          width = 0.87,
          height = 0.80,
          preview_cutoff = 120,
          prompt_position = "top",
          preview_width = function(_, cols, _)
            if cols > 200 then
              return math.floor(cols * 0.4)
            else
              return math.floor(cols * 0.6)
            end
          end,
        },
        vertical = {
          mirror = false,
          width = 0.87,
          height = 0.80,
          preview_cutoff = 40,
          prompt_position = "top",
        },
        flex = {
          horizontal = {
            preview_width = 0.9,
          },
        },
      },
      
      -- Keymaps within Telescope
      mappings = {
        i = {
          -- Insert mode mappings
          -- Note: Use Tab to select multiple files, then Enter to open all
          ["<C-n>"] = actions.move_selection_next,
          ["<C-p>"] = actions.move_selection_previous,
          ["<C-j>"] = actions.move_selection_next,
          ["<C-k>"] = actions.move_selection_previous,
          
          ["<C-c>"] = actions.close,
          ["<Esc>"] = actions.close,
          
          ["<CR>"] = function(prompt_bufnr)
            local picker = action_state.get_current_picker(prompt_bufnr)
            local multi_selections = picker:get_multi_selection()
            
            if #multi_selections > 0 then
              -- Open all selected files
              actions.close(prompt_bufnr)
              for _, entry in ipairs(multi_selections) do
                local filename = entry[1] or entry.path or entry.filename
                if filename then
                  vim.cmd(string.format("edit %s", vim.fn.fnameescape(filename)))
                end
              end
            else
              -- Fall back to default action for single selection
              actions.select_default(prompt_bufnr)
            end
          end,
          ["<C-x>"] = actions.select_horizontal,
          ["<C-v>"] = actions.select_vertical,
          ["<C-t>"] = actions.select_tab,
          
          ["<C-u>"] = actions.preview_scrolling_up,
          ["<C-d>"] = actions.preview_scrolling_down,
          
          ["<PageUp>"] = actions.results_scrolling_up,
          ["<PageDown>"] = actions.results_scrolling_down,
          
          ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
          ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
          ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
          ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
          
          -- Custom actions
          ["<C-l>"] = actions.complete_tag,
          ["<C-_>"] = actions.which_key, -- keys from pressing <C-/>
        },
        n = {
          -- Normal mode mappings
          ["<Esc>"] = actions.close,
          ["<CR>"] = function(prompt_bufnr)
            local picker = action_state.get_current_picker(prompt_bufnr)
            local multi_selections = picker:get_multi_selection()
            
            if #multi_selections > 0 then
              -- Open all selected files
              actions.close(prompt_bufnr)
              for _, entry in ipairs(multi_selections) do
                local filename = entry[1] or entry.path or entry.filename
                if filename then
                  vim.cmd(string.format("edit %s", vim.fn.fnameescape(filename)))
                end
              end
            else
              -- Fall back to default action for single selection
              actions.select_default(prompt_bufnr)
            end
          end,
          ["<C-x>"] = actions.select_horizontal,
          ["<C-v>"] = actions.select_vertical,
          ["<C-t>"] = actions.select_tab,
          
          ["<Tab>"] = actions.toggle_selection + actions.move_selection_worse,
          ["<S-Tab>"] = actions.toggle_selection + actions.move_selection_better,
          ["<C-q>"] = actions.send_to_qflist + actions.open_qflist,
          ["<M-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
          
          ["j"] = actions.move_selection_next,
          ["k"] = actions.move_selection_previous,
          ["H"] = actions.move_to_top,
          ["M"] = actions.move_to_middle,
          ["L"] = actions.move_to_bottom,
          
          ["<Down>"] = actions.move_selection_next,
          ["<Up>"] = actions.move_selection_previous,
          ["gg"] = actions.move_to_top,
          ["G"] = actions.move_to_bottom,
          
          ["<C-u>"] = actions.preview_scrolling_up,
          ["<C-d>"] = actions.preview_scrolling_down,
          
          ["<PageUp>"] = actions.results_scrolling_up,
          ["<PageDown>"] = actions.results_scrolling_down,
          
          ["?"] = actions.which_key,
        },
      },
      
      -- Generic sorter configuration
      generic_sorter = require('telescope.sorters').get_generic_fuzzy_sorter,
      
      -- Path display configuration
      path_display = { "truncate" },
      
      -- Window options
      winblend = 0,
      border = {},
      borderchars = { "─", "│", "─", "│", "╭", "╮", "╯", "╰" },
      color_devicons = true,
      use_less = true,
      set_env = { ["COLORTERM"] = "truecolor" }, -- default = nil,
    },
    
    -- 🔍 PICKER-SPECIFIC CONFIGURATIONS
    pickers = {
      -- File pickers
      find_files = {
        theme = "dropdown",
        previewer = false,
        hidden = false,
        find_command = { "find", ".", "-type", "f", "-not", "-path", "./.git/*" },
      },
      
      live_grep = {
        additional_args = function(opts)
          return {"--hidden"}
        end,
        glob_pattern = "!**/.git/*",
      },
      
      grep_string = {
        additional_args = function(opts)
          return {"--hidden"}
        end,
      },
      
      -- Buffer picker
      buffers = {
        theme = "dropdown",
        previewer = false,
        initial_mode = "normal",
        mappings = {
          i = {
            ["<C-d>"] = actions.delete_buffer,
          },
          n = {
            ["dd"] = actions.delete_buffer,
          },
        },
      },
      
      -- Recent files
      oldfiles = {
        theme = "dropdown",
        previewer = false,
      },
      
      -- Command picker
      commands = {
        theme = "dropdown",
        previewer = false,
      },
      
      -- Help tags
      help_tags = {
        theme = "ivy",
      },
      
      -- Git pickers
      git_files = {
        theme = "dropdown",
        previewer = false,
      },
      
      git_commits = {
        layout_config = {
          horizontal = {
            preview_width = 0.55,
          },
        },
      },
      
      git_bcommits = {
        layout_config = {
          horizontal = {
            preview_width = 0.55,
          },
        },
      },
      
      -- LSP pickers
      lsp_references = {
        theme = "cursor",
        initial_mode = "normal",
      },
      
      lsp_definitions = {
        theme = "cursor",
        initial_mode = "normal",
      },
      
      lsp_document_symbols = {
        theme = "dropdown",
      },
      
      lsp_workspace_symbols = {
        theme = "dropdown",
      },
      
      -- Diagnostic picker
      diagnostics = {
        theme = "ivy",
        initial_mode = "normal",
      },
    },
    
    -- 🔧 EXTENSIONS CONFIGURATION
    extensions = {
      fzf = {
        fuzzy = true,                    -- false will only do exact matching
        override_generic_sorter = true,  -- override the generic sorter
        override_file_sorter = true,     -- override the file sorter
        case_mode = "smart_case",        -- or "ignore_case" or "respect_case"
      },
    },
  })
  
  -- 📦 LOAD EXTENSIONS
  -- Load fzf native extension for better performance
  pcall(telescope.load_extension, 'fzf')
  
  -- 🎯 CUSTOM FUNCTIONS
  -- Create custom telescope functions for enhanced workflows
  
  -- Find files with preview
  M.find_files_with_preview = function()
    require('telescope.builtin').find_files({
      previewer = require('telescope.previewers').vim_buffer_cat.new({}),
      theme = "ivy",
    })
  end
  
  -- Search in current buffer
  M.current_buffer_fuzzy_find = function()
    require('telescope.builtin').current_buffer_fuzzy_find({
      theme = "dropdown",
      previewer = false,
    })
  end
  
  -- Live grep with args
  M.live_grep_args = function()
    require('telescope.builtin').live_grep({
      additional_args = function(opts)
        return {"--hidden", "--no-ignore"}
      end
    })
  end
  
  -- Search dotfiles
  M.search_dotfiles = function()
    require('telescope.builtin').find_files({
      prompt_title = "< Dotfiles >",
      cwd = vim.fn.expand("~/.dotfiles"),
      hidden = true,
    })
  end
  
  -- Search Neovim config
  M.search_nvim_config = function()
    require('telescope.builtin').find_files({
      prompt_title = "< Neovim Config >",
      cwd = vim.fn.stdpath("config"),
    })
  end
  
  -- Project search (look for git root or common project files)
  M.project_files = function()
    local opts = {}
    
    local ok = pcall(require('telescope.builtin').git_files, opts)
    if not ok then
      require('telescope.builtin').find_files(opts)
    end
  end
  
  -- LSP Symbol search functions
  M.lsp_document_symbols = function()
    require('telescope.builtin').lsp_document_symbols({
      symbols = {
        'Class', 'Function', 'Method', 'Constructor', 'Interface',
        'Module', 'Struct', 'Trait', 'Field', 'Property', 'Enum',
        'Constant', 'String', 'Number', 'Boolean', 'Array', 'Object',
        'Key', 'Null', 'EnumMember', 'Event', 'Operator', 'TypeParameter'
      }
    })
  end
  
  M.lsp_workspace_symbols = function(query)
    require('telescope.builtin').lsp_workspace_symbols({
      query = query or vim.fn.input("Symbol Query: "),
      symbols = {
        'Class', 'Function', 'Method', 'Constructor', 'Interface',
        'Module', 'Struct', 'Trait', 'Field', 'Property', 'Enum',
        'Constant', 'String', 'Number', 'Boolean', 'Array', 'Object',
        'Key', 'Null', 'EnumMember', 'Event', 'Operator', 'TypeParameter'
      }
    })
  end
  
  -- Dynamic symbol search with fallback
  M.lsp_dynamic_workspace_symbols = function()
    require('telescope.builtin').lsp_dynamic_workspace_symbols({
      symbols = {
        'Class', 'Function', 'Method', 'Constructor', 'Interface',
        'Module', 'Struct', 'Trait', 'Field', 'Property', 'Enum',
        'Constant', 'String', 'Number', 'Boolean', 'Array', 'Object',
        'Key', 'Null', 'EnumMember', 'Event', 'Operator', 'TypeParameter'
      }
    })
  end
  
  -- 📊 INTEGRATION WITH EXISTING WORKFLOW
  -- Set up integration points for existing keybindings and menu system
  
  -- Global telescope functions for easy access
  _G.telescope_find_files = function()
    require('telescope.builtin').find_files()
  end
  
  _G.telescope_live_grep = function()
    require('telescope.builtin').live_grep()
  end
  
  _G.telescope_buffers = function()
    require('telescope.builtin').buffers()
  end
  
  _G.telescope_help_tags = function()
    require('telescope.builtin').help_tags()
  end
  
  _G.telescope_recent = function()
    require('telescope.builtin').oldfiles()
  end
  
  _G.telescope_commands = function()
    require('telescope.builtin').commands()
  end
  
  _G.telescope_git_files = function()
    require('telescope.builtin').git_files()
  end
  
  _G.telescope_lsp_document_symbols = function()
    M.lsp_document_symbols()
  end
  
  _G.telescope_lsp_workspace_symbols = function()
    M.lsp_workspace_symbols()
  end
  
  _G.telescope_lsp_dynamic_workspace_symbols = function()
    M.lsp_dynamic_workspace_symbols()
  end
  
  -- 🎨 THEME INTEGRATION
  -- Integrate with existing theme switching system
  -- vim.api.nvim_create_autocmd("ColorScheme", {
  --   callback = function()
  --     -- Update telescope highlights to match current theme
  --     local colors = {
  --       TelescopeNormal = { link = "Normal" },
  --       TelescopeBorder = { link = "FloatBorder" },
  --       TelescopePromptBorder = { link = "FloatBorder" },
  --       TelescopeResultsBorder = { link = "FloatBorder" },
  --       TelescopePreviewBorder = { link = "FloatBorder" },
  --       TelescopeSelection = { link = "Visual" },
  --       TelescopeSelectionCaret = { link = "WarningMsg" },
  --       TelescopeMultiSelection = { link = "Type" },
  --       TelescopeMatching = { link = "Search" },
  --       TelescopePromptPrefix = { link = "Identifier" },
  --     }
  --     
  --     for group, opts in pairs(colors) do
  --       vim.api.nvim_set_hl(0, group, opts)
  --     end
  --   end,
  -- })
  -- 
  -- -- Apply highlights immediately
  -- vim.cmd("doautocmd ColorScheme")
end

-- 🚀 UTILITY FUNCTIONS
-- Additional utility functions for telescope integration

function M.grep_word_under_cursor()
  require('telescope.builtin').grep_string({
    search = vim.fn.expand("<cword>")
  })
end

function M.find_string(search_term)
  require('telescope.builtin').grep_string({
    search = search_term or vim.fn.input("Grep for > ")
  })
end

function M.find_files_by_extension(ext)
  require('telescope.builtin').find_files({
    find_command = {"rg", "--files", "--glob", "*." .. (ext or "lua")}
  })
end

return M
