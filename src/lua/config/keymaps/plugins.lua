--
-- config/keymaps/plugins.lua
-- Plugin-specific mappings (organized by plugin)
--

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Safe plugin wrapper
local function safe_require(module, fn)
  return function(...)
    local ok, m = pcall(require, module)
    if ok and m and (fn and m[fn] or m) then
      if fn then
        return m[fn](...)
      else
        return m(...)
      end
    else
      vim.notify(module .. " not available", vim.log.levels.WARN)
    end
  end
end

-- ============================================================================
-- TELESCOPE
-- ============================================================================
local function telescope_builtin(picker, opts_override)
  return function()
    local ok, builtin = pcall(require, 'telescope.builtin')
    if ok and builtin[picker] then
      builtin[picker](opts_override)
    else
      vim.notify("Telescope not available", vim.log.levels.WARN)
    end
  end
end

-- Core pickers
map("n", "<C-p>", telescope_builtin("find_files"), { desc = "Find Files" })
map("n", "<leader>ff", telescope_builtin("find_files"), { desc = "Find Files" })
map("n", "<leader>fF", telescope_builtin("find_files", { hidden = true }), { desc = "Find Files (+ hidden)" })
map("n", "<leader>fr", telescope_builtin("oldfiles"), { desc = "Recent Files" })
map("n", "<leader>fg", telescope_builtin("live_grep"), { desc = "Live Grep" })
map("n", "<leader>fG", telescope_builtin("live_grep", { additional_args = {"--hidden"} }), { desc = "Live Grep (+ hidden)" })
map("n", "<leader>fb", telescope_builtin("buffers"), { desc = "Buffers" })
map("n", "<leader>fh", telescope_builtin("help_tags"), { desc = "Help" })
map("n", "<leader>fc", telescope_builtin("commands"), { desc = "Commands" })
map("n", "<leader>fk", telescope_builtin("keymaps"), { desc = "Keymaps" })

-- Advanced pickers
map("n", "<leader>f/", telescope_builtin("grep_string"), { desc = "Grep Word Under Cursor" })
map("n", "<leader>f:", telescope_builtin("command_history"), { desc = "Command History" })
map("n", "<leader>f;", telescope_builtin("resume"), { desc = "Resume Last Picker" })
map("n", "<leader>fj", telescope_builtin("jumplist"), { desc = "Jumps" })
map("n", "<leader>fm", telescope_builtin("marks"), { desc = "Marks" })
map("n", "<leader>fq", telescope_builtin("quickfix"), { desc = "Quickfix List" })
map("n", "<leader>fl", telescope_builtin("loclist"), { desc = "Location List" })

-- Specialized pickers
map("n", "<leader>fd", telescope_builtin("find_files", { cwd = vim.fn.stdpath("config") }), { desc = "Config Files" })
map("n", "<leader>fp", telescope_builtin("find_files", { cwd = vim.fn.stdpath("data") .. "/lazy" }), { desc = "Plugin Files" })

-- Git pickers
map("n", "<leader>gf", telescope_builtin("git_files"), { desc = "Git Files" })
map("n", "<leader>gs", telescope_builtin("git_status"), { desc = "Git Status" })
map("n", "<leader>gc", telescope_builtin("git_commits"), { desc = "Git Commits" })
map("n", "<leader>gC", telescope_builtin("git_bcommits"), { desc = "Buffer Git Commits" })

-- Visual mode search
map("v", "<leader>fg", function() 
  local selection = vim.fn.getregion(vim.fn.getpos("'<"), vim.fn.getpos("'>"), { type = vim.fn.mode() })
  telescope_builtin("grep_string")({ search = table.concat(selection, "\n") })
end, { desc = "Grep Selection" })

-- Legacy mappings for compatibility
map("n", "<leader>F", telescope_builtin("find_files"), { desc = "Find Files" })
map("n", "<leader>B", telescope_builtin("buffers"), { desc = "Buffers" })
map("n", "<leader>g", telescope_builtin("live_grep"), { desc = "Live Grep" })

-- ============================================================================
-- SNACKS.NVIM
-- ============================================================================
local ok, snacks = pcall(require, "snacks")

-- Dashboard
map("n", "<leader>sd", function() if ok and snacks then snacks.dashboard() end end, { desc = "Dashboard" })

-- File Explorer
map("n", "<leader>e", function() if ok and snacks then snacks.explorer() end end, { desc = "Explorer" })
map("n", "<leader>E", function() if ok and snacks then snacks.explorer({ cwd = vim.fn.expand("%:p:h") }) end end, { desc = "Explorer (file dir)" })
map("n", "<leader>o", function() if ok and snacks then snacks.explorer() end end, { desc = "Open File Explorer" })
map("n", "<leader>O", function() if ok and snacks then snacks.explorer({ float = true }) end end, { desc = "Open Explorer in Float" })
map("n", "-", function() if ok and snacks then snacks.explorer() end end, { desc = "Open File Explorer" })

