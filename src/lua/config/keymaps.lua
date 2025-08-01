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
map("n", "<S-h>", ":bprevious<cr>", { desc = "Previous buffer" })
map("n", "<S-l>", ":bnext<cr>", { desc = "Next buffer" })
map("n", "[b", ":bprevious<cr>", { desc = "Previous buffer" })
map("n", "]b", ":bnext<cr>", { desc = "Next buffer" })

-- Buffer management
map("n", "<leader>bd", ":bdelete<cr>", { desc = "Delete buffer" })
map("n", "<leader>ba", ":%bdelete<cr>", { desc = "Delete all buffers" })
map("n", "<leader>bo", ":%bdelete|edit#|bdelete#<cr>", { desc = "Delete other buffers" })

-- Buffer navigation by number
for i = 1, 9 do
  map("n", "<leader>" .. i, function() vim.cmd("buffer " .. i) end, { desc = "Go to buffer " .. i })
end

-- Show buffer list with indices
map("n", "<leader>bb", function()
  local buffers = vim.fn.getbufinfo({ buflisted = 1 })
  local lines = {}
  for i, buf in ipairs(buffers) do
    local name = vim.fn.fnamemodify(buf.name, ':t')
    if name == '' then name = '[No Name]' end
    local modified = buf.changed == 1 and ' [+]' or ''
    table.insert(lines, string.format('%d: %s%s', i, name, modified))
  end
  vim.notify(table.concat(lines, '\n'), vim.log.levels.INFO, { title = 'Open Buffers' })
end, { desc = "Show buffer list" })
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

-- Safe Snacks wrapper
local function safe_snacks(fn)
  return function(...)
    local ok, snacks = pcall(require, "snacks")
    if ok and snacks and snacks[fn] then
      return snacks[fn](...)
    else
      vim.notify("Snacks.nvim is not loaded", vim.log.levels.WARN)
    end
  end
end

-- File Management
map("n", "<leader>o", safe_snacks("explorer"), { desc = "Open File Explorer" })
map("n", "<leader>O", function() safe_snacks("explorer")({ float = true }) end, { desc = "Open Explorer in Float" })
map("n", "-", safe_snacks("explorer"), { desc = "Open File Explorer" })
-- Telescope fuzzy finding (modern replacement for FZF)
local function safe_telescope(picker, opts)
  return function()
    local ok, builtin = pcall(require, 'telescope.builtin')
    if ok and builtin[picker] then
      builtin[picker](opts)
    else
      vim.notify("Telescope not available", vim.log.levels.WARN)
    end
  end
end

map("n", "<C-p>", safe_telescope("find_files"), { desc = "Find Files" })
map("n", "<leader>F", safe_telescope("find_files"), { desc = "Find Files" })  -- Telescope
map("n", "<leader>B", safe_telescope("buffers"), { desc = "Buffers" })  -- Telescope
-- <leader>T is now used for Aerial (code outline)
map("n", "<leader>g", safe_telescope("live_grep"), { desc = "Live Grep" })
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

-- Typing practice (comprehensive configuration in config/plugins/typr.lua)
-- Access via commands: :Typr, :TyprStats, :TyprQuick, :TyprLong, :TyprProgramming
-- Or via main menu (<C-t> or <leader>m) under "Typing Test" section

-- Modern improvements

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

-- Toggle between different adapters (safe switching without destroying config)
local function switch_codecompanion_adapter(adapter_name)
  local ok, codecompanion = pcall(require, "codecompanion")
  if not ok then
    vim.notify("CodeCompanion not loaded", vim.log.levels.ERROR)
    return
  end
  
  -- Get current config and update only the adapter
  local config = codecompanion.config
  if config and config.strategies and config.strategies.chat then
    config.strategies.chat.adapter = adapter_name
    vim.notify("CodeCompanion switched to " .. adapter_name, vim.log.levels.INFO)
  else
    vim.notify("Failed to switch adapter - config structure not found", vim.log.levels.ERROR)
  end
end

