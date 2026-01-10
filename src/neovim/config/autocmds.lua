--
-- config/autocmds.lua
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

-- Known issue: Treesitter has errors with markdown code fences
-- When editing markdown with incomplete code blocks, treesitter may throw
-- "Invalid 'index': Expected Lua number" or "get_offset" errors
-- This is a known upstream bug in treesitter's markdown parser
-- Users will see these errors but they are harmless and can be ignored

-- Safer markdown editing with code fences
vim.api.nvim_create_autocmd({ "FileType" }, {
  pattern = { "markdown", "markdown.pandoc" },
  callback = function()
    local bufnr = vim.api.nvim_get_current_buf()

    -- Create error-resistant wrapper for this buffer
    vim.api.nvim_buf_attach(bufnr, false, {
      ---@diagnostic disable-next-line: unused-local
      on_lines = function(_, _, _, first_line, last_line, new_last_line)
        -- Use vim.schedule to defer the check
        vim.schedule(function()
          -- Temporarily suppress errors during parsing
          local ok, err = pcall(function()
            local parser = vim.treesitter.get_parser(bufnr)
            if parser then
              parser:parse()
            end
          end)

          if not ok and err:match("Invalid 'index'") then
            -- Restart treesitter to recover from error state
            vim.treesitter.stop(bufnr)
            vim.defer_fn(function()
              pcall(vim.treesitter.start, bufnr)
            end, 50)
          end
        end)
      end,
    })
  end,
  desc = "Setup error-resistant markdown treesitter handling",
})

-- Add command to manually reset treesitter if needed
vim.api.nvim_create_user_command("TSReset", function()
  local bufnr = vim.api.nvim_get_current_buf()
  vim.treesitter.stop(bufnr)
  vim.defer_fn(function()
    vim.treesitter.start(bufnr)
    vim.notify("Treesitter reset for current buffer", vim.log.levels.INFO)
  end, 100)
end, { desc = "Reset treesitter for current buffer" })

-- Workaround for treesitter highlighter out of range errors
-- This wraps the problematic function to handle invalid positions gracefully
local original_nvim_buf_set_extmark = vim.api.nvim_buf_set_extmark
---@diagnostic disable-next-line: duplicate-set-field
vim.api.nvim_buf_set_extmark = function(buffer, ns_id, line, col, opts)
  local ok, result = pcall(original_nvim_buf_set_extmark, buffer, ns_id, line, col, opts)
  if not ok then
    -- Silently ignore out of range errors from treesitter highlighter
    local err = tostring(result)
    if err:match("Invalid 'end_col': out of range") or err:match("Invalid 'col': out of range") then
      return 0 -- Return a dummy extmark id
    else
      -- Re-throw other errors
      error(result)
    end
  end
  return result
end

-- Workaround for treesitter get_offset errors when deleting code fences
local ts_utils = vim.treesitter.get_node
---@diagnostic disable-next-line: duplicate-set-field
vim.treesitter.get_node = function(...)
  local ok, result = pcall(ts_utils, ...)
  if not ok then
    return nil
  end
  return result
end

