--
-- autocmds.lua
-- Autocommands and skeleton file system for Neovim
--
-- This module provides:
-- • Automated file processing (whitespace, markdown normalization)
-- • Enhanced markdown syntax highlighting with embedded code blocks
-- • Google Style Guide indentation for all languages:
--   - Python: 4 spaces (Google Python Style)
--   - C/C++, Shell, JavaScript, Swift, Lua: 2 spaces
-- • Comprehensive skeleton file templates for new files
-- • LaTeX and code runner integrations
--

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Historical note: two workarounds for treesitter markdown parser crashes
-- ("Invalid 'index'" during code-fence edits) used to live here. The upstream
-- bugs were fixed before Neovim 0.12; the per-keystroke full re-parse they
-- performed doubled parsing work in exactly the buffers where typing latency
-- matters. :TSReset below remains as a manual escape hatch.

-- Add command to manually reset treesitter if needed
vim.api.nvim_create_user_command("TSReset", function()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.treesitter.stop(bufnr)
  vim.defer_fn(function()
    vim.treesitter.start(bufnr)
    vim.notify("Treesitter reset for current buffer", vim.log.levels.INFO)
  end, 100)
end, { desc = "Reset treesitter for current buffer" })

local original_nvim_buf_set_extmark = vim.api.nvim_buf_set_extmark

-- Wrap extmark to handle out-of-range errors from treesitter highlighter
-- Still global but lightweight: only catches specific errors, passes through otherwise.
-- Swallowed errors are logged at DEBUG (NVIM_LOG_LEVEL=DEBUG) so misbehaving plugins
-- (extmarks are set constantly by render-markdown, gitsigns, ...) stay observable.
---@diagnostic disable-next-line: duplicate-set-field
vim.api.nvim_buf_set_extmark = function(buffer, ns_id, line, col, opts)
  local ok, result = pcall(original_nvim_buf_set_extmark, buffer, ns_id, line, col, opts)
  if not ok then
    local err = tostring(result)
    if err:match("Invalid 'end_col': out of range") or err:match("Invalid 'col': out of range") then
      require("logging").debug(
        "extmark",
        string.format(
          "swallowed out-of-range set_extmark buf=%d ns=%d line=%d col=%d",
          buffer,
          ns_id,
          line,
          col
        )
      )
      return 0
    else
      error(result)
    end
  end
  return result
end

-- Workaround for treesitter get_node errors when deleting code fences
local original_ts_get_node = vim.treesitter.get_node
---@diagnostic disable-next-line: duplicate-set-field
vim.treesitter.get_node = function(...)
  local ok, result = pcall(original_ts_get_node, ...)
  if not ok then
    return nil
  end
  return result
end

-- Workaround for treesitter get_range crash when node is nil
-- This happens when fold/highlight code passes a nil node after tree invalidation
local original_ts_get_range = vim.treesitter.get_range
---@diagnostic disable-next-line: duplicate-set-field
vim.treesitter.get_range = function(node, source, metadata)
  if node == nil then
    return { 0, 0, 0, 0, 0, 0 }
  end
  local ok, result = pcall(original_ts_get_range, node, source, metadata)
  if not ok then
    return { 0, 0, 0, 0, 0, 0 }
  end
  return result
end

-- Ensure terminal cursor visibility
local terminal_cursor_group = augroup("TerminalCursor", { clear = true })
local ui = require("ui")
local default_guicursor = ui.default_guicursor

autocmd({ "TermEnter" }, {
  group = terminal_cursor_group,
  callback = function()
    vim.opt.guicursor = "a:ver25-blinkon1"
  end,
  desc = "Ensure cursor is visible in terminal mode",
})

autocmd({ "TermLeave", "BufLeave" }, {
  group = terminal_cursor_group,
  pattern = "term://*",
  callback = function()
    vim.opt.guicursor = default_guicursor
  end,
  desc = "Restore cursor to block shape when leaving terminal",
})

-- Ensure cursor is restored when entering normal buffers from terminal
autocmd({ "BufEnter", "WinEnter" }, {
  group = terminal_cursor_group,
  callback = function()
    if vim.bo.buftype ~= "terminal" then
      vim.opt.guicursor = default_guicursor
    end
  end,
  desc = "Ensure cursor is restored when entering non-terminal buffers",
})

-- Force cursor restoration after terminal closes
autocmd({ "TermClose" }, {
  group = terminal_cursor_group,
  callback = function()
    vim.defer_fn(function()
      vim.opt.guicursor = default_guicursor
    end, 50)
  end,
  desc = "Force cursor restoration after terminal closes",
})

-- (Markdown syntax enhancements removed — handled by render-markdown.nvim)

-- =============================================================================
-- FILE PROCESSING AUTOMATION
-- =============================================================================

-- Automated file normalization and cleanup
local normalize_group = augroup("normalize", { clear = true })

autocmd("FileType", {
  group = normalize_group,
  pattern = { "make", "makefile" },
  command = "set noexpandtab",
})

-- Removed auto-formatting on save
-- Use :Format command to manually format files

-- =============================================================================
-- LSP SETUP AFTER PLUGINS
-- =============================================================================

-- LSP setup is now handled in plugins.lua via nvim-lspconfig's config function
-- This prevents duplicate initialization

-- =============================================================================
-- PROJECT-SPECIFIC SETTINGS
-- =============================================================================

-- File type associations and project conventions
local projects_group = augroup("projects", { clear = true })

autocmd({ "BufRead", "BufNewFile" }, {
  group = projects_group,
  pattern = { "*.h", "*.c" },
  command = "set filetype=c",
})