map("n", "<leader>cal", function() switch_codecompanion_adapter("ollama") end, { desc = "Switch to Ollama" })
map("n", "<leader>caa", function() switch_codecompanion_adapter("anthropic") end, { desc = "Switch to Anthropic" })
map("n", "<leader>cao", function() switch_codecompanion_adapter("openai") end, { desc = "Switch to OpenAI" })
map("n", "<leader>cac", function() switch_codecompanion_adapter("copilot") end, { desc = "Switch to Copilot" })

-- 🍿 SNACKS.NVIM: High-Performance Power User Keybindings

-- 🎯 DASHBOARD & CORE
map("n", "<leader>sd", safe_snacks("dashboard"), { desc = "Dashboard" })
map("n", "<leader>sD", function() 
  local ok, snacks = pcall(require, "snacks")
  if ok and snacks and snacks.dashboard and snacks.dashboard.open then
    snacks.dashboard.open()
  else
    vim.notify("Snacks dashboard not available", vim.log.levels.WARN)
  end
end, { desc = "Force Open Dashboard" })

-- 📋 SCRATCH BUFFERS (Power User Workflow)
map("n", "<leader>.", safe_snacks("scratch"), { desc = "Toggle Scratch Buffer" })
map("n", "<leader>S", function()
  local ok, snacks = pcall(require, "snacks")
  if ok and snacks and snacks.scratch and snacks.scratch.select then
    snacks.scratch.select()
  else
    vim.notify("Snacks scratch not available", vim.log.levels.WARN)
  end
end, { desc = "Select Scratch Buffer" })
map("n", "<leader>sn", function() safe_snacks("scratch")({ name = "notes" }) end, { desc = "Notes Scratch" })
map("n", "<leader>st", function() safe_snacks("scratch")({ name = "todo", ft = "markdown" }) end, { desc = "Todo Scratch" })
map("n", "<leader>sc", function() safe_snacks("scratch")({ name = "code", ft = "lua" }) end, { desc = "Code Scratch" })

-- 🚀 TERMINAL (Lightning Fast)
map("n", "<leader>tt", safe_snacks("terminal"), { desc = "Toggle Terminal" })
map("n", "<leader>tf", function()
  local ok, snacks = pcall(require, "snacks")
  if ok and snacks and snacks.terminal and snacks.terminal.float then
    snacks.terminal.float()
  else
    vim.notify("Snacks terminal not available", vim.log.levels.WARN)
  end
end, { desc = "Terminal (float)" })
map("n", "<leader>ts", function()
  local ok, snacks = pcall(require, "snacks")
  if ok and snacks and snacks.terminal and snacks.terminal.split then
    snacks.terminal.split()
  else
    vim.notify("Snacks terminal not available", vim.log.levels.WARN)
  end
end, { desc = "Terminal (split)" })
map("n", "<leader>tv", function()
  local ok, snacks = pcall(require, "snacks")
  if ok and snacks and snacks.terminal and snacks.terminal.split then
    snacks.terminal.split({ position = "right" })
  else
    vim.notify("Snacks terminal not available", vim.log.levels.WARN)
  end
end, { desc = "Terminal (vsplit)" })
-- Quick terminal commands
map("n", "<leader>tg", function() safe_snacks("terminal")("git status") end, { desc = "Git Status Terminal" })
map("n", "<leader>tp", function() safe_snacks("terminal")("python3") end, { desc = "Python Terminal" })
map("n", "<leader>tn", function() safe_snacks("terminal")("node") end, { desc = "Node Terminal" })

-- 🔍 TELESCOPE (Modern Fuzzy Finding)
-- Core pickers with advanced features
map("n", "<leader>ff", safe_telescope("find_files"), { desc = "Find Files" })
map("n", "<leader>fF", safe_telescope("find_files", { hidden = true }), { desc = "Find Files (+ hidden)" })
map("n", "<leader>fr", safe_telescope("oldfiles"), { desc = "Recent Files" })
map("n", "<leader>fg", safe_telescope("live_grep"), { desc = "Live Grep" })
map("n", "<leader>fG", safe_telescope("live_grep", { additional_args = {"--hidden"} }), { desc = "Live Grep (+ hidden)" })
map("n", "<leader>fb", safe_telescope("buffers"), { desc = "Buffers" })
map("n", "<leader>fh", safe_telescope("help_tags"), { desc = "Help" })
map("n", "<leader>fc", safe_telescope("commands"), { desc = "Commands" })
map("n", "<leader>fk", safe_telescope("keymaps"), { desc = "Keymaps" })

