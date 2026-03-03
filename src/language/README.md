# Language Configurations

Formatters, linters, and build tools for consistent code quality.

## Files

| File                 | Language | Tool         | Purpose                              |
| -------------------- | -------- | ------------ | ------------------------------------ |
| `.clang-format`      | C/C++    | clang-format | Google style, 100 cols               |
| `clangd_config.yaml` | C/C++    | clangd       | LSP with C++17, warnings, clang-tidy |
| `pyproject.toml`     | Python   | Multiple     | Black, isort, project metadata       |
| `ruff.toml`          | Python   | Ruff         | Fast linting and formatting          |
| `stylua.toml`        | Lua      | StyLua       | 2 spaces, 100 cols                   |
| `latexmkrc`          | LaTeX    | latexmk      | PDF compilation with bibliography    |
| `markdownlint.json`  | Markdown | markdownlint | Style rules, 100 char lines          |

## Usage

Files are symlinked to home directory during setup:

```bash
~/.clang-format
~/.config/clangd/config.yaml
~/.markdownlint.json
~/.ruff.toml
~/pyproject.toml
~/.latexmkrc
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

**Python**: 100 char lines (modern preference), comprehensive linting
**C/C++**: Google style base, C++17 default, modernize checks, 100 col limit
**Lua**: 2-space indent, expanded tables, 100 char limit
**Markdown**: ATX-style headers, 100 char limit

## Customization

Override locally by creating same files in project root.
Project configs take precedence over global ones.
