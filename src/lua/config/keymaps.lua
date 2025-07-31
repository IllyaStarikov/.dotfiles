--
-- config/keymaps.lua
-- Key mappings (migrated from vimscript)
--

local map = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Set leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Ensure VIMRUNTIME is properly set (fix for checkhealth)
if not vim.env.VIMRUNTIME or vim.env.VIMRUNTIME == "" then
  local runtime_path = vim.fn.fnamemodify(vim.v.progpath, ":h:h") .. "/share/nvim/runtime"
  if vim.fn.isdirectory(runtime_path) == 1 then
    vim.env.VIMRUNTIME = runtime_path
  end
end

-- Commands for common typos
vim.api.nvim_create_user_command("W", "w", {})
vim.api.nvim_create_user_command("Q", "q", {})
vim.api.nvim_create_user_command("Wq", "wq", {})

-- Go up and down properly on wrapped text
map("n", "<Down>", "gj", opts)
map("n", "<Up>", "gk", opts)
map("v", "<Down>", "gj", opts)
map("v", "<Up>", "gk", opts)
map("i", "<Down>", "<C-o>gj", opts)
map("i", "<Up>", "<C-o>gk", opts)

-- Word wrap navigation
map("n", "k", "v:count == 0 ? 'gk' : 'k'", { expr = true, silent = true })
map("n", "j", "v:count == 0 ? 'gj' : 'j'", { expr = true, silent = true })
map("n", "0", "g0", { buffer = true, silent = true })
map("n", "$", "g$", { buffer = true, silent = true })

-- Window navigation using arrow keys
map("n", "<up>", "<C-w><up>", opts)
map("n", "<down>", "<C-w><down>", opts)
map("n", "<left>", "<C-w><left>", opts)
map("n", "<right>", "<C-w><right>", opts)

-- Buffer navigation
map("n", "<Tab>", ":bnext<cr>", opts)
map("n", "<S-Tab>", ":bprevious<cr>", opts)

-- Buffer navigation by number
for i = 1, 9 do
  map("n", "<leader>" .. i, function() vim.cmd("buffer " .. i) end, { desc = "Go to buffer " .. i })
end
map("n", "<leader>0", ":bprevious<cr>", { desc = "Go to previous buffer" })

-- Diagnostic navigation (using built-in LSP)
map("n", "[W", function() vim.diagnostic.goto_prev({ severity = vim.diagnostic.severity.ERROR }) end, { desc = "Go to first error" })
map("n", "[w", vim.diagnostic.goto_prev, { desc = "Go to previous diagnostic" })
map("n", "]w", vim.diagnostic.goto_next, { desc = "Go to next diagnostic" })
map("n", "]W", function() vim.diagnostic.goto_next({ severity = vim.diagnostic.severity.ERROR }) end, { desc = "Go to last error" })

-- LSP functionality (replacing ALE)
map("n", "<C-]>", vim.lsp.buf.definition, { desc = "Go to definition" })
map("n", "<C-\\>", vim.lsp.buf.references, { desc = "Find references" })
map("n", "<C-[>", vim.lsp.buf.hover, { desc = "Show hover information" })

-- Copy filename
map("n", ",cs", ":let @+=expand('%')<CR>", opts)
map("n", ",cl", ":let @+=expand('%:p')<CR>", opts)

-- Leader key mappings
map("n", "<leader>w", ":w<cr>", opts)
map("n", "<leader>q", ":q<cr>", opts)
map("n", "<leader>c", ":Kwbd<cr>", opts)
map("n", "<leader>x", ":x<cr>", opts)
map("n", "<leader>d", '"_d', opts)

-- File Management
map("n", "<leader>o", function() require('oil').open() end, { desc = "Open Oil File Manager" })
map("n", "<leader>O", function() require('oil').open_float() end, { desc = "Open Oil in Float" })
map("n", "-", function() require('oil').open() end, { desc = "Open Oil File Manager" })
-- Telescope fuzzy finding (modern replacement for FZF)
map("n", "<C-p>", function() require('telescope.builtin').find_files() end, { desc = "Find Files" })
map("n", "<leader>F", function() require('telescope.builtin').find_files() end, { desc = "Find Files" })  -- Telescope
map("n", "<leader>B", function() require('telescope.builtin').buffers() end, { desc = "Buffers" })  -- Telescope
-- <leader>T is now used for Aerial (code outline)
map("n", "<leader>g", function() require('telescope.builtin').live_grep() end, { desc = "Live Grep" })
map("n", "<leader><leader>", "v$h", opts)

-- Mini.align is configured with ga/gA in the plugin setup

-- Copy full path
map("n", "<Leader>p", ":let @+=expand('%:p')<CR>", opts)

-- Terminal (using snacks.nvim terminal instead)
-- <leader>T is now used for Aerial (code outline)
map("t", "<Esc>", "<C-\\><C-n>", opts)

-- Quick save
map("n", "<C-s>", ":w<CR>", opts)
map("i", "<C-s>", "<Esc>:w<CR>a", opts)
map("v", "<C-s>", "<Esc>:w<CR>", opts)

-- Select all
map("n", "<C-a>", "ggVG", opts)

-- Better indenting
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)

