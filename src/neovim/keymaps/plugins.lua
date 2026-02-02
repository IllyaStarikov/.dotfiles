--
-- keymaps/plugins.lua
-- Plugin-specific mappings organized by logical category
--
-- Prefix Guide:
--   a = AI (CodeCompanion)
--   b = Buffer
--   c = Code (symbols, LSP, run)
--   d = Debug (see debug.lua)
--   e = Editor (zen, toggles)
--   f = Find (Telescope)
--   g = Git
--   l = Language (filetype-specific)
--   n = Notes (notifications)
--   o = Open (explorer, terminal)
--   q = Quickfix
--   w = Window
--   x = Scratch
--

local map = vim.keymap.set

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

-- Snacks helper
local function get_snacks()
  local ok, snacks = pcall(require, "snacks")
  if ok then
    return snacks
  end
  return nil
end

-- Telescope helper
local function telescope_builtin(picker, opts_override)
  return function()
    local ok, builtin = pcall(require, "telescope.builtin")
    if ok and builtin[picker] then
      builtin[picker](opts_override)
    else
      vim.notify("Telescope not available", vim.log.levels.WARN)
    end
  end
end

-- ============================================================================
-- AI (<leader>a) - CodeCompanion
-- ============================================================================
local ai_config = require("plugins.ai")

-- Chat and interaction
map("n", "<leader>ac", "<cmd>CodeCompanionChat<cr>", { desc = "AI Chat" })
map("v", "<leader>ac", "<cmd>CodeCompanionChat<cr>", { desc = "AI Chat with selection" })
map("n", "<leader>aa", "<cmd>CodeCompanionActions<cr>", { desc = "AI Actions" })
map("v", "<leader>aa", "<cmd>CodeCompanionActions<cr>", { desc = "AI Actions" })
map("n", "<leader>ai", "<cmd>CodeCompanionInline<cr>", { desc = "AI Inline" })
map("v", "<leader>ai", "<cmd>CodeCompanionInline<cr>", { desc = "AI Inline with selection" })

-- Quick code actions
local function codecompanion_action(action_text)
  return function()
    vim.cmd("CodeCompanionActions")
    vim.defer_fn(function()
      vim.api.nvim_feedkeys(action_text, "n", false)
    end, 100)
  end
end

map("v", "<leader>ae", codecompanion_action("Explain Code"), { desc = "AI Explain" })
map("v", "<leader>ar", codecompanion_action("Code Review"), { desc = "AI Review" })
map("v", "<leader>ao", codecompanion_action("Optimize Code"), { desc = "AI Optimize" })
map("v", "<leader>af", codecompanion_action("Fix Bug"), { desc = "AI Fix" })
map("v", "<leader>at", codecompanion_action("Generate Tests"), { desc = "AI Tests" })
map("v", "<leader>am", codecompanion_action("Add Comments"), { desc = "AI Comments" })

-- Chat management
map("n", "<leader>an", "<cmd>CodeCompanionChat New<cr>", { desc = "AI New Chat" })
map("n", "<leader>al", "<cmd>CodeCompanionChat Toggle<cr>", { desc = "AI Toggle Chat" })
map("n", "<leader>as", "<cmd>CodeCompanionChat Stop<cr>", { desc = "AI Stop" })

-- Model switching
map("n", "<leader>a1", function()
  ai_config.use_small_model()
end, { desc = "AI Small Model" })
map("n", "<leader>a2", function()
  ai_config.use_medium_model()
end, { desc = "AI Medium Model" })
map("n", "<leader>a3", function()
  ai_config.use_large_model()
end, { desc = "AI Large Model" })
map("n", "<leader>a?", function()
  ai_config.list_models()
end, { desc = "AI List Models" })

-- macOS: MLX/Ollama switching
if vim.fn.has("mac") == 1 then
  map("n", "<leader>aM", function()
    ai_config.use_mlx()
  end, { desc = "AI Use MLX" })
  map("n", "<leader>aO", function()
    ai_config.use_ollama()
  end, { desc = "AI Use Ollama" })
  map("n", "<leader>aX", function()
    ai_config.start_mlx_server()
  end, { desc = "AI Start MLX" })
