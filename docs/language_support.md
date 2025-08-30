# Language Support Configuration

## Overview
This document details the comprehensive language support configuration for LSP (Language Server Protocol) and formatting via fixy.

## Supported Languages

### Web Development

#### HTML
- **LSP**: `html` (HTML Language Server)
- **Formatter**: `prettier`
- **Extensions**: `.html`, `.htm`
- **Status**: ✅ Fully configured

#### CSS/SCSS/SASS/LESS
- **LSP**: `cssls` (CSS Language Server)
- **Formatter**: `prettier`
- **Extensions**: `.css`, `.scss`, `.sass`, `.less`
- **Status**: ✅ Fully configured

#### JavaScript/TypeScript
- **LSP**: `ts_ls` (TypeScript Language Server)
- **Formatter**: `prettier` (primary), `eslint` (secondary)
- **Extensions**: `.js`, `.jsx`, `.ts`, `.tsx`
- **Special Support**: Ghost.js, React, Vue, Svelte frameworks
- **Status**: ✅ Fully configured

#### JSON
- **LSP**: `jsonls` (JSON Language Server)
- **Formatter**: `prettier`
- **Extensions**: `.json`
- **Features**: Schema validation for package.json, tsconfig.json, eslintrc
- **Status**: ✅ Fully configured

#### Markdown
- **LSP**: `marksman` (Markdown Language Server)
- **Formatter**: `prettier`
- **Extensions**: `.md`, `.mdx`
- **Status**: ✅ Fully configured

### Document Processing

#### LaTeX/TeX
- **LSP**: `texlab` (LaTeX Language Server)
- **Formatter**: `latexindent`
- **Extensions**: `.tex`, `.latex`, `.bib`
- **Status**: ✅ Fully configured

#### XML/SVG
- **LSP**: `lemminx` (XML Language Server)
- **Formatter**: `prettier` (primary), `xmllint` (fallback)
- **Extensions**: `.xml`, `.svg`
- **Status**: ✅ Fully configured

### Data Formats

#### CSV/TSV
- **LSP**: None (plain text)
- **Formatter**: `text-formatter` (basic normalization)
- **Extensions**: `.csv`, `.tsv`
- **Status**: ✅ Fully configured

#### YAML
- **LSP**: `yamlls` (YAML Language Server)
- **Formatter**: `prettier`
- **Extensions**: `.yaml`, `.yml`
- **Features**: GitHub Actions schema validation, Docker Compose schema
- **Status**: ✅ Fully configured

#### TOML
- **LSP**: `taplo` (TOML Language Server)
- **Formatter**: `taplo` (primary), `toml-sort` (secondary)
- **Extensions**: `.toml`
- **Status**: ✅ Fully configured

### Systems Programming

#### C/C++
- **LSP**: `clangd` (LLVM C/C++ Language Server)
- **Formatter**: `clang-format` (primary), `astyle` (fallback)
- **Extensions**: `.c`, `.h`, `.cpp`, `.cc`, `.cxx`, `.hpp`, `.hxx`
- **Features**: Background indexing, header insertion
- **Status**: ✅ Fully configured

#### Swift
- **LSP**: `sourcekit` (Swift Language Server)
- **Formatter**: `swiftformat`
- **Extensions**: `.swift`
- **Status**: ✅ Fully configured (macOS only)

#### Rust
- **LSP**: `rust_analyzer` (Rust Language Server)
- **Formatter**: `rustfmt`
- **Extensions**: `.rs`
- **Features**: Clippy integration for linting
- **Status**: ✅ Fully configured

#### Assembly
- **LSP**: `zls` (Can handle assembly)
- **Formatter**: `asmfmt` (primary), `nasm` (assembler)
- **Extensions**: `.asm`, `.s`, `.S`
- **Status**: ✅ Fully configured

### Scripting Languages

#### Python
- **LSP**: `pyright` (Microsoft Python Language Server)
- **Formatter**: `ruff` (primary), `black` (secondary), `yapf`, `autopep8` (fallbacks)
- **Additional**: `isort` for import sorting
- **Extensions**: `.py`, `.pyw`, `.pyi`
- **Status**: ✅ Fully configured

#### Lua
- **LSP**: `lua_ls` (Lua Language Server)
- **Formatter**: `stylua` (with custom config)
- **Extensions**: `.lua`
- **Status**: ✅ Fully configured

#### Shell/Bash/Zsh
- **LSP**: `bashls` (Bash Language Server)
- **Formatter**: `shfmt`
- **Extensions**: `.sh`, `.bash`, `.zsh`
- **Status**: ✅ Fully configured

