--
-- config/autocmds.lua
-- Autocommands (migrated from vimscript)
--

local autocmd = vim.api.nvim_create_autocmd
local augroup = vim.api.nvim_create_augroup

-- Helper functions (migrated from vimscript functions)
local function trim_whitespace()
  local save = vim.fn.winsaveview()
  vim.cmd([[%s/\t/    /ge]])
  vim.cmd([[%s/\s\+$//ge]])
  vim.fn.winrestview(save)
end

local function normalize_markdown()
  local save = vim.fn.winsaveview()
  vim.cmd([[%s/'/'/ge]])
  vim.cmd([[%s/"/"/ge]])
  vim.cmd([[%s/"/"/ge]])
  vim.cmd([[%s/"/"/ge]])
  vim.fn.winrestview(save)
end

-- Create user commands for functions
vim.api.nvim_create_user_command("TrimWhitespace", trim_whitespace, {})
vim.api.nvim_create_user_command("NormalizeMarkdown", normalize_markdown, {})

-- Normalize group - file processing rules
local normalize_group = augroup("normalize", { clear = true })

autocmd("FileType", {
  group = normalize_group,
  pattern = { "make", "makefile" },
  command = "set noexpandtab"
})

autocmd("BufWritePre", {
  group = normalize_group,
  pattern = "*",
  callback = function()
    local blocklist = { "make", "makefile", "snippets", "sh" }
    local ft = vim.bo.filetype
    for _, blocked_ft in ipairs(blocklist) do
      if ft == blocked_ft then
        return
      end
    end
    trim_whitespace()
  end
})

autocmd("BufWritePre", {
  group = normalize_group,
  pattern = "*.md",
  callback = normalize_markdown
})

-- Projects group - treat headers as C
local projects_group = augroup("projects", { clear = true })

autocmd({ "BufRead", "BufNewFile" }, {
  group = projects_group,
  pattern = { "*.h", "*.c" },
  command = "set filetype=c"
})

-- Python specific settings
autocmd("FileType", {
  pattern = "python",
  command = "setlocal shiftwidth=2 tabstop=2 softtabstop=2"
})

-- NERDTree group
local nerdtree_group = augroup("nerdtreehelp", { clear = true })

autocmd("VimEnter", {
  group = nerdtree_group,
  pattern = "*",
  command = "NERDTree"
})

autocmd("VimEnter", {
  group = nerdtree_group,
  pattern = "*",
  command = "wincmd p"
})

autocmd("BufEnter", {
  group = nerdtree_group,
  pattern = "*",
  callback = function()
    if vim.fn.winnr("$") == 1 and vim.b.NERDTree ~= nil and vim.b.NERDTree.isTabTree() then
      vim.cmd("q")
    end
  end
})

-- Syntax group - special highlighting for large files
local syntax_group = augroup("syntax", { clear = true })

autocmd("FileType", {
  group = syntax_group,
  pattern = { "tex", "latex", "markdown", "pandoc" },
  command = "set synmaxcol=2048"
})

autocmd({ "BufNewFile", "BufRead" }, {
  group = syntax_group,
  pattern = "*.tex",
  command = "set syntax=tex"
})

autocmd({ "BufNewFile", "BufRead" }, {
  group = syntax_group,
  pattern = "*.md",
  command = "set syntax=pandoc | set conceallevel=0"
})

-- Markdown writing group - special configuration for markdown files
local markdown_group = augroup("markdown_writing", { clear = true })

local markdown_settings = {
  "setlocal wrap",                    -- Enable word wrap
  "setlocal linebreak",               -- Break lines at word boundaries
  "setlocal nolist",                  -- Hide special characters for cleaner view
  "setlocal textwidth=0",             -- No hard line breaks
  "setlocal wrapmargin=0",            -- No wrap margin
  "setlocal formatoptions-=t",        -- Don't auto-wrap text
  "setlocal formatoptions+=l",        -- Don't break long lines in insert mode
  "setlocal display+=lastline",       -- Show partial wrapped lines
  "setlocal breakindent",             -- Indent wrapped lines
  "setlocal breakindentopt=shift:2,min:40",
  "setlocal spell",                   -- Enable spell check
  "setlocal nonumber",                -- Hide line numbers
  "setlocal norelativenumber",        -- Hide relative line numbers
  "setlocal colorcolumn=",            -- Remove color column
  "setlocal signcolumn=no"            -- Hide sign column
}

autocmd("FileType", {
  group = markdown_group,
  pattern = { "markdown", "pandoc" },
  callback = function()
    for _, setting in ipairs(markdown_settings) do
      vim.cmd(setting)
    end
    
    -- Font settings for GUI vim
    if vim.fn.has("gui_running") == 1 then
      vim.cmd("setlocal guifont=Verdana:h14")
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
  end
})

-- Code runner group
local run_group = augroup("run", { clear = true })

-- RunCode function
local function run_code(run_command)
  if vim.fn.filereadable("makefile") == 1 or vim.fn.filereadable("Makefile") == 1 then
    vim.cmd("AsyncRun make")
  else
    vim.cmd("AsyncRun " .. run_command)
  end
end

-- Create user command for RunCode
vim.api.nvim_create_user_command("RunCode", function(opts)
  run_code(opts.args)
end, { nargs = 1 })

local window_open = 1

autocmd("FileType", {
  group = run_group,
  pattern = { "tex", "plaintex" },
  callback = function()
    window_open = 0
  end
})

autocmd("QuickFixCmdPost", {
  group = run_group,
  pattern = "*",
  callback = function()
    vim.fn["asyncrun#quickfix_toggle"](8, window_open)
  end
})

-- Language-specific run commands
local run_commands = {
  python = "python3 %",
  c = "clang *.c -o driver && ./driver",
  cpp = "clang++ *.cpp -std=c++14 -o driver && ./driver",
  tex = "latexmk",
  plaintex = "latexmk",
  perl = "perl %",
  sh = "bash %",
  swift = "swift %"
}

for ft, cmd in pairs(run_commands) do
  autocmd("FileType", {
    group = run_group,
    pattern = ft,
    callback = function()
      vim.keymap.set("n", "<leader>r", function()
        run_code(cmd)
      end, { buffer = true })
    end
  })
end

-- Markdown run command (platform specific)
autocmd("FileType", {
  group = run_group,
  pattern = "markdown",
  callback = function()
    local cmd
    if vim.fn.has("macunix") == 1 then
      cmd = "pandoc --standalone --from=markdown --to=rtf % | pbcopy"
    else
      cmd = "pandoc % | xclip -t text/html -selection clipboard"
    end
    vim.keymap.set("n", "<leader>r", function()
      run_code(cmd)
    end, { buffer = true })
  end
})

-- Generic async run repeat
autocmd("FileType", {
  group = run_group,
  pattern = "*",
  callback = function()
    vim.keymap.set("n", "<leader>R", ":Async<Up><CR>", { buffer = true })
  end
})

-- Skeleton files group
local templates_group = augroup("templates", { clear = true })

autocmd("BufNewFile", {
  group = templates_group,
  pattern = "main.*",
  callback = function()
    local ext = vim.fn.expand("<afile>:e")
    vim.cmd("silent! execute '0r ~/.vim/plugged/skeleton-files/skeleton-main." .. ext .. "'")
  end
})

autocmd("BufNewFile", {
  group = templates_group,
  pattern = "*.*",
  callback = function()
    local ext = vim.fn.expand("<afile>:e")
    vim.cmd("silent! execute '0r ~/.vim/plugged/skeleton-files/skeleton." .. ext .. "'")
  end
})

autocmd("BufNewFile", {
  group = templates_group,
  pattern = "*",
  command = [[%substitute#\[:VIM_EVAL:\]\(.\{-\}\)\[:END_EVAL:\]#\=eval(submatch(1))#ge]]
})