-- BUILD and Bazel file detection
autocmd({ "BufRead", "BufNewFile" }, {
  group = projects_group,
  pattern = {
    "BUILD",
    "BUILD.bazel",
    "WORKSPACE",
    "WORKSPACE.bazel",
    "*.BUILD",
    "*.bzl",
    "*.bazel",
  },
  callback = function()
    vim.bo.filetype = "bzl"
  end,
  desc = "Set filetype for Bazel/BUILD files",
})

-- Additional pattern for BUILD files in subdirectories
autocmd({ "BufRead", "BufNewFile" }, {
  group = projects_group,
  pattern = { "*/BUILD", "*/BUILD.bazel", "*/WORKSPACE", "*/WORKSPACE.bazel" },
  callback = function()
    vim.bo.filetype = "bzl"
  end,
  desc = "Set filetype for Bazel/BUILD files in subdirectories",
})

-- =============================================================================
-- PYTHON INDENTATION ENFORCEMENT
-- =============================================================================

-- Google Python Style Guide indentation (4-space standard)
-- https://google.github.io/styleguide/pyguide.html
local python_group = augroup("python_indent", { clear = true })

autocmd("FileType", {
  group = python_group,
  pattern = "python",
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab = true
  end,
})

-- Removed auto-enforcement of Python settings
-- Settings are only applied when opening Python files, not on save

-- =============================================================================
-- GOOGLE STYLE GUIDE INDENTATION FOR OTHER LANGUAGES
-- =============================================================================

-- Google style guides for various languages
local google_style_group = augroup("google_style", { clear = true })

