# 📝 /src/language - Language Configurations

> **Polyglot perfection** - Formatters, linters, and tools for every language

Centralized configuration for language-specific development tools. Each file defines formatting rules, linting standards, and build configurations to ensure consistent code quality across all projects.

## 🎯 Quick Reference

| Language | Config File | Tool | Purpose |
|----------|------------|------|---------|
| **C/C++** | `.clang-format` | clang-format | Code formatting |
| **C/C++** | `clangd_config.yaml` | clangd | Language server |
| **Python** | `pyproject.toml` | Python tooling | Project metadata |
| **Python** | `ruff.toml` | Ruff | Linting & formatting |
| **Lua** | `stylua.toml` | StyLua | Code formatting |
| **LaTeX** | `latexmkrc` | latexmk | Document compilation |
| **Markdown** | `markdownlint.json` | markdownlint | Style checking |

## 📁 File Configurations

### 🔧 C/C++ Development

#### `.clang-format`
**Modern C/C++ formatting with Google style base**

```yaml
BasedOnStyle: Google
IndentWidth: 4
ColumnLimit: 100
AllowShortFunctionsOnASingleLine: Empty
```

**Features:**
- Google style foundation
- 4-space indentation
- 100 character line limit
- Smart function formatting

#### `clangd_config.yaml`
**Language server configuration for intelligent C/C++ development**

```yaml
CompileFlags:
  Add:
    - -std=c++17
    - -Wall
    - -Wextra
Diagnostics:
  ClangTidy:
    Add: ['modernize-*', 'performance-*']
```

**Provides:**
- C++17 standard by default
- Enhanced warnings
- Clang-tidy integration
- Performance suggestions

### 🐍 Python Development

#### `pyproject.toml`
**Modern Python project configuration**

```toml
[project]
name = "dotfiles"
requires-python = ">=3.8"

[tool.black]
line-length = 88
target-version = ['py38', 'py39', 'py310', 'py311']

[tool.isort]
profile = "black"
line_length = 88
```

**Configures:**
- Project metadata
- Black formatter settings
- isort import sorting
- Tool versions

#### `ruff.toml`
**Ultra-fast Python linting and formatting**

```toml
line-length = 88
target-version = "py38"

[lint]
select = ["E", "F", "W", "C90", "I", "N", "UP", "B", "A", "C4", "DTZ", "ISC", "ICN", "PIE", "PT", "RET", "SIM", "ARG", "ERA", "PD", "PGH", "PL", "TRY", "NPY", "RUF"]
ignore = ["E501"]  # Line too long (handled by formatter)

[format]
quote-style = "double"
indent-style = "space"
```

**Features:**
- Comprehensive rule set
- Black-compatible formatting
- Performance optimized
- Type checking support

### 🌙 Lua Development

#### `stylua.toml`
**Consistent Lua formatting for Neovim configs**

```toml
column_width = 120
line_endings = "Unix"
indent_type = "Spaces"
indent_width = 2
quote_style = "AutoPreferDouble"
call_parentheses = "Always"
collapse_simple_statement = "Never"
```

**Standards:**
- 120 character lines
- 2-space indentation
- Unix line endings
- Consistent parentheses

### 📚 Document Processing

#### `latexmkrc`
**Automated LaTeX compilation with live preview**

```perl
$pdf_mode = 1;
$pdflatex = 'pdflatex -interaction=nonstopmode -synctex=1 %O %S';
$pdf_previewer = 'open -a Skim';
$clean_ext = 'synctex.gz synctex.gz(busy) run.xml tex.bak bbl bcf fdb_latexmk run tdo %R-blx.bib';

# Continuous compilation
$continuous_mode = 1;
$pdf_update_method = 2;
```

**Features:**
- PDF generation with synctex
- Skim.app integration (macOS)
- Continuous compilation mode
- Smart file cleaning
- Bibliography support

### 📝 Markdown

#### `markdownlint.json`
**Consistent Markdown formatting rules**

```json
{
  "MD013": false,  // Line length
  "MD033": false,  // Allow HTML
  "MD041": false,  // First line heading
  "MD024": { "siblings_only": true },  // Duplicate headings
  "MD026": false   // Trailing punctuation in headings
}
```

**Allows:**
- Long lines for tables
- Inline HTML for formatting
- Flexible heading structure
- Punctuation in headings

## 🚀 Usage

### Integration with Editors

#### Neovim
All configs are automatically loaded by LSPs and formatters:
```lua
-- Automatically uses ruff.toml for Python
require('lspconfig').ruff_lsp.setup{}

-- Uses stylua.toml for Lua formatting
require('formatter').setup({
  filetype = {
    lua = { require('formatter.filetypes.lua').stylua }
  }
})
```

