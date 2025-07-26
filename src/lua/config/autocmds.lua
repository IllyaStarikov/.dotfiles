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

-- Python specific settings - enforce 2-space indentation
local python_group = augroup("python_indent", { clear = true })

autocmd("FileType", {
  group = python_group,
  pattern = "python",
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
  end
})

-- Re-enforce Python indentation after any buffer write or format
autocmd({"BufWritePost", "User"}, {
  group = python_group,
  pattern = "*.py",
  callback = function()
    if vim.bo.filetype == "python" then
      vim.opt_local.shiftwidth = 2
      vim.opt_local.tabstop = 2
      vim.opt_local.softtabstop = 2
      vim.opt_local.expandtab = true
    end
  end
})

-- Also enforce on any LSP format or external command
autocmd("User", {
  group = python_group,
  pattern = "FormatterPost",
  callback = function()
    if vim.bo.filetype == "python" then
      vim.opt_local.shiftwidth = 2
      vim.opt_local.tabstop = 2
      vim.opt_local.softtabstop = 2
      vim.opt_local.expandtab = true
    end
  end
})

-- Enforce Python indentation after buffer writes
autocmd({"BufWritePre", "BufWritePost"}, {
  group = python_group,
  pattern = "*.py",
  callback = function()
    if vim.bo.filetype == "python" then
      vim.opt_local.shiftwidth = 2
      vim.opt_local.tabstop = 2
      vim.opt_local.softtabstop = 2
      vim.opt_local.expandtab = true
    end
  end
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

-- Skeleton files group - modern LuaSnip based auto-insertion
local skeleton_group = augroup("skeleton_files", { clear = true })

-- Helper function to get skeleton content directly
local function get_skeleton_content(filetype, context)
  local date = os.date('%Y-%m-%d')
  local year = os.date('%Y')
  local filename = vim.fn.expand('%:t') or 'untitled'
  local project = vim.fn.expand('%:p:h:t') or 'project'
  
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
      "  level=logging.INFO,",
      "  format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'",
      ")",
      "logger = logging.getLogger(__name__)",
      "",
      "",
      "def main() -> int:",
      '  """',
      "  Main function entry point.",
      "",
      "  Returns:",
      "    int: Exit code (0 for success, non-zero for failure)",
      '  """',
      "  parser = argparse.ArgumentParser(",
      "    description='" .. (context.description or "Script description") .. "'",
      "  )",
      "",
      "  # Add command line arguments",
      "  parser.add_argument(",
      "    '-v', '--verbose',",
      "    action='store_true',",
      "    help='Enable verbose logging'",
      "  )",
      "",
      "  args = parser.parse_args()",
      "",
      "  # Set logging level based on verbosity",
      "  if args.verbose:",
      "    logger.setLevel(logging.DEBUG)",
      "",
      "  try:",
      "    # Main logic here",
      "    logger.info('Starting...')",
      "    # TODO: Add your implementation here",
      "",
      "    logger.info('Completed successfully')",
      "    return 0",
      "",
      "  except Exception as e:",
      "    logger.error(f'Error: {e}')",
      "    return 1",
      "",
      "",
      'if __name__ == "__main__":',
      "    sys.exit(main())",
      ""
    }
  elseif filetype == "shell" then
    return {
      "#!/bin/bash",
      "#",
      "# " .. (context.description or "Script description"),
      "#",
      "# Author: " .. (context.author or "Illya Starikov"),
      "# Date: " .. date,
      "# Copyright (c) " .. year .. " " .. (context.author or "Illya Starikov") .. ". All rights reserved.",
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
      '# Only run main if script is executed directly (not sourced)',
      'if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then',
      '  main "$@"',
      "fi",
      ""
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
      '  <title>' .. (context.title or "Page Title") .. '</title>',
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
      "    <p>&copy; " .. year .. " " .. (context.author or "Illya Starikov") .. ". All rights reserved.</p>",
      "  </footer>",
      "",
      '  <script src="script.js"></script>',
      "</body>",
      "</html>",
      ""
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
        ""
      }
    else
      return {
        "---",
        'title: "' .. (context.title or "Document Title") .. '"',
        'author: "' .. (context.author or "Illya Starikov") .. '"',
        'date: "' .. date .. '"',
        "tags: []",
        "categories: []",
        "---",
        "",
        "# " .. (context.title or "Document Title"),
        "",
        context.description or "Brief introduction or overview.",
        ""
      }
    end
  elseif filetype == "javascript" then
    return {
      "/**",
      " * " .. (context.description or "Module description"),
      " *",
      " * Author: " .. (context.author or "Illya Starikov"),
      " * Date: " .. date,
      " * Copyright (c) " .. year .. " " .. (context.author or "Illya Starikov") .. ". All rights reserved.",
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
      ""
    }
  elseif filetype == "c" then
    return {
      "//",
      "//  " .. filename,
      "//  " .. project,
      "//",
      "//  Created by " .. (context.author or "Illya Starikov") .. " on " .. date .. ".",
      "//  Copyright " .. year .. ". " .. (context.author or "Illya Starikov") .. ". All rights reserved.",
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
      ""
    }
  elseif filetype == "java" then
    local classname = filename:gsub("%.java$", ""):gsub("^%l", string.upper)
    return {
      "/*",
      " * Copyright " .. year .. " " .. (context.author or "Illya Starikov"),
      " *",
      " * Licensed under the Apache License, Version 2.0 (the \"License\");",
      " * you may not use this file except in compliance with the License.",
      " * You may obtain a copy of the License at",
      " *",
      " *     http://www.apache.org/licenses/LICENSE-2.0",
      " *",
      " * Unless required by applicable law or agreed to in writing, software",
      " * distributed under the License is distributed on an \"AS IS\" BASIS,",
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
      "  private static final Logger logger = Logger.getLogger(" .. classname .. ".class.getName());",
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
      ""
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
      ""
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
      ""
    }
  end
  
  return {"# TODO: Add skeleton for " .. filetype}
end

-- Helper function to insert skeleton content
local function insert_skeleton(filetype, context)
  -- Only insert if the buffer is completely empty
  local line_count = vim.api.nvim_buf_line_count(0)
  local first_line = vim.api.nvim_buf_get_lines(0, 0, 1, false)[1] or ""
  
  if line_count == 1 and first_line == "" then
    local content = get_skeleton_content(filetype, context or {})
    vim.api.nvim_buf_set_lines(0, 0, 1, false, content)
    
    -- Position cursor at first TODO or at end of first editable line
    for i, line in ipairs(content) do
      if line:match("TODO") or line:match("Module description") or line:match("Script description") then
        vim.api.nvim_win_set_cursor(0, {i, 0})
        break
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
        vim.api.nvim_win_set_cursor(0, {current_pos[1], current_pos[2]})
        
        -- Final redraw
        vim.cmd("redraw!")
        
        -- Trigger buffer text changed events that Snacks might listen to
        vim.cmd("doautocmd TextChanged")
        vim.cmd("doautocmd TextChangedI")
      end)
    end)
  end