-- Move lines up and down
map("n", "<A-j>", ":m .+1<CR>==", opts)
map("n", "<A-k>", ":m .-2<CR>==", opts)
map("v", "<A-j>", ":m '>+1<CR>gv=gv", opts)
map("v", "<A-k>", ":m '<-2<CR>gv=gv", opts)

-- Clear search highlight
map("n", "<Esc>", ":noh<CR>", opts)

-- Menu system (comprehensive configuration in config/menu.lua)
-- <C-t>        - Smart context-aware menu
-- <leader>m    - Open main menu
-- <leader>M    - Open context menu
-- <leader>mf   - Quick file operations menu
-- <leader>mg   - Git operations menu  
-- <leader>mc   - Code/LSP operations menu
-- <leader>ma   - AI Assistant menu
-- <RightMouse> - Context menu at mouse position

-- Typing practice (comprehensive configuration in config/typr.lua)
-- Access via commands: :Typr, :TyprStats, :TyprQuick, :TyprLong, :TyprProgramming
-- Or via main menu (<C-t> or <leader>m) under "Typing Test" section

-- Modern improvements
-- Better search experience
map("n", "<Esc>", ":nohlsearch<CR>", opts)

-- Move lines up/down
map("v", "J", ":m '>+1<CR>gv=gv", opts)
map("v", "K", ":m '<-2<CR>gv=gv", opts)

-- Better indenting in visual mode
map("v", "<", "<gv", opts)
map("v", ">", ">gv", opts)

-- Paste without yanking in visual mode
map("v", "p", '"_dP', opts)

-- Better jumps without centering (for performance)
map("n", "<C-d>", "<C-d>", opts)
map("n", "<C-u>", "<C-u>", opts)
map("n", "n", "nzv", opts)
map("n", "N", "Nzv", opts)

-- Quick save all
map("n", "<leader>W", ":wa<cr>", opts)

-- Close all but current buffer
map("n", "<leader>bo", ":%bd|e#<cr>", opts)

-- CodeCompanion AI Assistant
-- Chat and interaction
map("n", "<leader>cc", "<cmd>CodeCompanionChat<cr>", { desc = "CodeCompanion Chat" })
map("v", "<leader>cc", "<cmd>CodeCompanionChat<cr>", { desc = "CodeCompanion Chat with selection" })
map("n", "<leader>ca", "<cmd>CodeCompanionActions<cr>", { desc = "CodeCompanion Action Palette" })
map("v", "<leader>ca", "<cmd>CodeCompanionActions<cr>", { desc = "CodeCompanion Action Palette" })

-- Inline assistance
map("n", "<leader>ci", "<cmd>CodeCompanionInline<cr>", { desc = "CodeCompanion Inline" })
map("v", "<leader>ci", "<cmd>CodeCompanionInline<cr>", { desc = "CodeCompanion Inline with selection" })

-- Quick code actions (visual mode)
map("v", "<leader>cr", function()
  vim.cmd("CodeCompanionActions")
  vim.defer_fn(function()
    vim.api.nvim_feedkeys("Code Review", "n", false)
  end, 100)
end, { desc = "Code Review" })

map("v", "<leader>co", function()
  vim.cmd("CodeCompanionActions")
  vim.defer_fn(function()
    vim.api.nvim_feedkeys("Optimize Code", "n", false)
  end, 100)
end, { desc = "Optimize Code" })

map("v", "<leader>cm", function()
  vim.cmd("CodeCompanionActions")
  vim.defer_fn(function()
    vim.api.nvim_feedkeys("Add Comments", "n", false)
  end, 100)
end, { desc = "Add Comments" })

map("v", "<leader>ct", function()
  vim.cmd("CodeCompanionActions")
  vim.defer_fn(function()
    vim.api.nvim_feedkeys("Generate Tests", "n", false)
  end, 100)
end, { desc = "Generate Tests" })

map("v", "<leader>ce", function()
  vim.cmd("CodeCompanionActions")
  vim.defer_fn(function()
    vim.api.nvim_feedkeys("Explain Code", "n", false)
  end, 100)
end, { desc = "Explain Code" })

map("v", "<leader>cf", function()
  vim.cmd("CodeCompanionActions")
  vim.defer_fn(function()
    vim.api.nvim_feedkeys("Fix Bug", "n", false)
  end, 100)
end, { desc = "Fix Bug" })

-- Chat management
map("n", "<leader>cl", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "Toggle CodeCompanion Chat" })
map("n", "<leader>cs", "<cmd>CodeCompanionChat Stop<cr>", { desc = "Stop CodeCompanion" })
map("n", "<leader>cn", "<cmd>CodeCompanionChat New<cr>", { desc = "New CodeCompanion Chat" })

-- Toggle between different adapters (requires custom function)
map("n", "<leader>cal", function()
  require("codecompanion").setup({
    strategies = { chat = { adapter = "ollama" } }
  })
end, { desc = "Switch to Ollama" })

map("n", "<leader>caa", function()
  require("codecompanion").setup({
    strategies = { chat = { adapter = "anthropic" } }
  })
end, { desc = "Switch to Anthropic" })

map("n", "<leader>cao", function()
  require("codecompanion").setup({
    strategies = { chat = { adapter = "openai" } }
  })
end, { desc = "Switch to OpenAI" })

