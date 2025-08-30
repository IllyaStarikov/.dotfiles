# src/scripts/

Utility scripts for system maintenance, development workflows, and productivity enhancements.

## Overview

This directory contains shell scripts that provide essential functionality for the dotfiles ecosystem. These scripts handle everything from code formatting to system updates, theme switching, and tmux status bar utilities.

## Scripts

### common.sh

Shared library of functions used by other scripts.

**Purpose**: Provides reusable functions for color output, platform detection, command execution, and error handling.

**Key Functions**:
- `print_color()`: Colored terminal output
- `platform_command()`: Cross-platform command execution
- `check_command()`: Command availability checking
- `get_os()`: Operating system detection
- `error_exit()`: Graceful error handling

**Usage**:
```bash
source "${SCRIPT_DIR}/common.sh"
print_color green "Success!"
platform_command "brew install" "apt install"
```

### extract

Universal archive extraction tool supporting 20+ formats.

**Purpose**: Extract any compressed archive with a single command, automatically detecting format.

**Supported Formats**:
- tar, tar.gz, tar.bz2, tar.xz, tar.Z
- zip, rar, 7z
- gz, bz2, xz, Z
- deb, rpm
- jar, war
- And more...

**Usage**:
```bash
extract archive.tar.gz
extract file.zip /target/directory
extract -l archive.7z  # List contents
```

### fetch-quotes

Fetches and displays inspirational programming quotes.

**Purpose**: Retrieve motivational quotes for terminal sessions, tmux status bars, or daily inspiration.

**Features**:
- Multiple quote sources
- Caching for offline access
- Random selection
- JSON output support

**Usage**:
```bash
fetch-quotes           # Random quote
fetch-quotes --json    # JSON format
fetch-quotes --cache   # Use cached quotes
```

### fixy

Universal code formatter with configuration-based priority system.

**Purpose**: Format code files using the best available formatter, with automatic fallback to alternatives.

**Configuration**: Uses `~/.dotfiles/config/fixy.json` for formatter priorities.

**Features**:
- 20+ language support
- Priority-based formatter selection
- Text normalization (whitespace, tabs, quotes)
- Dry-run mode
- Additional formatters (import sorting)

**Usage**:
```bash
fixy file.py                    # Format Python file
fixy --all file.js             # All normalizations + formatting
fixy --dry-run file.cpp        # Preview changes
fixy --trailing-whitespace *.sh # Only remove trailing whitespace
```

**Operations**:
- `--trailing-whitespace`: Remove trailing spaces
- `--tabs-to-spaces`: Convert tabs to spaces
- `--smart-quotes`: Convert smart quotes to ASCII
- `--formatters`: Run language-specific formatters

### scratchpad

Creates temporary files for quick notes or testing.

**Purpose**: Quickly create and open temporary files with automatic cleanup options.

**Features**:
- Auto-generated filenames with timestamps
- Multiple editor support
- Optional persistence
- Custom extensions

**Usage**:
```bash
scratchpad                  # Create temp file, open in $EDITOR
scratchpad --keep          # Don't auto-delete
scratchpad --ext py        # Python scratch file
scratchpad --name test     # Named scratch file
```

### theme

Quick theme switching command (alias for theme-switcher).

**Purpose**: Convenient wrapper for the theme switching system.

**Usage**:
```bash
theme           # Auto-detect from macOS appearance
theme day       # TokyoNight Day (light)
theme night     # TokyoNight Night (dark)
theme moon      # TokyoNight Moon (dark)
theme storm     # TokyoNight Storm (dark)
```

### tmux-utils

Utilities for tmux status bar components.

**Purpose**: Provide system information for tmux status bar display.

**Components**:
- `battery`: Battery status and percentage
- `cpu`: CPU usage monitoring
- `memory`: RAM usage display
- `network`: Network status
- `weather`: Weather information
- `time`: Custom time formats

**Features**:
- Caching for performance
- Color-coded indicators
- Platform-specific implementations
- Emoji support

**Usage**:
```bash
tmux-utils battery    # 🔋 85%
tmux-utils cpu       # 💻 12%
tmux-utils memory    # 🧠 8.2G/16G
tmux-utils network   # 🌐 Connected
```

**tmux.conf Integration**:
```tmux
set -g status-right '#(~/.dotfiles/src/scripts/tmux-utils battery)'
```

### update-dotfiles

