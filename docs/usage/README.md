# Dotfiles Usage Documentation

Welcome to the comprehensive usage documentation for this dotfiles configuration. Each guide follows a consistent format designed for quick reference and deep understanding.

## Documentation Structure

Each document contains:
- **Command/Shortcut Reference Table** - Quick lookup for all commands
- **Quick Reference** - Essential features and settings
- **About** - Overview and key capabilities
- **Additional Usage Info** - Detailed explanations
- **Further Command Explanations** - Deep dives into complex commands
- **Theory & Background** - Conceptual understanding
- **Good to Know / Lore / History** - Tips, tricks, and evolution

## Available Guides

### [Neovim Usage Guide](vim.md)
Complete guide to the modern Neovim configuration featuring:
- Comprehensive keybinding reference
- AI assistant integration (CodeCompanion)
- Snacks.nvim power features
- LaTeX environment (VimTeX)
- Debugging setup (DAP)
- Plugin ecosystem overview

### [Zsh with Oh My Zsh Guide](zsh.md)
Master the enhanced shell environment:
- Extensive alias collection
- Oh My Zsh plugin features
- Vi-mode operations
- Smart completions
- Modern tool replacements
- Directory navigation tricks

### [Tmux & Tmuxinator Guide](tmux.md)
Professional terminal multiplexer setup:
- Complete keybinding reference
- Session management
- Pane and window control
- Copy mode operations
- Tmuxinator project templates
- Plugin features

### [Alacritty Terminal Guide](alacritty.md)
GPU-accelerated terminal configuration:
- Keyboard shortcuts
- Mouse operations
- Performance settings
- Theme integration
- Platform-specific features

### [Git Configuration Guide](git.md)
Professional version control setup:
- Extensive alias collection
- Workflow helpers
- Commit conventions
- Performance optimizations
- Safety features

### [Tools & Scripts Guide](tools.md)
Modern CLI tools and utilities:
- System update script
- Theme switcher
- Modern tool replacements (eza, bat, fd, rg)
- Development utilities
- Network and system tools

## Quick Start

1. **New to this setup?** Start with the [Zsh guide](zsh.md) to understand the shell environment
2. **Setting up development?** Read the [Neovim guide](vim.md) for editor configuration
3. **Need multiplexing?** Check the [Tmux guide](tmux.md) for session management
4. **Version control?** The [Git guide](git.md) has all the aliases and workflows

## Key Concepts Across All Tools

### Theme Integration
All tools coordinate through the theme switching system:
- Run `theme` to auto-detect and apply system theme
- Use `dark` or `light` to force a specific theme
- Affects: Alacritty, tmux, Neovim, and shell prompt

### Performance Focus
Every tool is optimized for speed:
- Lazy loading where possible
- Modern replacements for slow tools
- Efficient configurations
- Smart caching strategies

### Consistent Keybindings
Vi-style navigation throughout:
- `hjkl` movement in tmux, Neovim
- Vi-mode in shell
- Consistent leader keys
- Unified clipboard operations

### Integration Points
Tools work together seamlessly:
- Neovim ↔ tmux smart navigation
- Shell aliases complement git aliases
- Theme system coordinates all applications
- Clipboard shared across all tools

## Tips for Using This Documentation

1. **Start with tables** - Quick reference for daily use
2. **Explore progressively** - Basic → Advanced → Theory
3. **Try examples** - Each guide includes practical examples
4. **Learn shortcuts** - Efficiency comes from muscle memory
5. **Understand integration** - Tools work better together

## Maintenance

- Run `update` regularly to keep everything current
- Check individual guide troubleshooting sections for issues
- Theme switching should be automatic but can be forced
- Most configurations hot-reload without restart

## Contributing

Found an issue or have an improvement? This documentation lives in `/docs/usage/` within the dotfiles repository. Each guide is a standalone Markdown file designed for both quick reference and deep learning.