map("n", "<leader>cac", function()
  require("codecompanion").setup({
    strategies = { chat = { adapter = "copilot" } }
  })
end, { desc = "Switch to Copilot" })

-- 🍿 SNACKS.NVIM: High-Performance Power User Keybindings

-- 🎯 DASHBOARD & CORE
map("n", "<leader>sd", function() Snacks.dashboard() end, { desc = "Dashboard" })
map("n", "<leader>sD", function() Snacks.dashboard.open() end, { desc = "Force Open Dashboard" })

-- 📋 SCRATCH BUFFERS (Power User Workflow)
map("n", "<leader>.", function() Snacks.scratch() end, { desc = "Toggle Scratch Buffer" })
map("n", "<leader>S", function() Snacks.scratch.select() end, { desc = "Select Scratch Buffer" })
map("n", "<leader>sn", function() Snacks.scratch({ name = "notes" }) end, { desc = "Notes Scratch" })
map("n", "<leader>st", function() Snacks.scratch({ name = "todo", ft = "markdown" }) end, { desc = "Todo Scratch" })
map("n", "<leader>sc", function() Snacks.scratch({ name = "code", ft = "lua" }) end, { desc = "Code Scratch" })

-- 🚀 TERMINAL (Lightning Fast)
map("n", "<leader>tt", function() Snacks.terminal() end, { desc = "Toggle Terminal" })
map("n", "<leader>tf", function() Snacks.terminal.float() end, { desc = "Terminal (float)" })
map("n", "<leader>ts", function() Snacks.terminal.split() end, { desc = "Terminal (split)" })
map("n", "<leader>tv", function() Snacks.terminal.split({ position = "right" }) end, { desc = "Terminal (vsplit)" })
-- Quick terminal commands
map("n", "<leader>tg", function() Snacks.terminal("git status") end, { desc = "Git Status Terminal" })
map("n", "<leader>tp", function() Snacks.terminal("python3") end, { desc = "Python Terminal" })
map("n", "<leader>tn", function() Snacks.terminal("node") end, { desc = "Node Terminal" })

-- 🔍 TELESCOPE (Modern Fuzzy Finding)
-- Core pickers with advanced features
map("n", "<leader>ff", function() require('telescope.builtin').find_files() end, { desc = "Find Files" })
map("n", "<leader>fF", function() require('telescope.builtin').find_files({ hidden = true }) end, { desc = "Find Files (+ hidden)" })
map("n", "<leader>fr", function() require('telescope.builtin').oldfiles() end, { desc = "Recent Files" })
map("n", "<leader>fg", function() require('telescope.builtin').live_grep() end, { desc = "Live Grep" })
map("n", "<leader>fG", function() require('telescope.builtin').live_grep({ additional_args = {"--hidden"} }) end, { desc = "Live Grep (+ hidden)" })
map("n", "<leader>fb", function() require('telescope.builtin').buffers() end, { desc = "Buffers" })
map("n", "<leader>fh", function() require('telescope.builtin').help_tags() end, { desc = "Help" })
map("n", "<leader>fc", function() require('telescope.builtin').commands() end, { desc = "Commands" })
map("n", "<leader>fk", function() require('telescope.builtin').keymaps() end, { desc = "Keymaps" })

-- Advanced pickers
map("n", "<leader>f/", function() require('telescope.builtin').grep_string() end, { desc = "Grep Word Under Cursor" })
map("n", "<leader>f:", function() require('telescope.builtin').command_history() end, { desc = "Command History" })
map("n", "<leader>f;", function() require('telescope.builtin').resume() end, { desc = "Resume Last Picker" })
map("n", "<leader>fj", function() require('telescope.builtin').jumplist() end, { desc = "Jumps" })
map("n", "<leader>fm", function() require('telescope.builtin').marks() end, { desc = "Marks" })
map("n", "<leader>fq", function() require('telescope.builtin').quickfix() end, { desc = "Quickfix List" })
map("n", "<leader>fl", function() require('telescope.builtin').loclist() end, { desc = "Location List" })

-- Specialized pickers
map("n", "<leader>fd", function() require('telescope.builtin').find_files({ cwd = vim.fn.stdpath("config") }) end, { desc = "Config Files" })
map("n", "<leader>fp", function() require('telescope.builtin').find_files({ cwd = vim.fn.stdpath("data") .. "/lazy" }) end, { desc = "Plugin Files" })
map("n", "<leader>fv", function() require('telescope.builtin').find_files({ cwd = vim.env.VIMRUNTIME }) end, { desc = "Neovim Runtime" })

-- 🌐 GIT INTEGRATION (Supercharged)
map("n", "<leader>gg", function() Snacks.lazygit() end, { desc = "Lazygit" })
map("n", "<leader>gG", function() Snacks.lazygit({ cwd = vim.fn.expand("%:p:h") }) end, { desc = "Lazygit (file dir)" })
map("n", "<leader>gb", function() Snacks.git.blame_line() end, { desc = "Git Blame Line" })
map("n", "<leader>gB", function() Snacks.gitbrowse() end, { desc = "Git Browse" })
map("n", "<leader>gf", function() require('telescope.builtin').git_files() end, { desc = "Git Files" })
map("n", "<leader>gs", function() require('telescope.builtin').git_status() end, { desc = "Git Status" })
map("n", "<leader>gc", function() require('telescope.builtin').git_commits() end, { desc = "Git Commits" })
map("n", "<leader>gC", function() require('telescope.builtin').git_bcommits() end, { desc = "Buffer Git Commits" })