end

-- ============================================================================
-- BUFFER (<leader>b)
-- ============================================================================
map("n", "<leader>bd", function()
  local s = get_snacks()
  if s then
    s.bufdelete()
  end
end, { desc = "Buffer Delete" })

map("n", "<leader>bD", function()
  local s = get_snacks()
  if s then
    s.bufdelete.all()
  end
end, { desc = "Buffer Delete All" })

map("n", "<leader>bo", function()
  local s = get_snacks()
  if s then
    s.bufdelete.other()
  end
end, { desc = "Buffer Delete Others" })

map("n", "<leader>bb", telescope_builtin("buffers"), { desc = "Buffer List" })

-- Quick buffer switching (1-9)
for i = 1, 9 do
  map("n", "<leader>b" .. i, "<cmd>buffer " .. i .. "<cr>", { desc = "Buffer " .. i })
end

-- ============================================================================
-- CODE (<leader>c) - Symbols, LSP, Run
-- ============================================================================
-- Run (sniprun - keymaps defined in plugin spec with retry logic)

-- Make targets
map("n", "<leader>cm", "<cmd>MakePicker<cr>", { desc = "Code Make (pick target)" })
map("n", "<leader>cM", "<cmd>Make<cr>", { desc = "Code Make (default)" })

-- Symbol navigation (Aerial)
map("n", "<leader>cn", "<cmd>AerialNext<CR>", { desc = "Code Next Symbol" })
map("n", "<leader>cp", "<cmd>AerialPrev<CR>", { desc = "Code Prev Symbol" })
map("n", "<leader>cN", "<cmd>AerialNextUp<CR>", { desc = "Code Next Symbol (up)" })
map("n", "<leader>cP", "<cmd>AerialPrevUp<CR>", { desc = "Code Prev Symbol (up)" })
map("n", "<leader>cg", "<cmd>AerialGo<CR>", { desc = "Code Go to Symbol" })

-- Telescope symbol search
map("n", "<leader>cf", function()
  local ok, telescope = pcall(require, "telescope")
  if ok then
    telescope.extensions.aerial.aerial()
  else
    vim.notify("Telescope aerial extension not available", vim.log.levels.WARN)
  end
end, { desc = "Code Find Symbols" })

-- LSP actions (buffer-local in lsp.lua, but global fallbacks here)
map("n", "<leader>ca", vim.lsp.buf.code_action, { desc = "Code Action" })
map("n", "<leader>cR", vim.lsp.buf.rename, { desc = "Code Rename" })
map("n", "<leader>ch", vim.lsp.buf.hover, { desc = "Code Hover" })
map("n", "<leader>cd", vim.lsp.buf.definition, { desc = "Code Definition" })
map("n", "<leader>cD", vim.lsp.buf.declaration, { desc = "Code Declaration" })
map("n", "<leader>ci", vim.lsp.buf.implementation, { desc = "Code Implementation" })
map("n", "<leader>ct", vim.lsp.buf.type_definition, { desc = "Code Type Definition" })

-- ============================================================================
-- EDITOR (<leader>e) - Zen, Toggles
-- ============================================================================
-- Zen mode
map("n", "<leader>ez", function()
  local s = get_snacks()
  if s then
    s.zen()
  end
end, { desc = "Editor Zen Mode" })

map("n", "<leader>eZ", function()
  local s = get_snacks()
  if s then
    s.zen.zoom()
  end
end, { desc = "Editor Zen Zoom" })

-- Toggles
map("n", "<leader>ew", function()
  local s = get_snacks()
  if s then
    s.toggle.option("wrap", { name = "Wrap" })()
  end
end, { desc = "Editor Toggle Wrap" })

map("n", "<leader>es", function()
  local s = get_snacks()
  if s then
    s.toggle.option("spell", { name = "Spell" })()
  end
end, { desc = "Editor Toggle Spell" })