#### Ruby
- **LSP**: `solargraph` (Ruby Language Server)
- **Formatter**: `rubocop` (primary), `rufo` (secondary)
- **Extensions**: `.rb`, `.rake`, `.gemspec`
- **Status**: ⚠️ LSP configured, formatters need Ruby 3.0+

#### Perl
- **LSP**: `perlnavigator` (Perl Language Server)
- **Formatter**: `perltidy`
- **Extensions**: `.pl`, `.pm`
- **Status**: ✅ Fully configured

### Build Systems

#### Make
- **LSP**: None (plain text)
- **Formatter**: `text-formatter`
- **Extensions**: `Makefile`, `.mk`, `makefile`
- **Status**: ✅ Fully configured

#### CMake
- **LSP**: `cmake` (CMake Language Server)
- **Formatter**: `cmake-format`
- **Extensions**: `.cmake`, `CMakeLists.txt`
- **Status**: ✅ Fully configured

### Database

#### SQL/PostgreSQL
- **LSP**: `sqlls` (SQL Language Server)
- **Formatter**: `sqlformat` (primary), `pg_format` (PostgreSQL specific)
- **Extensions**: `.sql`
- **Status**: ✅ Fully configured

### Other Languages

#### Go
- **LSP**: `gopls` (Go Language Server)
- **Formatter**: `goimports` (primary), `gofmt` (fallback)
- **Extensions**: `.go`
- **Status**: ✅ Fully configured

#### GraphQL
- **LSP**: Supported via `ts_ls`
- **Formatter**: `prettier`
- **Extensions**: `.graphql`, `.gql`
- **Status**: ✅ Fully configured

## Installation Commands

### Install Missing Formatters
```bash
# Python formatters
pip install ruff black yapf autopep8 isort sqlformat cmake-format toml-sort

# Web formatters  
brew install prettier

# System formatters
brew install clang-format shfmt swiftformat taplo

# Go formatters
go install golang.org/x/tools/cmd/goimports@latest

# Ruby formatters (requires Ruby 3.0+)
gem install rubocop rufo

# Perl formatters
cpan install Perl::Tidy
```

### Install LSP Servers via Mason
All LSP servers are automatically installed via Mason when you open Neovim. Manual installation:
```vim
:MasonInstall pyright clangd lua_ls marksman texlab ts_ls rust_analyzer gopls 
:MasonInstall dockerls yamlls jsonls html cssls emmet_ls lemminx cmake
:MasonInstall bashls zls solargraph taplo perlnavigator sqlls sourcekit
```

## Usage

### Format Files
```bash
# Format any supported file
fixy file.py
fixy file.js
fixy file.rs

# Format with specific operations
fixy --all file.cpp        # All normalizations + formatting
fixy --formatters file.go  # Only run language formatters
fixy --trailing file.sh    # Only remove trailing whitespace
```

### LSP Features
In Neovim, LSP features are automatically available:
- `gd` - Go to definition
- `gr` - Find references
- `K` - Hover documentation
- `<F2>` - Rename symbol
- `<F4>` - Code actions
- `gl` - Show diagnostics

## Configuration Files

### Formatter Configuration
- **Location**: `~/.dotfiles/config/fixy.json`
- **Purpose**: Defines formatter priorities and settings

### LSP Configuration
- **Location**: `~/.dotfiles/src/neovim/config/lsp/servers.lua`
- **Purpose**: Configures LSP servers and their settings

### Custom Formatter Configs
- **Stylua**: `~/.dotfiles/.stylua.toml` (Lua formatting)
- **Clang-format**: Uses inline Google style configuration

## Troubleshooting

### Formatter Not Working
1. Check if formatter is installed: `which <formatter>`
2. Check fixy config: `jq '.formatters.<formatter>' ~/.dotfiles/config/fixy.json`
3. Run with verbose: `fixy --verbose file.ext`

### LSP Not Working
1. Check Mason installation: `:Mason` in Neovim
2. Check LSP status: `:LspInfo` in Neovim
3. Check health: `:checkhealth lsp`

### Performance Issues
- Some formatters like `prettier` can be slow
- Consider using `prettierd` (daemon version) for faster formatting
- Disable format on save for large files

## Notes

- All formatters respect project-specific configuration files when present
- LSP servers are automatically managed by Mason
- Format on save can be enabled per-filetype in Neovim
- Some formatters require specific runtime versions (e.g., Ruby 3.0+ for rubocop)