-- 📱 NOTIFICATIONS (Smart Management)
map("n", "<leader>un", function() Snacks.notifier.hide() end, { desc = "Dismiss All Notifications" })
map("n", "<leader>nh", function() Snacks.notifier.show_history() end, { desc = "Notification History" })
map("n", "<leader>nd", function() Snacks.notifier.hide() Snacks.notifier.show_history() end, { desc = "Clear & Show History" })

-- 📦 BUFFER MANAGEMENT (Power User)
map("n", "<leader>bd", function() Snacks.bufdelete() end, { desc = "Delete Buffer" })
map("n", "<leader>bD", function() Snacks.bufdelete.all() end, { desc = "Delete All Buffers" })
map("n", "<leader>bo", function() Snacks.bufdelete.other() end, { desc = "Delete Other Buffers" })
map("n", "<leader>bh", function() Snacks.bufdelete.hidden() end, { desc = "Delete Hidden Buffers" })
map("n", "<leader>bu", function() Snacks.bufdelete.unnamed() end, { desc = "Delete Unnamed Buffers" })

-- 🔍 FILE EXPLORER (Lightning Fast)
map("n", "<leader>e", function() Snacks.explorer() end, { desc = "Explorer" })
map("n", "<leader>E", function() Snacks.explorer({ cwd = vim.fn.expand("%:p:h") }) end, { desc = "Explorer (file dir)" })
-- Alternative file explorer (Oil)
map("n", "<leader>N", function() require('oil').open() end, { desc = "Oil File Explorer" })

-- 🧘 ZEN MODE (Focus Enhancement)
map("n", "<leader>z", function() Snacks.zen() end, { desc = "Toggle Zen Mode" })
map("n", "<leader>Z", function() Snacks.zen.zoom() end, { desc = "Zen Zoom" })

-- 🔄 RENAME (LSP-Integrated)
map("n", "<leader>rn", function() Snacks.rename.rename_file() end, { desc = "Rename File" })
map("n", "<leader>rN", function() vim.lsp.buf.rename() end, { desc = "LSP Rename Symbol" })

-- ⚡ TOGGLE UTILITIES (Quick Switches)
map("n", "<leader>tw", function() Snacks.toggle.option("wrap", { name = "Wrap" }) end, { desc = "Toggle Wrap" })
map("n", "<leader>tS", function() Snacks.toggle.option("spell", { name = "Spell" }) end, { desc = "Toggle Spell" })
map("n", "<leader>tn", function() Snacks.toggle.option("number", { name = "Number" }) end, { desc = "Toggle Number" })
map("n", "<leader>tr", function() Snacks.toggle.option("relativenumber", { name = "Relative Number" }) end, { desc = "Toggle Relative Number" })
map("n", "<leader>tc", function() Snacks.toggle.option("conceallevel", { off = 0, on = 2 }) end, { desc = "Toggle Conceal" })
map("n", "<leader>th", function() Snacks.toggle.option("hlsearch") end, { desc = "Toggle Highlight Search" })
map("n", "<leader>ti", function() Snacks.toggle.indent() end, { desc = "Toggle Indent Guides" })
map("n", "<leader>td", function() Snacks.toggle.dim() end, { desc = "Toggle Dim" })
map("n", "<leader>tD", function() Snacks.toggle.diagnostics() end, { desc = "Toggle Diagnostics" })

-- 🎯 SCOPE NAVIGATION (Treesitter Magic)
map("n", "[s", function() Snacks.scope.jump({ direction = "prev" }) end, { desc = "Previous Scope" })
map("n", "]s", function() Snacks.scope.jump({ direction = "next" }) end, { desc = "Next Scope" })
map("n", "[S", function() Snacks.scope.jump({ direction = "prev", edge = true }) end, { desc = "Previous Scope Edge" })
map("n", "]S", function() Snacks.scope.jump({ direction = "next", edge = true }) end, { desc = "Next Scope Edge" })

-- 🔧 POWER USER UTILITIES
map("n", "<leader>pp", function() Snacks.profiler.pick() end, { desc = "Profiler" })
map("n", "<leader>pP", function() Snacks.profiler.scratch() end, { desc = "Profiler Scratch" })
map("n", "<leader>pd", function() Snacks.debug.inspect() end, { desc = "Debug Inspect" })
map("n", "<leader>pD", function() Snacks.debug.backtrace() end, { desc = "Debug Backtrace" })

-- 🎨 VISUAL ENHANCEMENTS
map("n", "<leader>vh", function() Snacks.words.jump(vim.v.count1, true) end, { desc = "Next Reference" })
map("n", "<leader>vH", function() Snacks.words.jump(-vim.v.count1, true) end, { desc = "Prev Reference" })

