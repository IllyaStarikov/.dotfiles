# config/

Application configuration files and settings for development tools.

## Overview

This directory contains configuration files that control the behavior of various development tools and utilities used throughout the dotfiles ecosystem. These configurations are referenced by scripts and applications to provide consistent, customizable functionality.

## Directory Structure

```
config/
├── brain/              # AI assistant configuration
│   └── logs/          # Runtime logs for brain AI system
└── fixy.json  # Universal code formatter configuration
```

## Files

### fixy.json

Comprehensive configuration for the universal code formatting script (`~/. dotfiles/src/scripts/fixy`).

**Purpose**: Defines formatter priorities, commands, and language mappings for automatic code formatting across 20+ programming languages.

**Structure**:
- **formatters**: Detailed formatter definitions with commands and arguments
- **extensions**: File extension to language and formatter mappings
- **settings**: Global formatting behavior settings

**Key Features**:
- Priority-based formatter selection (tries formatters in order)
- Fallback mechanisms for missing formatters
- Additional formatters for specific operations (e.g., import sorting)
- Built-in text processing for basic formatting

**Example Configuration**:
```json
{
  "extensions": {
    "py": {
      "language": "Python",
      "formatters": ["ruff", "black", "yapf", "autopep8"],
      "additional": ["isort"]
    }
  }
}
```

This means Python files will:
1. Try Ruff first (fastest, Rust-based)
2. Fall back to Black if Ruff unavailable
3. Then yapf, then autopep8
4. Also run isort for import sorting if available

## Subdirectories

### brain/

Configuration and runtime data for the Brain AI assistant system.

**Contents**:
- Configuration files for AI providers
- Runtime logs and cache data
- Model selection preferences
- API endpoint configurations

**Structure**:
```
brain/
└── logs/           # Runtime logs
    ├── server.log  # MLX server logs
    ├── agent.log   # AI agent logs
    └── ...
```

## Formatter Configuration Details

### Supported Languages

The fixy.json supports the following languages with priority-based formatters:

**Python**: ruff → black → yapf → autopep8 (+ isort)
**C/C++**: clang-format → astyle
**Shell**: shfmt → beautysh
**Lua**: stylua → lua-format
**JavaScript/TypeScript**: prettierd → prettier → eslint
**Rust**: rustfmt
**Go**: goimports → gofmt
**Web**: prettier for HTML/CSS/JSON/YAML/Markdown

### Formatter Definitions

Each formatter includes:
- **command**: Executable name
- **check_command**: Version check command
- **format_args**: Arguments with `{file}` placeholder
- **description**: Human-readable description

Example:
```json
"ruff": {
  "command": "ruff",
  "check_command": "ruff --version",
  "format_args": "format --line-length 100 {file}",
  "fix_args": "check --fix --line-length 100 {file}",
  "description": "Fast Python linter and formatter (Rust-based)"
}
```

### Global Settings

**Default Operations**:
1. `trailing_whitespace`: Remove trailing spaces
2. `tabs_to_spaces`: Convert tabs to spaces
3. `smart_quotes`: Convert smart quotes to regular quotes
4. `formatters`: Run language-specific formatters

**Behavior Flags**:
- `show_formatter_fallback`: Display when using fallback formatter
- `run_additional_formatters`: Execute supplementary formatters (like isort)
- `verbose`: Enable detailed output

## Usage

### Format Script Integration

The format script reads this configuration:
```bash
# Format a file using configured priority
~/. dotfiles/src/scripts/fixy myfile.py

# The script will:
# 1. Read config/fixy.json
# 2. Identify file as Python
# 3. Try formatters in order: ruff, black, yapf, autopep8
# 4. Run isort if available
# 5. Apply text normalizations
```

### Adding New Formatters

1. Add formatter definition:
```json
"myformatter": {
  "command": "myformatter",
  "check_command": "myformatter --version",
  "format_args": "-i {file}",
  "description": "My custom formatter"
}
```

2. Add to language extensions:
```json
"myext": {
  "language": "MyLanguage",
  "formatters": ["myformatter", "fallback-formatter"]
}
```

### Customizing Priorities

Change formatter order to adjust priorities:
```json
"py": {
  "language": "Python",
  "formatters": ["black", "ruff", "yapf"]  // Black now preferred
}
```

## Integration Points

### With Scripts

- `src/scripts/fixy`: Primary consumer of fixy.json
- `src/scripts/fixy-all`: Batch formatting using configuration
- Git hooks: Pre-commit formatting

### With Editors

- Neovim: Can trigger format script via keybinding
- VSCode: tasks.json can reference format script
- Other editors: External formatter command

### With CI/CD

- GitHub Actions: Uses format script for consistency checks
- Pre-commit hooks: Enforces formatting before commits
- Linting workflows: Validates code style

## Best Practices

### Formatter Selection

1. **Performance**: Prefer faster formatters (ruff, prettierd)
2. **Compatibility**: Include widely-available fallbacks
3. **Consistency**: Use same formatter across team
4. **Features**: Consider formatter capabilities

### Configuration Management

1. **Version Control**: Track fixy.json changes
2. **Documentation**: Document custom formatter configs
3. **Testing**: Verify formatters work as expected
4. **Fallbacks**: Always provide alternatives

### Language-Specific Settings

1. **Line Length**: Match project standards
2. **Indentation**: Consistent spaces/tabs
3. **Style Guides**: Follow language conventions
4. **Import Sorting**: Use additional formatters

## Troubleshooting

### Formatter Not Found

Check installation:
```bash
# Verify formatter is installed
which ruff
ruff --version

# Install if missing
pip install ruff
# or
brew install ruff
```

### Formatting Fails

Debug with verbose mode:
```bash
# Edit config/fixy.json
"verbose": true

# Run formatter
~/. dotfiles/src/scripts/fixy --verbose myfile.py
```

### Wrong Formatter Used

Check priority order:
```bash
# View configuration
jq '.extensions.py' config/fixy.json
```

### Performance Issues

Use faster alternatives:
- `prettierd` instead of `prettier`
- `ruff` instead of `black`
- Disable additional formatters if not needed

## Security Notes

- Formatters execute with user privileges
- Avoid formatters from untrusted sources
- Review formatter arguments for safety
- Don't format sensitive files automatically

## Future Enhancements

Planned improvements:
- Parallel formatting for multiple files
- Custom formatter chains
- Project-specific overrides
- Formatter performance metrics
- Integration with language servers

## See Also

- Format Script: `src/scripts/fixy`
- Script Documentation: `src/scripts/README.md`
- Main README: `~/.dotfiles/README.md`