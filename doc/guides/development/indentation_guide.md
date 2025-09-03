# Indentation Guide

This dotfiles repository follows industry-standard style guides for all languages.

Official style guide resources are included as a git submodule in `src/styleguide/`.

## Indentation Standards

### Python: 4 Spaces
Per PEP 8 standard:
- **Indent**: 4 spaces per indentation level
- **Line Length**: 100 characters maximum
- **Continuation Lines**: Use 4 space hanging indent

### Other Languages: 2 Spaces
All other languages use 2-space indentation:
- **C/C++**: 2 spaces (industry standard)
- **JavaScript/TypeScript**: 2 spaces (industry standard)
- **Shell Scripts**: 2 spaces (industry standard)
- **HTML/CSS**: 2 spaces (industry standard)
- **Lua**: 2 spaces
- **Ruby**: 2 spaces
- **Swift**: 2 spaces
- **LaTeX**: 2 spaces

### Exceptions
- **Go**: Uses tabs (gofmt standard)
- **Makefiles**: Require tabs

## Configuration Files

### `src/editorconfig`
Universal editor configuration that enforces these standards across all editors.

### `pyproject.toml`
Python-specific tooling configuration:
- Black: 4-space indentation, 100 char line length
- isort: 4-space indentation for imports

### `pylintrc`
Google's Python Style Guide Pylint configuration is available at `styleguide/pylintrc` for Python style enforcement.

### Neovim Configuration
- **Default**: 2 spaces (set in `options.lua`)
- **Python Override**: 4 spaces (set in `autocmds.lua`)
- **Snippets**: Follow language-specific standards

## Automatic Formatting

The repository includes the fixy script that automatically applies these standards:
- Python: `black` and `isort`
- JavaScript/TypeScript: `prettier`
- Shell: `shfmt`
- Lua: `stylua`

Run the fixy script with:
```bash
fixy [file]  # Format specific file
fixy --all [file]  # All operations including formatting
```

## Available Style Guide Resources

The style guide submodule includes:

### Configuration Files
- **Python**: `pylintrc`, `python_style.vim`
- **C/C++**: `eclipse-cpp-style.xml`, `c-style.el`
- **Java**: `eclipse-java-style.xml`, `intellij-java-style.xml`

### Style Documentation
- **Python**: `pyguide.md`
- **C++**: `cppguide.html`
- **JavaScript**: `jsguide.html`
- **TypeScript**: `tsguide.html`
- **Shell**: `shellguide.md`
- **HTML/CSS**: `htmlcssguide.html`
- **Go**: `go/` directory
- **Objective-C**: `objcguide.md`
- **Java**: `javaguide.html`
- **R**: `Rguide.md`

Access these resources in `src/styleguide/`.