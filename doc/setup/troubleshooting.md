# Troubleshooting Guide

> **Solutions for common setup and configuration issues**

## Quick Diagnostics

```bash
# Run comprehensive health check
nvim +checkhealth
brew doctor

# Individual component checks
brew doctor                      # Homebrew issues
nvim +checkhealth               # Neovim configuration
tmux info                       # tmux server status
echo $SHELL                     # Current shell
```

## Installation Issues

### Homebrew Problems

**Cannot install in Homebrew on ARM processor**

```bash
# Solution: Ensure correct architecture
arch -arm64 brew install <package>  # Apple Silicon
arch -x86_64 brew install <package> # Intel/Rosetta
```

**Permission denied errors**

```bash
# Fix Homebrew permissions
sudo chown -R $(whoami) $(brew --prefix)/*
brew doctor
```

**No formulae found**

```bash
# Update Homebrew
brew update
brew tap homebrew/core
```

### Shell Configuration

**Command not found after installation**

```bash
# Reload shell configuration
exec zsh -l

# Verify PATH
echo $PATH | tr ':' '\n'

# Check shell
echo $SHELL
which zsh
```

**Zinit not loading**

```bash
# Verify installation
ls -la ~/.local/share/zinit

# Reinstall if needed
rm -rf ~/.local/share/zinit
exec zsh  # Will auto-reinstall

# Check plugin loading
zinit status
```

### Neovim Issues

**Plugins not installing**

```bash
# In Neovim
:Lazy sync
:Lazy clean
:Lazy restore

# Clear cache
rm -rf ~/.local/share/nvim
rm -rf ~/.cache/nvim
```

#### Issue: LSP servers not working

```bash
# In Neovim
:LspInfo
:Mason
:MasonInstallAll

# Manual installation
:MasonInstall pyright lua-language-server
```

#### Issue: Treesitter errors

```bash
# In Neovim
:TSUpdate
:TSInstall! all
```

### tmux Problems

#### Issue: Plugins not loading

```bash
# Install TPM manually
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# In tmux
# Press: Ctrl-a, Shift-I
```

#### Issue: "server not found" error

```bash
# Kill all tmux sessions
tmux kill-server

# Start fresh
tmux new -s main
```

### Terminal Display Issues

#### Issue: Broken characters/icons

```bash
# Verify font installation
fc-list | grep -i "nerd"

# Reinstall fonts
brew reinstall --cask font-fira-code-nerd-font
brew reinstall --cask font-jetbrains-mono-nerd-font

# Clear font cache
sudo atsutil databases -remove
```

#### Issue: Colors not displaying correctly

```bash
# Check terminal capabilities
echo $TERM
infocmp $TERM | grep -E "colors|RGB"

# Set correct TERM
export TERM=xterm-256color  # or alacritty
```

## Performance Issues

### Slow Shell Startup

```bash
# Profile zsh startup
time zsh -i -c exit

# Detailed profiling
zsh -xvf 2>&1 | ts -i "%.s" > /tmp/zsh-startup.log

# Check for slow plugins
zinit times
```

### Neovim Startup Time

```vim
" Profile startup
:StartupTime

" Disable plugins temporarily
:Lazy profile

" Check specific plugin
:Lazy load <plugin-name>
```

### High CPU Usage

```bash
# Identify culprit
htop

# Common causes:
# - Language servers
# - File watchers
# - Background indexing
```

## Git Configuration Issues

### Issue: "fatal: not a git repository"

```bash
# Initialize git in dotfiles
cd ~/.dotfiles
git init
git remote add origin https://github.com/IllyaStarikov/.dotfiles.git
```

### Issue: Delta not working

```bash
# Verify installation
which delta

# Check git config
git config --get core.pager

# Reinstall
brew reinstall git-delta
```

## Theme Switching Problems

### Issue: Theme not changing

```bash
# Manual theme switch
~/.dotfiles/src/theme-switcher/switch-theme.sh

# Check theme files
ls -la ~/.config/alacritty/theme.toml
ls -la ~/.config/tmux/theme.conf

# Reset theme cache
rm -rf ~/.cache/theme-switcher
```

### Issue: Partial theme application

```bash
# Force reload all components
killall tmux
theme

# In Neovim
:source $MYVIMRC
```

## Network-Related Issues

### Issue: Package downloads failing

```bash
# Check DNS
scutil --dns

# Use alternative DNS
sudo networksetup -setdnsservers Wi-Fi 8.8.8.8 8.8.4.4

# Reset DNS cache
sudo dscacheutil -flushcache
```

### Issue: SSL certificate errors

```bash
# Update certificates
brew install ca-certificates
brew link --force ca-certificates

# For Python
pip install --upgrade certifi
```

## Recovery Procedures

### Complete Reset

```bash
# Backup current config
mv ~/.dotfiles ~/.dotfiles.backup

# Fresh installation
git clone https://github.com/IllyaStarikov/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles
./src/setup/mac.sh
```

### Partial Reset

```bash
# Reset Neovim
rm -rf ~/.config/nvim ~/.local/share/nvim ~/.local/state/nvim
cd ~/.dotfiles && ./src/setup/aliases.sh

# Reset tmux
rm -rf ~/.tmux/plugins
tmux kill-server
cd ~/.dotfiles && ./src/setup/aliases.sh

# Reset shell
rm ~/.zshrc ~/.oh-my-zsh
cd ~/.dotfiles && ./src/setup/mac.sh
```

## Debug Mode

### Enable Verbose Logging

```bash
# Shell debugging
set -x  # Enable
set +x  # Disable

# Neovim debugging
nvim -V9nvim.log

# Git debugging
GIT_TRACE=1 git <command>
```

## Getting Help

### Diagnostic Information

When reporting issues, include:

```bash
# System info
sw_vers
uname -a
arch

# Tool versions
brew --version
nvim --version
tmux -V
zsh --version

# Configuration
echo $SHELL
echo $PATH
```

### Resources

- [Homebrew Troubleshooting](https://docs.brew.sh/Troubleshooting)
- [Neovim FAQ](https://neovim.io/doc/user/faq.html)
- [tmux FAQ](https://github.com/tmux/tmux/wiki/FAQ)
- [Zinit Documentation](https://github.com/zdharma-continuum/zinit)

---

<p align="center">
  <a href="README.md">← Back to Setup</a>
</p>