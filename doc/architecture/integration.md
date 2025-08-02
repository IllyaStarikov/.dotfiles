# Integration Architecture

> **How components work together seamlessly**

## Theme Synchronization

### Overview

Our theme system provides automatic synchronization across all tools based on macOS appearance settings.

```
┌─────────────────┐
│ macOS Dark Mode │
└────────┬────────┘
         │
    ┌────▼─────┐
    │  Theme   │
    │ Switcher │
    └────┬─────┘
         │
    ┌────▼──────────────────────────────────┐
    │         Configuration Files           │
    ├───────────────────┬───────────────────┤
    │ Alacritty         │ ~/.config/        │
    │ theme.toml        │ alacritty/        │
    ├───────────────────┼───────────────────┤
    │ tmux              │ ~/.config/        │
    │ theme.conf        │ tmux/             │
    ├───────────────────┼───────────────────┤
    │ Environment       │ ~/.config/        │
    │ Variables         │ theme-switcher/   │
    └───────────────────┴───────────────────┘
```

### Implementation Details

1. **Detection**: `defaults read -g AppleInterfaceStyle`
2. **Configuration Generation**: Theme files created in `~/.config/`
3. **Application**: Each tool sources its theme configuration
4. **Persistence**: State saved for session restoration

### Affected Components

| Component | Light Theme | Dark Theme | Config Path |
|-----------|-------------|------------|-------------|
| Alacritty | Tokyo Night Day | Tokyo Night Moon | `~/.config/alacritty/theme.toml` |
| Neovim | Auto-detected | Auto-detected | Via `$MACOS_THEME` |
| tmux | Custom light | Custom dark | `~/.config/tmux/theme.conf` |
| Starship | Minimal | Vibrant | Via environment |
| bat | GitHub | Dracula | Via `$BAT_THEME` |
| delta | GitHub | Dracula | In `.gitconfig` |

## Clipboard Integration

### System-Wide Clipboard

```
┌──────────┐     ┌──────────┐     ┌──────────┐
│  macOS   │◄────┤   tmux   │◄────┤  Neovim  │
│Clipboard │     │   yank   │     │    "+    │
└──────────┘     └──────────┘     └──────────┘
     ▲                                   │
     │                                   │
     └───────────────────────────────────┘
```

### Configuration

- **Neovim**: `clipboard = "unnamedplus"`
- **tmux**: `tmux-yank` plugin with `set -g @yank_selection_mouse 'clipboard'`
- **Shell**: pbcopy/pbpaste integration

## Navigation Integration

### Seamless Movement

```
┌─────────────────────────────────────┐
│        vim-tmux-navigator           │
├─────────────┬───────────┬───────────┤
│   Neovim    │   tmux    │   Shell   │
│ <C-h/j/k/l> │<C-h/j/k/l>│  vi-mode  │
└─────────────┴───────────┴───────────┘
```

### Implementation

1. **Neovim**: `vim-tmux-navigator` plugin
2. **tmux**: Smart pane switching
3. **Shell**: Vi-mode with same bindings

## Completion System

### Unified Experience

```
┌─────────────────────────────────────┐
│        Completion Sources           │
├──────────┬──────────┬───────────────┤
│   LSP    │ Snippets │ Buffer/Path   │
└────┬─────┴────┬─────┴───────┬───────┘
     │          │             │
     └──────────▼─────────────┘
            Blink.cmp
                │
         ┌──────▼──────┐
         │   Fuzzy     │
         │  Matching   │
         └─────────────┘
```

### Priority System

1. **LSP** (score_offset: 100)
2. **Snippets** (score_offset: 80)
3. **Path** (score_offset: 50)
4. **Buffer** (score_offset: 30)

## Git Integration

### Multi-Level Integration

```
Shell Aliases ──┐
                ├──> Git Commands ──> Delta ──> Output
Neovim Fugitive ┤
                │
LazyGit UI ─────┘
```

### Features

- **Aliases**: 150+ git shortcuts
- **Visual Diff**: Delta integration
- **Editor Integration**: Fugitive + Gitsigns
- **UI**: LazyGit for complex operations

## AI Integration

### Context Flow

```
┌─────────────┐     ┌──────────────┐     ┌────────────┐
│   Buffer    │────▶│              │────▶│            │
│  Content    │     │ CodeCompanion│     │   Ollama   │
├─────────────┤     │              │     │  (Local)   │
│  Selection  │────▶│   Context    │     ├────────────┤
├─────────────┤     │   Builder    │────▶│  Claude    │
│   Files     │────▶│              │     │  (Cloud)   │
└─────────────┘     └──────────────┘     └────────────┘
```

### Smart Context

1. **Automatic**: Current buffer/selection
2. **Manual**: `/file`, `/buffer` commands
3. **Project**: Git status, file tree
4. **History**: Previous interactions

## Performance Optimization

### Lazy Loading Strategy

```
Startup ──┐
          ├──> Essential Only
          │
User Action ──> Load on Demand ──> Cache
          │
          └──> Background Load ──> Ready
```

### Caching Layers

| Component     | Cache Type        | Location                     |
|---------------|-------------------|------------------------------|
| Completions   | Frecency          | `~/.local/share/nvim/`       |
| File Search   | mtime             | In-memory                    |
| Git Status    | FileSystemWatcher | Buffer-local                 |
| Theme State   | File              | `~/.config/theme-switcher/`  |
| Z Directories | Frecency          | `~/.z`                       |

## Plugin Communication

### Event System

```
┌─────────────┐
│  Vim Events │
└──────┬──────┘
       │
   ┌───▼────┐     ┌────────────┐     ┌─────────┐
   │ BufRead├────▶│ Treesitter ├────▶│ Blink   │
   └────────┘     └────────────┘     └─────────┘
       │
   ┌───▼────────┐     ┌──────────┐
   │  FileType  ├────▶│   LSP    │
   └────────────┘     └──────────┘
```

### Shared State

- **LSP Diagnostics**: Available to Trouble, Gitsigns, statusline
- **Git Status**: Shared between Gitsigns, statusline, explorer
- **Theme**: Environment variable for all tools

## Security Considerations

### Credential Flow

```
┌─────────────┐     ┌─────────────┐     ┌────────────┐
│ .zshrc.local│────▶│ Environment │────▶│ Application│
│  (ignored)  │     │  Variables  │     │   Usage    │
└─────────────┘     └─────────────┘     └────────────┘
```

### Isolation

- **API Keys**: Never in version control
- **SSH Keys**: Standard locations only
- **GPG**: System keychain integration

---

<p align="center">
  <a href="README.md">← Back to Architecture</a>
</p>

