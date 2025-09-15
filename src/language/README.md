# Language Configurations

Formatters, linters, and build tools for consistent code quality.

## Files

| File | Language | Tool | Purpose |
|------|----------|------|---------|
| `.clang-format` | C/C++ | clang-format | Google style, 4 spaces, 100 cols |
| `clangd_config.yaml` | C/C++ | clangd | LSP with C++17, warnings, clang-tidy |
| `pyproject.toml` | Python | Multiple | Black, isort, project metadata |
| `ruff.toml` | Python | Ruff | Fast linting and formatting |
| `stylua.toml` | Lua | StyLua | 2 spaces, 100 cols, call parens |
| `latexmkrc` | LaTeX | latexmk | PDF compilation with bibliography |
| `markdownlint.json` | Markdown | markdownlint | Style rules, 100 char lines |

## Usage

Files are symlinked to home directory during setup:
```bash
~/.clang-format
~/.pyproject.toml
~/.ruff.toml
# etc...
```

## Integration

### With Neovim
- Formatters run on save via `conform.nvim`
- LSPs use these configs automatically
- Linters provide inline diagnostics

### With fixy script
```bash
fixy file.py   # Uses ruff from these configs
fixy file.cpp  # Uses clang-format settings
```

## Key Settings

**Python**: 88 char lines (Black standard), comprehensive linting
**C/C++**: Google style base, C++17 default, modernize checks
**Lua**: 2-space indent, expanded tables, call parentheses
**Markdown**: No bare URLs, consistent headers, 100 char limit

## Customization

Override locally by creating same files in project root.
Project configs take precedence over global ones.