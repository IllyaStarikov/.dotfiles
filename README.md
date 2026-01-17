# dotfiles

> Power of an IDE, speed of a text editor.

![macOS](https://img.shields.io/badge/macOS-black?logo=apple)
![Linux](https://img.shields.io/badge/Linux-black?logo=linux&logoColor=white)
![Neovim](https://img.shields.io/badge/Neovim-black?logo=neovim)
![License](https://img.shields.io/github/license/IllyaStarikov/dotfiles)

![dotfiles](template/dotfiles.png)

## Demo

*Coming soon - animated demo of key features*

## Requirements

| Platform | Version |
|----------|---------|
| macOS | 12.0+ (Intel or Apple Silicon) |
| Ubuntu | 20.04+ |
| Debian | 11+ |
| Fedora | 35+ |
| Arch | Rolling |

**Prerequisites:**
- `git` 2.30+
- `curl` or `wget`
- `zsh` shell (macOS default, install on Linux)
- ~5GB disk space (full install)
- Internet connection

## Install

### Quick Start

```bash
git clone https://github.com/IllyaStarikov/dotfiles.git ~/.dotfiles && ~/.dotfiles/src/setup/setup.sh
```

| Mode | Command | Time | Description |
|------|---------|------|-------------|
| Full | `./src/setup/setup.sh` | 15-30 min | Complete environment |
| Core | `./src/setup/setup.sh --core` | 5-10 min | Essential tools only |
| Symlinks | `./src/setup/setup.sh --symlinks` | 30 sec | Link configs only |

**Options:** `--skip-brew` (corporate machines) · `--verbose` · `--help`

## Features

- **Neovim**
  - 80+ plugins, lazy-loaded
  - LSP for 20+ languages
  - ~150ms startup
  - AI integration (Copilot, Ollama)
- **Zsh**
  - Starship prompt
  - Fast completions, syntax highlighting, autosuggestions
- **Theme System** TokyoNight (4 variants)
- **fzf** + **ripgrep** for fast fuzzy search
- **tmux**
  - Intuitive bindings
  - Session management

`neovim` `zsh` `tmux` `git` `fzf` `ripgrep` `starship`

`python` `javascript` `typescript` `go` `rust` `c/c++` `lua` `bash/zsh` `swift` `kotlin` `latex` `markdown`

## Performance

| Component | Measured | Notes |
|-----------|----------|-------|
| Neovim startup | 150ms | M1 Mac, 80+ plugins |
| Zsh startup | 50-150ms | Zinit turbo mode |
| tmux startup | ~125ms | New session |
| Theme switching | <500ms | All apps synced |
| Memory usage | <200MB | Under normal load |

## Documentation

### Core Components

| Component | Description |
|-----------|-------------|
| [Neovim](src/neovim/README.md) | 80+ plugins, LSP, AI integration |
| [Zsh](src/zsh/README.md) | Zinit, completions, prompt |
| [Git](src/git/README.md) | SSH signing, delta, hooks |
| [Scripts](src/scripts/README.md) | fixy, theme, update, utilities |
| [Setup](src/setup/README.md) | Installation, platform detection |
| [Themes](src/theme-switcher/README.md) | TokyoNight, app sync |

### Guides

| Guide | Description |
|-------|-------------|
| [Quick Start](doc/setup/README.md) | Get up and running |
| [Customization](doc/guides/README.md) | Make it yours |
| [Usage Reference](doc/usage/README.md) | Commands & keybindings |

### Development

| Resource | Description |
|----------|-------------|
| [Language Tools](src/language/README.md) | Formatters, linters |
| [Testing](test/README.md) | Test infrastructure |
| [CI/CD](.github/workflows/README.md) | GitHub Actions |

## Uninstall / Reset

```bash
./src/setup/uninstall.sh             # Remove symlinks only
./src/setup/uninstall.sh --restore   # Remove symlinks + restore backups
./src/setup/uninstall.sh --full      # Complete removal
./src/setup/uninstall.sh --dry-run   # Preview changes
```

Backups are at `~/.dotfiles.backups/`

## Contributing

Bug fixes and improvements welcome. These are personal dotfiles, so features may be declined if they don't fit my workflow.

## License

MIT - See [LICENSE](LICENSE) for details.

---

<div align="center">
  <sub>A decade of vim, mostly because I couldn't figure out how to exit.</sub>
</div>