-- Terminal
map("n", "<leader>tt", function() if ok and snacks then snacks.terminal() end end, { desc = "Toggle Terminal" })
map("n", "<leader>tf", function() if ok and snacks then snacks.terminal.float() end end, { desc = "Terminal (float)" })
map("n", "<leader>ts", function() if ok and snacks then snacks.terminal.split() end end, { desc = "Terminal (split)" })
map("n", "<leader>tv", function() if ok and snacks then snacks.terminal.split({ position = "right" }) end end, { desc = "Terminal (vsplit)" })
map("n", "<leader>tg", function() if ok and snacks then snacks.terminal("git status") end end, { desc = "Git Status Terminal" })
map("n", "<leader>tp", function() if ok and snacks then snacks.terminal("python3") end end, { desc = "Python Terminal" })
map("n", "<leader>tn", function() if ok and snacks then snacks.terminal("node") end end, { desc = "Node Terminal" })

-- Git
map("n", "<leader>gg", function() if ok and snacks then snacks.lazygit() end end, { desc = "Lazygit" })
map("n", "<leader>gG", function() if ok and snacks then snacks.lazygit({ cwd = vim.fn.expand("%:p:h") }) end end, { desc = "Lazygit (file dir)" })
map("n", "<leader>gb", function() if ok and snacks then snacks.git.blame_line() end end, { desc = "Git Blame Line" })
map("n", "<leader>gB", function() if ok and snacks then snacks.gitbrowse() end end, { desc = "Git Browse" })

-- Scratch buffers
map("n", "<leader>.", function() if ok and snacks then snacks.scratch() end end, { desc = "Toggle Scratch Buffer" })
map("n", "<leader>S", function() if ok and snacks then snacks.scratch.select() end end, { desc = "Select Scratch Buffer" })

-- Notifications
map("n", "<leader>un", function() if ok and snacks then snacks.notifier.hide() end end, { desc = "Dismiss All Notifications" })
map("n", "<leader>nh", function() if ok and snacks then snacks.notifier.show_history() end end, { desc = "Notification History" })

-- Buffer management
map("n", "<leader>bd", function() if ok and snacks then snacks.bufdelete() end end, { desc = "Delete Buffer" })
map("n", "<leader>bD", function() if ok and snacks then snacks.bufdelete.all() end end, { desc = "Delete All Buffers" })
map("n", "<leader>bo", function() if ok and snacks then snacks.bufdelete.other() end end, { desc = "Delete Other Buffers" })

-- Zen mode
map("n", "<leader>z", function() if ok and snacks then snacks.zen() end end, { desc = "Toggle Zen Mode" })
map("n", "<leader>Z", function() if ok and snacks then snacks.zen.zoom() end end, { desc = "Zen Zoom" })

-- Toggle utilities
map("n", "<leader>tw", function() if ok and snacks then snacks.toggle.option("wrap", { name = "Wrap" })() end end, { desc = "Toggle Wrap" })
map("n", "<leader>tS", function() if ok and snacks then snacks.toggle.option("spell", { name = "Spell" })() end end, { desc = "Toggle Spell" })
map("n", "<leader>tn", function() if ok and snacks then snacks.toggle.option("number", { name = "Number" })() end end, { desc = "Toggle Number" })
map("n", "<leader>tr", function() if ok and snacks then snacks.toggle.option("relativenumber", { name = "Relative Number" })() end end, { desc = "Toggle Relative Number" })
map("n", "<leader>th", function() if ok and snacks then snacks.toggle.option("hlsearch")() end end, { desc = "Toggle Highlight Search" })
map("n", "<leader>tD", function() if ok and snacks then snacks.toggle.diagnostics() end end, { desc = "Toggle Diagnostics" })

-- ============================================================================
-- CODECOMPANION
-- ============================================================================
-- Chat and interaction
map("n", "<leader>cc", "<cmd>CodeCompanionChat<cr>", { desc = "CodeCompanion Chat" })
map("v", "<leader>cc", "<cmd>CodeCompanionChat<cr>", { desc = "CodeCompanion Chat with selection" })
map("n", "<leader>ca", "<cmd>CodeCompanionActions<cr>", { desc = "CodeCompanion Action Palette" })
map("v", "<leader>ca", "<cmd>CodeCompanionActions<cr>", { desc = "CodeCompanion Action Palette" })

-- Inline assistance
map("n", "<leader>ci", "<cmd>CodeCompanionInline<cr>", { desc = "CodeCompanion Inline" })
map("v", "<leader>ci", "<cmd>CodeCompanionInline<cr>", { desc = "CodeCompanion Inline with selection" })

-- Quick code actions
local function codecompanion_action(action_text)
  return function()
    vim.cmd("CodeCompanionActions")
    vim.defer_fn(function()
      vim.api.nvim_feedkeys(action_text, "n", false)
    end, 100)
  end