-- Additional protection for treesitter highlighter errors
autocmd("FileType", {
  pattern = { "markdown", "markdown.pandoc" },
  group = augroup("TreesitterMarkdownFix", { clear = true }),
  callback = function()
    -- Defer to ensure treesitter is loaded
    vim.defer_fn(function()
      local bufnr = vim.api.nvim_get_current_buf()

      -- Wrap the decoration provider to catch errors
      local ns = vim.api.nvim_get_namespaces()["nvim.treesitter.highlighter"]
      if ns then
        -- Override the decoration provider
        ---@diagnostic disable-next-line: unused-local
        local orig_provider = vim.api.nvim_buf_get_extmarks

        -- Create a safe wrapper for get_offset
        local ts = vim.treesitter
        if ts._range and ts._range.get_range then
          local orig_get_range = ts._range.get_range
          ts._range.get_range = function(...)
            local ok, result = pcall(orig_get_range, ...)
            if not ok then
              return nil
            end
            return result
          end
        end
      end

      -- Also wrap the highlighter's on_line method
      local highlighter = vim.treesitter.highlighter
      if highlighter and highlighter.active and highlighter.active[bufnr] then
        local hl = highlighter.active[bufnr]
        if hl.on_line_impl then
          local orig_on_line = hl.on_line_impl
          ---@diagnostic disable-next-line: inject-field
          hl.on_line_impl = function(self, ...)
            local ok, result = pcall(orig_on_line, self, ...)
            if not ok then
              -- Silently ignore errors
              return
            end
            return result
          end
        end
      end
    end, 100)
  end,
  desc = "Add error handling for treesitter in markdown files",
})

-- Ensure terminal cursor visibility
local terminal_cursor_group = augroup("TerminalCursor", { clear = true })

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
    -- Restore normal mode cursor to block shape
    vim.opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"
      .. ",a:blinkwait700-blinkoff400-blinkon250"
      .. ",sm:block-blinkwait175-blinkoff150-blinkon175"
  end,
  desc = "Restore cursor to block shape when leaving terminal",
})

-- Ensure cursor is restored when entering normal buffers from terminal
autocmd({ "BufEnter", "WinEnter" }, {
  group = terminal_cursor_group,
  callback = function()
    -- Only restore if we're entering a non-terminal buffer
    if vim.bo.buftype ~= "terminal" then
      vim.opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"
        .. ",a:blinkwait700-blinkoff400-blinkon250"
        .. ",sm:block-blinkwait175-blinkoff150-blinkon175"
    end
  end,
  desc = "Ensure cursor is restored when entering non-terminal buffers",
})

-- Force cursor restoration after terminal closes
autocmd({ "TermClose" }, {
  group = terminal_cursor_group,
  callback = function()
    vim.defer_fn(function()
      -- Restore cursor shape after terminal closes
      vim.opt.guicursor = "n-v-c:block,i-ci-ve:ver25,r-cr:hor20,o:hor50"
        .. ",a:blinkwait700-blinkoff400-blinkon250"
        .. ",sm:block-blinkwait175-blinkoff150-blinkon175"
    end, 50)
  end,
  desc = "Force cursor restoration after terminal closes",
})

-- =============================================================================
-- MARKDOWN ENHANCEMENTS
-- =============================================================================

-- Advanced syntax highlighting for markdown with embedded code blocks
local markdown_group = augroup("MarkdownEnhancements", { clear = true })