-- 🌈 MULTI-SELECT OPERATIONS (Advanced Telescope Usage)
map("v", "<leader>fg", function() 
  local selection = vim.fn.getregion(vim.fn.getpos("'<"), vim.fn.getpos("'>"), { type = vim.fn.mode() })
  require('telescope.builtin').grep_string({ search = table.concat(selection, "\n") })
end, { desc = "Grep Selection" })

map("v", "<leader>ff", function()
  local selection = vim.fn.getregion(vim.fn.getpos("'<"), vim.fn.getpos("'>"), { type = vim.fn.mode() })
  require('telescope.builtin').find_files({ default_text = table.concat(selection, "") })
end, { desc = "Find Files with Selection" })

-- 📝 VIMTEX: LaTeX Power User Keybindings (Buffer-local for .tex files)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "tex", "latex", "plaintex" },
  callback = function()
    local buf_opts = { buffer = true, silent = true }
    
    -- 🚀 COMPILATION
    map("n", "<leader>ll", "<cmd>VimtexCompile<cr>", vim.tbl_extend("force", buf_opts, { desc = "Toggle Compilation" }))
    map("n", "<leader>lc", "<cmd>VimtexCompileSelected<cr>", vim.tbl_extend("force", buf_opts, { desc = "Compile Selection" }))
    map("n", "<leader>ls", "<cmd>VimtexStop<cr>", vim.tbl_extend("force", buf_opts, { desc = "Stop Compilation" }))
    map("n", "<leader>lS", "<cmd>VimtexStopAll<cr>", vim.tbl_extend("force", buf_opts, { desc = "Stop All Compilation" }))
    
    -- 📖 VIEWING
    map("n", "<leader>lv", "<cmd>VimtexView<cr>", vim.tbl_extend("force", buf_opts, { desc = "View PDF" }))
    map("n", "<leader>lr", "<cmd>VimtexReverse<cr>", vim.tbl_extend("force", buf_opts, { desc = "Reverse Search" }))
    
    -- 🧹 CLEANING
    map("n", "<leader>lk", "<cmd>VimtexClean<cr>", vim.tbl_extend("force", buf_opts, { desc = "Clean Auxiliary Files" }))
    map("n", "<leader>lK", "<cmd>VimtexClean!<cr>", vim.tbl_extend("force", buf_opts, { desc = "Clean All Files" }))
    
    -- 📋 TABLE OF CONTENTS & NAVIGATION
    map("n", "<leader>lt", "<cmd>VimtexTocToggle<cr>", vim.tbl_extend("force", buf_opts, { desc = "Toggle TOC" }))
    map("n", "<leader>lT", "<cmd>VimtexTocOpen<cr>", vim.tbl_extend("force", buf_opts, { desc = "Open TOC" }))
    
    -- 🔍 INFORMATION & STATUS
    map("n", "<leader>li", "<cmd>VimtexInfo<cr>", vim.tbl_extend("force", buf_opts, { desc = "VimTeX Info" }))
    map("n", "<leader>lI", "<cmd>VimtexInfoFull<cr>", vim.tbl_extend("force", buf_opts, { desc = "VimTeX Full Info" }))
    map("n", "<leader>lq", "<cmd>VimtexLog<cr>", vim.tbl_extend("force", buf_opts, { desc = "Show Log" }))
    
    -- 🎯 CONTEXT COMMANDS
    map("n", "<leader>lm", "<cmd>VimtexContextMenu<cr>", vim.tbl_extend("force", buf_opts, { desc = "Context Menu" }))
    map("n", "<leader>le", "<cmd>VimtexErrors<cr>", vim.tbl_extend("force", buf_opts, { desc = "Show Errors" }))
    
    -- 🔄 RELOAD & REFRESH
    map("n", "<leader>lR", "<cmd>VimtexReload<cr>", vim.tbl_extend("force", buf_opts, { desc = "Reload VimTeX" }))
    
    -- 📝 TEXT OBJECTS (Enhanced navigation)
    -- Environments
    map("n", "]]", "<cmd>VimtexSectionNext<cr>", vim.tbl_extend("force", buf_opts, { desc = "Next Section" }))
    map("n", "[[", "<cmd>VimtexSectionPrev<cr>", vim.tbl_extend("force", buf_opts, { desc = "Previous Section" }))
    map("n", "][", "<cmd>VimtexSectionNextEnd<cr>", vim.tbl_extend("force", buf_opts, { desc = "Next Section End" }))
    map("n", "[]", "<cmd>VimtexSectionPrevEnd<cr>", vim.tbl_extend("force", buf_opts, { desc = "Previous Section End" }))
    
    -- 🎨 FORMATTING & EDITING
    -- Surround with common LaTeX commands
    map("v", "<leader>lb", "c\\textbf{<C-r>\"}<Esc>", vim.tbl_extend("force", buf_opts, { desc = "Bold" }))
    map("v", "<leader>li", "c\\textit{<C-r>\"}<Esc>", vim.tbl_extend("force", buf_opts, { desc = "Italic" }))
    map("v", "<leader>lu", "c\\underline{<C-r>\"}<Esc>", vim.tbl_extend("force", buf_opts, { desc = "Underline" }))
    map("v", "<leader>lf", "c\\texttt{<C-r>\"}<Esc>", vim.tbl_extend("force", buf_opts, { desc = "Monospace" }))
    map("v", "<leader>le", "c\\emph{<C-r>\"}<Esc>", vim.tbl_extend("force", buf_opts, { desc = "Emphasize" }))
    
    -- Math mode shortcuts
    map("v", "<leader>lM", "c\\[<CR><C-r>\"<CR>\\]<Esc>", vim.tbl_extend("force", buf_opts, { desc = "Display Math" }))
    map("v", "<leader>l$", "c$<C-r>\"$<Esc>", vim.tbl_extend("force", buf_opts, { desc = "Inline Math" }))
    
    -- 🏗️ STRUCTURE COMMANDS
    map("n", "<leader>lsc", "i\\chapter{}<Left>", vim.tbl_extend("force", buf_opts, { desc = "Insert Chapter" }))
    map("n", "<leader>lss", "i\\section{}<Left>", vim.tbl_extend("force", buf_opts, { desc = "Insert Section" }))
    map("n", "<leader>lsS", "i\\subsection{}<Left>", vim.tbl_extend("force", buf_opts, { desc = "Insert Subsection" }))
    map("n", "<leader>lsp", "i\\subsubsection{}<Left>", vim.tbl_extend("force", buf_opts, { desc = "Insert Subsubsection" }))
    
    -- 📚 REFERENCES & CITATIONS
    map("n", "<leader>lrl", "i\\label{}<Left>", vim.tbl_extend("force", buf_opts, { desc = "Insert Label" }))
    map("n", "<leader>lrr", "i\\ref{}<Left>", vim.tbl_extend("force", buf_opts, { desc = "Insert Reference" }))
    map("n", "<leader>lrc", "i\\cite{}<Left>", vim.tbl_extend("force", buf_opts, { desc = "Insert Citation" }))
    map("n", "<leader>lrp", "i\\pageref{}<Left>", vim.tbl_extend("force", buf_opts, { desc = "Insert Page Reference" }))
    
    -- 🖼️ FIGURES & TABLES
    map("n", "<leader>lff", function()
      vim.api.nvim_put({
        "\\begin{figure}[htbp]",
        "    \\centering",
        "    \\includegraphics[width=0.8\\textwidth]{filename}",
        "    \\caption{Caption}",
        "    \\label{fig:label}",
        "\\end{figure}"
      }, "l", true, true)
    end, vim.tbl_extend("force", buf_opts, { desc = "Insert Figure" }))
    
    map("n", "<leader>lft", function()
      vim.api.nvim_put({
        "\\begin{table}[htbp]",
        "    \\centering",
        "    \\begin{tabular}{|c|c|}",
        "        \\hline",
        "        Header1 & Header2 \\\\",
        "        \\hline",
        "        Data1 & Data2 \\\\",
        "        \\hline",
        "    \\end{tabular}",
        "    \\caption{Caption}",
        "    \\label{tab:label}",
        "\\end{table}"
      }, "l", true, true)
    end, vim.tbl_extend("force", buf_opts, { desc = "Insert Table" }))
    
    -- ⚡ QUICK ENVIRONMENTS
    map("n", "<leader>lei", "i\\begin{itemize}<CR>\\item <CR>\\end{itemize}<Esc>k$a", vim.tbl_extend("force", buf_opts, { desc = "Itemize Environment" }))
    map("n", "<leader>len", "i\\begin{enumerate}<CR>\\item <CR>\\end{enumerate}<Esc>k$a", vim.tbl_extend("force", buf_opts, { desc = "Enumerate Environment" }))
    map("n", "<leader>lea", "i\\begin{align}<CR><CR>\\end{align}<Esc>ka", vim.tbl_extend("force", buf_opts, { desc = "Align Environment" }))
    map("n", "<leader>leq", "i\\begin{equation}<CR><CR>\\end{equation}<Esc>ka", vim.tbl_extend("force", buf_opts, { desc = "Equation Environment" }))
    
    -- 🎯 QUICK SYMBOLS (Insert mode)
    vim.keymap.set("i", ",,", "\\,", buf_opts)  -- Thin space
    vim.keymap.set("i", "..", "\\ldots", buf_opts)  -- Ellipsis
    vim.keymap.set("i", "->", "\\rightarrow", buf_opts)  -- Right arrow
    vim.keymap.set("i", "<-", "\\leftarrow", buf_opts)  -- Left arrow
    vim.keymap.set("i", "<=", "\\leq", buf_opts)  -- Less than or equal
    vim.keymap.set("i", ">=", "\\geq", buf_opts)  -- Greater than or equal
    vim.keymap.set("i", "!=", "\\neq", buf_opts)  -- Not equal
    vim.keymap.set("i", "+-", "\\pm", buf_opts)  -- Plus minus
    vim.keymap.set("i", "~=", "\\approx", buf_opts)  -- Approximately equal
    
    -- 📐 MATH SHORTCUTS (Insert mode)
    vim.keymap.set("i", "^^", "^{}<Left>", buf_opts)  -- Superscript
    vim.keymap.set("i", "__", "_{}<Left>", buf_opts)  -- Subscript
    vim.keymap.set("i", "//", "\\frac{}{}<Left><Left><Left>", buf_opts)  -- Fraction
    vim.keymap.set("i", "((", "\\left(\\right)<Left><Left><Left><Left><Left><Left><Left>", buf_opts)  -- Parentheses
    vim.keymap.set("i", "[[", "\\left[\\right]<Left><Left><Left><Left><Left><Left><Left>", buf_opts)  -- Brackets
    vim.keymap.set("i", "{{", "\\left\\{\\right\\}<Left><Left><Left><Left><Left><Left><Left><Left>", buf_opts)  -- Braces
  end,
})