#### VS Code
Place configs in project root or use global settings:
```json
{
  "C_Cpp.clang_format_style": "file",
  "python.linting.ruffEnabled": true,
  "[lua]": {
    "editor.defaultFormatter": "JohnnyMorganz.stylua"
  }
}
```

### Command Line

```bash
# Format C++ files
clang-format -i src/*.cpp

# Lint Python with Ruff
ruff check .
ruff format .

# Format Lua files
stylua src/neovim/

# Compile LaTeX
latexmk -pdf document.tex

# Check Markdown
markdownlint README.md
```

### With fixy Script

The `fixy` script automatically uses these configs:
```bash
fixy file.py   # Uses ruff.toml
fixy file.cpp  # Uses .clang-format
fixy file.lua  # Uses stylua.toml
fixy file.md   # Uses markdownlint.json
```

## 🔧 Customization

### Per-Project Overrides

Create local config files in project root:
```bash
project/
├── .clang-format      # Override C++ formatting
├── pyproject.toml     # Project-specific Python
├── stylua.toml        # Custom Lua style
└── .markdownlint.json # Markdown rules
```

### Global Defaults

These configs serve as fallbacks when no project-specific config exists:
```bash
~/.config/
├── clang-format/config  → src/language/.clang-format
├── ruff/ruff.toml       → src/language/ruff.toml
└── stylua/stylua.toml   → src/language/stylua.toml
```

## 📊 Language Coverage

| Language | Formatter | Linter | LSP | Build Tool |
|----------|-----------|--------|-----|------------|
| C/C++ | ✅ clang-format | ✅ clang-tidy | ✅ clangd | ✅ cmake/make |
| Python | ✅ ruff/black | ✅ ruff | ✅ pyright | ✅ pip/poetry |
| Lua | ✅ stylua | ✅ luacheck | ✅ lua-language-server | ✅ luarocks |
| LaTeX | ✅ latexindent | ✅ chktex | ✅ texlab | ✅ latexmk |
| Markdown | ✅ prettier | ✅ markdownlint | ✅ marksman | - |
| JavaScript | ⚙️ prettier | ⚙️ eslint | ⚙️ typescript-language-server | ⚙️ npm |
| Go | ⚙️ gofmt | ⚙️ golangci-lint | ⚙️ gopls | ⚙️ go |
| Rust | ⚙️ rustfmt | ⚙️ clippy | ⚙️ rust-analyzer | ⚙️ cargo |

✅ = Configured here | ⚙️ = Uses tool defaults

## 🎯 Best Practices

### Consistency
1. **Use fixy** - It knows all the configs
2. **Format on save** - Enable in your editor
3. **Pre-commit hooks** - Catch issues early
4. **CI checks** - Enforce in pull requests

### Performance
1. **Ruff over Flake8** - 10-100x faster
2. **Parallel formatting** - Use fixy's parallel mode
3. **Incremental checks** - Only lint changed files
4. **Cache results** - Most tools support caching

### Project Setup
```bash
# New Python project
cp ~/dotfiles/src/language/{pyproject.toml,ruff.toml} .

# New C++ project  
cp ~/dotfiles/src/language/.clang-format .
cp ~/dotfiles/src/language/clangd_config.yaml .clangd

# New Lua project
cp ~/dotfiles/src/language/stylua.toml .
```

## 🧪 Testing

Validate configurations:
```bash
# Test formatters
fixy --check --all .

# Test linters
ruff check --no-fix .
markdownlint '**/*.md'

# Test LSP configs
clangd --check=clangd_config.yaml
```

## 📈 Adding Languages

To add a new language configuration:

1. Create config file in `/src/language/`
2. Update fixy.json to use it
3. Add to symlinks.sh if needed
4. Document in this README
5. Add tests

Example for adding Java:
```bash
# Create config
echo "indent_style = space" > src/language/.editorconfig

# Update fixy.json
jq '.languages.java.formatter = "google-java-format"' config/fixy.json

# Test it
fixy Test.java
```

## 🔗 Related

- [Fixy Configuration](/config/fixy.json) - Universal formatter settings
- [Neovim LSP](../neovim/config/lsp/) - Language server configs
- [Editor Config](../editorconfig) - Universal editor settings
- [Git Hooks](../git/hooks/) - Pre-commit formatting

## 💡 Tips

```bash
# Format all Python in project
find . -name "*.py" -exec ruff format {} +

# Lint all Markdown
markdownlint '**/*.md' --fix

# Watch and compile LaTeX
latexmk -pvc document.tex

# Format staged files only
git diff --cached --name-only | xargs fixy
```

---

<div align="center">

**[⬆ Back to /src](../README.md)**

Consistent code across all languages 🌍

</div>