end

-- Helper function to check for trailing spaces in skeleton content
local function check_skeleton_linting(filetype)
  local content = get_skeleton_content(filetype, {})
  local issues = {}
  
  for i, line in ipairs(content) do
    -- Check for trailing spaces
    if line:match("%s+$") and line ~= "" then
      table.insert(issues, "Line " .. i .. ": Trailing spaces found: '" .. line .. "'")
    end
    -- Check for tabs instead of spaces
    if line:match("\t") then
      table.insert(issues, "Line " .. i .. ": Tab character found (should use spaces)")
    end
  end
  
  return issues
end

-- Create user command to test skeleton linting
vim.api.nvim_create_user_command("CheckSkeletonLint", function(opts)
  local filetype = opts.args
  if filetype == "" then
    filetype = "python" -- default
  end
  
  local issues = check_skeleton_linting(filetype)
  if #issues == 0 then
    print("✓ Skeleton for " .. filetype .. " is clean (no linting issues)")
  else
    print("✗ Found " .. #issues .. " linting issues in " .. filetype .. " skeleton:")
    for _, issue in ipairs(issues) do
      print("  " .. issue)
    end
  end
end, {
  nargs = "?",
  desc = "Check skeleton template for linting issues",
  complete = function()
    return {"python", "shell", "javascript", "html", "markdown", "c", "java", "react", "latex"}
  end
})

-- Python files
autocmd("BufNewFile", {
  group = skeleton_group,
  pattern = "*.py",
  callback = function()
    insert_skeleton("python")
  end
})

-- Shell scripts
autocmd("BufNewFile", {
  group = skeleton_group,
  pattern = {"*.sh", "*.bash"},
  callback = function()
    insert_skeleton("shell")
  end
})

-- JavaScript files
autocmd("BufNewFile", {
  group = skeleton_group,
  pattern = {"*.js", "*.mjs"},
  callback = function()
    insert_skeleton("javascript")
  end
})

-- React components (JSX/TSX)
autocmd("BufNewFile", {
  group = skeleton_group,
  pattern = {"*.jsx", "*.tsx"},
  callback = function()
    insert_skeleton("react")
  end
})

-- LaTeX documents
autocmd("BufNewFile", {
  group = skeleton_group,
  pattern = "*.tex",
  callback = function()
    insert_skeleton("latex")
  end
})

-- Markdown files
autocmd("BufNewFile", {
  group = skeleton_group,
  pattern = {"*.md", "*.markdown"},
  callback = function()
    insert_skeleton("markdown")
  end
})

-- C/C++ files
autocmd("BufNewFile", {
  group = skeleton_group,
  pattern = {"*.c", "*.cpp", "*.cc", "*.cxx"},
  callback = function()
    insert_skeleton("c")
  end
})

-- Java files
autocmd("BufNewFile", {
  group = skeleton_group,
  pattern = "*.java",
  callback = function()
    insert_skeleton("java")
  end
})

-- HTML files
autocmd("BufNewFile", {
  group = skeleton_group,
  pattern = {"*.html", "*.htm"},
  callback = function()
    insert_skeleton("html")
  end
})