-- Advanced pickers
map("n", "<leader>f/", safe_telescope("grep_string"), { desc = "Grep Word Under Cursor" })
map("n", "<leader>f:", safe_telescope("command_history"), { desc = "Command History" })
map("n", "<leader>f;", safe_telescope("resume"), { desc = "Resume Last Picker" })
map("n", "<leader>fj", safe_telescope("jumplist"), { desc = "Jumps" })
map("n", "<leader>fm", safe_telescope("marks"), { desc = "Marks" })
map("n", "<leader>fq", safe_telescope("quickfix"), { desc = "Quickfix List" })
map("n", "<leader>fl", safe_telescope("loclist"), { desc = "Location List" })

-- Specialized pickers
map("n", "<leader>fd", safe_telescope("find_files", { cwd = vim.fn.stdpath("config") }), { desc = "Config Files" })
map("n", "<leader>fp", safe_telescope("find_files", { cwd = vim.fn.stdpath("data") .. "/lazy" }), { desc = "Plugin Files" })
map("n", "<leader>fv", safe_telescope("find_files", { cwd = vim.env.VIMRUNTIME }), { desc = "Neovim Runtime" })

-- 🌐 GIT INTEGRATION (Supercharged)
map("n", "<leader>gg", safe_snacks("lazygit"), { desc = "Lazygit" })
map("n", "<leader>gG", function() safe_snacks("lazygit")({ cwd = vim.fn.expand("%:p:h") }) end, { desc = "Lazygit (file dir)" })
map("n", "<leader>gb", function()
  local ok, snacks = pcall(require, "snacks")
  if ok and snacks and snacks.git and snacks.git.blame_line then
    snacks.git.blame_line()
  else
    vim.notify("Snacks git not available", vim.log.levels.WARN)
  end
end, { desc = "Git Blame Line" })
map("n", "<leader>gB", safe_snacks("gitbrowse"), { desc = "Git Browse" })
map("n", "<leader>gf", safe_telescope("git_files"), { desc = "Git Files" })
map("n", "<leader>gs", safe_telescope("git_status"), { desc = "Git Status" })
map("n", "<leader>gc", safe_telescope("git_commits"), { desc = "Git Commits" })
map("n", "<leader>gC", safe_telescope("git_bcommits"), { desc = "Buffer Git Commits" })

-- 📱 NOTIFICATIONS (Smart Management)
map("n", "<leader>un", function()
  local ok, snacks = pcall(require, "snacks")
  if ok and snacks and snacks.notifier and snacks.notifier.hide then
    snacks.notifier.hide()
  else
    vim.notify("Snacks notifier not available", vim.log.levels.WARN)
  end
end, { desc = "Dismiss All Notifications" })
map("n", "<leader>nh", function()
  local ok, snacks = pcall(require, "snacks")
  if ok and snacks and snacks.notifier and snacks.notifier.show_history then
    snacks.notifier.show_history()
  else
    vim.notify("Snacks notifier not available", vim.log.levels.WARN)
  end
end, { desc = "Notification History" })
map("n", "<leader>nd", function()
  local ok, snacks = pcall(require, "snacks")
  if ok and snacks and snacks.notifier then
    if snacks.notifier.hide then snacks.notifier.hide() end
    if snacks.notifier.show_history then snacks.notifier.show_history() end
  else
    vim.notify("Snacks notifier not available", vim.log.levels.WARN)
  end
end, { desc = "Clear & Show History" })