-- 🐛 DEBUG ADAPTER PROTOCOL (DAP) BINDINGS
-- Essential debugging keybindings for nvim-dap

-- Core debugging actions
map("n", "<leader>db", function()
  require('dap').toggle_breakpoint()
end, vim.tbl_extend("force", opts, { desc = "Toggle Breakpoint" }))

map("n", "<leader>dB", function()
  require('dap').set_breakpoint(vim.fn.input('Breakpoint condition: '))
end, vim.tbl_extend("force", opts, { desc = "Set Conditional Breakpoint" }))

map("n", "<leader>dlp", function()
  require('dap').set_breakpoint(nil, nil, vim.fn.input('Log point message: '))
end, vim.tbl_extend("force", opts, { desc = "Set Log Point" }))

-- Debug session control
map("n", "<leader>dc", function()
  require('dap').continue()
end, vim.tbl_extend("force", opts, { desc = "Continue/Start Debugging" }))

map("n", "<leader>dr", function()
  require('dap').restart()
end, vim.tbl_extend("force", opts, { desc = "Restart Debug Session" }))

map("n", "<leader>dt", function()
  require('dap').terminate()
end, vim.tbl_extend("force", opts, { desc = "Terminate Debug Session" }))

map("n", "<leader>dq", function()
  require('dap').close()
end, vim.tbl_extend("force", opts, { desc = "Close Debug Session" }))

