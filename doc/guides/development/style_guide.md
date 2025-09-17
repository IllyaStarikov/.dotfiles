# Neovim Style Guide Configuration

This document summarizes the coding style standards configured in Neovim, following industry-standard style guides.

## Language-Specific Settings

All settings are automatically applied when opening files of the corresponding type.

### Languages with 2-Space Indentation

| Language                  | Style Guide       | Column Limit | Notes                                      |
| ------------------------- | ----------------- | ------------ | ------------------------------------------ |
| **C/C++**                 | Industry standard | 80           | Includes `.c`, `.cpp`, `.cc`, `.h`, `.hpp` |
| **Shell/Bash**            | Industry standard | 80           | Includes `sh`, `bash`, `zsh`, `fish`       |
| **JavaScript/TypeScript** | Industry standard | 80           | Includes JSX/TSX, JSON                     |
| **HTML/CSS**              | Industry standard | 80           | Includes SCSS, SASS, LESS                  |
| **Swift**                 | Industry standard | 100          | Common convention                          |
| **Lua**                   | Industry standard | 80           | Common convention                          |
| **LaTeX**                 | Industry standard | 80           | With word wrap enabled                     |
| **Ruby**                  | Industry standard | 80           | Rails convention                           |
| **YAML/TOML**             | Industry standard | -            | Configuration files                        |
| **Markdown**              | Industry standard | 100          | With word wrap enabled                     |

### Languages with 4-Space Indentation

| Language   | Style Guide                                                   | Column Limit | Notes               |
| ---------- | ------------------------------------------------------------- | ------------ | ------------------- |
| **Python** | PEP 8 standard                                                | 80           | Industry convention |
| **Rust**   | [Official Rust Style](https://doc.rust-lang.org/1.0.0/style/) | 100          | rustfmt default     |

### Languages with Tab Indentation

| Language     | Style Guide                                                   | Notes              |
| ------------ | ------------------------------------------------------------- | ------------------ |
| **Go**       | [Official Go Style](https://golang.org/doc/effective_go.html) | gofmt enforced     |
| **Makefile** | Required by syntax                                            | Tabs are mandatory |

## Key Features

1. **Automatic Detection**: File type is automatically detected and appropriate settings are applied
2. **Column Indicators**: Visual guides at 80 or 100 characters (language-dependent)
3. **Smart Indentation**: Proper indent levels maintained when pressing Enter
4. **Spaces vs Tabs**: Automatically configured per language (spaces for most, tabs for Go/Make)

## LSP Integration

Language servers are configured to respect these settings:

- `clangd` for C/C++
- `pyright` for Python
- `gopls` for Go
- `rust_analyzer` for Rust
- `lua_ls` for Lua
- `texlab` for LaTeX

## Manual Override

To temporarily override settings for the current buffer:

```vim
:setlocal shiftwidth=4 tabstop=4
```

To check current settings:

```vim
:set shiftwidth? tabstop? expandtab?
```

## Format Command

Use the `:Format` command or the `format` shell script to automatically format files according to these standards.

## Python Linting

The Google Python Style Guide pylintrc is available at `styleguide/pylintrc`. This provides:

- PEP 8 compliance checking
- Consistent error and warning detection
- Best practices enforcement

Run pylint using the Google style guide:

```bash
pylint --rcfile=~/.dotfiles/styleguide/pylintrc myfile.py
```

The format script will automatically run pylint if it's installed.