autocmd("FileType", {
  group = markdown_group,
  pattern = { "markdown", "md" },
  callback = function()
    -- Enable treesitter highlighting for embedded code blocks
    vim.opt_local.conceallevel = 2
    -- Set concealcursor to "nc" to avoid concealment issues in insert mode
    -- n = normal mode, c = command line mode (no concealment in insert/visual modes)
    vim.opt_local.concealcursor = "nc"

    -- Set up syntax highlighting for code blocks with enhanced visual borders
    vim.cmd([[
      " Define custom highlight groups for code block borders
      highlight CodeBlockBorder guifg=#30363d gui=bold
      highlight CodeBlockBackground guibg=#161b22
      highlight CodeBlockLang guifg=#ffa657 gui=bold,italic guibg=#161b22

      " Python syntax
      syntax include @pythonSyntax syntax/python.vim
      syntax region markdownPythonCode start="```python" end="```" contains=@pythonSyntax keepend

      " JavaScript syntax
      syntax include @javascriptSyntax syntax/javascript.vim
      syntax region markdownJavaScriptCode start="```javascript" end="```" contains=@javascriptSyntax keepend
      syntax region markdownJavaScriptCode start="```js" end="```" contains=@javascriptSyntax keepend

      " Bash syntax
      syntax include @bashSyntax syntax/bash.vim
      syntax region markdownBashCode start="```bash" end="```" contains=@bashSyntax keepend
      syntax region markdownBashCode start="```sh" end="```" contains=@bashSyntax keepend

      " Lua syntax
      syntax include @luaSyntax syntax/lua.vim
      syntax region markdownLuaCode start="```lua" end="```" contains=@luaSyntax keepend

      " Vim syntax
      syntax include @vimSyntax syntax/vim.vim
      syntax region markdownVimCode start="```vim" end="```" contains=@vimSyntax keepend

      " JSON syntax
      syntax include @jsonSyntax syntax/json.vim
      syntax region markdownJsonCode start="```json" end="```" contains=@jsonSyntax keepend

      " YAML syntax
      syntax include @yamlSyntax syntax/yaml.vim
      syntax region markdownYamlCode start="```yaml" end="```" contains=@yamlSyntax keepend

      " HTML syntax
      syntax include @htmlSyntax syntax/html.vim
      syntax region markdownHtmlCode start="```html" end="```" contains=@htmlSyntax keepend

      " CSS syntax
      syntax include @cssSyntax syntax/css.vim
      syntax region markdownCssCode start="```css" end="```" contains=@cssSyntax keepend

      " Rust syntax
      syntax include @rustSyntax syntax/rust.vim
      syntax region markdownRustCode start="```rust" end="```" contains=@rustSyntax keepend

      " Go syntax
      syntax include @goSyntax syntax/go.vim
      syntax region markdownGoCode start="```go" end="```" contains=@goSyntax keepend

      " TypeScript syntax
      syntax include @typescriptSyntax syntax/typescript.vim
      syntax region markdownTypeScriptCode start="```typescript" end="```" contains=@typescriptSyntax keepend
      syntax region markdownTypeScriptCode start="```ts" end="```" contains=@typescriptSyntax keepend

      " Enhanced code block delimiters with box drawing
      syntax match markdownCodeBlockDelimiter /^```.*$/ contains=markdownCodeBlockLang
      syntax match markdownCodeBlockLang /```\zs\w\+/ contained
      highlight markdownCodeBlockDelimiter guifg=#48cae4 gui=bold
      highlight markdownCodeBlockLang guifg=#ffa657 gui=bold,italic guibg=#161b22
    ]])

    -- Removed code block border signs that were interfering with sign column
  end,
})

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
    vim.opt_local.colorcolumn = "100"
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
    vim.opt_local.colorcolumn = "100"
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
    vim.opt_local.colorcolumn = "100"
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
    vim.opt_local.colorcolumn = "100"
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
    vim.opt_local.colorcolumn = "100"
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
    vim.opt_local.colorcolumn = "100"
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
    vim.opt_local.colorcolumn = "100"
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
    vim.opt_local.colorcolumn = "100"
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
    vim.opt_local.colorcolumn = "100"
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
    vim.opt_local.colorcolumn = "100"
  end,
})