-- Stepping controls
map("n", "<leader>ds", function()
  require('dap').step_over()
end, vim.tbl_extend("force", opts, { desc = "Step Over" }))

map("n", "<leader>di", function()
  require('dap').step_into()
end, vim.tbl_extend("force", opts, { desc = "Step Into" }))

map("n", "<leader>do", function()
  require('dap').step_out()
end, vim.tbl_extend("force", opts, { desc = "Step Out" }))

map("n", "<leader>dj", function()
  require('dap').down()
end, vim.tbl_extend("force", opts, { desc = "Go Down Stack Frame" }))

map("n", "<leader>dk", function()
  require('dap').up()
end, vim.tbl_extend("force", opts, { desc = "Go Up Stack Frame" }))

-- DAP UI management
map("n", "<leader>du", function()
  require('dapui').toggle()
end, vim.tbl_extend("force", opts, { desc = "Toggle DAP UI" }))

map("n", "<leader>dU", function()
  require('dapui').open()
end, vim.tbl_extend("force", opts, { desc = "Open DAP UI" }))

map("n", "<leader>dC", function()
  require('dapui').close()
end, vim.tbl_extend("force", opts, { desc = "Close DAP UI" }))

-- Evaluation and inspection
map("n", "<leader>de", function()
  require('dap.ui.widgets').hover()
end, vim.tbl_extend("force", opts, { desc = "Evaluate Expression Under Cursor" }))

map("v", "<leader>de", function()
  require('dap.ui.widgets').hover()
end, vim.tbl_extend("force", opts, { desc = "Evaluate Selected Expression" }))

map("n", "<leader>dE", function()
  vim.ui.input({ prompt = "Expression: " }, function(expr)
    if expr then
      require('dap').eval(expr)
    end
  end)
end, vim.tbl_extend("force", opts, { desc = "Evaluate Expression" }))

-- REPL and scopes
map("n", "<leader>dR", function()
  require('dap').repl.open()
end, vim.tbl_extend("force", opts, { desc = "Open REPL" }))

map("n", "<leader>dS", function()
  local widgets = require('dap.ui.widgets');
  local sidebar = widgets.sidebar(widgets.scopes);
  sidebar.open();
end, vim.tbl_extend("force", opts, { desc = "Open Sidebar (Scopes)" }))

map("n", "<leader>dF", function()
  local widgets = require('dap.ui.widgets');
  local sidebar = widgets.sidebar(widgets.frames);
  sidebar.open();
end, vim.tbl_extend("force", opts, { desc = "Open Sidebar (Frames)" }))

-- Breakpoint management
map("n", "<leader>dbc", function()
  require('dap').clear_breakpoints()
  print("All breakpoints cleared")
end, vim.tbl_extend("force", opts, { desc = "Clear All Breakpoints" }))

map("n", "<leader>dbl", function()
  require('dap').list_breakpoints()
end, vim.tbl_extend("force", opts, { desc = "List Breakpoints" }))

-- Run configurations
map("n", "<leader>drl", function()
  require('dap').run_last()
end, vim.tbl_extend("force", opts, { desc = "Run Last Configuration" }))

map("n", "<leader>dro", function()
  require('dap').run_to_cursor()
end, vim.tbl_extend("force", opts, { desc = "Run to Cursor" }))

-- Utility functions
map("n", "<leader>dh", function()
  require('dap.ui.widgets').hover()
end, vim.tbl_extend("force", opts, { desc = "Hover Variables" }))

