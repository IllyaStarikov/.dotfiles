# Setup Scripts - Production Ready Installation

This directory contains three production-ready scripts for setting up a complete development environment on macOS. Each script is designed to be idempotent (safe to run multiple times) with comprehensive error handling.

**Important:** These scripts are completely self-contained with all package lists hardcoded. They do not require access to any external files or private repositories to function properly.

## 📋 Quick Start

```bash
# Run from the .dotfiles root directory
./src/setup/1-core-system.sh
# Restart terminal, then:
./src/setup/2-development.sh
./src/setup/3-tooling.sh
```

## 🔧 Script Overview

### Part 1: Core System Setup (`1-core-system.sh`)
**Foundation setup - run this first**

**What it installs:**
- Xcode Command Line Tools
- Homebrew package manager
- Git version control
- Oh My Zsh shell framework
- Spaceship theme for Zsh
- Basic directory structure
- **Core essential packages:**
  - Terminal: alacritty, tmux, tmuxinator
  - Editors: vim, neovim
  - Utilities: fzf, eza, tree, htop, jq, ranger
  - Languages: lua, luajit, luarocks
  - Fonts: Hack Nerd Font
  - Window management: Amethyst

**Prerequisites:** Fresh macOS installation
**Duration:** ~5-10 minutes
**Reboot required:** No, but terminal restart recommended

---

### Part 2: Development Environment (`2-development.sh`)
**Complete development environment setup**

**What it installs:**
- **Python:** pyenv, pyenv-virtualenv, pyright, ruff, black
- **Languages:** node, ruby, rust
- **Docker:** docker, docker-compose, colima, lima
- **Dev tools:** cloc, ctags, gnu-sed, marksman, texlab
- Vim-Plug for Neovim plugin management
- Python packages: neovim, ipython
- IBM Plex Mono Nerd Font
- All configuration symlinks
- Theme switcher integration

**Prerequisites:** Part 1 completed, terminal restarted
**Duration:** ~10-15 minutes
**Network required:** Yes (downloads fonts and packages)

---

### Part 3: Additional Tooling (`3-tooling.sh`)
**Nice-to-have utilities and complete package restoration**

**What it installs:**
- **Fun tools:** cmatrix, cowsay, neofetch
- **Media tools:** ffmpeg, imagemagick, yt-dlp, tesseract
- **Additional languages:** dotnet@8, emscripten, openjdk, gcc, llvm
- **GUI applications:** 1Password, Fork, ImageOptim, Calibre, VirtualBox
- **QuickLook plugins:** qlcolorcode, qlmarkdown, qlimagesize
- **100+ libraries and dependencies** (video codecs, build tools, system libraries)
- Ollama with llama3.2 model for AI coding
- Python environment with development tools
- Essential services (colima, unbound)

**Prerequisites:** Parts 1 & 2 completed
**Duration:** ~30-60 minutes (depending on packages)
**Network required:** Yes (large downloads)

## 🛡️ Safety Features

### Error Handling
- **Graceful failures:** Scripts continue on non-critical errors
- **Clear messaging:** ✅ Success, ⚠️ Warning, ❌ Error indicators
- **Exit codes:** Scripts exit with appropriate codes on critical failures
- **Network resilience:** Retries and fallbacks for network operations

### Idempotency (Safe Reruns)
- **Duplicate detection:** All installations check if already present
- **Skip existing:** Shows "already installed" for existing components
- **Safe symlinks:** Uses `ln -sf` for safe link replacement
- **Backup protection:** Timestamped backups of existing configurations

### Production Features
- **Directory validation:** Ensures scripts run from correct location
- **Prerequisites checking:** Validates dependencies before proceeding
- **Progress indicators:** Clear status updates throughout execution
- **Comprehensive logging:** Detailed output for troubleshooting

## 📦 Package Lists

### Essential Packages (Part 1)
```
alacritty, vim, neovim, tmux, tmuxinator, fzf, eza, tree, htop, jq, ranger,
lua, luajit, luarocks, git-extras, git-lfs, colordiff
```

### Development Packages (Part 2)
```
pyenv, pyenv-virtualenv, pyright, ruff, black, node, ruby, rust,
docker, docker-compose, colima, lima, cloc, ctags, marksman, texlab
```

### Optional Packages (Part 3)
The complete list includes fun tools, media processors, additional languages, GUI apps, and 100+ system libraries.