end

map("v", "<leader>cr", codecompanion_action("Code Review"), { desc = "Code Review" })
map("v", "<leader>co", codecompanion_action("Optimize Code"), { desc = "Optimize Code" })
map("v", "<leader>cm", codecompanion_action("Add Comments"), { desc = "Add Comments" })
map("v", "<leader>ct", codecompanion_action("Generate Tests"), { desc = "Generate Tests" })
map("v", "<leader>ce", codecompanion_action("Explain Code"), { desc = "Explain Code" })
map("v", "<leader>cf", codecompanion_action("Fix Bug"), { desc = "Fix Bug" })

-- Chat management
map("n", "<leader>cl", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Toggle CodeCompanion Chat" })
map("n", "<leader>cs", "<cmd>CodeCompanionChat Stop<cr>", { desc = "Stop CodeCompanion" })
map("n", "<leader>cn", "<cmd>CodeCompanionChat New<cr>", { desc = "New CodeCompanion Chat" })

-- Adapter switching
local function switch_codecompanion_adapter(adapter_name)
  local ok, codecompanion = pcall(require, "codecompanion")
  if ok and codecompanion.config and codecompanion.config.strategies and codecompanion.config.strategies.chat then
    codecompanion.config.strategies.chat.adapter = adapter_name
    vim.notify("CodeCompanion switched to " .. adapter_name, vim.log.levels.INFO)
  else
    vim.notify("Failed to switch adapter", vim.log.levels.ERROR)
  end
end

map("n", "<leader>cal", function() switch_codecompanion_adapter("ollama") end, { desc = "Switch to Ollama" })
map("n", "<leader>caa", function() switch_codecompanion_adapter("anthropic") end, { desc = "Switch to Anthropic" })
map("n", "<leader>cao", function() switch_codecompanion_adapter("openai") end, { desc = "Switch to OpenAI" })
map("n", "<leader>cac", function() switch_codecompanion_adapter("copilot") end, { desc = "Switch to Copilot" })

-- ============================================================================
-- OIL.NVIM
-- ============================================================================
map("n", "<leader>N", safe_require("oil", "open"), { desc = "Oil File Explorer" })

-- ============================================================================
-- VIMTEX (LaTeX)
-- ============================================================================
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "tex", "latex", "plaintex" },
  callback = function()
    local buf_opts = { buffer = true, silent = true }
    
    -- Compilation
    map("n", "<leader>ll", "<cmd>VimtexCompile<cr>", vim.tbl_extend("force", buf_opts, { desc = "Toggle Compilation" }))
    map("n", "<leader>lc", "<cmd>VimtexCompileSelected<cr>", vim.tbl_extend("force", buf_opts, { desc = "Compile Selection" }))
    map("n", "<leader>ls", "<cmd>VimtexStop<cr>", vim.tbl_extend("force", buf_opts, { desc = "Stop Compilation" }))
    
    -- Viewing
    map("n", "<leader>lv", "<cmd>VimtexView<cr>", vim.tbl_extend("force", buf_opts, { desc = "View PDF" }))
    map("n", "<leader>lr", "<cmd>VimtexReverse<cr>", vim.tbl_extend("force", buf_opts, { desc = "Reverse Search" }))
    
    -- Cleaning
    map("n", "<leader>lk", "<cmd>VimtexClean<cr>", vim.tbl_extend("force", buf_opts, { desc = "Clean Auxiliary Files" }))
    map("n", "<leader>lK", "<cmd>VimtexClean!<cr>", vim.tbl_extend("force", buf_opts, { desc = "Clean All Files" }))
    
    -- TOC & Navigation
    map("n", "<leader>lt", "<cmd>VimtexTocToggle<cr>", vim.tbl_extend("force", buf_opts, { desc = "Toggle TOC" }))
    map("n", "<leader>li", "<cmd>VimtexInfo<cr>", vim.tbl_extend("force", buf_opts, { desc = "VimTeX Info" }))
    
    -- Text objects
    map("n", "]]", "<cmd>VimtexSectionNext<cr>", vim.tbl_extend("force", buf_opts, { desc = "Next Section" }))
    map("n", "[[", "<cmd>VimtexSectionPrev<cr>", vim.tbl_extend("force", buf_opts, { desc = "Previous Section" }))
    
    -- Quick formatting
    map("v", "<leader>lb", "c\\textbf{<C-r>\"}<Esc>", vim.tbl_extend("force", buf_opts, { desc = "Bold" }))
    map("v", "<leader>li", "c\\textit{<C-r>\"}<Esc>", vim.tbl_extend("force", buf_opts, { desc = "Italic" }))
    map("v", "<leader>l$", "c$<C-r>\"$<Esc>", vim.tbl_extend("force", buf_opts, { desc = "Inline Math" }))
  end,
})