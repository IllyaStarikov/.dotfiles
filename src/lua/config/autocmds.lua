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

-- Terminal cursor fix
autocmd({ "TermEnter" }, {
  group = augroup("TerminalCursorFix", { clear = true }),
  callback = function()
    vim.opt.guicursor = "a:ver25-blinkon1"
  end,
  desc = "Ensure cursor is visible in terminal mode"
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
  end
})

-- =============================================================================
-- FILE PROCESSING AUTOMATION
-- =============================================================================

-- Automated file normalization and cleanup
local normalize_group = augroup("normalize", { clear = true })

autocmd("FileType", {
  group = normalize_group,
  pattern = { "make", "makefile" },
  command = "set noexpandtab"
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
  command = "set filetype=c"
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
  end
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
    vim.opt_local.textwidth = 80
    vim.opt_local.colorcolumn = "80"
  end
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
    vim.opt_local.textwidth = 80
    vim.opt_local.colorcolumn = "80"
  end
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
  end
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
    vim.opt_local.textwidth = 80
    vim.opt_local.colorcolumn = "80"
  end
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
    vim.opt_local.textwidth = 80
    vim.opt_local.colorcolumn = "80"
    -- LaTeX-specific settings
    vim.opt_local.wrap = true
    vim.opt_local.linebreak = true
  end
})

-- JavaScript/TypeScript (Google JavaScript Style Guide: 2 spaces)
-- https://google.github.io/styleguide/jsguide.html
autocmd("FileType", {
  group = google_style_group,
  pattern = { "javascript", "javascriptreact", "typescript", "typescriptreact", "json", "jsonc" },
  callback = function()
    vim.opt_local.shiftwidth = 2
    vim.opt_local.tabstop = 2
    vim.opt_local.softtabstop = 2
    vim.opt_local.expandtab = true
    vim.opt_local.textwidth = 80
    vim.opt_local.colorcolumn = "80"
  end
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
    vim.opt_local.textwidth = 80
    vim.opt_local.colorcolumn = "80"
  end
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
  end
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
    vim.opt_local.textwidth = 80
    vim.opt_local.colorcolumn = "80"
  end
})

-- Go (Official Go style: tabs)
autocmd("FileType", {
  group = google_style_group,
  pattern = { "go" },
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
    vim.opt_local.expandtab = false  -- Go uses tabs
    vim.opt_local.textwidth = 80
    vim.opt_local.colorcolumn = "80"
  end
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
  end
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
  end
})

-- =============================================================================
-- SYNTAX OPTIMIZATIONS
-- =============================================================================

-- Performance optimizations for large files and special syntax handling
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
  local big_file_limit = 1024 * 1024 * 10  -- 10MB
  
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
    vim.notify("Big file detected. Disabled expensive features for performance.", vim.log.levels.INFO)
  end
end

-- Apply optimizations before reading large files
autocmd("BufReadPre", {
  group = bigfile_group,
  pattern = "*",
  callback = optimize_for_bigfile
})

-- Additional optimization for files with long lines
autocmd("BufWinEnter", {
  group = bigfile_group,
  pattern = "*",
  callback = function()
    local max_filesize = 100 * 1024  -- 100KB
    local ok, stats = pcall(vim.loop.fs_stat, vim.api.nvim_buf_get_name(0))
    if ok and stats and stats.size > max_filesize then
      vim.opt_local.wrap = false
      vim.opt_local.synmaxcol = 200
    end
  end
})

-- =============================================================================
-- MARKDOWN WRITING ENVIRONMENT
-- =============================================================================

-- Professional markdown writing configuration with optimized display settings
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
  "setlocal number",                  -- Show line numbers
  "setlocal relativenumber",          -- Show relative line numbers
  "setlocal colorcolumn=",            -- Remove color column
  "setlocal signcolumn=yes"           -- Show sign column
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
      vim.cmd("setlocal guifont=Hasklug\\ Nerd\\ Font:h14")
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
  end
})

autocmd("QuickFixCmdPost", {
  group = run_group,
  pattern = "*",
  callback = function()
    vim.fn["asyncrun#quickfix_toggle"](8, window_open)
  end
})

-- Note: Language-specific run commands have been moved to commands.lua RunFile command

-- Async run repeat for last command
autocmd("FileType", {
  group = run_group,
  pattern = "*",
  callback = function()
    vim.keymap.set("n", "<leader>R", ":AsyncRun<Up><CR>", { buffer = true, desc = "Repeat last async command" })
  end
})



-- =============================================================================
-- SPELL CHECKING CONFIGURATION
-- =============================================================================
-- Enable spell checking only for text-heavy file types to avoid performance issues
local spell_group = augroup("spell_check", { clear = true })

vim.api.nvim_create_autocmd("FileType", {
  group = spell_group,
  pattern = { "markdown", "tex", "latex", "plaintex", "text", "gitcommit", "rst" },
  callback = function()
    vim.opt_local.spell = true
    vim.opt_local.spelllang = "en_us"
  end,
  desc = "Enable spell checking for documentation files"
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

-- Markdown files - DISABLED due to display issues
-- autocmd("BufNewFile", {
--   group = skeleton_group,
--   pattern = {"*.md", "*.markdown"},
--   callback = function()
--     -- Only insert skeleton for truly new files, not existing ones
--     local lines = vim.api.nvim_buf_get_lines(0, 0, -1, false)
--     if #lines == 1 and lines[1] == "" then
--       insert_skeleton("markdown")
--     end
--   end
-- })

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

-- =============================================================================
-- DEBUG COMMANDS
-- =============================================================================

-- Additional debug commands can be added here
