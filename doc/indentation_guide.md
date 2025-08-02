# Indentation Guide

This dotfiles repository follows [Google Style Guides](https://github.com/google/styleguide) for all languages.

The official Google Style Guide is included as a git submodule in `src/styleguide/`.

## Indentation Standards

### Python: 4 Spaces
Per [Google Python Style Guide](https://google.github.io/styleguide/pyguide.html#s3.4-indentation):
- **Indent**: 4 spaces per indentation level
- **Line Length**: 100 characters maximum
- **Continuation Lines**: Use 4 space hanging indent

### Other Languages: 2 Spaces
All other languages use 2-space indentation:
- **C/C++**: 2 spaces (Google C++ Style)
- **JavaScript/TypeScript**: 2 spaces (Google JS Style)
- **Shell Scripts**: 2 spaces (Google Shell Style)
- **HTML/CSS**: 2 spaces (Google HTML/CSS Style)
- **Lua**: 2 spaces
- **Ruby**: 2 spaces
- **Swift**: 2 spaces
- **LaTeX**: 2 spaces

### Exceptions
- **Go**: Uses tabs (gofmt standard)
- **Makefiles**: Require tabs

## Configuration Files

### `.editorconfig`
Universal editor configuration that enforces these standards across all editors.

### `pyproject.toml`
Python-specific tooling configuration:
- Black: 4-space indentation, 100 char line length
- isort: 4-space indentation for imports

### `.pylintrc`
Symlinked to Google's official Pylint configuration (`src/styleguide/pylintrc`) for Python style enforcement.

### Neovim Configuration
- **Default**: 2 spaces (set in `options.lua`)
- **Python Override**: 4 spaces (set in `autocmds.lua`)
- **Snippets**: Follow language-specific standards

## Automatic Formatting

The repository includes format scripts that automatically apply these standards:
- Python: `black` and `isort`
- JavaScript/TypeScript: `prettier`
- Shell: `shfmt`
- Lua: `stylua`

Run the format script with:
```bash
./src/scripts/format
```

## Available Style Guide Resources

The Google Style Guide submodule includes:

### Configuration Files
- **Python**: `pylintrc` (symlinked), `google_python_style.vim`
- **C/C++**: `eclipse-cpp-google-style.xml`, `google-c-style.el`
- **Java**: `eclipse-java-google-style.xml`, `intellij-java-google-style.xml`

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

Access these resources in `src/styleguide/` or view them online at [google.github.io/styleguide](https://google.github.io/styleguide/).