-- Markdown (Common convention: 2 spaces, wider text)
autocmd("FileType", {
  group = google_style_group,
  pattern = { "markdown", "pandoc", "rst" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
    vim.opt_local.textwidth = 100
    vim.opt_local.colorcolumn = "100"
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
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

-- Removed duplicate markdown settings - handled by markdown_settings above

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
  "setlocal textwidth=0", -- No hard line breaks
  "setlocal wrapmargin=0", -- No wrap margin
  "setlocal formatoptions-=t", -- Don't auto-wrap text
  "setlocal formatoptions+=l", -- Don't break long lines in insert mode
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
    for _, setting in ipairs(markdown_settings) do
      vim.cmd(setting)
    end

    -- Font settings for GUI vim (JetBrainsMono has better Haskell ligatures than Hasklug)
    if vim.fn.has("gui_running") == 1 then
      vim.cmd("setlocal guifont=JetBrainsMono\\ Nerd\\ Font:h14")
    end

    -- Improved navigation for wrapped lines
    local buf_opts = { buffer = true, noremap = true, silent = true }
    vim.keymap.set("n", "j", "gj", buf_opts)
    vim.keymap.set("n", "k", "gk", buf_opts)
    vim.keymap.set("n", "0", "g0", buf_opts)
    vim.keymap.set("n", "$", "g$", buf_opts)
    vim.keymap.set("v", "j", "gj", buf_opts)
    vim.keymap.set("v", "k", "gk", buf_opts)
    vim.keymap.set("v", "0", "g0", buf_opts)
    vim.keymap.set("v", "$", "g$", buf_opts)
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

-- Note: Language-specific run commands have been moved to commands.lua RunFile command

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

-- Auto reload for specific file types (immediate reload without prompt)
autocmd({ "FileChangedShell" }, {
  group = autoreload_group,
  pattern = "*",
  callback = function()
    -- Auto reload if file wasn't modified in vim
    if not vim.bo.modified then
      vim.cmd("edit!")
      vim.notify("File auto-reloaded (external change detected)", vim.log.levels.INFO)
    end
  end,
  desc = "Auto reload unmodified files",
})

-- More aggressive checking for terminal users
if vim.env.TERM_PROGRAM == "Alacritty" or vim.env.TERM then
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

autocmd("ColorScheme", {
  group = lsp_highlight_group,
  pattern = "*",
  callback = function()
    -- Make LSP references more visible with a subtle background highlight
    vim.api.nvim_set_hl(0, "LspReferenceText", { bg = "#3b3b3b", underline = false })
    vim.api.nvim_set_hl(0, "LspReferenceRead", { bg = "#3b3b3b", underline = false })
    vim.api.nvim_set_hl(0, "LspReferenceWrite", { bg = "#4b3b3b", underline = false })
  end,
  desc = "Set LSP reference highlight colors",
})

-- Apply highlight groups immediately
vim.api.nvim_set_hl(0, "LspReferenceText", { bg = "#3b3b3b", underline = false })
vim.api.nvim_set_hl(0, "LspReferenceRead", { bg = "#3b3b3b", underline = false })
vim.api.nvim_set_hl(0, "LspReferenceWrite", { bg = "#4b3b3b", underline = false })

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
      local git_repo =
        vim.fn.system("git rev-parse --show-toplevel 2>/dev/null | xargs basename"):gsub("\n", "")
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
      -- Use Treesitter for highlighting if available
      if pcall(require, "nvim-treesitter.configs") then
        -- Ensure starlark parser is installed and active
        local ts_parsers = require("nvim-treesitter.parsers")
        if ts_parsers.has_parser("starlark") then
          vim.treesitter.start(0, "starlark")
        else
          -- Fallback to traditional syntax if treesitter not available
          vim.cmd("syntax on")
          vim.cmd("syntax sync fromstart")
        end
      else
        -- Fallback to traditional syntax
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
-- TREESITTER SAFETY - Ensure parsers are installed
-- =============================================================================

-- Auto-install markdown parser if it fails
vim.api.nvim_create_autocmd({ "BufRead", "BufNewFile" }, {
  pattern = { "*.md", "*.markdown" },
  callback = function()
    -- Check if markdown parser is available
    local ok, parsers = pcall(require, "nvim-treesitter.parsers")
    if ok then
      local has_parser = parsers.has_parser("markdown")
      if not has_parser then
        -- Try to install it silently
        vim.defer_fn(function()
          vim.cmd("silent! TSInstall markdown markdown_inline")
        end, 100)
      end
    end
  end,
  desc = "Auto-install markdown treesitter parser if missing",
})

-- =============================================================================
-- TABLINE - Now handled by bufferline.nvim plugin
-- =============================================================================
-- Tabline functionality moved to bufferline.nvim for better buffer overflow handling