map("n", "<leader>en", function()
  local s = get_snacks()
  if s then
    s.toggle.option("number", { name = "Number" })()
  end
end, { desc = "Editor Toggle Numbers" })

map("n", "<leader>er", function()
  local s = get_snacks()
  if s then
    s.toggle.option("relativenumber", { name = "Relative Number" })()
  end
end, { desc = "Editor Toggle Relative" })

map("n", "<leader>eh", function()
  local s = get_snacks()
  if s then
    s.toggle.option("hlsearch")()
  end
end, { desc = "Editor Toggle Highlight" })

map("n", "<leader>ed", function()
  local s = get_snacks()
  if s then
    s.toggle.diagnostics()
  end
end, { desc = "Editor Toggle Diagnostics" })

map("n", "<leader>ec", function()
  local s = get_snacks()
  if s then
    s.toggle.option("conceallevel", { off = 0, on = 2, name = "Conceal" })()
  end
end, { desc = "Editor Toggle Conceal" })

-- ============================================================================
-- FIND (<leader>f) - Telescope
-- ============================================================================
-- Files
map("n", "<C-p>", telescope_builtin("find_files"), { desc = "Find Files" })
map("n", "<leader>ff", telescope_builtin("find_files"), { desc = "Find Files" })
map(
  "n",
  "<leader>fF",
  telescope_builtin("find_files", { hidden = true }),
  { desc = "Find Files (+hidden)" }
)
map("n", "<leader>fr", telescope_builtin("oldfiles"), { desc = "Find Recent" })
map(
  "n",
  "<leader>fd",
  telescope_builtin("find_files", { cwd = vim.fn.stdpath("config") }),
  { desc = "Find Dotfiles" }
)
map(
  "n",
  "<leader>fp",
  telescope_builtin("find_files", { cwd = vim.fn.stdpath("data") .. "/lazy" }),
  { desc = "Find Plugins" }
)

-- Grep
map("n", "<leader>fg", telescope_builtin("live_grep"), { desc = "Find Grep" })
map(
  "n",
  "<leader>fG",
  telescope_builtin("live_grep", { additional_args = { "--hidden" } }),
  { desc = "Find Grep (+hidden)" }
)
map("n", "<leader>f/", telescope_builtin("grep_string"), { desc = "Find Word" })
map("v", "<leader>fg", function()
  local selection =
    vim.fn.getregion(vim.fn.getpos("'<"), vim.fn.getpos("'>"), { type = vim.fn.mode() })
  local ok, builtin = pcall(require, "telescope.builtin")
  if ok and builtin.grep_string then
    builtin.grep_string({ search = table.concat(selection, "\n") })
  else
    vim.notify("Telescope not available", vim.log.levels.WARN)
  end
end, { desc = "Find Grep Selection" })

-- Navigation
map("n", "<leader>fb", telescope_builtin("buffers"), { desc = "Find Buffers" })
map("n", "<leader>fm", telescope_builtin("marks"), { desc = "Find Marks" })
map("n", "<leader>fj", telescope_builtin("jumplist"), { desc = "Find Jumps" })
map("n", "<leader>f;", telescope_builtin("resume"), { desc = "Find Resume" })
map("n", "<leader>f:", telescope_builtin("command_history"), { desc = "Find Command History" })

-- Help
map("n", "<leader>fh", telescope_builtin("help_tags"), { desc = "Find Help" })
map("n", "<leader>fc", telescope_builtin("commands"), { desc = "Find Commands" })
map("n", "<leader>fk", telescope_builtin("keymaps"), { desc = "Find Keymaps" })

-- Symbols
map("n", "<leader>fs", telescope_builtin("lsp_document_symbols"), { desc = "Find Symbols (doc)" })
map(
  "n",
  "<leader>fS",
  telescope_builtin("lsp_workspace_symbols"),
  { desc = "Find Symbols (workspace)" }
)

