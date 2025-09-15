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
    local ok, builtin = pcall(require, "telescope.builtin")
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
map(
  "n",
  "<leader>fF",
  telescope_builtin("find_files", { hidden = true }),
  { desc = "Find Files (+ hidden)" }
)
map("n", "<leader>fr", telescope_builtin("oldfiles"), { desc = "Recent Files" })
map("n", "<leader>fg", telescope_builtin("live_grep"), { desc = "Live Grep" })
map(
  "n",
  "<leader>fG",
  telescope_builtin("live_grep", { additional_args = { "--hidden" } }),
  { desc = "Live Grep (+ hidden)" }
)
map("n", "<leader>fb", telescope_builtin("buffers"), { desc = "Buffers" })
map("n", "<leader>fh", telescope_builtin("help_tags"), { desc = "Help" })
map("n", "<leader>fc", telescope_builtin("commands"), { desc = "Commands" })
map("n", "<leader>fk", telescope_builtin("keymaps"), { desc = "Keymaps" })

-- Advanced pickers
map(
  "n",
  "<leader>f/",
  telescope_builtin("grep_string"),
  { desc = "Grep Word Under Cursor" }
)
map(
  "n",
  "<leader>f:",
  telescope_builtin("command_history"),
  { desc = "Command History" }
)
map(
  "n",
  "<leader>f;",
  telescope_builtin("resume"),
  { desc = "Resume Last Picker" }
)
map("n", "<leader>fj", telescope_builtin("jumplist"), { desc = "Jumps" })
map("n", "<leader>fm", telescope_builtin("marks"), { desc = "Marks" })
map(
  "n",
  "<leader>fq",
  telescope_builtin("quickfix"),
  { desc = "Quickfix List" }
)
map("n", "<leader>fl", telescope_builtin("loclist"), { desc = "Location List" })

-- Specialized pickers
map(
  "n",
  "<leader>fd",
  telescope_builtin("find_files", { cwd = vim.fn.stdpath("config") }),
  { desc = "Config Files" }
)
map(
  "n",
  "<leader>fp",
  telescope_builtin("find_files", { cwd = vim.fn.stdpath("data") .. "/lazy" }),
  { desc = "Plugin Files" }
)

-- Git pickers
map("n", "<leader>gf", telescope_builtin("git_files"), { desc = "Git Files" })
map("n", "<leader>gs", telescope_builtin("git_status"), { desc = "Git Status" })
map(
  "n",
  "<leader>gc",
  telescope_builtin("git_commits"),
  { desc = "Git Commits" }
)
map(
  "n",
  "<leader>gC",
  telescope_builtin("git_bcommits"),
  { desc = "Buffer Git Commits" }
)

-- Visual mode search
map("v", "<leader>fg", function()
  local selection = vim.fn.getregion(
    vim.fn.getpos("'<"),
    vim.fn.getpos("'>"),
    { type = vim.fn.mode() }
  )
  telescope_builtin("grep_string")({ search = table.concat(selection, "\n") })
end, { desc = "Grep Selection" })

-- LSP Symbol search
map(
  "n",
  "<leader>fs",
  telescope_builtin("lsp_document_symbols"),
  { desc = "Document Symbols" }
)
map(
  "n",
  "<leader>fS",
  telescope_builtin("lsp_workspace_symbols"),
  { desc = "Workspace Symbols" }
)
map(
  "n",
  "<leader>fws",
  telescope_builtin("lsp_dynamic_workspace_symbols"),
  { desc = "Dynamic Workspace Symbols" }
)

-- Alternative symbol keybindings (more discoverable)
map(
  "n",
  "<leader>ss",
  telescope_builtin("lsp_document_symbols"),
  { desc = "Search Symbols (Document)" }
)
map(
  "n",
  "<leader>sS",
  telescope_builtin("lsp_workspace_symbols"),
  { desc = "Search Symbols (Workspace)" }
)
map(
  "n",
  "<leader>sW",
  telescope_builtin("lsp_dynamic_workspace_symbols"),
  { desc = "Search Symbols (Dynamic)" }
)

-- Insert symbols (emoji, math, etc.)
map(
  "n",
  "<leader>se",
  telescope_builtin("symbols", { sources = { "emoji" } }),
  { desc = "Insert Emoji" }
)
map(
  "n",
  "<leader>sm",
  telescope_builtin("symbols", { sources = { "math", "latex" } }),
  { desc = "Insert Math Symbol" }
)
map(
  "n",
  "<leader>si",
  telescope_builtin("symbols"),
  { desc = "Insert Symbol (All)" }
)
map(
  "n",
  "<leader>sk",
  telescope_builtin("symbols", { sources = { "kaomoji" } }),
  { desc = "Insert Kaomoji" }
)
map(
  "n",
  "<leader>sg",
  telescope_builtin("symbols", { sources = { "gitmoji" } }),
  { desc = "Insert Gitmoji" }
)