-- C/C++ (Google C++ Style Guide: 2 spaces)
-- https://google.github.io/styleguide/cppguide.html
autocmd("FileType", {
  group = google_style_group,
  pattern = { "c", "cpp", "cc", "cxx", "h", "hpp", "hxx" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
    vim.opt_local.textwidth = 100
  end,
})

-- Shell/Bash (Google Shell Style Guide: 2 spaces)
-- https://google.github.io/styleguide/shellguide.html
autocmd("FileType", {
  group = google_style_group,
  pattern = { "sh", "bash", "zsh", "fish" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
    vim.opt_local.textwidth = 100
  end,
})

-- Swift (Apple/Google convention: 2 spaces)
-- Swift typically follows similar conventions to Google's other languages
autocmd("FileType", {
  group = google_style_group,
  pattern = { "swift" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
    vim.opt_local.textwidth = 100
  end,
})

-- Lua (Common convention: 2 spaces)
autocmd("FileType", {
  group = google_style_group,
  pattern = { "lua" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
    vim.opt_local.textwidth = 100
  end,
})

-- LaTeX (Common convention: 2 spaces)
-- LaTeX doesn't have an official Google style guide, but 2 spaces is common
autocmd("FileType", {
  group = google_style_group,
  pattern = { "tex", "latex", "plaintex", "bib" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
    vim.opt_local.textwidth = 100
    -- LaTeX-specific settings
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end,
})

-- JavaScript/TypeScript (Google JavaScript Style Guide: 2 spaces)
-- https://google.github.io/styleguide/jsguide.html
autocmd("FileType", {
  group = google_style_group,
  pattern = {
    "javascript",
    "javascriptreact",
    "typescript",
    "typescriptreact",
    "json",
    "jsonc",
  },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
    vim.opt_local.textwidth = 100
  end,
})

-- HTML/XML (Google HTML/CSS Style Guide: 2 spaces)
-- https://google.github.io/styleguide/htmlcssguide.html
autocmd("FileType", {
  group = google_style_group,
  pattern = { "html", "xml", "xhtml", "css", "scss", "sass", "less" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
    vim.opt_local.textwidth = 100
  end,
})

-- YAML/TOML (Common convention: 2 spaces)
autocmd("FileType", {
  group = google_style_group,
  pattern = { "yaml", "yml", "toml" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
  end,
})

-- Ruby (Common convention: 2 spaces)
autocmd("FileType", {
  group = google_style_group,
  pattern = { "ruby", "erb", "rake" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
    vim.opt_local.textwidth = 100
  end,
})

-- Go (Official Go style: tabs)
autocmd("FileType", {
  group = google_style_group,
  pattern = { "go" },
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab = false -- Go uses tabs
    vim.opt_local.textwidth = 100
  end,
})

-- Rust (Official Rust style: 4 spaces)
autocmd("FileType", {
  group = google_style_group,
  pattern = { "rust" },
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab = true
    vim.opt_local.textwidth = 100
  end,
})

-- Markdown (Common convention: 2 spaces)
-- Display settings (wrap/linebreak/textwidth) live in the MARKDOWN WRITING
-- ENVIRONMENT block below — one owner, not two.
autocmd("FileType", {
  group = google_style_group,
  pattern = { "markdown", "pandoc", "rst" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
  end,
})

-- =============================================================================
-- SYNTAX OPTIMIZATIONS
-- =============================================================================

-- Performance optimizations for large files and special syntax handling
local syntax_group = augroup("syntax", { clear = true })

autocmd("FileType", {
  group = syntax_group,
  pattern = { "tex", "latex", "markdown", "pandoc" },
  command = "set synmaxcol=2048",
})

autocmd({ "BufNewFile", "BufRead" }, {
  group = syntax_group,
  pattern = "*.tex",
  command = "set syntax=tex",
})

-- Markdown display settings are owned by the MARKDOWN WRITING ENVIRONMENT
-- block below; indentation by the google_style block above.

-- =============================================================================
-- BIG FILE OPTIMIZATIONS
-- =============================================================================

-- Disable expensive features for large files
local bigfile_group = augroup("bigfile", { clear = true })

-- Function to optimize settings for large files
local function optimize_for_bigfile()
  local file = vim.fn.expand("<afile>")
  local size = vim.fn.getfsize(file)
  local big_file_limit = 1024 * 1024 * 50 -- 50MB, default behavior at 10MB

  if size > big_file_limit or size == -2 then
    -- Disable expensive features
    vim.opt_local.syntax = "off"
    vim.opt_local.filetype = "off"
    vim.opt_local.swapfile = false
    vim.opt_local.foldmethod = "manual"
    vim.opt_local.undolevels = -1
    vim.opt_local.undoreload = 0
    vim.opt_local.list = false
    vim.opt_local.relativenumber = false
    vim.opt_local.colorcolumn = ""
    vim.opt_local.cursorline = false
    vim.opt_local.spell = false

    -- Disable matchparen
    if vim.fn.exists(":NoMatchParen") == 2 then
      vim.cmd("NoMatchParen")
    end

    -- Notify user
    vim.notify(
      "Big file detected. Disabled expensive features for performance.",
      vim.log.levels.INFO
    )
  end
end

-- Apply optimizations before reading large files
autocmd("BufReadPre", {
  group = bigfile_group,
  pattern = "*",
  callback = optimize_for_bigfile,
})

-- Additional optimization for files with long lines
autocmd("BufWinEnter", {
  group = bigfile_group,
  pattern = "*",
  callback = function()
    local max_filesize = 100 * 1024 -- 100KB
    ---@diagnostic disable-next-line: undefined-field
    local ok, stats = pcall((vim.uv or vim.loop).fs_stat, vim.api.nvim_buf_get_name(0))
    if ok and stats and stats.size > max_filesize then
      vim.opt_local.wrap = false
      vim.opt_local.synmaxcol = 200
    end
  end,
})

-- =============================================================================
-- MARKDOWN WRITING ENVIRONMENT
-- =============================================================================

-- Professional markdown writing configuration with optimized display settings
local markdown_writing_group = augroup("markdown_writing", { clear = true })

local markdown_settings = {
  "setlocal wrap", -- Enable word wrap
  "setlocal linebreak", -- Break lines at word boundaries
  "setlocal nolist", -- Hide special characters for cleaner view
  -- textwidth only affects explicit gq reflow (repo standard 100, matching
  -- ~/.editorconfig); auto-wrap while typing stays off via formatoptions-=t.
  "setlocal textwidth=100",
  "setlocal wrapmargin=0", -- No wrap margin
  "setlocal formatoptions-=t", -- Don't auto-wrap text
  "setlocal formatoptions+=l", -- Don't break long lines in insert mode
  "setlocal formatoptions+=r", -- <CR> continues lists/blockquotes ('comments')
  "setlocal formatoptions+=o", -- o/O continue lists/blockquotes too
  -- The runtime ftplugin uses fb: flags (indent-only continuation); b: makes
  -- <CR>/o actually repeat the bullet marker like any markdown editor.
  "setlocal comments=b:*,b:-,b:+,n:>",
  "setlocal display+=lastline", -- Show partial wrapped lines
  "setlocal breakindent", -- Indent wrapped lines
  "setlocal breakindentopt=shift:2,min:40",
  "setlocal spell", -- Enable spell check
  "setlocal number", -- Show line numbers
  "setlocal relativenumber", -- Show relative line numbers
  "setlocal colorcolumn=", -- Remove color column
  "setlocal signcolumn=yes", -- Show sign column
}

autocmd("FileType", {
  group = markdown_writing_group,
  pattern = { "markdown", "pandoc" },
  callback = function()
    -- NOTE: FileType markdown fires twice per buffer (lazy.nvim re-fires it
    -- after loading ft-triggered plugins) and the runtime ftplugin re-adds
    -- formatoptions 't' / removes 'r','o' on each fire. This callback must
    -- re-run every time so the settings below win the last word; everything
    -- here is idempotent.
    for _, setting in ipairs(markdown_settings) do
      vim.cmd(setting)
    end

    -- Font settings for GUI vim (JetBrainsMono has better Haskell ligatures than Hasklug)
    if vim.fn.has("gui_running") == 1 then
      vim.cmd("setlocal guifont=JetBrainsMono\\ Nerd\\ Font:h14")
    end

    -- Improved navigation for wrapped lines. j/k stay count-aware so that
    -- 5j under relativenumber still moves 5 file lines, not display lines.
    local buf_opts = { buffer = true, noremap = true, silent = true }
    local expr_opts = { buffer = true, noremap = true, silent = true, expr = true }
    vim.keymap.set({ "n", "v" }, "j", "v:count == 0 ? 'gj' : 'j'", expr_opts)
    vim.keymap.set({ "n", "v" }, "k", "v:count == 0 ? 'gk' : 'k'", expr_opts)
    vim.keymap.set({ "n", "v" }, "0", "g0", buf_opts)
    vim.keymap.set({ "n", "v" }, "$", "g$", buf_opts)

    -- Undo breakpoints at sentence punctuation, so u after a long paragraph
    -- doesn't nuke the whole thing.
    for _, ch in ipairs({ ".", ",", "!", "?", ";" }) do
      vim.keymap.set("i", ch, ch .. "<C-g>u", { buffer = true })
    end

    -- Quick spell fixes: accept the top suggestion for the last misspelling.
    -- Insert-mode <C-s> shadows LSP signature help, which is useless in prose.
    vim.keymap.set("i", "<C-s>", "<C-g>u<Esc>[s1z=`]a<C-g>u", {
      buffer = true,
      desc = "Fix last spelling error",
    })
    vim.keymap.set("n", "<leader>z", "[s1z=``", {
      buffer = true,
      desc = "Fix last spelling error",
    })
  end,
})

-- =============================================================================
-- CODE EXECUTION SYSTEM
-- =============================================================================

-- AsyncRun integration for background compilation
local run_group = augroup("run", { clear = true })

local window_open = 1

autocmd("FileType", {
  group = run_group,
  pattern = { "tex", "plaintex" },
  callback = function()
    window_open = 0
  end,
})

autocmd("QuickFixCmdPost", {
  group = run_group,
  pattern = "*",
  callback = function()
    vim.fn["asyncrun#quickfix_toggle"](8, window_open)
  end,
})

-- Note: Code execution uses sniprun plugin (<leader>cr or <cr> in scratch buffers)

-- Async run repeat for last command
autocmd("FileType", {
  group = run_group,
  pattern = "*",
  callback = function()
    vim.keymap.set(
      "n",
      "<leader>R",
      ":AsyncRun<Up><CR>",
      { buffer = true, desc = "Repeat last async command" }
    )
  end,
})

-- =============================================================================
-- AUTO-RELOAD FILES
-- =============================================================================
-- Automatically reload files when they change on disk
local autoreload_group = augroup("auto_reload", { clear = true })

-- Enable autoread and set up auto-reload
vim.opt.autoread = true

-- Check for file changes when focusing vim or entering a buffer
autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = autoreload_group,
  pattern = "*",
  callback = function()
    if vim.fn.mode() ~= "c" and vim.fn.getcmdwintype() == "" then
      vim.cmd("checktime")
    end
  end,
  desc = "Check for file changes on disk",
})

-- Notification when file changes
autocmd("FileChangedShellPost", {
  group = autoreload_group,
  pattern = "*",
  callback = function()
    -- Don't notify if fixy is currently formatting (check both global and buffer flags)
    local bufnr = vim.api.nvim_get_current_buf()
    -- Also check if we're in a special buffer type that shouldn't show notifications
    local buftype = vim.bo[bufnr].buftype
    local should_notify = buftype == "" -- Only notify for normal file buffers
      and not vim.g._fixy_formatting
      and not vim.b[bufnr]._fixy_formatting
      and not string.match(vim.bo[bufnr].filetype or "", "^snacks_")

    if should_notify then
      vim.notify("File reloaded from disk", vim.log.levels.INFO)
    end
  end,
  desc = "Notify when file is reloaded",
})

-- Auto reload for specific file types (immediate reload without prompt).
-- :edit! is disallowed inside FileChangedShell (the current buffer may not
-- even be the changed one); v:fcs_choice is the documented mechanism. The
-- FileChangedShellPost autocmd above handles the notification.
autocmd({ "FileChangedShell" }, {
  group = autoreload_group,
  pattern = "*",
  callback = function()
    if not vim.bo.modified then
      vim.v.fcs_choice = "reload"
    else
      -- Keep the conflict prompt for locally-modified buffers (defining this
      -- autocmd suppresses the default warning unless fcs_choice is set).
      vim.v.fcs_choice = "ask"
    end
  end,
  desc = "Auto reload unmodified files",
})

-- More aggressive checking for Alacritty terminal users
if vim.env.TERM_PROGRAM == "Alacritty" then
  -- Check more frequently in terminal
  vim.opt.updatetime = 1000 -- Trigger CursorHold after 1 second

  -- Watch for changes using timer (checks every 2 seconds)
  ---@diagnostic disable-next-line: undefined-field
  local timer = (vim.uv or vim.loop).new_timer()
  timer:start(
    2000,
    2000,
    vim.schedule_wrap(function()
      if vim.fn.mode() ~= "c" and vim.fn.getcmdwintype() == "" then
        vim.cmd("silent! checktime")
      end
    end)
  )

  -- Clean up timer when Neovim exits
  vim.api.nvim_create_autocmd("VimLeavePre", {
    callback = function()
      timer:stop()
      timer:close()
    end,
  })
elseif vim.env.TERM_PROGRAM == "WezTerm" then
  -- WezTerm-specific settings to prevent hangs
  vim.opt.updatetime = 4000 -- Much less aggressive for WezTerm
  -- No automatic redraws or timers for WezTerm
end

-- =============================================================================
-- LSP DOCUMENT HIGHLIGHT CONFIGURATION
-- =============================================================================

-- Configure LSP highlight groups for better visibility
local lsp_highlight_group = augroup("LspDocumentHighlight", { clear = true })

local function apply_lsp_highlights()
  if vim.o.background == "dark" then
    vim.api.nvim_set_hl(0, "LspReferenceText", { bg = "#3b3b3b", underline = false })
    vim.api.nvim_set_hl(0, "LspReferenceRead", { bg = "#3b3b3b", underline = false })
    vim.api.nvim_set_hl(0, "LspReferenceWrite", { bg = "#4b3b3b", underline = false })
  else
    vim.api.nvim_set_hl(0, "LspReferenceText", { bg = "#e8e8e8", underline = false })
    vim.api.nvim_set_hl(0, "LspReferenceRead", { bg = "#e8e8e8", underline = false })
    vim.api.nvim_set_hl(0, "LspReferenceWrite", { bg = "#e0d8d8", underline = false })
  end
end

autocmd("ColorScheme", {
  group = lsp_highlight_group,
  pattern = "*",
  callback = apply_lsp_highlights,
  desc = "Set LSP reference highlight colors",
})

-- Apply highlight groups immediately
apply_lsp_highlights()

-- =============================================================================
-- VISUAL SELECTION HIGHLIGHT
-- =============================================================================
-- Make visual selection more visible (especially over comments)
local visual_highlight_group = augroup("VisualHighlight", { clear = true })

autocmd("ColorScheme", {
  group = visual_highlight_group,
  pattern = "*",
  callback = function()
    if vim.o.background == "dark" then
      vim.api.nvim_set_hl(0, "Visual", { bg = "#3a3a00", fg = "#ffff00" })
      vim.api.nvim_set_hl(0, "VisualNOS", { bg = "#3a3a00", fg = "#ffff00" })
    else
      vim.api.nvim_set_hl(0, "Visual", { bg = "#d6d6ff", fg = "#000080" })
      vim.api.nvim_set_hl(0, "VisualNOS", { bg = "#d6d6ff", fg = "#000080" })
    end
  end,
  desc = "Set Visual selection highlight for better visibility",
})

-- Apply immediately
vim.api.nvim_set_hl(0, "Visual", { bg = "#3a3a00", fg = "#ffff00" })
vim.api.nvim_set_hl(0, "VisualNOS", { bg = "#3a3a00", fg = "#ffff00" })

-- =============================================================================
-- SPELL CHECKING CONFIGURATION
-- =============================================================================
-- Enable spell checking only for text-heavy file types to avoid performance issues
local spell_group = augroup("spell_check", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = spell_group,
  pattern = {
    "markdown",
    "tex",
    "latex",
    "plaintex",
    "text",
    "gitcommit",
    "rst",
  },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
    -- The default spelloptions=noplainbuffer only spell-checks regions that
    -- syntax or treesitter marks as prose. ft=text has neither, so without
    -- this the spell highlighting never renders in .txt files.
    if vim.bo.filetype == "text" then
      vim.opt_local.spelloptions = ""
    end
  end,
  desc = "Enable spell checking for documentation files",
})

-- =============================================================================
-- SKELETON FILE SYSTEM
-- =============================================================================

-- Comprehensive skeleton template system for automatic file initialization
-- Supports Python, Shell, HTML, JavaScript, C, Java, LaTeX, Markdown, React
-- Features:
-- • Professional headers with author, date, and license information
-- • Language-specific imports and structure (e.g., if __name__ == '__main__')
-- • 2-space indentation (4 spaces for Python per Google Style Guide)
-- • Integration with Snacks.nvim for immediate indentation guides
-- • Cursor positioning at first TODO or editable content
local skeleton_group = augroup("skeleton_files", { clear = true })

-- Helper function to get skeleton content directly
local function get_skeleton_content(filetype, context)
  local date = os.date("%Y-%m-%d")
  local year = os.date("%Y")
  local filename = vim.fn.expand("%:t") or "untitled"
  local project = vim.fn.expand("%:p:h:t") or "project"

  if filetype == "python" then
    return {
      "#!/usr/bin/env python3",
      '"""',
      context.description or "Module description",
      "",
      "Author: " .. (context.author or "Illya Starikov"),
      "Date: " .. date,
      "License: MIT",
      '"""',
      "",
      "import argparse",
      "import logging",
      "import sys",
      "from typing import Optional",
      "",
      "",
      "# Configure logging",
      "logging.basicConfig(",
      "    level=logging.INFO,",
      "    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'",
      ")",
      "logger = logging.getLogger(__name__)",
      "",
      "",
      "def main() -> int:",
      '    """',
      "    Main function entry point.",
      "",
      "    Returns:",
      "        int: Exit code (0 for success, non-zero for failure)",
      '    """',
      "    parser = argparse.ArgumentParser(",
      "        description='" .. (context.description or "Script description") .. "'",
      "    )",
      "",
      "    # Add command line arguments",
      "    parser.add_argument(",
      "        '-v', '--verbose',",
      "        action='store_true',",
      "        help='Enable verbose logging'",
      "    )",
      "",
      "    args = parser.parse_args()",
      "",
      "    # Set logging level based on verbosity",
      "    if args.verbose:",
      "        logger.setLevel(logging.DEBUG)",
      "",
      "    try:",
      "        # Main logic here",
      "        logger.info('Starting...')",
      "        # TODO: Add your implementation here",
      "",
      "        logger.info('Completed successfully')",
      "        return 0",
      "",
      "    except KeyboardInterrupt:",
      "        logger.info('Interrupted by user')",
      "        return 130",
      "    except Exception as e:",
      "        logger.error('Error: %s', e)",
      "        return 1",
      "",
      "",
      "if __name__ == '__main__':",
      "    sys.exit(main())",
      "",
    }
  elseif filetype == "shell" then
    return {
      "#!/bin/bash",
      "#",
      "# " .. (context.description or "Script description"),
      "#",
      "# Author: " .. (context.author or "Illya Starikov"),
      "# Date: " .. date,
      "# Copyright (c) "
        .. year
        .. " "
        .. (context.author or "Illya Starikov")
        .. ". All rights reserved.",
      "#",
      "",
      "# Enable strict error handling",
      "set -euo pipefail",
      "",
      "# Script metadata",
      'readonly SCRIPT_NAME="$(basename "${BASH_SOURCE[0]}")"',
      'readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"',
      "",
      "# Main function",
      "main() {",
      "  echo 'Hello, World!'",
      "  # TODO: Add your implementation here",
      "}",
      "",
      "# Only run main if script is executed directly (not sourced)",
      'if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then',
      '  main "$@"',
      "fi",
      "",
    }
  elseif filetype == "html" then
    return {
      "<!DOCTYPE html>",
      '<html lang="' .. (context.lang or "en") .. '">',
      "<head>",
      '  <meta charset="UTF-8">',
      '  <meta name="viewport" content="width=device-width, initial-scale=1.0">',
      '  <meta name="description" content="' .. (context.description or "Page description") .. '">',
      '  <meta name="author" content="' .. (context.author or "Illya Starikov") .. '">',
      "  <title>" .. (context.title or "Page Title") .. "</title>",
      '  <link rel="stylesheet" href="styles.css">',
      "</head>",
      "<body>",
      "  <header>",
      "    <nav>",
      "      <!-- Navigation content -->",
      "    </nav>",
      "  </header>",
      "",
      "  <main>",
      "    <h1>" .. (context.title or "Page Title") .. "</h1>",
      "    <!-- Main content -->",
      "  </main>",
      "",
      "  <footer>",
      "    <p>&copy; "
        .. year
        .. " "
        .. (context.author or "Illya Starikov")
        .. ". All rights reserved.</p>",
      "  </footer>",
      "",
      '  <script src="script.js"></script>',
      "</body>",
      "</html>",
      "",
    }
  elseif filetype == "markdown" then
    local filename_lower = filename:lower()
    if filename_lower == "readme.md" then
      return {
        "# " .. (context.title or project:gsub("^%l", string.upper)),
        "",
        "> " .. (context.description or "Brief project description"),
        "",
        "## Table of Contents",
        "",
        "- [Installation](#installation)",
        "- [Usage](#usage)",
        "- [Features](#features)",
        "- [Contributing](#contributing)",
        "- [License](#license)",
        "",
        "## Installation",
        "",
        "```bash",
        "# Installation instructions",
        "```",
        "",
        "## Usage",
        "",
        "```bash",
        "# Usage examples",
        "```",
        "",
        "## Features",
        "",
        "- [ ] Feature 1",
        "- [ ] Feature 2",
        "- [ ] Feature 3",
        "",
        "## Contributing",
        "",
        "1. Fork the repository",
        "2. Create a feature branch",
        "3. Commit your changes",
        "4. Push to the branch",
        "5. Open a Pull Request",
        "",
        "## License",
        "",
        "This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.",
        "",
      }
    else
      -- Use the template from reference/markdown_reference.md
      local today = os.date("%d.%m.%Y")
      -- Resolve the repo from the FILE's directory, not nvim's cwd — a note
      -- created outside the current project should not inherit its name.
      local file_dir = vim.fn.expand("%:p:h")
      local toplevel =
        vim.fn.system({ "git", "-C", file_dir, "rev-parse", "--show-toplevel" }):gsub("\n", "")
      local git_repo = vim.v.shell_error == 0 and vim.fn.fnamemodify(toplevel, ":t") or ""
      if git_repo == "" then
        git_repo = vim.fn.expand("%:p:h:t")
      end

      return {
        "<!--",
        "NAME         " .. filename,
        "PROJECT      " .. git_repo,
        "D.CREATED    " .. today,
        "D.MODIFIED   " .. today,
        "VERSION      1.0",
        "",
        "AUTHOR       Illya Starikov",
        "EMAIL        illya@starikov.co",
        "COPYRIGHT    © " .. year .. " Illya Starikov",
        "LICENSE      MIT (https://spdx.org/licenses/MIT.html)",
        "-->",
        "",
        "# ",
        "",
      }
    end
  elseif filetype == "javascript" then
    return {
      "/**",
      " * " .. (context.description or "Module description"),
      " *",
      " * Author: " .. (context.author or "Illya Starikov"),
      " * Date: " .. date,
      " * Copyright (c) "
        .. year
        .. " "
        .. (context.author or "Illya Starikov")
        .. ". All rights reserved.",
      " */",
      "",
      "'use strict';",
      "",
      "// TODO: Module implementation",
      "",
      "if (typeof module !== 'undefined' && module.exports) {",
      "  module.exports = {",
      "    // TODO: Exported functions/objects",
      "  };",
      "}",
      "",
    }
  elseif filetype == "c" then
    return {
      "//",
      "//  " .. filename,
      "//  " .. project,
      "//",
      "//  Created by " .. (context.author or "Illya Starikov") .. " on " .. date .. ".",
      "//  Copyright "
        .. year
        .. ". "
        .. (context.author or "Illya Starikov")
        .. ". All rights reserved.",
      "//",
      "",
      "#include <stdio.h>",
      "#include <stdlib.h>",
      "#include <string.h>",
      "#include <stdbool.h>",
      "",
      "/**",
      " * Main function - entry point of the program",
      " *",
      " * @param argc Number of command line arguments",
      " * @param argv Array of command line argument strings",
      " * @return EXIT_SUCCESS on success, EXIT_FAILURE on error",
      " */",
      "int main(int argc, char *argv[]) {",
      "  // TODO: Program logic here",
      '  printf("Hello, World!\\n");',
      "",
      "  return EXIT_SUCCESS;",
      "}",
      "",
    }
  elseif filetype == "java" then
    local classname = filename:gsub("%.java$", ""):gsub("^%l", string.upper)
    return {
      "/*",
      " * Copyright " .. year .. " " .. (context.author or "Illya Starikov"),
      " *",
      ' * Licensed under the Apache License, Version 2.0 (the "License");',
      " * you may not use this file except in compliance with the License.",
      " * You may obtain a copy of the License at",
      " *",
      " *     http://www.apache.org/licenses/LICENSE-2.0",
      " *",
      " * Unless required by applicable law or agreed to in writing, software",
      ' * distributed under the License is distributed on an "AS IS" BASIS,',
      " * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.",
      " * See the License for the specific language governing permissions and",
      " * limitations under the License.",
      " */",
      "",
      "import java.util.logging.Logger;",
      "import java.util.logging.Level;",
      "",
      "/**",
      " * " .. (context.description or "Main application class"),
      " *",
      " * @author " .. (context.author or "Illya Starikov"),
      " * @since " .. date,
      " */",
      "public final class " .. classname .. " {",
      "",
      "  private static final Logger logger = Logger.getLogger("
        .. classname
        .. ".class.getName());",
      "",
      "  // Prevent instantiation",
      "  private " .. classname .. "() {}",
      "",
      "  /**",
      "   * Main entry point for the application.",
      "   *",
      "   * @param args Command line arguments",
      "   */",
      "  public static void main(String[] args) {",
      "    try {",
      '      logger.info("Starting application");',
      "      // TODO: Application logic here",
      '      System.out.println("Hello, World!");',
      '      logger.info("Application completed successfully");',
      "    } catch (Exception e) {",
      '      logger.log(Level.SEVERE, "Application failed", e);',
      "      System.exit(1);",
      "    }",
      "  }",
      "}",
      "",
    }
  elseif filetype == "latex" then
    return {
      "\\documentclass[12pt]{article}",
      "",
      "% Essential packages",
      "\\usepackage[utf8]{inputenc}",
      "\\usepackage[T1]{fontenc}",
      "\\usepackage{lmodern}",
      "\\usepackage{microtype}",
      "\\usepackage{geometry}",
      "",
      "% Math packages",
      "\\usepackage{amsmath,amssymb,amsthm}",
      "\\usepackage{mathtools}",
      "",
      "% Graphics and tables",
      "\\usepackage{graphicx}",
      "\\usepackage{booktabs}",
      "",
      "% References and citations",
      "\\usepackage[hidelinks]{hyperref}",
      "\\usepackage{cleveref}",
      "",
      "% Document information",
      "\\title{" .. (context.title or "Document Title") .. "}",
      "\\author{" .. (context.author or "Illya Starikov") .. "}",
      "\\date{\\today}",
      "",
      "\\begin{document}",
      "\\maketitle",
      "",
      "% TODO: Document content",
      "",
      "\\end{document}",
      "",
    }
  elseif filetype == "react" then
    return {
      "import React, { useState, useEffect } from 'react';",
      "import PropTypes from 'prop-types';",
      "",
      "/**",
      " * " .. (context.description or "Component description"),
      " * @param {Object} props - Component props",
      " * @returns {JSX.Element} Rendered component",
      " */",
      "const " .. (context.name or "ComponentName") .. " = ({ }) => {",
      "  // TODO: Component state and effects",
      "  const [state, setState] = useState(null);",
      "",
      "  useEffect(() => {",
      "    // TODO: Effect logic",
      "  }, []);",
      "",
      "  return (",
      "    <div>",
      "      <h1>" .. (context.title or "Component Title") .. "</h1>",
      "      {/* TODO: Component content */}",
      "    </div>",
      "  );",
      "};",
      "",
      (context.name or "ComponentName") .. ".propTypes = {",
      "  // TODO: Define prop types",
      "};",
      "",
      "export default " .. (context.name or "ComponentName") .. ";",
      "",
    }
  end

  return { "# TODO: Add skeleton for " .. filetype }
end

-- Helper function to insert skeleton content
local function insert_skeleton(filetype, context)
  -- Only insert if the buffer is completely empty
  local line_count = vim.api.nvim_buf_line_count(0)
  local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] or ""

  if line_count == 1 and first_line == "" then
    local content = get_skeleton_content(filetype, context or {})
    vim.api.nvim_buf_set_lines(0, 0, 1, false, content)

    -- Special cursor positioning for markdown files
    if filetype == "markdown" then
      -- Find the line with "# " and position cursor after it
      for i, line in ipairs(content) do
        if line == "# " then
          vim.api.nvim_win_set_cursor(0, { i, 2 }) -- Position after "# "
          vim.cmd("startinsert!") -- Enter insert mode at cursor
          break
        end
      end
    else
      -- Position cursor at first TODO or at end of first editable line for other filetypes
      for i, line in ipairs(content) do
        if
          line:match("TODO")
          or line:match("Module description")
          or line:match("Script description")
        then
          vim.api.nvim_win_set_cursor(0, { i, 0 })
          break
        end
      end
    end

    -- Force proper filetype detection and trigger events to ensure indentation guides work
    vim.schedule(function()
      -- Ensure filetype is properly detected
      vim.cmd("filetype detect")

      -- Trigger events that plugins might be listening to
      vim.cmd("doautocmd BufRead")
      vim.cmd("doautocmd BufWinEnter")

      -- Trigger specific events for Snacks.nvim
      vim.cmd("doautocmd User SnacksIndentRefresh")
      vim.cmd("doautocmd CursorMoved")
      vim.cmd("doautocmd CursorMovedI")

      -- Try to refresh Snacks indent if available
      local ok, snacks = pcall(require, "snacks")
      if ok and snacks.indent then
        pcall(snacks.indent.refresh)
      end

      -- Force a redraw to ensure indentation guides appear
      vim.cmd("redraw!")

      -- Set buffer as modified initially, then unmodify to trigger proper state
      vim.bo.modified = true
      vim.bo.modified = false

      -- Additional schedule to ensure everything is processed
      vim.schedule(function()
        -- Trigger a small cursor movement to activate indent guides
        local current_pos = vim.api.nvim_win_get_cursor(0)
        vim.api.nvim_win_set_cursor(0, { current_pos[1], current_pos[2] })

        -- Final redraw
        vim.cmd("redraw!")

        -- Trigger buffer text changed events that Snacks might listen to
        vim.cmd("doautocmd TextChanged")
        vim.cmd("doautocmd TextChangedI")
      end)
    end)
  end
end

-- Python files
autocmd("BufNewFile", {
  group = skeleton_group,
  pattern = "*.py",
  callback = function()
    insert_skeleton("python")
  end,
})

-- Shell scripts
autocmd("BufNewFile", {
  group = skeleton_group,
  pattern = { "*.sh", "*.bash" },
  callback = function()
    insert_skeleton("shell")
  end,
})

-- JavaScript files
autocmd("BufNewFile", {
  group = skeleton_group,
  pattern = { "*.js", "*.mjs" },
  callback = function()
    insert_skeleton("javascript")
  end,
})

-- React components (JSX/TSX)
autocmd("BufNewFile", {
  group = skeleton_group,
  pattern = { "*.jsx", "*.tsx" },
  callback = function()
    insert_skeleton("react")
  end,
})

-- LaTeX documents
autocmd("BufNewFile", {
  group = skeleton_group,
  pattern = "*.tex",
  callback = function()
    insert_skeleton("latex")
  end,
})

-- Markdown files
autocmd("BufNewFile", {
  group = skeleton_group,
  pattern = { "*.md", "*.markdown" },
  callback = function()
    -- Skip throwaway and vault locations: scratchpad/temp notes don't want a
    -- copyright header, and Obsidian expects YAML frontmatter, not HTML
    -- comments.
    -- resolve() both sides: macOS temp dirs are symlinks (/tmp, /var/folders
    -- point into /private), so raw and resolved prefixes must both match.
    local path = vim.fn.resolve(vim.fn.expand("<afile>:p"))
    local skip_prefixes = {
      vim.fn.resolve(vim.env.TMPDIR or "/tmp"),
      "/tmp/",
      "/private/tmp/",
      vim.fn.expand("~/Documents/obsidian"),
    }
    for _, prefix in ipairs(skip_prefixes) do
      if prefix ~= "" and path:find(prefix, 1, true) == 1 then
        return
      end
    end

    -- Only insert skeleton for truly new files, not existing ones
    local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
    if #lines == 1 and lines[1] == "" then
      insert_skeleton("markdown")
    end
  end,
})

-- C/C++ files
autocmd("BufNewFile", {
  group = skeleton_group,
  pattern = { "*.c", "*.cpp", "*.cc", "*.cxx" },
  callback = function()
    insert_skeleton("c")
  end,
})

-- Java files
autocmd("BufNewFile", {
  group = skeleton_group,
  pattern = "*.java",
  callback = function()
    insert_skeleton("java")
  end,
})

-- HTML files
autocmd("BufNewFile", {
  group = skeleton_group,
  pattern = { "*.html", "*.htm" },
  callback = function()
    insert_skeleton("html")
  end,
})

-- =============================================================================
-- LARGE FILE OPTIMIZATIONS
-- =============================================================================

-- Optimize handling for large BUILD/Bazel files
local large_file_group = augroup("large_file_handling", { clear = true })

-- Handle large BUILD files with proper syntax highlighting
autocmd({ "BufReadPre", "FileReadPre" }, {
  group = large_file_group,
  pattern = {
    "BUILD",
    "BUILD.bazel",
    "*.BUILD",
    "*.bzl",
    "*.bazel",
    "WORKSPACE",
    "WORKSPACE.bazel",
  },
  callback = function()
    local file = vim.fn.expand("<afile>")
    local size = vim.fn.getfsize(file)

    -- Quick line count check without reading entire file
    local lines = 0
    if vim.fn.filereadable(file) == 1 then
      local line_count_str = vim.fn.system("wc -l < " .. vim.fn.shellescape(file))
      -- Strip all whitespace and newlines
      line_count_str = line_count_str:gsub("^%s*(.-)%s*$", "%1")
      -- Safely convert to number, ensuring we only get digits
      local num_str = line_count_str:match("^(%d+)")
      if num_str then
        lines = tonumber(num_str) or 0
      end
    end

    -- For BUILD files over 20000 lines or 50MB, optimize settings
    if lines > 20000 or size > 52428800 then
      vim.notify(
        "Large BUILD file detected (" .. lines .. " lines). Applying optimizations...",
        vim.log.levels.INFO
      )

      -- Set buffer-local variables to track large file
      vim.b.large_build_file = true
      vim.b.large_file_lines = lines

      -- Performance optimizations
      vim.opt_local.foldmethod = "manual"
      vim.opt_local.undolevels = 5000 -- Default: 1000
      vim.opt_local.swapfile = false -- Disable swap for large files
      vim.opt_local.backup = false -- Disable backup
      vim.opt_local.writebackup = false -- Disable write backup

      -- Increase processing limits for large files
      vim.opt.maxmempattern = 100000 -- Default: 1000
      vim.opt.redrawtime = 30000 -- Default: 2000

      -- Disable some expensive features for performance
      vim.opt_local.cursorline = false -- Disable cursor line highlighting
      vim.opt_local.relativenumber = false -- Disable relative numbers
      vim.opt_local.spell = false -- Disable spell checking
    end
  end,
  desc = "Optimize settings for large BUILD files",
})

-- Ensure proper filetype and highlighting after file is loaded
autocmd({ "BufReadPost", "FileReadPost" }, {
  group = large_file_group,
  pattern = {
    "BUILD",
    "BUILD.bazel",
    "*.BUILD",
    "*.bzl",
    "*.bazel",
    "WORKSPACE",
    "WORKSPACE.bazel",
  },
  callback = function()
    -- Always set filetype to bzl for BUILD files
    if vim.bo.filetype ~= "bzl" and vim.bo.filetype ~= "starlark" then
      vim.bo.filetype = "bzl"
    end

    -- For large files, ensure treesitter is used instead of regex-based syntax
    if vim.b.large_build_file then
      -- Try treesitter highlighting with starlark parser
      local ok = pcall(vim.treesitter.start, 0, "starlark")
      if not ok then
        -- Fallback to traditional syntax if treesitter not available
        vim.cmd("syntax on")
        vim.cmd("syntax sync fromstart")
      end

      -- Trigger LSP attachment
      vim.schedule(function()
        vim.cmd("LspStart")
      end)
    end
  end,
  desc = "Setup highlighting for BUILD files",
})

-- =============================================================================
-- DEBUG COMMANDS
-- =============================================================================

-- Additional debug commands can be added here

-- =============================================================================
-- (Removed: markdown parser auto-install safety net. Its pcall(get_parser)
-- check could never detect a missing parser on Neovim 0.12 (returns ok=true,
-- nil), and the treesitter config's ts.install() already ensures parsers.)

-- =============================================================================
-- TABLINE - Now handled by bufferline.nvim plugin
-- =============================================================================
-- Tabline functionality moved to bufferline.nvim for better buffer overflow handling
