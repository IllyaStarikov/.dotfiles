# Customization Guides

> **Deep dives into what makes our configuration unique**

## Purpose

These guides explain:

- **Why** we made specific configuration choices
- **What** makes our setup different from defaults
- **How** our customizations improve the development experience

For quick command references, see [Usage Documentation](../usage/README.md).

## Guide Categories

### [Editor Customizations](editor/)

Advanced Neovim configurations that go beyond standard setups:

- **[Neovim Config Structure](editor/neovim-config.md)** - Modular Lua organization
- **[Blink.cmp](editor/blink.md)** - Ultra-fast completion with custom priorities
- **[CodeCompanion](editor/codecompanion.md)** - Local-first AI with Ollama
- **[Snacks.nvim](editor/snacks.md)** - Quality of life improvements
- **[Snippets](editor/snippets.md)** - Custom snippet system
- **[VimTeX](editor/vimtex.md)** - Professional LaTeX environment
- **[Modern Plugins](editor/modern_plugins_guide.md)** - Plugin migration guide

### [Terminal Environment](terminal/)

Shell and terminal customizations:

- **[Zinit Setup](terminal/zinit-setup.md)** - Modern plugin manager replacing Oh My Zsh
- **[Theme System](terminal/theme-system.md)** - Automatic light/dark mode synchronization
- **[Terminal Guide](README.md)** - Alacritty configuration

### [Development Standards](development/)

Code quality and consistency:

- **[Format Script](development/format_guide.md)** - Universal code formatter
- **[Indentation Guide](development/indentation_guide.md)** - Industry standard compliance
- **[Style Guide](development/style_guide.md)** - Comprehensive coding standards

### [Tool Configurations](tools/)

Modern CLI tool setups:

- **[Modern CLI Tools](../usage/commands/modern-cli.md)** - Replacements for traditional Unix tools
- **[Git Workflow](../usage/commands/git.md)** - Enhanced version control
- **[Shell Commands](../usage/commands/shell.md)** - Productivity aliases

## Key Differentiators

### 1. Performance Focus

Every configuration prioritizes speed:

- Lazy loading everywhere possible
- Caching strategies for completions and searches
- Async operations by default

### 2. Integration

Components work together seamlessly:

- Unified theme switching across all tools
- Consistent keybindings (vim-style everywhere)
- Shared clipboard between tmux, vim, and system

### 3. Modern Tooling

We replace traditional tools with faster alternatives:

- `ripgrep` instead of `grep` (10-100x faster)
- `fd` instead of `find` (more intuitive)
- `eza` instead of `ls` (git integration)
- `bat` instead of `cat` (syntax highlighting)

### 4. AI-First Development

Built-in AI assistance that respects privacy:

- Local LLMs via Ollama by default
- Context-aware code suggestions
- Custom prompts for common tasks

## How to Use These Guides

1. **New to a tool?** Start with the official documentation
2. **Want our specifics?** Read the relevant guide here
3. **Customizing further?** Use our configuration as a base

## Contributing

When adding new guides:

1. Focus on **unique** aspects of our configuration
2. Link to official documentation for standard features
3. Include performance comparisons where relevant
4. Provide troubleshooting for common issues

---

<p align="center">
  <a href="../README.md">← Back to Documentation</a>
</p>
