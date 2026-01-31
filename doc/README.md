# Documentation

Everything you need to get started and stay productive.

## Quick Start

- **New here?** Start with the [Setup Guide](setup/README.md)
- **Need a command?** Check the [Quick Reference](usage/reference.md)
- **Something broken?** See [Troubleshooting](setup/troubleshooting.md)

---

## I Want To...

### Set up a new machine

1. [Prerequisites](setup/README.md#prerequisites)
2. [macOS Setup](setup/macos.md)
3. [Post-Installation](setup/README.md#post-installation-setup)

### Learn the keybindings

1. [Keybinding Overview](usage/keybindings/README.md)
2. [Neovim keys](usage/keybindings/neovim.md#leader-key-mappings), [tmux keys](usage/keybindings/tmux.md#prefix-key), [Shell keys](usage/keybindings/shell.md#navigation)

### Fix something broken

1. [Common Issues](setup/troubleshooting.md#common-installation-issues)
2. [Recovery Procedures](setup/troubleshooting.md#recovery-procedures)

### Customize my setup

1. [Theme System](guides/terminal/theme-system.md#switching-themes)
2. [Plugin Configuration](guides/README.md)
3. [Custom Snippets](guides/editor/snippets.md#creating-custom-snippets)

### Work with AI assistance

1. [Cortex](guides/editor/cortex.md)
2. [CodeCompanion Setup](guides/editor/codecompanion.md#setup)
3. [AI Keybindings](usage/keybindings/neovim.md#ai-leadera)

### Improve performance

1. [Modern CLI Replacements](usage/commands/modern-cli.md#replacements)
2. [Performance Benchmarks](usage/commands/tools-comparison.md)
3. [Zinit Turbo Mode](guides/terminal/zinit-setup.md#turbo-mode)

---

## By Tool

### Neovim

- [Configuration](guides/editor/neovim-config.md)
- [Keybindings](usage/keybindings/neovim.md)
- [Blink.cmp](guides/editor/blink.md)
- [CodeCompanion](guides/editor/codecompanion.md)
- [Snacks.nvim](guides/editor/snacks.md)
- [Snippets](guides/editor/snippets.md)
- [VimTeX](guides/editor/vimtex.md)

### Terminal

- [Alacritty](usage/tools/alacritty.md)
- [WezTerm](usage/tools/wezterm.md)
- [Kitty](usage/tools/kitty.md)
- [Theme System](guides/terminal/theme-system.md)
- [tmux](usage/tools/tmux.md)
- [tmux Keybindings](usage/keybindings/tmux.md)

### Shell

- [Zinit](guides/terminal/zinit-setup.md)
- [Commands](usage/commands/shell.md)
- [Keybindings](usage/keybindings/shell.md)
- [Modern CLI](usage/commands/modern-cli.md)

### Git

- [Aliases](usage/commands/git.md)
- [Feature Workflow](usage/workflows/features.md)
- [Code Review](usage/workflows/review.md)

---

## Quick Reference

### Config Files

| Tool      | Location               |
| --------- | ---------------------- |
| Neovim    | `~/.config/nvim/`      |
| Zsh       | `~/.zshrc`             |
| tmux      | `~/.tmux.conf`         |
| Alacritty | `~/.config/alacritty/` |
| Git       | `~/.gitconfig`         |

### External Resources

- [Zinit](https://github.com/zdharma-continuum/zinit)
- [Neovim Docs](https://neovim.io/doc/)
- [tmux Manual](https://man7.org/linux/man-pages/man1/tmux.1.html)
- [Starship](https://starship.rs/config/)

---

## Directory Structure

```
doc/
├── setup/          # Installation and configuration
├── usage/          # Quick reference and daily workflows
│   ├── commands/
│   ├── workflows/
│   ├── keybindings/
│   └── tools/
├── guides/         # Deep-dive customization
│   ├── editor/
│   ├── terminal/
│   └── development/
└── skeleton/       # Documentation templates
```

---

## Contributing

- **Usage docs** focus on "what" and "how"
- **Guides** explain "why" and implementation details
- **Always link** to official docs for standard features
