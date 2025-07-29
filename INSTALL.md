# Installation Guide

## Quick Install (macOS)

```bash
# Clone the repository
git clone https://github.com/IllyaStarikov/.dotfiles.git ~/.dotfiles

# Run the setup script
cd ~/.dotfiles
bash src/setup/mac.sh
```

## Manual Installation Steps

### 1. Prerequisites

- macOS (Intel or Apple Silicon)
- Internet connection
- Admin privileges for installing software

### 2. What Gets Installed

- **Package Managers**: Homebrew
- **Shell**: Oh My Zsh with Spaceship theme
- **Editor**: Neovim with modern Lua configuration
- **Terminal**: Configuration for Alacritty
- **Multiplexer**: tmux with custom configuration
- **Languages**: Python (via pyenv)
- **Fonts**: FiraCode Nerd Font and others
- **CLI Tools**: eza, bat, ripgrep, fd, fzf, and more

### 3. Post-Installation

After running the setup script:

1. **Restart your terminal** or run `source ~/.zshrc`
2. **Install Neovim plugins**: Open nvim and run `:Lazy`
3. **Set your theme**: Run `theme` to configure colors
4. **Optional**: Install Alacritty with `brew install --cask alacritty`

### 4. Updating

To update your dotfiles:

```bash
cd ~/.dotfiles
git pull
bash src/setup/aliases.sh  # Re-link any new files
```

### 5. Troubleshooting

- **Oh My Zsh installation stops the script**: This is normal. Just run the script again.
- **Permission errors**: Make sure you have admin privileges
- **Homebrew not found**: The script will install it automatically
- **Theme not working**: Run `theme default` to reset

### 6. Customization

- Personal settings go in `~/.dotfiles.private/` (gitignored)
- Theme preferences: Edit `~/.config/theme-switcher/current-theme.sh`
- Additional packages: Add to `src/setup/mac.sh`

## Features

- 🎨 **Dynamic theme switching** based on macOS appearance
- 🚀 **Optimized Neovim** with LSP, completion, and AI assistance
- 🖥️ **tmux integration** with vim-like keybindings
- 🔍 **Modern CLI tools** replacing traditional Unix utilities
- ⚡ **Fast shell** with syntax highlighting and autosuggestions

## Support

Report issues at: https://github.com/IllyaStarikov/.dotfiles/issues