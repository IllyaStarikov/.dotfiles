# Utility Scripts

Custom productivity tools that automate daily development tasks.

## Scripts Overview

| Script               | Purpose                                  | Usage                 |
| -------------------- | ---------------------------------------- | --------------------- |
| **fixy**             | Universal code formatter (20+ languages) | `fixy file.py`        |
| **theme**            | System-wide theme switcher               | `theme dark`          |
| **tmux-utils**       | System monitoring for tmux status        | `tmux-utils battery`  |
| **tmux-auto**        | Auto-create/attach tmux sessions         | `tmux-auto`           |
| **scratchpad**       | Quick temporary file editor              | `scratchpad`          |
| **extract**          | Universal archive extractor              | `extract file.tar.gz` |
| **fetch-quotes**     | Inspirational quotes from APIs           | `fetch-quotes`        |
| **fallback**         | Command fallback handler                 | Internal use          |
| **install-ruby-lsp** | Ruby LSP installer                       | `install-ruby-lsp`    |
| **bugreport**        | Comprehensive diagnostic report          | `bugreport`           |
| **nvim-debug**       | Neovim diagnostic tool                   | `nvim-debug`          |
| **services**         | Service manager with PID tracking        | `services start`      |
| **validate-configs** | Config standards validation              | `validate-configs`    |
| **cortex**           | Local AI assistant wrapper               | `cortex`              |
| **common.sh**        | Compatibility wrapper around src/lib/    | Sourced by scripts    |

## Key Features

### fixy - Universal Formatter

```bash
fixy file.py              # Auto-detect and format
fixy --all src/           # Format with normalizations
fixy --check file.rs      # Check without modifying
```

- Supports 20+ languages via priority system
- Parallel processing with CPU core detection
- Config-driven via `/config/fixy.json`
- Smart fallbacks and normalizations

### theme - Theme Synchronization

```bash
theme              # Auto-detect from macOS
theme dark         # Force dark mode
theme light        # Force light mode
```

Synchronizes: Neovim, Alacritty, WezTerm, Kitty, tmux, Starship, bat, delta

### update-dotfiles - System Updater

```bash
update             # Update everything
update --brew      # Only Homebrew packages
update --nvim      # Only Neovim plugins
```

Updates: Homebrew, Neovim plugins, Zsh plugins, tmux plugins, pip packages, LSPs

### tmux-utils - Status Bar Utilities

```bash
tmux-utils battery     # Battery status
tmux-utils cpu         # CPU usage
tmux-utils memory      # Memory usage
```

Smart icons, real-time monitoring, optimized for tmux status bar.

## Quick Start

```bash
# Daily workflow
theme                  # Set theme
update                 # Update everything
fixy --all src/        # Format code

# Development
scratchpad             # Quick notes
extract archive.tar.gz # Extract files
```

## Configuration

- `/config/fixy.json` - Formatter priorities

## Performance

- fixy: < 100ms per file
- theme: < 500ms switching
- update: 1-5 minutes
- scratchpad: < 50ms

## Troubleshooting

**fixy not formatting**: Check formatter installed with `which <formatter>`

**theme not switching**: Check lockfile `/tmp/theme-switch.lock`

**update failing**: Verify network and credentials

## Testing

```bash
./test/runner.zsh unit/scripts/fixy
./test/runner.zsh functional/scripts
```