-- Legacy mappings for compatibility
map("n", "<leader>F", telescope_builtin("find_files"), { desc = "Find Files" })
map("n", "<leader>B", telescope_builtin("buffers"), { desc = "Buffers" })
map("n", "<leader>g", telescope_builtin("live_grep"), { desc = "Live Grep" })

-- ============================================================================
-- AERIAL.NVIM (Symbol Outline)
-- ============================================================================
-- Toggle symbol outline
map(
  "n",
  "<leader>a",
  "<cmd>AerialToggle<CR>",
  { desc = "Toggle Symbol Outline" }
)
map(
  "n",
  "<leader>A",
  "<cmd>AerialNavToggle<CR>",
  { desc = "Toggle Symbol Navigator" }
)

-- Navigation
map("n", "<leader>an", "<cmd>AerialNext<CR>", { desc = "Next Symbol" })
map("n", "<leader>ap", "<cmd>AerialPrev<CR>", { desc = "Previous Symbol" })
map(
  "n",
  "<leader>aN",
  "<cmd>AerialNextUp<CR>",
  { desc = "Next Symbol (Parent Level)" }
)
map(
  "n",
  "<leader>aP",
  "<cmd>AerialPrevUp<CR>",
  { desc = "Previous Symbol (Parent Level)" }
)

-- Go to symbol
map(
  "n",
  "<leader>ag",
  "<cmd>AerialGo<CR>",
  { desc = "Go to Symbol (Interactive)" }
)

-- Telescope integration for Aerial
map("n", "<leader>fa", function()
  local ok, telescope = pcall(require, "telescope")
  if ok then
    telescope.extensions.aerial.aerial()
  else
    vim.notify("Telescope aerial extension not available", vim.log.levels.WARN)
  end
end, { desc = "Find Symbols (Aerial)" })

-- Alternative binding that's more discoverable
map("n", "<leader>so", "<cmd>AerialToggle<CR>", { desc = "Symbol Outline" })

-- ============================================================================
-- SNACKS.NVIM
-- ============================================================================
-- Defer loading to ensure snacks is fully initialized
local function get_snacks()
  local ok, snacks = pcall(require, "snacks")
  if ok then
    return snacks
  end
  return nil
end

-- Dashboard
map("n", "<leader>sd", function()
  local snacks = get_snacks()
  if snacks then
    snacks.dashboard()
  else
    vim.notify("Snacks not available", vim.log.levels.WARN)
  end
end, { desc = "Dashboard" })

-- File Explorer
map("n", "<leader>e", function()
  local snacks = get_snacks()
  if snacks then
    local status, err = pcall(function()
      snacks.explorer()
    end)
    if not status then
      vim.notify(
        "Snacks explorer error: " .. tostring(err),
        vim.log.levels.ERROR
      )
    end
  else
    vim.notify("Snacks not loaded", vim.log.levels.ERROR)
  end
end, { desc = "Explorer" })
map("n", "<leader>E", function()
  local s = get_snacks()
  if s then
    s.explorer({ cwd = vim.fn.expand("%:p:h") })
  end
end, { desc = "Explorer (file dir)" })
map("n", "<leader>o", function()
  local s = get_snacks()
  if s then
    s.explorer()
  end
end, { desc = "Open File Explorer" })
map("n", "<leader>O", function()
  local s = get_snacks()
  if s then
    s.explorer({ float = true })
  end
end, { desc = "Open Explorer in Float" })
map("n", "-", function()
  local s = get_snacks()
  if s then
    s.explorer()
  end
end, { desc = "Open File Explorer" })

-- Terminal
map("n", "<leader>tt", function()
  local s = get_snacks()
  if s then
    s.terminal()
  end
end, { desc = "Toggle Terminal" })
map("n", "<leader>tf", function()
  local s = get_snacks()
  if s then
    s.terminal.float()
  end
end, { desc = "Terminal (float)" })
map("n", "<leader>ts", function()
  local s = get_snacks()
  if s then
    s.terminal.split()
  end
end, { desc = "Terminal (split)" })
map("n", "<leader>tv", function()
  local s = get_snacks()
  if s then
    s.terminal.split({ position = "right" })
  end
end, { desc = "Terminal (vsplit)" })
map("n", "<leader>tg", function()
  local s = get_snacks()
  if s then
    s.terminal("git status")
  end
end, { desc = "Git Status Terminal" })
map("n", "<leader>tp", function()
  local s = get_snacks()
  if s then
    s.terminal("python3")
  end
end, { desc = "Python Terminal" })
map("n", "<leader>tn", function()
  local s = get_snacks()
  if s then
    s.terminal("node")
  end
end, { desc = "Node Terminal" })

