# Tool Configuration Guides

> **Guides for tools with unique configurations in this setup**

## Available Guides

### Background Services

- **[Services Manager](services.md)** - Background service manager for persistent applications with LaunchAgent integration

### Development Tools

Tool-specific configurations are documented in usage guides:

- **[Git Configuration](../../usage/tools/git.md)** - Extensive aliases, delta diff, and workflows
- **[Modern CLI Tools](../../usage/commands/modern-cli.md)** - Rust-based replacements (ripgrep, fd, bat, eza)

## Tool Integration

### Universal Code Formatter (fixy)

The `fixy` script provides unified formatting across 20+ languages:

```bash
# Format any file
fixy file.py
fixy file.lua
fixy file.ts

# Dry run
fixy --dry-run file.py

# Format multiple files
fixy *.py
```

**Configuration**: `~/.dotfiles/config/fixy.json`

**Supported formatters:**
| Language | Formatters (priority order) |
|----------|----------------------------|
| Python | yapf, ruff, black |
| Lua | stylua |
| JavaScript/TypeScript | prettier, eslint |
| C/C++ | clang-format |
| Shell | shfmt |
| Go | gofmt |
| Rust | rustfmt |

### AI Model Management (Cortex)

See **[Cortex Guide](../editor/cortex.md)** for the unified AI model management system.

## Tool Philosophy

Our tool configurations prioritize:

### 1. Consistency

Similar patterns across tools:
- Vi-style keybindings where possible
- Consistent theme colors
- Unified leader key concepts

### 2. Performance

Fast startup and operation:
- Lazy loading where applicable
- Minimal dependencies
- GPU acceleration for terminals

### 3. Integration

Tools work together seamlessly:
- Theme switching affects all applications
- Shell aliases for common operations
- Shared configuration patterns

### 4. Simplicity

Easy to understand and modify:
- Well-documented configurations
- Modular file organization
- Clear naming conventions

## Common Configurations

### Shell Aliases

Defined in `~/.dotfiles/src/zsh/aliases.zsh`:

```bash
# Git shortcuts
alias gs="git status"
alias ga="git add"
alias gc="git commit"
alias gp="git push"

# Modern replacements
alias ls="eza --icons"
alias cat="bat"
alias find="fd"
alias grep="rg"

# Utilities
alias update="update-dotfiles"
alias ff="fzf-file"
alias fg="fzf-grep"
```

### Environment Variables

Set in `~/.dotfiles/src/zsh/zshrc`:

```bash
export EDITOR="nvim"
export VISUAL="nvim"
export PAGER="less"
export MANPAGER="nvim +Man!"
```

### Path Configuration

Tools are available via PATH additions:

```bash
# In .zshrc
export PATH="$HOME/.dotfiles/src/scripts:$PATH"
export PATH="$HOME/.local/bin:$PATH"
```

## Utility Scripts

Located in `~/.dotfiles/src/scripts/`:

| Script | Description |
|--------|-------------|
| `fixy` | Universal code formatter |
| `theme` | Theme switching |
| `update-dotfiles` | Update all packages and plugins |
| `extract` | Universal archive extractor |
| `cortex` | AI model management |
| `services` | Background service manager |
| `scratchpad` | Quick temporary file editing |

## Adding New Tools

### Integration Checklist

When adding a new tool:

1. **Configuration file** - Add to appropriate `src/` directory
2. **Symlink** - Update `src/setup/symlinks.sh`
3. **Theme support** - Add to theme switcher if applicable
4. **Documentation** - Add usage guide in `doc/usage/tools/`
5. **Aliases** - Add common aliases to `src/zsh/aliases.zsh`

### Documentation Template

```markdown
# Tool Name Reference

> **Brief description**

## Quick Start

\`\`\`bash
# Basic usage examples
\`\`\`

## Configuration

### File Location

### Key Settings

## Keyboard Shortcuts

## Integration

## Troubleshooting
```

---

<p align="center">
  <a href="../README.md">← Back to Guides</a>
</p>
