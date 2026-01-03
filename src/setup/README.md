# Setup & Installation

Automated installation system for dotfiles across macOS and Linux.

## Quick Start

```bash
# Full installation (15-30 min)
./src/setup/setup.sh

# Core tools only (5-10 min)
./src/setup/setup.sh --core

# Symlinks only (30 sec)
./src/setup/symlinks.sh
```

## Installation Modes

| Mode     | Command                 | Description          | Use Case       |
| -------- | ----------------------- | -------------------- | -------------- |
| Full     | `./setup.sh`            | Complete environment | New machines   |
| Core     | `./setup.sh --core`     | Essential tools      | Minimal setups |
| Symlinks | `./setup.sh --symlinks` | Links only           | Config updates |

## Scripts

### setup.sh

Main installation script with platform detection.

**Options:**

- `--core` - Essential packages only
- `--symlinks` - Create symlinks only
- `--skip-brew` - Skip Homebrew (work machines)
- `--force-brew` - Force Homebrew install
- `--verbose` - Detailed output

**Platforms:**

- macOS (Intel & Apple Silicon)
- Ubuntu/Debian (apt)
- Fedora/RHEL (dnf/yum)
- Arch Linux (pacman)

### symlinks.sh

Creates dotfile symlinks with automatic backups.

**Key Mappings:**

```bash
src/zsh/zshrc → ~/.zshrc
src/git/gitconfig → ~/.gitconfig
src/neovim → ~/.config/nvim
src/kitty → ~/.config/kitty
src/language/*.toml → ~/.*
```

## Packages Installed

### Core Tools

- Git, curl, wget, tree, jq
- ripgrep, fd, fzf, eza
- tmux, tmuxinator
- Neovim
- Starship prompt

### Development

- Node.js, Python 3, Rust, Go
- Docker, kubectl
- GitHub CLI
- Language servers via Mason
- LaTeX tools (latexindent with Perl dependencies)

### macOS Specific

- Homebrew package manager
- Alacritty, WezTerm, Kitty
- Rectangle window manager
- JetBrains Mono Nerd Font

## Work Machine Detection

Automatically detects work environments and adjusts:

- Skips Homebrew if on managed systems
- Loads work-specific configs from `.dotfiles.private`
- Preserves existing tool installations

## Safety Features

- Automatic backups to `~/.dotfiles-backup/`
- Dry run mode with `--dry-run`
- Rollback support on failure
- Non-destructive symlink creation
- Comprehensive logging

## Troubleshooting

**Homebrew fails on macOS**: Ensure Xcode Command Line Tools installed:

```bash
xcode-select --install
```

**Permission errors**: Don't use sudo, script handles permissions

**Work machine issues**: Use `--skip-brew` flag

**Symlink conflicts**: Check `~/.dotfiles-backup/` for originals

## Lessons Learned

- Never use `sudo` for dotfiles installation
- Always backup before symlinking
- Work detection via hostname prevents package conflicts
- Platform-specific package lists prevent errors
- Atomic operations prevent partial installations