-- Insert symbols
map(
  "n",
  "<leader>fie",
  telescope_builtin("symbols", { sources = { "emoji" } }),
  { desc = "Find Insert Emoji" }
)
map(
  "n",
  "<leader>fim",
  telescope_builtin("symbols", { sources = { "math", "latex" } }),
  { desc = "Find Insert Math" }
)
map(
  "n",
  "<leader>fig",
  telescope_builtin("symbols", { sources = { "gitmoji" } }),
  { desc = "Find Insert Gitmoji" }
)

-- ============================================================================
-- GIT (<leader>g)
-- ============================================================================
-- Lazygit
map("n", "<leader>gg", function()
  local s = get_snacks()
  if s then
    s.lazygit()
  end
end, { desc = "Git Lazygit" })

map("n", "<leader>gG", function()
  local s = get_snacks()
  if s then
    s.lazygit({ cwd = vim.fn.expand("%:p:h") })
  end
end, { desc = "Git Lazygit (file dir)" })

-- Browse/Blame
map("n", "<leader>gb", function()
  local s = get_snacks()
  if s then
    s.git.blame_line()
  end
end, { desc = "Git Blame Line" })

map("n", "<leader>gB", function()
  local s = get_snacks()
  if s then
    s.gitbrowse()
  end
end, { desc = "Git Browse" })

-- Telescope git pickers
map("n", "<leader>gf", telescope_builtin("git_files"), { desc = "Git Files" })
map("n", "<leader>gs", telescope_builtin("git_status"), { desc = "Git Status" })
map("n", "<leader>gc", telescope_builtin("git_commits"), { desc = "Git Commits" })
map("n", "<leader>gC", telescope_builtin("git_bcommits"), { desc = "Git Buffer Commits" })
map("n", "<leader>gd", "<cmd>Gitsigns diffthis<cr>", { desc = "Git Diff" })

-- ============================================================================
-- LANGUAGE (<leader>l) - Filetype-specific
-- ============================================================================

-- LaTeX (<leader>ll*)
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "tex", "latex", "plaintex" },
  callback = function()
    local buf_opts = { buffer = true, silent = true }
    map(
      "n",
      "<leader>llc",
      "<cmd>VimtexCompile<cr>",
      vim.tbl_extend("force", buf_opts, { desc = "LaTeX Compile" })
    )
    map(
      "n",
      "<leader>llv",
      "<cmd>VimtexView<cr>",
      vim.tbl_extend("force", buf_opts, { desc = "LaTeX View" })
    )
    map(
      "n",
      "<leader>lls",
      "<cmd>VimtexStop<cr>",
      vim.tbl_extend("force", buf_opts, { desc = "LaTeX Stop" })
    )
    map(
      "n",
      "<leader>llt",
      "<cmd>VimtexTocToggle<cr>",
      vim.tbl_extend("force", buf_opts, { desc = "LaTeX TOC" })
    )
    map(
      "n",
      "<leader>llk",
      "<cmd>VimtexClean<cr>",
      vim.tbl_extend("force", buf_opts, { desc = "LaTeX Clean" })
    )
    map(
      "n",
      "<leader>llK",
      "<cmd>VimtexClean!<cr>",
      vim.tbl_extend("force", buf_opts, { desc = "LaTeX Clean All" })
    )
    map(
      "n",
      "<leader>lli",
      "<cmd>VimtexInfo<cr>",
      vim.tbl_extend("force", buf_opts, { desc = "LaTeX Info" })
    )
    map(
      "n",
      "<leader>llr",
      "<cmd>VimtexReverse<cr>",
      vim.tbl_extend("force", buf_opts, { desc = "LaTeX Reverse" })
    )
    -- Formatting
    map(
      "v",
      "<leader>llb",
      'c\\textbf{<C-r>"}<Esc>',
      vim.tbl_extend("force", buf_opts, { desc = "LaTeX Bold" })
    )
    map(
      "v",
      "<leader>lli",
      'c\\textit{<C-r>"}<Esc>',
      vim.tbl_extend("force", buf_opts, { desc = "LaTeX Italic" })
    )
    map(
      "v",
      "<leader>ll$",
      'c$<C-r>"$<Esc>',
      vim.tbl_extend("force", buf_opts, { desc = "LaTeX Math" })
    )
    -- Navigation
    map(
      "n",
      "]]",
      "<cmd>VimtexSectionNext<cr>",
      vim.tbl_extend("force", buf_opts, { desc = "Next Section" })
    )
    map(
      "n",
      "[[",
      "<cmd>VimtexSectionPrev<cr>",
      vim.tbl_extend("force", buf_opts, { desc = "Previous Section" })
    )
  end,
})

