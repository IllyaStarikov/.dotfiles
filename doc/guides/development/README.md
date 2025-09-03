# Development Standards and Guidelines

> **Code style, formatting, and development practices**

## Overview

This section contains guides for maintaining consistent code quality and style across the dotfiles repository and your development projects.

## Available Guides

### [Format Script Guide](format_guide.md)
Universal code formatter that combines:
- File operations (trailing whitespace, tabs)
- Language-specific formatters
- Smart quote normalization

### [Indentation Guide](indentation_guide.md)
Industry standard compliance:
- Python: 4 spaces
- Other languages: 2 spaces
- Exceptions: Go (tabs), Makefiles (tabs)

### [Style Guide](style_guide.md)
Comprehensive coding standards:
- Language-specific conventions
- Naming patterns
- Documentation requirements

## Quick Reference

### Python
```python
# 4 spaces, 100 char lines
def example_function(parameter_one: str,
                    parameter_two: int) -> bool:
    """Docstring with industry-standard format."""
    return True
```

### JavaScript/TypeScript
```javascript
// 2 spaces, modern syntax
const exampleFunction = async (param) => {
  const result = await fetchData(param);
  return result;
};
```

### Shell
```bash
# 2 spaces, industry standard
main() {
  local arg="${1}"
  if [[ -z "${arg}" ]]; then
    echo "Error: Missing argument" >&2
    return 1
  fi
}
```

## Enforcement

These standards are enforced through:

1. **Editor Configuration** - `src/editorconfig` and language servers
2. **Formatters** - Automated via `format` script
3. **Linters** - Pre-commit hooks and CI checks
4. **Code Review** - Manual verification

## Resources

- Industry-standard style guides
- Local copy: `src/styleguide/` (git submodule)

---

<p align="center">
  <a href="../README.md">← Back to Guides</a>
</p>