-- Git
map("n", "<leader>gg", function()
  local s = get_snacks()
  if s then
    s.lazygit()
  end
end, { desc = "Lazygit" })
map("n", "<leader>gG", function()
  local s = get_snacks()
  if s then
    s.lazygit({ cwd = vim.fn.expand("%:p:h") })
  end
end, { desc = "Lazygit (file dir)" })
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

-- Scratch buffers
map("n", "<leader>.", function()
  local s = get_snacks()
  if s then
    s.scratch()
  end
end, { desc = "Toggle Scratch Buffer" })
map("n", "<leader>S", function()
  local s = get_snacks()
  if s then
    s.scratch.select()
  end
end, { desc = "Select Scratch Buffer" })

-- Notifications
map("n", "<leader>un", function()
  local s = get_snacks()
  if s then
    s.notifier.hide()
  end
end, { desc = "Dismiss All Notifications" })
map("n", "<leader>nh", function()
  local s = get_snacks()
  if s then
    s.notifier.show_history()
  end
end, { desc = "Notification History" })

-- Buffer management
map("n", "<leader>bd", function()
  local s = get_snacks()
  if s then
    s.bufdelete()
  end
end, { desc = "Delete Buffer" })
map("n", "<leader>bD", function()
  local s = get_snacks()
  if s then
    s.bufdelete.all()
  end
end, { desc = "Delete All Buffers" })
map("n", "<leader>bo", function()
  local s = get_snacks()
  if s then
    s.bufdelete.other()
  end
end, { desc = "Delete Other Buffers" })

-- Zen mode
map("n", "<leader>z", function()
  local s = get_snacks()
  if s then
    s.zen()
  end
end, { desc = "Toggle Zen Mode" })
map("n", "<leader>Z", function()
  local s = get_snacks()
  if s then
    s.zen.zoom()
  end
end, { desc = "Zen Zoom" })

-- Toggle utilities
map("n", "<leader>tw", function()
  local s = get_snacks()
  if s then
    s.toggle.option("wrap", { name = "Wrap" })()
  end
end, { desc = "Toggle Wrap" })
map("n", "<leader>tS", function()
  local s = get_snacks()
  if s then
    s.toggle.option("spell", { name = "Spell" })()
  end
end, { desc = "Toggle Spell" })
map("n", "<leader>tn", function()
  local s = get_snacks()
  if s then
    s.toggle.option("number", { name = "Number" })()
  end
end, { desc = "Toggle Number" })
map("n", "<leader>tr", function()
  local s = get_snacks()
  if s then
    s.toggle.option("relativenumber", { name = "Relative Number" })()
  end
end, { desc = "Toggle Relative Number" })
map("n", "<leader>th", function()
  local s = get_snacks()
  if s then
    s.toggle.option("hlsearch")()
  end
end, { desc = "Toggle Highlight Search" })
map("n", "<leader>tD", function()
  local s = get_snacks()
  if s then
    s.toggle.diagnostics()
  end
end, { desc = "Toggle Diagnostics" })

-- ============================================================================
-- CODECOMPANION
-- ============================================================================
-- Chat and interaction
map(
  "n",
  "<leader>cc",
  "<cmd>CodeCompanionChat<cr>",
  { desc = "CodeCompanion Chat" }
)
map(
  "v",
  "<leader>cc",
  "<cmd>CodeCompanionChat<cr>",
  { desc = "CodeCompanion Chat with selection" }
)
map(
  "n",
  "<leader>ca",
  "<cmd>CodeCompanionActions<cr>",
  { desc = "CodeCompanion Action Palette" }
)
map(
  "v",
  "<leader>ca",
  "<cmd>CodeCompanionActions<cr>",
  { desc = "CodeCompanion Action Palette" }
)

-- Inline assistance
map(
  "n",
  "<leader>ci",
  "<cmd>CodeCompanionInline<cr>",
  { desc = "CodeCompanion Inline" }
)
map(
  "v",
  "<leader>ci",
  "<cmd>CodeCompanionInline<cr>",
  { desc = "CodeCompanion Inline with selection" }
)

-- Quick code actions
local function codecompanion_action(action_text)
  return function()
    vim.cmd("CodeCompanionActions")
    vim.defer_fn(function()
      vim.api.nvim_feedkeys(action_text, "n", false)
    end, 100)
  end
end

map(
  "v",
  "<leader>cr",
  codecompanion_action("Code Review"),
  { desc = "Code Review" }
)
map(
  "v",
  "<leader>co",
  codecompanion_action("Optimize Code"),
  { desc = "Optimize Code" }
)
map(
  "v",
  "<leader>cm",
  codecompanion_action("Add Comments"),
  { desc = "Add Comments" }
)
map(
  "v",
  "<leader>ct",
  codecompanion_action("Generate Tests"),
  { desc = "Generate Tests" }
)
map(
  "v",
  "<leader>ce",
  codecompanion_action("Explain Code"),
  { desc = "Explain Code" }
)
map("v", "<leader>cf", codecompanion_action("Fix Bug"), { desc = "Fix Bug" })