-- ============================================================================
-- NOTES (<leader>n) - Notifications
-- ============================================================================
map("n", "<leader>nh", function()
  local s = get_snacks()
  if s then
    s.notifier.show_history()
  end
end, { desc = "Notes Notification History" })

map("n", "<leader>nd", function()
  local s = get_snacks()
  if s then
    s.notifier.hide()
  end
end, { desc = "Notes Dismiss Notifications" })

-- Dashboard
map("n", "<leader>nD", function()
  local s = get_snacks()
  if s then
    s.dashboard()
  end
end, { desc = "Notes Dashboard" })

-- ============================================================================
-- OPEN (<leader>o) - Explorer, Terminal
-- ============================================================================
-- Explorer
map("n", "<leader>oe", function()
  local s = get_snacks()
  if s then
    s.explorer()
  end
end, { desc = "Open Explorer" })

map("n", "<leader>oE", function()
  local s = get_snacks()
  if s then
    s.explorer({ cwd = vim.fn.expand("%:p:h") })
  end
end, { desc = "Open Explorer (file dir)" })

map("n", "<leader>of", function()
  local s = get_snacks()
  if s then
    s.explorer({ float = true })
  end
end, { desc = "Open Explorer Float" })

map("n", "<leader>oo", safe_require("oil", "open"), { desc = "Open Oil" })

-- Symbol outline (Aerial)
map("n", "<leader>oa", "<cmd>AerialToggle<CR>", { desc = "Open Aerial" })
map("n", "<leader>oA", "<cmd>AerialNavToggle<CR>", { desc = "Open Aerial Navigator" })

-- Shortcut: - opens explorer
map("n", "-", function()
  local s = get_snacks()
  if s then
    s.explorer()
  end
end, { desc = "Open Explorer" })

-- Terminal
map("n", "<leader>ot", function()
  local s = get_snacks()
  if s then
    s.terminal()
  end
end, { desc = "Open Terminal" })

map("n", "<leader>oT", function()
  local s = get_snacks()
  if s then
    s.terminal.float()
  end
end, { desc = "Open Terminal Float" })

map("n", "<leader>os", function()
  local s = get_snacks()
  if s then
    s.terminal.split()
  end
end, { desc = "Open Terminal Split" })

map("n", "<leader>ov", function()
  local s = get_snacks()
  if s then
    s.terminal.split({ position = "right" })
  end
end, { desc = "Open Terminal Vsplit" })

-- Language-specific terminals
map("n", "<leader>otp", function()
  local s = get_snacks()
  if s then
    s.terminal("python3")
  end
end, { desc = "Open Terminal Python" })

map("n", "<leader>otn", function()
  local s = get_snacks()
  if s then
    s.terminal("node")
  end
end, { desc = "Open Terminal Node" })

-- ============================================================================
-- SCRATCH (<leader>x) - Scratch buffers with filetype selection
-- ============================================================================

-- Usage tracking for sorting filetypes by frequency
local scratch_usage_file = vim.fn.stdpath("data") .. "/scratch_usage.json"

local function load_scratch_usage()
  local ok, content = pcall(vim.fn.readfile, scratch_usage_file)
  if ok and content[1] then
    local data = vim.json.decode(content[1])
    return data or {}
  end
  return {}
end

local function save_scratch_usage(usage)
  local json = vim.json.encode(usage)
  vim.fn.writefile({ json }, scratch_usage_file)
end

local function increment_scratch_usage(ft)
  local usage = load_scratch_usage()
  usage[ft] = (usage[ft] or 0) + 1
  save_scratch_usage(usage)
