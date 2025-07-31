--
-- config/oil.lua
-- Oil.nvim configuration - Edit your filesystem like a buffer
-- Modern file manager that integrates seamlessly with Neovim
--

local M = {}

function M.setup()
  local oil = require('oil')
  
  -- ⚡ MAIN CONFIGURATION
  oil.setup({
    -- Oil will take over directory buffers (e.g. `vim .` or `:e src/`)
    default_file_explorer = true,
    
    -- ⚙️ COLUMNS CONFIGURATION
    -- Show file details in columns
    columns = {
      "icon",      -- File type icon
      "permissions", -- File permissions (rwx)
      "size",      -- File size
      "mtime",     -- Modified time
    },
    
    -- 🎨 UI CONFIGURATION
    -- Window and buffer settings
    buf_options = {
      buflisted = false,
      bufhidden = "hide",
    },
    win_options = {
      wrap = false,
      signcolumn = "no",
      cursorcolumn = false,
      foldcolumn = "0",
      spell = false,
      list = false,
      conceallevel = 3,
      concealcursor = "nvic",
    },
    
    -- 🔍 DISPLAY OPTIONS
    delete_to_trash = true,      -- Send deleted files to trash
    skip_confirm_for_simple_edits = false,  -- Always confirm edits
    prompt_save_on_select_new_entry = true, -- Save before selecting
    cleanup_delay_ms = 2000,     -- Delay cleanup of oil buffers
    lsp_file_methods = {
      -- Enable LSP file operations
      timeout_ms = 1000,
      autosave_changes = false,
    },
    constrain_cursor = "editable", -- Keep cursor on editable files
    watch_for_changes = true,      -- Watch for external file changes
    
    -- 📁 VIEW OPTIONS
    view_options = {
      -- Show files and directories that start with "."
      show_hidden = false,
      -- This function defines what is considered a "hidden" file
      is_hidden_file = function(name, bufnr)
        return vim.startswith(name, ".")
      end,
      -- This function defines what will never be shown, even when `show_hidden` is set
      is_always_hidden = function(name, bufnr)
        return name == ".." or name == ".git"
      end,
      natural_order = true,      -- Natural sorting (1, 2, 10 instead of 1, 10, 2)
      sort = {
        { "type", "asc" },       -- Directories first
        { "name", "asc" },       -- Then alphabetical
      },
    },
    
    -- 🖥️ FLOAT CONFIGURATION
    float = {
      -- Padding around the floating window
      padding = 2,
      max_width = 100,
      max_height = 30,
      border = "rounded",
      win_options = {
        winblend = 0,
      },
      -- This is the config that will be passed to nvim_open_win.
      -- Change values here to customize the layout
      override = function(conf)
        return conf
      end,
    },
    
    -- 🎯 PREVIEW WINDOW
    preview = {
      -- Width dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
      -- min_width and max_width can be a single value or a list of mixed integer/float types.
      max_width = 0.9,
      -- min_width = {40, 0.4} means "at least 40 columns, or at least 40% of total"
      min_width = {40, 0.4},
      -- optionally define an integer/float for the exact width of the preview window
      width = nil,
      -- Height dimensions can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
      max_height = 0.9,
      min_height = {5, 0.1},
      -- optionally define an integer/float for the exact height of the preview window
      height = nil,
      border = "rounded",
      win_options = {
        winblend = 0,
      },
      -- Whether the preview window is automatically updated when the cursor is moved
      update_on_cursor_moved = true,
    },
    
    -- 📄 PROGRESS CONFIGURATION
    progress = {
      max_width = 0.9,
      min_width = {40, 0.4},
      width = nil,
      max_height = {10, 0.9},
      min_height = {5, 0.1},
      height = nil,
      border = "rounded",
      minimized_border = "none",
      win_options = {
        winblend = 0,
      },
    },
    
    -- 🔧 SSH CONFIGURATION
    ssh = {
      border = "rounded",
    },
  })
  
  -- 🎯 KEYMAPS
  -- Set up oil-specific keymaps
  vim.api.nvim_create_autocmd("FileType", {
    pattern = "oil",
    callback = function()
      local map = vim.keymap.set
      
      -- Navigation
      map("n", "<CR>", "actions.select", { buffer = true, remap = true, desc = "Open file/directory" })
      map("n", "<C-s>", "actions.select_vsplit", { buffer = true, remap = true, desc = "Open in vertical split" })
      map("n", "<C-h>", "actions.select_split", { buffer = true, remap = true, desc = "Open in horizontal split" })
      map("n", "<C-t>", "actions.select_tab", { buffer = true, remap = true, desc = "Open in new tab" })
      map("n", "<C-p>", "actions.preview", { buffer = true, remap = true, desc = "Preview file" })
      map("n", "<C-c>", "actions.close", { buffer = true, remap = true, desc = "Close oil" })
      map("n", "<C-l>", "actions.refresh", { buffer = true, remap = true, desc = "Refresh" })
      
      -- Directory navigation
      map("n", "-", "actions.parent", { buffer = true, remap = true, desc = "Go to parent directory" })
      map("n", "_", "actions.open_cwd", { buffer = true, remap = true, desc = "Open cwd" })
      map("n", "`", "actions.cd", { buffer = true, remap = true, desc = "CD to directory" })
      map("n", "~", "actions.tcd", { buffer = true, remap = true, desc = "Tab CD to directory" })
      
      -- File operations
      map("n", "gs", "actions.change_sort", { buffer = true, remap = true, desc = "Change sort" })
      map("n", "gx", "actions.open_external", { buffer = true, remap = true, desc = "Open with system app" })
      map("n", "g.", "actions.toggle_hidden", { buffer = true, remap = true, desc = "Toggle hidden files" })
      map("n", "g\\", "actions.toggle_trash", { buffer = true, remap = true, desc = "Toggle trash" })
      
      -- Advanced operations
      map("n", "g?", "actions.show_help", { buffer = true, remap = true, desc = "Show help" })
      
      -- Integration with other tools
      map("n", "<leader>ff", function()
        require('telescope.builtin').find_files({ cwd = require('oil').get_current_dir() })
      end, { buffer = true, desc = "Telescope in current directory" })
      
      map("n", "<leader>fg", function()
        require('telescope.builtin').live_grep({ cwd = require('oil').get_current_dir() })
      end, { buffer = true, desc = "Live grep in current directory" })
    end,
  })
  
  -- 🎨 THEME INTEGRATION
  -- Set up oil highlights to match current theme
  vim.api.nvim_create_autocmd("ColorScheme", {
    callback = function()
      local colors = {
        OilDir = { link = "Directory" },
        OilFile = { link = "Normal" },
        OilLink = { link = "Constant" },
        OilSocket = { link = "Special" },
        OilPipe = { link = "Special" },
        OilBlock = { link = "Special" },
        OilChar = { link = "Special" },
        OilExecutable = { link = "Function" },
        OilSize = { link = "Number" },
        OilMtime = { link = "Comment" },
        OilPermissions = { link = "String" },
        OilTrash = { link = "Comment" },
        OilCreate = { link = "DiffAdd" },
        OilDelete = { link = "DiffDelete" },
        OilMove = { link = "DiffChange" },
        OilRestore = { link = "DiffAdd" },
      }
      
      for group, opts in pairs(colors) do
        vim.api.nvim_set_hl(0, group, opts)
      end
    end,
  })
  
  -- Apply highlights immediately
  vim.cmd("doautocmd ColorScheme")
  
  -- 🌐 GLOBAL FUNCTIONS
  -- Set up global functions for easy access
  _G.oil_open = function()
    require('oil').open()
  end
  
  _G.oil_float = function()
    require('oil').open_float()
  end
  
  _G.oil_toggle = function()
    local oil_buffers = vim.tbl_filter(function(buf)
      return vim.bo[buf].filetype == "oil"
    end, vim.api.nvim_list_bufs())
    
    if #oil_buffers > 0 then
      -- Close all oil buffers
      for _, buf in ipairs(oil_buffers) do
        if vim.api.nvim_buf_is_valid(buf) then
          vim.api.nvim_buf_delete(buf, { force = true })
        end
      end
    else
      -- Open oil
      require('oil').open()
    end
  end
  
  -- 🔧 UTILITY FUNCTIONS
  -- Convenience functions for common operations
  
  -- Open oil in the directory of the current file
  function M.open_current_dir()
    local current_file = vim.fn.expand('%:p')
    if current_file == '' then
      require('oil').open()
    else
      require('oil').open(vim.fn.fnamemodify(current_file, ':h'))
    end
  end
  
  -- Open oil in a floating window
  function M.open_float()
    require('oil').open_float()
  end
  
  -- Save and quit oil buffer
  function M.save_and_quit()
    local oil = require('oil')
    oil.save({ confirm = false }, function()
      vim.cmd('q')
    end)
  end
  
  -- Discard changes and quit
  function M.discard_and_quit()
    local oil = require('oil')
    oil.discard_all_changes()
    vim.cmd('q')
  end
  
  -- 📊 INTEGRATION WITH EXISTING WORKFLOW
  -- Set up integration points for existing keybindings
  
  -- File explorer functionality
  vim.api.nvim_create_user_command('Oil', function()
    require('oil').open()
  end, { desc = 'Open Oil file manager' })
  
  vim.api.nvim_create_user_command('OilFloat', function()
    require('oil').open_float()
  end, { desc = 'Open Oil in floating window' })
  
  vim.api.nvim_create_user_command('OilToggle', function()
    _G.oil_toggle()
  end, { desc = 'Toggle Oil file manager' })
  
  -- 🚀 STARTUP OPTIMIZATION
  -- Configure oil for better performance
  
  -- Don't load oil for directories passed as arguments to nvim
  -- This lets oil take over naturally when needed
  
  -- Oil will automatically take over directory buffers due to default_file_explorer = true
end

-- 🎯 ADDITIONAL UTILITIES
-- Helper functions for oil integration

-- Get the directory that oil is currently viewing
function M.get_oil_cwd()
  local oil = require('oil')
  return oil.get_current_dir()
end

-- Check if current buffer is an oil buffer
function M.is_oil_buffer()
  return vim.bo.filetype == "oil"
end

-- Open telescope in the current oil directory
function M.telescope_in_oil_dir()
  if M.is_oil_buffer() then
    local cwd = M.get_oil_cwd()
    require('telescope.builtin').find_files({ cwd = cwd })
  else
    require('telescope.builtin').find_files()
  end
end

return M