-- 📦 BUFFER MANAGEMENT (Power User)
map("n", "<leader>bd", safe_snacks("bufdelete"), { desc = "Delete Buffer" })
map("n", "<leader>bD", function()
  local ok, snacks = pcall(require, "snacks")
  if ok and snacks and snacks.bufdelete and snacks.bufdelete.all then
    snacks.bufdelete.all()
  else
    vim.notify("Snacks bufdelete not available", vim.log.levels.WARN)
  end
end, { desc = "Delete All Buffers" })
map("n", "<leader>bo", function()
  local ok, snacks = pcall(require, "snacks")
  if ok and snacks and snacks.bufdelete and snacks.bufdelete.other then
    snacks.bufdelete.other()
  else
    vim.notify("Snacks bufdelete not available", vim.log.levels.WARN)
  end
end, { desc = "Delete Other Buffers" })
map("n", "<leader>bh", function()
  local ok, snacks = pcall(require, "snacks")
  if ok and snacks and snacks.bufdelete and snacks.bufdelete.hidden then
    snacks.bufdelete.hidden()
  else
    vim.notify("Snacks bufdelete not available", vim.log.levels.WARN)
  end
end, { desc = "Delete Hidden Buffers" })
map("n", "<leader>bu", function()
  local ok, snacks = pcall(require, "snacks")
  if ok and snacks and snacks.bufdelete and snacks.bufdelete.unnamed then
    snacks.bufdelete.unnamed()
  else
    vim.notify("Snacks bufdelete not available", vim.log.levels.WARN)
  end
end, { desc = "Delete Unnamed Buffers" })

-- 🔍 FILE EXPLORER (Lightning Fast)
map("n", "<leader>e", safe_snacks("explorer"), { desc = "Explorer" })
map("n", "<leader>E", function() safe_snacks("explorer")({ cwd = vim.fn.expand("%:p:h") }) end, { desc = "Explorer (file dir)" })
-- Alternative file explorer (Oil)
map("n", "<leader>N", function() 
  local ok, oil = pcall(require, 'oil')
  if ok then 
    oil.open() 
  else
    vim.notify("Oil.nvim not loaded", vim.log.levels.WARN)
  end
end, { desc = "Oil File Explorer" })

-- 🧘 ZEN MODE (Focus Enhancement)
map("n", "<leader>z", safe_snacks("zen"), { desc = "Toggle Zen Mode" })
map("n", "<leader>Z", function()
  local ok, snacks = pcall(require, "snacks")
  if ok and snacks and snacks.zen and snacks.zen.zoom then
    snacks.zen.zoom()
  else
    vim.notify("Snacks zen not available", vim.log.levels.WARN)
  end
end, { desc = "Zen Zoom" })

-- 🔄 RENAME (LSP-Integrated)
map("n", "<leader>re", function() vim.lsp.buf.rename() end, { desc = "LSP Rename Symbol" })

-- ⚡ TOGGLE UTILITIES (Quick Switches)
local function safe_toggle(toggle_fn, ...)
  local args = {...}
  return function()
    local ok, snacks = pcall(require, "snacks")
    if ok and snacks and snacks.toggle then
      local fn = snacks.toggle[toggle_fn] or snacks.toggle
      if type(fn) == "function" then
        fn(unpack(args))
      else
        vim.notify("Snacks toggle." .. toggle_fn .. " not available", vim.log.levels.WARN)
      end
    else
      vim.notify("Snacks toggle not available", vim.log.levels.WARN)
    end
  end
end

map("n", "<leader>tw", safe_toggle("option", "wrap", { name = "Wrap" }), { desc = "Toggle Wrap" })
map("n", "<leader>tS", safe_toggle("option", "spell", { name = "Spell" }), { desc = "Toggle Spell" })
map("n", "<leader>tn", safe_toggle("option", "number", { name = "Number" }), { desc = "Toggle Number" })
map("n", "<leader>tr", safe_toggle("option", "relativenumber", { name = "Relative Number" }), { desc = "Toggle Relative Number" })
map("n", "<leader>tc", safe_toggle("option", "conceallevel", { off = 0, on = 2 }), { desc = "Toggle Conceal" })
map("n", "<leader>th", safe_toggle("option", "hlsearch"), { desc = "Toggle Highlight Search" })
map("n", "<leader>ti", safe_toggle("indent"), { desc = "Toggle Indent Guides" })
map("n", "<leader>td", safe_toggle("dim"), { desc = "Toggle Dim" })
map("n", "<leader>tD", safe_toggle("diagnostics"), { desc = "Toggle Diagnostics" })

