# Format Script Guide

The `format` script is a universal code formatter that combines file operations (like removing trailing whitespace) with language-specific formatters.

## Installation

The script is automatically available in your PATH after sourcing `.zshrc`. You can also use the `fmt` alias.

### Required formatters

Install the formatters you need:

```bash
# C/C++ formatter
brew install clang-format

# Python formatters (Google standard: 4 spaces)
pip install ruff      # Recommended - fast, modern, follows PEP8/Google style
pip install black     # Popular alternative, opinionated formatter
pip install yapf      # Google's formatter with explicit Google style support
pip install autopep8  # Traditional PEP8 formatter

# Shell script formatter
brew install shfmt

# Lua formatter
brew install stylua

# JavaScript/TypeScript/Web formatter
npm install -g prettier
# Or the faster daemon version:
npm install -g @fsouza/prettierd
```

## Usage

```bash
# Format all tracked files in the repository
format

# Format a specific file
format main.cpp

# Format with specific operations only
format -t file.txt          # Remove trailing whitespace only
format -T file.py           # Convert tabs to spaces only
format -q document.md       # Normalize smart quotes only
format -f src/              # Apply language formatters only

# Combine operations
format -t -T *.py          # Remove trailing whitespace and convert tabs

# Dry run to see what would change
format -n --all

# Use the alias
fmt main.cpp
```

## In Neovim

The `:Format` command now uses this shell script:

```vim
:Format                    " Format current file with all operations
:Format trailing          " Remove trailing whitespace only
:Format tabs              " Convert tabs to spaces only
:Format quotes            " Normalize quotes only
:Format formatters        " Apply language formatters only
:Format all               " Apply all operations (default)
```

## Supported Languages

All languages follow the official [Google Style Guides](https://google.github.io/styleguide/):

| Language | Formatter | Style Guide |
|----------|-----------|-------------|
| C/C++ | clang-format | [Google C++ Style](https://google.github.io/styleguide/cppguide.html): 2 spaces, 80 column limit |
| Python | ruff/black/yapf | [Google Python Style](https://google.github.io/styleguide/pyguide.html): 4 spaces, 80 column limit |
| Shell | shfmt | [Google Shell Style](https://google.github.io/styleguide/shellguide.html): 2 spaces |
| JavaScript/TypeScript | prettier/prettierd | [Google JS Style](https://google.github.io/styleguide/jsguide.html): 2 spaces, single quotes, 80 column |
| Lua | stylua | 2 spaces, 80 column limit |
| JSON/YAML | prettier/prettierd | 2 spaces |
| HTML/CSS/SCSS | prettier/prettierd | 2 spaces |
| Markdown | prettier/prettierd | 80 column limit |

## Configuration

Edit `~/.dotfiles/src/scripts/.formatrc` to customize formatter settings.

## Features

1. **File Operations**:
   - Remove trailing whitespace
   - Convert tabs to spaces (respects file type conventions)
   - Normalize smart quotes to regular quotes

2. **Language Formatters**:
   - Automatically detects file type
   - Applies appropriate formatter
   - Suggests installation if formatter is missing

3. **Smart Defaults**:
   - Uses 4 spaces for Python (Google Python Style)
   - Uses 2 spaces for all other languages (Google standard)
   - Skips binary files automatically

4. **Git Integration**:
   - If no files specified, formats all tracked files
   - Respects `.gitignore` patterns