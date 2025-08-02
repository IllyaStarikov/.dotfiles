# Migration Guide: macOS-Only to Universal Setup

This guide helps you transition from the macOS-only dotfiles setup to the new universal setup that supports both macOS and Linux.

## Overview

The universal setup maintains full compatibility with macOS while adding Linux support. All existing functionality is preserved.

## What's Changed

### New Universal Files
- `src/zshrc.universal` - Cross-platform Zsh configuration
- `src/tmux.conf.universal` - Cross-platform tmux configuration  
- `src/alacritty.toml.universal` - Cross-platform Alacritty configuration
- `src/scripts/update-universal` - Cross-platform update script
- `src/theme-switcher/switch-theme-universal.sh` - Cross-platform theme switcher

### New Setup Scripts
- `src/setup/setup.sh` - Main entry point (detects OS automatically)
- `src/setup/setup-linux.sh` - Linux-specific setup
- `src/setup/setup-macos.sh` - macOS-specific setup
- `src/setup/setup-common.sh` - Shared setup logic
- `src/setup/setup-helpers.sh` - Helper functions

## Migration Steps

### 1. Backup Current Configuration
```bash
# Create a backup of your current setup
cp -r ~/.dotfiles ~/.dotfiles.backup
```

### 2. Update Repository
```bash
cd ~/.dotfiles
git pull origin main
```

### 3. Run the New Setup
```bash
# The new setup script will detect your OS automatically
./src/setup/setup.sh
```

### 4. Update Symlinks
```bash
# Update all symlinks to use universal versions
./src/setup/aliases.sh
```

### 5. Restart Your Shell
```bash
exec zsh
```

## Key Differences

### Zsh Configuration
- Now uses Zinit instead of Oh My Zsh (faster, more minimal)
- Platform-aware PATH management
- Cross-platform clipboard aliases (clip/paste work on both OS)
- Universal `open` command that works on both platforms

### Theme Switching
- Automatically detects desktop environment on Linux
- Falls back gracefully if detection fails
- Same `theme` command works on both platforms

### Update Script
- Detects package manager automatically on Linux
- Supports: apt, dnf, yum, pacman, zypper
- Updates Flatpak and Snap packages if installed
- Same `update` command works on both platforms

### Alacritty Configuration
- Uses Ctrl+Shift instead of Command for cross-platform compatibility
- You can create a local override file at `~/.config/alacritty/local.toml` for OS-specific bindings

### tmux Configuration
- Clipboard integration works automatically on both platforms
- Falls back to file-based clipboard if xclip/xsel not available on Linux

## Maintaining OS-Specific Settings

### Local Overrides
Create `~/.zshrc.local` for machine-specific settings:
```bash
# Example: macOS-specific aliases
if [[ "$OS_TYPE" == "macos" ]]; then
    alias code="/Applications/Visual Studio Code.app/Contents/Resources/app/bin/code"
fi
```

### Platform Detection in Scripts
The universal setup exports these variables:
- `$OS_TYPE` - "macos", "linux", or "unknown"
- `$IS_WSL` - Set to 1 if running on WSL

## Troubleshooting

### Fonts Not Working on Linux
Run the font installation manually:
```bash
~/.dotfiles/src/setup/setup-linux.sh install_fonts
```

### Theme Not Switching on Linux
Install required tools:
```bash
# For GNOME
sudo apt install gsettings

# For KDE
sudo apt install kde-config

# For XFCE
sudo apt install xfconf
```

### Clipboard Not Working on Linux
Install clipboard utilities:
```bash
# Debian/Ubuntu
sudo apt install xclip xsel

# Fedora
sudo dnf install xclip xsel

# Arch
sudo pacman -S xclip xsel
```

## Rollback (if needed)

If you need to rollback to the macOS-only setup:
```bash
# Restore backup
rm -rf ~/.dotfiles
mv ~/.dotfiles.backup ~/.dotfiles

# Re-run original setup
~/.dotfiles/src/setup/aliases.sh

# Restart shell
exec zsh
```

## Support

For issues or questions:
1. Check existing issues at the repository
2. Review the CLAUDE.md file for AI-assisted troubleshooting
3. Create a new issue with your OS details and error messages