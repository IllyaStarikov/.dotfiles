# Architecture Overview

> **System design and integration details of the dotfiles environment**

## Design Principles

1. **Modularity** Each component can be updated independently
2. **Performance** Lazy loading and caching wherever possible
3. **Consistency** Unified keybindings and workflows across tools
4. **Extensibility** Easy to add new tools and configurations
5. **Maintainability** Clear separation of concerns

## System Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                     User Interface Layer                    │
├─────────────┬───────────────┬───────────────┬───────────────┤
│  Alacritty  │    Neovim     │     tmux      │   Starship    │
│  (Terminal) │   (Editor)    │ (Multiplexer) │   (Prompt)    │
├─────────────┴───────────────┴───────────────┴───────────────┤
│                      Shell Layer (Zsh)                      │
│                     Zinit + Plugins                         │
├─────────────────────────────────────────────────────────────┤
│                    Tool Integration Layer                   │
│          Modern CLI Tools + Package Managers                │
├─────────────────────────────────────────────────────────────┤
│                      System Layer                           │
│                 macOS + Homebrew + Fonts                    │
└─────────────────────────────────────────────────────────────┘
```

## Component Integration

### Theme Synchronization

```
macOS Appearance ──┐
                   ├──> Theme Switcher ──┬──> Alacritty Config
                   │                     ├──> Neovim Config
                   │                     ├──> tmux Config
                   │                     └──> Environment Vars
                   │
Manual Override ───┘
```

### Configuration Management

```
~/.dotfiles/
    │
    ├── src/                  # Source configurations
    │   ├── *.symlink         # Files to be symlinked
    │   └── config/           # XDG config directories
    │
    ├── scripts/              # Automation scripts
    │   └── setup/            # Installation scripts
    │
    └── Symbolic Links:
        ~/.zshrc       -> src/zshrc.symlink
        ~/.config/     -> src/config/*
        ~/.tmux.conf   -> src/tmux.conf.symlink
```

### Plugin Architecture

#### Neovim (Lazy.nvim)

```
init.lua
    │
    ├── lua/config/
    │   ├── lazy.lua          # Plugin manager setup
    │   ├── plugins.lua       # Plugin specifications
    │   └── plugins/          # Individual configs
    │
    └── Lazy Loading:
        - Event-based (BufRead, InsertEnter)
        - Command-based (on demand)
        - Filetype-based (language-specific)
```

#### Zsh (Zinit)

```
.zshrc
    │
    ├── Zinit Framework
    │   ├── Fast plugin loading
    │   └── Turbo mode plugins
    │
    └── Performance:
        - Async plugin loading
        - Completion caching
        - Lazy command definitions
```

## Data Flow

### Command Execution Path

```
User Input
    │
    ├── Shell Aliases ──────> Direct execution
    │
    ├── Shell Functions ────> Processing ──> Execution
    │
    └── External Commands ──> PATH lookup ──> Tool execution
                                   │
                                   └──> Modern tool replacements
```

### Configuration Loading

```
System Boot
    │
    ├── Shell Init (.zprofile)
    │   └── Environment setup
    │
    ├── Interactive Shell (.zshrc)
    │   ├── Zinit
    │   ├── Plugins
    │   └── Aliases
    │
    └── Application Launch
        ├── Read configs
        ├── Apply theme
        └── Load plugins
```

## Performance Optimizations

### Startup Time Optimization

1. **Lazy Loading**
   Neovim plugins load on demand
   Shell plugins use async loading
   Completions cached after first generation

2. **Caching Strategy**
   Font cache for terminal rendering
   Completion cache for faster suggestions
   Theme state cached between sessions

3. **Process Management**
   Background services (language servers)
   Persistent sessions (tmux)
   Daemon processes (Ollama for AI)

### Resource Usage

| Component | Memory | CPU      | Startup Time |
|-----------|--------|----------|--------------|
| Alacritty | ~50MB  | Low      | <100ms       |
| Neovim    | ~100MB | Variable | <125ms        |
| tmux      | ~20MB  | Minimal  | Instant      |
| Zsh       | ~30MB  | Low      | <200ms       |

## Security Considerations

### Credential Management

API keys in `~/.zshrc.local` (gitignored)
SSH keys in standard locations
GPG integration for commit signing

### Permission Model

User-space installations (Homebrew)
No system modification required
Isolated virtual environments

## Extensibility Points

### Adding New Tools

1. **Package Installation**
   ```bash
   # Add to src/setup/packages/brewfile
   brew "new-tool"
   ```

2. **Configuration**
   ```bash
   # Add to src/config/new-tool/
   # Symlink in setup script
   ```

3. **Integration**
   ```bash
   # Add aliases to src/zsh/aliases.zsh
   # Add to theme switcher if needed
   ```

### Custom Plugins

**Neovim** Add to `lua/config/plugins.lua`
**Zsh** Add to `.zshrc` plugin list
**tmux** Add to `.tmux.conf` with TPM

## Maintenance Strategy

### Update Workflow

```
Regular Updates (weekly)
    │
    ├── System: brew upgrade
    ├── Neovim: :Lazy sync
    ├── tmux: prefix + U
    └── Shell: zinit update

Major Updates (monthly)
    │
    └── Full system update script
```

### Backup Strategy

Git repository for configurations
Local backups before major changes
Restoration scripts for quick recovery

---

<p align="center">
  <a href="../README.md">← Back to Documentation</a> •
  <a href="integration.md">Integration Details →</a>
</p>