**Key categories:**
- **Development:** docker, colima, rust, node, python, gcc, llvm
- **Media Processing:** ffmpeg, imagemagick, yt-dlp
- **CLI Utilities:** eza, htop, jq, tree, ripgrep, bat
- **Git Tools:** git-extras, git-lfs, git-filter-repo
- **Languages:** lua, ruby, python@3.13, python@3.8, python@3.9
- **AI Tools:** ollama (with llama3.2 model)

## 🔍 Troubleshooting

### Common Issues

**"Command not found" after installation:**
```bash
# Restart terminal or reload shell
exec zsh
# Or source the configuration
source ~/.zshrc
```

**Homebrew PATH issues:**
```bash
# Add to current session
export PATH="/opt/homebrew/bin:$PATH"  # Apple Silicon
export PATH="/usr/local/bin:$PATH"     # Intel Mac
```

**Permission errors:**
```bash
# Fix Homebrew permissions
sudo chown -R $(whoami) /opt/homebrew/*  # Apple Silicon
sudo chown -R $(whoami) /usr/local/*     # Intel Mac
```

**Python package installation fails:**
```bash
# Upgrade pip first
python3 -m pip install --upgrade pip
# Then rerun the script
```

### Script Failures

**Part 1 fails:** Usually network or permissions
- Check internet connection
- Verify admin privileges
- Try running individual commands manually

**Part 2 fails:** Usually missing prerequisites
- Ensure Part 1 completed successfully
- Restart terminal before running Part 2
- Check that Homebrew is in PATH

**Part 3 fails:** Usually specific package issues
- Script continues on individual package failures
- Check brew logs: `brew doctor`
- Manually install failed packages later

## 🔄 Re-running Scripts

All scripts are designed to be safely rerun:

**First run:** Installs everything needed
**Subsequent runs:** 
- Skips existing installations
- Shows "✅ already installed" messages
- Updates existing packages to latest versions
- Does not duplicate or break existing setups

## 📝 Customization

### Adding Packages
To add packages to the appropriate part:

**Part 1 (Essential):** Edit `CORE_PACKAGES` array in `1-core-system.sh`
**Part 2 (Development):** Edit `DEV_PACKAGES` array in `2-development.sh`  
**Part 3 (Tooling):** Edit the category-specific arrays in `3-tooling.sh`:
- `FUN_PACKAGES` - Fun/entertainment tools
- `MEDIA_PACKAGES` - Media processing tools
- `PROG_PACKAGES` - Additional programming languages
- `LIBRARIES` - System libraries and dependencies
- `OPTIONAL_CASKS` - GUI applications

### Modifying Python Packages
Edit the `PIP_PACKAGES` array in Part 3:

```bash
PIP_PACKAGES=("neovim" "ipython" "black" "ruff" "your-package")
```

### Theme Customization
Theme switching is handled automatically via the theme-switcher system. Configurations are in `src/theme-switcher/themes/`.

## 📊 System Requirements

- **macOS:** 10.15+ (Catalina or later)
- **RAM:** 8GB+ recommended for full package set
- **Storage:** ~10GB free space for all packages
- **Network:** Broadband recommended (large downloads)
- **Privileges:** Admin access required for some installations

## 🚀 Performance Notes

- **Part 1:** Lightweight, completes quickly
- **Part 2:** Medium impact, includes font downloads
- **Part 3:** Heavy, installs 170+ packages including:
  - Large packages: llvm, gcc, emscripten, dotnet
  - GUI applications: Docker Desktop, VirtualBox
  - AI models: llama3.2 (several GB)

Consider running Part 3 overnight or during off-peak hours.

## 🔐 Security

All scripts:
- Download from official sources only
- Use HTTPS for all network operations
- Verify package integrity via Homebrew
- Create backups before overwriting files
- Never require `sudo` for normal operations (except `chsh`)

## 📚 Additional Resources

- [Homebrew Documentation](https://docs.brew.sh/)
- [Oh My Zsh Documentation](https://ohmyz.sh/)
- [Neovim Documentation](https://neovim.io/doc/)
- [tmux Documentation](https://github.com/tmux/tmux/wiki)

---

## Manual Installation Tasks (Legacy Notes)
- Install [iStat](https://bjango.com/mac/istatmenus/)
- Review MacApp store
- Download [Logitech software](https://www.logitech.com/en-us/software/options.html)
- Download [Bartender](https://www.macbartender.com/)