Comprehensive system update script (aliased as `update`).

**Purpose**: Update all system packages, plugins, and tools with a single command.

**Updates**:
- Homebrew packages and casks
- App Store applications (via mas)
- Neovim plugins (lazy.nvim)
- Tmux plugins (TPM)
- Zsh plugins (zinit)
- Python packages (pip)
- Ruby gems
- Node packages (npm)
- Rust toolchain
- System software updates

**Usage**:
```bash
update              # Update everything
update --brew       # Only Homebrew
update --plugins    # Only editor/shell plugins
update --languages  # Programming language packages
```

## Script Standards

### Shell Selection

All scripts use:
```bash
#!/usr/bin/env bash
```
For maximum portability and feature availability.

### Error Handling

Standard error handling pattern:
```bash
set -euo pipefail  # Exit on error, undefined vars, pipe failures
trap 'echo "Error on line $LINENO"' ERR
```

### Cross-Platform Support

Scripts detect and handle platform differences:
```bash
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS specific
else
  # Linux specific
fi
```

### Color Output

Using common.sh functions:
```bash
print_color green "Success"
print_color red "Error"
print_color yellow "Warning"
print_color blue "Info"
```

## Configuration Files

### fixy.json

Located at: `~/.dotfiles/config/fixy.json`

Defines:
- Formatter commands and arguments
- Language to formatter mappings
- Priority orders
- Global settings

### Script Environment Variables

Common variables:
- `DOTFILES_DIR`: Root of dotfiles repository
- `EDITOR`: Preferred text editor
- `TERM`: Terminal type
- `OSTYPE`: Operating system type

## Integration Points

### With Shell Configuration

Scripts are added to PATH via zshrc:
```bash
export PATH="$HOME/.dotfiles/src/scripts:$PATH"
```

### With Aliases

Common aliases defined:
```bash
alias update='update-dotfiles'
alias fmt='fixy'
alias scratch='scratchpad'
alias extract='extract'
```

### With Editors

- Neovim: Can call format script via keybinding
- VSCode: Task runner integration
- Tmux: Status bar components

## Testing

### Manual Testing

Test individual scripts:
```bash
# Test fixy script
fixy --dry-run test.py

# Test tmux utils
tmux-utils battery

# Test extraction
extract test.zip /tmp/
```

### Automated Testing

Part of test suite:
```bash
~/.dotfiles/test/test scripts
```

## Debugging

### Enable Debug Mode

Most scripts support debug output:
```bash
DEBUG=1 fixy file.py
VERBOSE=1 update-dotfiles
```

### Common Issues

**Permission Denied**:
```bash
chmod +x ~/.dotfiles/src/scripts/*
```

**Command Not Found**:
```bash
# Ensure PATH includes scripts
echo $PATH | grep dotfiles/src/scripts
```

**Platform Issues**:
```bash
# Test platform detection
bash -c 'source common.sh && get_os'
```

## Best Practices

### Script Development

1. **Source common.sh**: Use shared functions
2. **Error handling**: Always use `set -euo pipefail`
3. **Help text**: Include usage information
4. **Validation**: Check inputs and dependencies
5. **Cross-platform**: Test on macOS and Linux

### Performance

1. **Cache when possible**: Reduce repeated operations
2. **Background jobs**: Use `&` for parallel tasks
3. **Minimal dependencies**: Check availability
4. **Early exit**: Fail fast on errors

### Documentation

1. **Header comments**: Describe purpose
2. **Function docs**: Document parameters
3. **Usage examples**: Show common uses
4. **Error messages**: Be descriptive

## Security

- No hardcoded credentials
- Validate user input
- Use quotes around variables
- Avoid eval and arbitrary execution
- Check file permissions

## Future Enhancements

Planned improvements:
- Script dependency management
- Automated script testing
- Performance profiling
- Plugin architecture
- Configuration UI

## Dependencies

### Required

- Bash 4.0+
- Core utilities (sed, awk, grep)
- Git

### Optional

Tool-specific dependencies:
- `format`: Language formatters
- `tmux-utils`: tmux
- `update-dotfiles`: Package managers
- `fetch-quotes`: curl/wget

## See Also

- Common Library: [common.sh](common.sh)
- Format Config: `~/.dotfiles/config/fixy.json`
- Theme Switcher: `~/.dotfiles/src/theme-switcher/`
- Main README: `~/.dotfiles/README.md`