-- 🎯 SCOPE NAVIGATION (Treesitter Magic)
local function safe_scope_jump(opts)
  return function()
    local ok, snacks = pcall(require, "snacks")
    if ok and snacks and snacks.scope and snacks.scope.jump then
      snacks.scope.jump(opts)
    else
      vim.notify("Snacks scope not available", vim.log.levels.WARN)
    end
  end
end

map("n", "[s", safe_scope_jump({ direction = "prev" }), { desc = "Previous Scope" })
map("n", "]s", safe_scope_jump({ direction = "next" }), { desc = "Next Scope" })
map("n", "[S", safe_scope_jump({ direction = "prev", edge = true }), { desc = "Previous Scope Edge" })
map("n", "]S", safe_scope_jump({ direction = "next", edge = true }), { desc = "Next Scope Edge" })

-- 🔧 POWER USER UTILITIES
local function safe_snacks_sub(module, fn)
  return function(...)
    local ok, snacks = pcall(require, "snacks")
    if ok and snacks and snacks[module] and snacks[module][fn] then
      snacks[module][fn](...)
    else
      vim.notify("Snacks " .. module .. "." .. fn .. " not available", vim.log.levels.WARN)
    end
  end
end

map("n", "<leader>pp", safe_snacks_sub("profiler", "pick"), { desc = "Profiler" })
map("n", "<leader>pP", safe_snacks_sub("profiler", "scratch"), { desc = "Profiler Scratch" })
map("n", "<leader>pd", safe_snacks_sub("debug", "inspect"), { desc = "Debug Inspect" })
map("n", "<leader>pD", safe_snacks_sub("debug", "backtrace"), { desc = "Debug Backtrace" })

-- 🎨 VISUAL ENHANCEMENTS
map("n", "<leader>vh", function()
  local ok, snacks = pcall(require, "snacks")
  if ok and snacks and snacks.words and snacks.words.jump then
    snacks.words.jump(vim.v.count1, true)
  else
    vim.notify("Snacks words not available", vim.log.levels.WARN)
  end
end, { desc = "Next Reference" })
map("n", "<leader>vH", function()
  local ok, snacks = pcall(require, "snacks")
  if ok and snacks and snacks.words and snacks.words.jump then
    snacks.words.jump(-vim.v.count1, true)
  else
    vim.notify("Snacks words not available", vim.log.levels.WARN)
  end
end, { desc = "Prev Reference" })

-- 🌈 MULTI-SELECT OPERATIONS (Advanced Telescope Usage)
map("v", "<leader>fg", function() 
  local selection = vim.fn.getregion(vim.fn.getpos("'<"), vim.fn.getpos("'>"), { type = vim.fn.mode() })
  local ok, builtin = pcall(require, 'telescope.builtin')
  if ok then
    builtin.grep_string({ search = table.concat(selection, "\n") })
  else
    vim.notify("Telescope not available", vim.log.levels.WARN)
  end
end, { desc = "Grep Selection" })

map("v", "<leader>ff", function()
  local selection = vim.fn.getregion(vim.fn.getpos("'<"), vim.fn.getpos("'>"), { type = vim.fn.mode() })
  local ok, builtin = pcall(require, 'telescope.builtin')
  if ok then
    builtin.find_files({ default_text = table.concat(selection, "") })
  else
    vim.notify("Telescope not available", vim.log.levels.WARN)
  end
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

-- Code execution
vim.keymap.set("n", "<leader>r", "<cmd>RunFile<cr>", { desc = "Run current file" })

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
map("n", "<leader>sw", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]], { desc = "Replace word under cursor" })

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