end

-- Common filetypes for scratch buffers
local scratch_filetypes = {
  "markdown",
  "lua",
  "python",
  "javascript",
  "typescript",
  "json",
  "yaml",
  "toml",
  "sh",
  "zsh",
  "go",
  "rust",
  "c",
  "cpp",
  "html",
  "css",
  "sql",
  "text",
  "vim",
}

-- Sort filetypes by usage count (descending)
local function get_sorted_filetypes()
  local usage = load_scratch_usage()
  local sorted = vim.deepcopy(scratch_filetypes)
  table.sort(sorted, function(a, b)
    return (usage[a] or 0) > (usage[b] or 0)
  end)
  return sorted
end

-- Open scratch with filetype picker
local function scratch_with_picker()
  local s = get_snacks()
  if not s then
    return
  end

  local filetypes = get_sorted_filetypes()
  local usage = load_scratch_usage()

  -- Build display items with usage counts
  local display_items = {}
  for _, ft in ipairs(filetypes) do
    local count = usage[ft] or 0
    local display = count > 0 and string.format("%s (%d)", ft, count) or ft
    table.insert(display_items, display)
  end

  vim.ui.select(display_items, {
    prompt = "Scratch Filetype:",
  }, function(choice, idx)
    if choice and idx then
      local ft = filetypes[idx]
      increment_scratch_usage(ft)
      s.scratch({ ft = ft })
    end
  end)
end

-- Toggle scratch (current filetype or markdown)
map("n", "<leader>xx", function()
  local s = get_snacks()
  if s then
    s.scratch()
  end
end, { desc = "Scratch Toggle" })

-- New scratch with filetype picker
map("n", "<leader>xn", scratch_with_picker, { desc = "Scratch New (pick type)" })

-- Select from existing scratches
map("n", "<leader>xs", function()
  local s = get_snacks()
  if s then
    s.scratch.select()
  end
end, { desc = "Scratch Select" })

-- List scratches (alias for select)
map("n", "<leader>xl", function()
  local s = get_snacks()
  if s then
    s.scratch.select()
  end
end, { desc = "Scratch List" })

-- ============================================================================
-- QUICKFIX (<leader>q)
-- ============================================================================
map("n", "<leader>qo", "<cmd>copen<cr>", { desc = "Quickfix Open" })
map("n", "<leader>qc", "<cmd>cclose<cr>", { desc = "Quickfix Close" })
map("n", "<leader>qn", "<cmd>cnext<cr>", { desc = "Quickfix Next" })
map("n", "<leader>qp", "<cmd>cprev<cr>", { desc = "Quickfix Prev" })
map("n", "<leader>ql", "<cmd>lopen<cr>", { desc = "Location Open" })
map("n", "<leader>qL", "<cmd>lclose<cr>", { desc = "Location Close" })
map("n", "<leader>qf", telescope_builtin("quickfix"), { desc = "Quickfix Find" })

-- ============================================================================
-- WINDOW (<leader>w)
-- ============================================================================
map("n", "<leader>w-", "<cmd>split<cr>", { desc = "Window Split Horizontal" })
map("n", "<leader>w|", "<cmd>vsplit<cr>", { desc = "Window Split Vertical" })
map("n", "<leader>wd", "<cmd>close<cr>", { desc = "Window Delete" })
map("n", "<leader>wo", "<cmd>only<cr>", { desc = "Window Only" })
map("n", "<leader>w=", "<C-w>=", { desc = "Window Equal Size" })

-- Tabs
map("n", "<leader>wn", "<cmd>tabnew<cr>", { desc = "Window Tab New" })
map("n", "<leader>wc", "<cmd>tabclose<cr>", { desc = "Window Tab Close" })
map("n", "<leader>wO", "<cmd>tabonly<cr>", { desc = "Window Tab Only" })
map("n", "<leader>wl", "<cmd>tabnext<cr>", { desc = "Window Tab Next" })
map("n", "<leader>wh", "<cmd>tabprev<cr>", { desc = "Window Tab Prev" })
