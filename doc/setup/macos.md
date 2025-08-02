# macOS-Specific Setup

> **Optimizations and configurations for macOS environments**

## System Preferences

### Essential macOS Settings

```bash
# Show hidden files in Finder
defaults write com.apple.finder AppleShowAllFiles -bool true
killall Finder

# Enable key repeat (for vim users)
defaults write -g ApplePressAndHoldEnabled -bool false

# Faster key repeat
defaults write -g KeyRepeat -int 2
defaults write -g InitialKeyRepeat -int 15

# Disable smart quotes and dashes
defaults write -g NSAutomaticQuoteSubstitutionEnabled -bool false
defaults write -g NSAutomaticDashSubstitutionEnabled -bool false
```

### Development Environment

```bash
# Install Xcode Command Line Tools
xcode-select --install

# Accept Xcode license
sudo xcodebuild -license accept
```

## Architecture-Specific Setup

### Apple Silicon (M1/M2/M3)

```bash
# Rosetta 2 for x86_64 compatibility
softwareupdate --install-rosetta --agree-to-license

# Homebrew installation path
# Apple Silicon: /opt/homebrew
# Intel: /usr/local
```

### Path Configuration

Add to `~/.zprofile`:

```bash
# Apple Silicon Homebrew
if [[ -f /opt/homebrew/bin/brew ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# Intel Homebrew
if [[ -f /usr/local/bin/brew ]]; then
    eval "$(/usr/local/bin/brew shellenv)"
fi
```

## Security Considerations

### Gatekeeper

```bash
# Allow apps from anywhere (use carefully)
sudo spctl --master-disable

# Re-enable Gatekeeper
sudo spctl --master-enable
```

### File Permissions

```bash
# Fix Homebrew permissions
sudo chown -R $(whoami) $(brew --prefix)/*

# Fix npm permissions
mkdir ~/.npm-global
npm config set prefix '~/.npm-global'
echo 'export PATH=~/.npm-global/bin:$PATH' >> ~/.zprofile
```

## Performance Optimizations

### Shell Performance

```bash
# Disable Homebrew auto-update
export HOMEBREW_NO_AUTO_UPDATE=1

# Speed up zsh completion
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache
```

### System Resources

```bash
# Increase file descriptor limit
ulimit -n 10240

# Add to /etc/sysctl.conf
kern.maxfiles=65536
kern.maxfilesperproc=65536
```

## Font Configuration

### Terminal Fonts

1. **Install via Homebrew**:
   ```bash
   brew install --cask font-fira-code-nerd-font
   ```

2. **Configure applications**:
   - **Alacritty**: Automatically configured
   - **Terminal.app**: Preferences → Profiles → Text → Font
   - **iTerm2**: Preferences → Profiles → Text → Font

### Font Smoothing

```bash
# Adjust font smoothing (if text appears too thin)
defaults -currentHost write -g AppleFontSmoothing -int 2
```

## Application-Specific Setup

### Alacritty

```bash
# Grant full disk access for better performance
# System Preferences → Security & Privacy → Privacy → Full Disk Access
# Add: /Applications/Alacritty.app
```

### tmux

```bash
# Install tmux-256color terminfo
curl -LO https://invisible-island.net/datafiles/current/terminfo.src.gz
gunzip terminfo.src.gz
tic -xe tmux-256color terminfo.src
```

## Troubleshooting

### Common macOS Issues

| Issue | Solution |
|-------|----------|
| "xcrun: error: invalid active developer path" | `xcode-select --install` |
| Homebrew SSL certificate errors | `brew install ca-certificates` |
| "operation not permitted" errors | Grant Full Disk Access to Terminal |
| Slow terminal startup | Disable shell integration in iTerm2 |
| Font rendering issues | Adjust AppleFontSmoothing value |

### Reset Shell Environment

```bash
# Reset PATH to default
export PATH="/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin"

# Reload shell configuration
exec zsh -l
```

## References

- [macOS Setup Guide](https://sourabhbajaj.com/mac-setup/)
- [Homebrew Documentation](https://docs.brew.sh)
- [Apple Developer - Shell Scripting](https://developer.apple.com/library/archive/documentation/OpenSource/Conceptual/ShellScripting/)

---

<p align="center">
  <a href="README.md">← Back to Setup</a>
</p>