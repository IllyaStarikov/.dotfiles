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

-- Markdown syntax highlighting enhancement
local markdown_group = augroup("MarkdownEnhancements", { clear = true })

autocmd("FileType", {
  group = markdown_group,
  pattern = { "markdown", "md" },
  callback = function()
    -- Enable treesitter highlighting for embedded code blocks
    vim.opt_local.conceallevel = 2
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
    
    -- Add signs for code block borders (visual left border)
    vim.fn.sign_define("CodeBlockBorder", { text = "│", texthl = "CodeBlockBorder" })
    
    -- Function to add visual borders to code blocks
    local function add_code_block_borders()
      local bufnr = vim.api.nvim_get_current_buf()
      local lines = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
      local in_code_block = false
      
      for i, line in ipairs(lines) do
        if line:match("^```") then
          in_code_block = not in_code_block
        elseif in_code_block then
          -- Add sign for visual left border
          vim.fn.sign_place(0, "CodeBlockBorderGroup", "CodeBlockBorder", bufnr, { lnum = i })
        end
      end
    end
    
    -- Apply borders on buffer changes (with error handling)
    local success, _ = pcall(function()
      vim.api.nvim_create_autocmd({ "BufEnter", "TextChanged", "InsertLeave" }, {
        buffer = vim.api.nvim_get_current_buf(),
        callback = function()
          pcall(add_code_block_borders)
        end
      })
    end)
    
    -- Initial border application
    add_code_block_borders()
  end
})

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


autocmd("BufEnter", {
  group = nerdtree_group,
  pattern = "*",
  callback = function()
    -- Close NERDTree if it's the last window and is a tab tree
    if vim.fn.winnr("$") == 1 and vim.fn.exists("b:NERDTree") == 1 then
      local nerdtree = vim.b.NERDTree
      if nerdtree and type(nerdtree) == "table" and nerdtree.isTabTree and nerdtree:isTabTree() then
        vim.cmd("q")
      end
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