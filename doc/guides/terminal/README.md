# Terminal Configuration Guides

> **Unique configurations for terminal emulators and shell environments**

## Overview

This section contains configuration guides for terminal-related tools that have unique setups or customizations beyond standard usage.

## Available Guides

Currently, terminal configurations are integrated into the main tool references:

- **[Alacritty](../../usage/tools/alacritty.md)** - GPU-accelerated terminal
- **[tmux](../../usage/tools/tmux.md)** - Terminal multiplexer
- **[Zsh](../../usage/commands/shell.md)** - Shell configuration

## Common Customizations

### Theme Integration

All terminal tools in this setup automatically sync with the system theme:

1. **Alacritty** - Loads `~/.config/alacritty/theme.toml`
2. **tmux** - Sources `~/.config/tmux/theme.conf`
3. **Shell** - Exports `$MACOS_THEME` environment variable

### Font Configuration

We use JetBrainsMono Nerd Font across all terminals:
- Includes programming ligatures
- Has powerline symbols
- Contains devicons for file types

### Performance Optimizations

- GPU acceleration in Alacritty
- Minimal prompt calculations
- Lazy-loaded shell plugins
- Optimized tmux status updates

## Creating Custom Terminal Guides

Add guides here when you have:
- Complex terminal setups
- Custom integrations
- Performance optimizations
- Unique workflows

Place new guides in this directory with descriptive names.

---

<p align="center">
  <a href="../README.md">← Back to Guides</a>
</p>