-- Chat management
map(
  "n",
  "<leader>cl",
  "<cmd>CodeCompanionChat Toggle<cr>",
  { desc = "Toggle CodeCompanion Chat" }
)
map(
  "n",
  "<leader>cs",
  "<cmd>CodeCompanionChat Stop<cr>",
  { desc = "Stop CodeCompanion" }
)
map(
  "n",
  "<leader>cn",
  "<cmd>CodeCompanionChat New<cr>",
  { desc = "New CodeCompanion Chat" }
)

-- Adapter switching
local function switch_codecompanion_adapter(adapter_name)
  local ok, codecompanion = pcall(require, "codecompanion")
  if
    ok
    and codecompanion.config
    and codecompanion.config.strategies
    and codecompanion.config.strategies.chat
  then
    codecompanion.config.strategies.chat.adapter = adapter_name
    vim.notify(
      "CodeCompanion switched to " .. adapter_name,
      vim.log.levels.INFO
    )
  else
    vim.notify("Failed to switch adapter", vim.log.levels.ERROR)
  end
end

map("n", "<leader>cal", function()
  switch_codecompanion_adapter("ollama")
end, { desc = "Switch to Ollama" })
map("n", "<leader>caa", function()
  switch_codecompanion_adapter("anthropic")
end, { desc = "Switch to Anthropic" })
map("n", "<leader>cao", function()
  switch_codecompanion_adapter("openai")
end, { desc = "Switch to OpenAI" })
map("n", "<leader>cac", function()
  switch_codecompanion_adapter("copilot")
end, { desc = "Switch to Copilot" })

-- ============================================================================
-- OIL.NVIM
-- ============================================================================
map(
  "n",
  "<leader>N",
  safe_require("oil", "open"),
  { desc = "Oil File Explorer" }
)

-- ============================================================================
-- VIMTEX (LaTeX)
-- ============================================================================
vim.api.nvim_create_autocmd("FileType", {
  pattern = { "tex", "latex", "plaintex" },
  callback = function()
    local buf_opts = { buffer = true, silent = true }

    -- Compilation
    map(
      "n",
      "<leader>ll",
      "<cmd>VimtexCompile<cr>",
      vim.tbl_extend("force", buf_opts, { desc = "Toggle Compilation" })
    )
    map(
      "n",
      "<leader>lc",
      "<cmd>VimtexCompileSelected<cr>",
      vim.tbl_extend("force", buf_opts, { desc = "Compile Selection" })
    )
    map(
      "n",
      "<leader>ls",
      "<cmd>VimtexStop<cr>",
      vim.tbl_extend("force", buf_opts, { desc = "Stop Compilation" })
    )

    -- Viewing
    map(
      "n",
      "<leader>lv",
      "<cmd>VimtexView<cr>",
      vim.tbl_extend("force", buf_opts, { desc = "View PDF" })
    )
    map(
      "n",
      "<leader>lr",
      "<cmd>VimtexReverse<cr>",
      vim.tbl_extend("force", buf_opts, { desc = "Reverse Search" })
    )

    -- Cleaning
    map(
      "n",
      "<leader>lk",
      "<cmd>VimtexClean<cr>",
      vim.tbl_extend("force", buf_opts, { desc = "Clean Auxiliary Files" })
    )
    map(
      "n",
      "<leader>lK",
      "<cmd>VimtexClean!<cr>",
      vim.tbl_extend("force", buf_opts, { desc = "Clean All Files" })
    )

    -- TOC & Navigation
    map(
      "n",
      "<leader>lt",
      "<cmd>VimtexTocToggle<cr>",
      vim.tbl_extend("force", buf_opts, { desc = "Toggle TOC" })
    )
    map(
      "n",
      "<leader>li",
      "<cmd>VimtexInfo<cr>",
      vim.tbl_extend("force", buf_opts, { desc = "VimTeX Info" })
    )

    -- Text objects
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

    -- Quick formatting
    map(
      "v",
      "<leader>lb",
      'c\\textbf{<C-r>"}<Esc>',
      vim.tbl_extend("force", buf_opts, { desc = "Bold" })
    )
    map(
      "v",
      "<leader>li",
      'c\\textit{<C-r>"}<Esc>',
      vim.tbl_extend("force", buf_opts, { desc = "Italic" })
    )
    map(
      "v",
      "<leader>l$",
      'c$<C-r>"$<Esc>',
      vim.tbl_extend("force", buf_opts, { desc = "Inline Math" })
    )
  end,
})