map("n", "<leader>dp", function()
  require('dap.ui.widgets').preview()
end, vim.tbl_extend("force", opts, { desc = "Preview Variables" }))

-- Custom debug functions
map("n", "<leader>dn", function()
  require('config.dap').debug_nearest()
end, vim.tbl_extend("force", opts, { desc = "Debug Nearest" }))

-- Function key shortcuts for common actions
map("n", "<F5>", function()
  require('dap').continue()
end, vim.tbl_extend("force", opts, { desc = "DAP Continue" }))

map("n", "<F10>", function()
  require('dap').step_over()
end, vim.tbl_extend("force", opts, { desc = "DAP Step Over" }))

map("n", "<F11>", function()
  require('dap').step_into()
end, vim.tbl_extend("force", opts, { desc = "DAP Step Into" }))

map("n", "<F12>", function()
  require('dap').step_out()
end, vim.tbl_extend("force", opts, { desc = "DAP Step Out" }))

-- Quick toggle for virtual text
map("n", "<leader>dvt", function()
  require('nvim-dap-virtual-text').toggle()
end, vim.tbl_extend("force", opts, { desc = "Toggle Virtual Text" }))

-- Additional quality of life keymaps
-- Quick window resizing
map("n", "<C-Up>", ":resize +2<CR>", opts)
map("n", "<C-Down>", ":resize -2<CR>", opts)
map("n", "<C-Left>", ":vertical resize -2<CR>", opts)
map("n", "<C-Right>", ":vertical resize +2<CR>", opts)

-- Smart split navigation
map("n", "<C-h>", "<C-w>h", opts)
map("n", "<C-j>", "<C-w>j", opts)
map("n", "<C-k>", "<C-w>k", opts)
map("n", "<C-l>", "<C-w>l", opts)

-- Quick split creation
map("n", "<leader>-", ":split<CR>", { desc = "Horizontal Split" })
map("n", "<leader>|", ":vsplit<CR>", { desc = "Vertical Split" })

-- Center cursor after jumps
map("n", "<C-d>", "<C-d>zz", opts)
map("n", "<C-u>", "<C-u>zz", opts)
map("n", "n", "nzzzv", opts)
map("n", "N", "Nzzzv", opts)
map("n", "*", "*zz", opts)
map("n", "#", "#zz", opts)
map("n", "g*", "g*zz", opts)
map("n", "g#", "g#zz", opts)

-- Better join lines
map("n", "J", "mzJ`z", opts)

-- Quickfix navigation
map("n", "<leader>qo", ":copen<CR>", { desc = "Open Quickfix" })
map("n", "<leader>qc", ":cclose<CR>", { desc = "Close Quickfix" })
map("n", "[q", ":cprevious<CR>", { desc = "Previous Quickfix" })
map("n", "]q", ":cnext<CR>", { desc = "Next Quickfix" })

-- Location list navigation
map("n", "<leader>lo", ":lopen<CR>", { desc = "Open Location List" })
map("n", "<leader>lc", ":lclose<CR>", { desc = "Close Location List" })
map("n", "[l", ":lprevious<CR>", { desc = "Previous Location" })
map("n", "]l", ":lnext<CR>", { desc = "Next Location" })

-- Code execution (using <leader>R to avoid conflict with rename mappings)
map("n", "<leader>R", function() vim.cmd.RunFile() end, { desc = "Run current file" })

-- Python specific run command with better terminal
map("n", "<F5>", function()
  if vim.bo.filetype == "python" then
    vim.cmd("write")
    local cmd = "python3 " .. vim.fn.shellescape(vim.fn.expand("%"))
    local ok, snacks = pcall(require, "snacks")
    if ok then
      snacks.terminal(cmd, { cwd = vim.fn.expand("%:p:h"), win = { position = "bottom", height = 0.3 } })
    else
      vim.cmd("split | terminal " .. cmd)
    end
  end
end, { desc = "Run Python file" })

-- Tab navigation
map("n", "<leader>tn", ":tabnew<CR>", { desc = "New Tab" })
map("n", "<leader>tc", ":tabclose<CR>", { desc = "Close Tab" })
map("n", "<leader>to", ":tabonly<CR>", { desc = "Close Other Tabs" })
map("n", "[t", ":tabprevious<CR>", { desc = "Previous Tab" })
map("n", "]t", ":tabnext<CR>", { desc = "Next Tab" })

-- Replace word under cursor
map("n", "<leader>rw", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace word under cursor" })

-- Quick macro playback
map("n", "Q", "@q", { desc = "Play macro q" })
map("v", "Q", ":norm @q<CR>", { desc = "Play macro q on selection" })

-- Yank to system clipboard shortcuts
map({"n", "v"}, "<leader>y", [["+y]], { desc = "Yank to clipboard" })
map("n", "<leader>Y", [["+Y]], { desc = "Yank line to clipboard" })

-- Delete without yanking
map({"n", "v"}, "<leader>d", [["_d]], { desc = "Delete without yank" })

-- Paste in visual mode without yanking
map("v", "<leader>p", [["_dP]], { desc = "Paste without yank" })

-- Manual completion trigger is now handled by nvim-cmp mapping

