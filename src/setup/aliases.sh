#!/usr/bin/env bash
# ════════════════════════════════════════════════════════════════════════════════════════════════════════════
# 🔗 DOTFILES SYMLINK MANAGER - Production-Ready Installation Script
# ════════════════════════════════════════════════════════════════════════════════════════════════════════════
# Creates all necessary symlinks from the dotfiles repository to their expected locations
# Features: Atomic operations, automatic backups, comprehensive error handling
# ════════════════════════════════════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# ────────────────────────────────────────────────────────────────────────────────────────────────────────────
# 🎨 CONFIGURATION & CONSTANTS
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────

# Script directory for relative paths
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
readonly BACKUP_DIR="$HOME/.dotfiles.backups/$(date +%Y%m%d_%H%M%S)"

# Color output for better visibility
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly BLUE='\033[0;34m'
readonly MAGENTA='\033[0;35m'
readonly CYAN='\033[0;36m'
readonly NC='\033[0m'  # No Color

# Counters for summary
declare -i SUCCESS_COUNT=0
declare -i SKIP_COUNT=0
declare -i ERROR_COUNT=0

# ────────────────────────────────────────────────────────────────────────────────────────────────────────────
# 🛠️ HELPER FUNCTIONS
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────

# Logging functions with timestamps
log() {
    local level="$1"
    shift
    local timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    echo -e "${timestamp} $level $*"
}

info() { log "${GREEN}[INFO]${NC}" "$@"; }
warn() { log "${YELLOW}[WARN]${NC}" "$@"; }
error() { log "${RED}[ERROR]${NC}" "$@" >&2; }
success() { log "${CYAN}[✓]${NC}" "$@"; ((SUCCESS_COUNT++)); }
skip() { log "${BLUE}[SKIP]${NC}" "$@"; ((SKIP_COUNT++)); }

# Progress indicator
progress() {
    echo -e "\n${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "${MAGENTA}▶${NC} $1"
    echo -e "${MAGENTA}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
}

# Create directory if it doesn't exist
ensure_dir() {
    local dir="$1"
    if [[ ! -d "$dir" ]]; then
        info "Creating directory: $dir"
        if mkdir -p "$dir"; then
            success "Created: $dir"
        else
            error "Failed to create directory: $dir"
            ((ERROR_COUNT++))
            return 1
        fi
    fi
}

# Create symlink with backup
create_symlink() {
    local source="$1"
    local target="$2"
    local link_name="${3:-$(basename "$source")}"
    
    # Check if source exists
    if [[ ! -e "$source" ]]; then
        error "Source does not exist: $source"
        ((ERROR_COUNT++))
        return 1
    fi
    
    # Check if target already points to the correct source
    if [[ -L "$target" ]] && [[ "$(readlink "$target")" == "$source" ]]; then
        skip "Already linked: $link_name"
        return 0
    fi
    
    # Backup existing file if it's not a symlink or points elsewhere
    if [[ -e "$target" ]]; then
        ensure_dir "$BACKUP_DIR"
        local backup_path="$BACKUP_DIR/$(basename "$target")"
        info "Backing up: $target → $backup_path"
        if cp -RPp "$target" "$backup_path"; then
            rm -rf "$target"
        else
            error "Failed to backup: $target"
            ((ERROR_COUNT++))
            return 1
        fi
    fi
    
    # Create parent directory if needed
    local target_dir="$(dirname "$target")"
    ensure_dir "$target_dir" || return 1
    
    # Create symlink
    if ln -sf "$source" "$target"; then
        success "Linked: $link_name"
    else
        error "Failed to create symlink: $source → $target"
        ((ERROR_COUNT++))
        return 1
    fi
}

# ────────────────────────────────────────────────────────────────────────────────────────────────────────────
# 🚀 MAIN INSTALLATION PROCESS
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────

# Welcome message
echo -e "\n${CYAN}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                     DOTFILES INSTALLATION MANAGER                              ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════════════════╝${NC}\n"

progress "Setting up Neovim configuration"
ensure_dir "$HOME/.config/nvim"

# Remove any conflicting init.vim
if [[ -f "$HOME/.config/nvim/init.vim" ]]; then
    info "Removing conflicting init.vim"
    rm -f "$HOME/.config/nvim/init.vim"
fi

# Neovim configuration
create_symlink "$DOTFILES_DIR/init.lua" "$HOME/.config/nvim/init.lua" "Neovim init.lua"
create_symlink "$DOTFILES_DIR/lua" "$HOME/.config/nvim/lua" "Neovim Lua configs"


# ZSH configuration - use universal version
progress "Setting up ZSH configuration"
create_symlink "$DOTFILES_DIR/zshrc.universal" "$HOME/.zshrc" "ZSH configuration (universal)"
create_symlink "$DOTFILES_DIR/zshenv.universal" "$HOME/.zshenv" "ZSH environment (universal)"
ensure_dir "$HOME/.config/zsh"
create_symlink "$DOTFILES_DIR/zsh" "$HOME/.config/zsh" "ZSH config directory"

# Terminal configuration - use universal version
progress "Setting up Alacritty configuration"
ensure_dir "$HOME/.config/alacritty"
create_symlink "$DOTFILES_DIR/alacritty.toml.universal" "$HOME/.config/alacritty/alacritty.toml" "Alacritty config (universal)"

# Git configuration
progress "Setting up Git configuration"
create_symlink "$DOTFILES_DIR/gitignore" "$HOME/.gitignore" "Git ignore patterns"
create_symlink "$DOTFILES_DIR/gitconfig" "$HOME/.gitconfig" "Git configuration"
create_symlink "$DOTFILES_DIR/gitmessage" "$HOME/.gitmessage" "Git commit template"

# LaTeX configuration - use universal version
progress "Setting up LaTeX configuration"
create_symlink "$DOTFILES_DIR/latexmkrc.universal" "$HOME/.latexmkrc" "LaTeX build config (universal)"

# TMUX configuration - use universal version
progress "Setting up tmux configuration"
create_symlink "$DOTFILES_DIR/tmux.conf.universal" "$HOME/.tmux.conf" "tmux configuration (universal)"

# Tmuxinator with private repo fallback
progress "Setting up tmuxinator configuration"
PRIVATE_TMUXINATOR="$HOME/.dotfiles/.dotfiles.private/src/tmuxinator"
PUBLIC_TMUXINATOR="$DOTFILES_DIR/tmuxinator"

# Check if private tmuxinator directory exists
if [[ -d "$PRIVATE_TMUXINATOR" ]]; then
    info "Using tmuxinator configs from private repository"
    create_symlink "$PRIVATE_TMUXINATOR" "$HOME/.tmuxinator" "tmuxinator configs (private)"
    ensure_dir "$HOME/.config"
    create_symlink "$PRIVATE_TMUXINATOR" "$HOME/.config/tmuxinator" "tmuxinator XDG config (private)"
elif [[ -d "$PUBLIC_TMUXINATOR" ]]; then
    warn "Private tmuxinator directory not found, falling back to public configs"
    create_symlink "$PUBLIC_TMUXINATOR" "$HOME/.tmuxinator" "tmuxinator configs (public)"
    ensure_dir "$HOME/.config"
    create_symlink "$PUBLIC_TMUXINATOR" "$HOME/.config/tmuxinator" "tmuxinator XDG config (public)"
else
    error "No tmuxinator configs found in either private or public repositories"
    ((ERROR_COUNT++))
fi

# Custom scripts directory (will be added to PATH)
progress "Setting up custom scripts"
success "Scripts directory: $DOTFILES_DIR/scripts"
success "Setup scripts directory: $DOTFILES_DIR/setup"
info "These directories will be added to PATH for direct script execution"

# Spell files for Neovim
progress "Setting up spell files"
create_symlink "$DOTFILES_DIR/spell" "$HOME/.config/nvim/spell" "Neovim spell files"

# Google Style Guide pylintrc
progress "Setting up Google pylintrc"
if [[ -f "$DOTFILES_DIR/submodules/google-styleguide/pylintrc" ]]; then
    create_symlink "$DOTFILES_DIR/submodules/google-styleguide/pylintrc" "$HOME/.pylintrc" "Google Style Guide pylintrc"
else
    warn "Google styleguide submodule not found. Run: git submodule update --init --recursive"
fi

# Clangd configuration - use universal version
progress "Setting up clangd configuration"
ensure_dir "$HOME/.config/clangd"
create_symlink "$DOTFILES_DIR/clangd_config.universal.yaml" "$HOME/.config/clangd/config.yaml" "Clangd LSP config (universal)"

# Ripgrep configuration
progress "Setting up ripgrep configuration"
create_symlink "$DOTFILES_DIR/ripgreprc" "$HOME/.ripgreprc" "Ripgrep config"

# Starship configuration
progress "Setting up Starship prompt configuration"
ensure_dir "$HOME/.config"
create_symlink "$DOTFILES_DIR/config/starship.toml" "$HOME/.config/starship.toml" "Starship prompt config"

# Create backup directory for Neovim
progress "Creating backup directories"
ensure_dir "$HOME/.vim/undodir"
ensure_dir "$HOME/.local/share/nvim/sessions"
ensure_dir "$HOME/.local/share/nvim/swap"
ensure_dir "$HOME/.local/share/nvim/backup"
ensure_dir "$HOME/.cache/nvim"

# ────────────────────────────────────────────────────────────────────────────────────────────────────────────
# 📊 INSTALLATION SUMMARY
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────

echo -e "\n${CYAN}╔════════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                           INSTALLATION SUMMARY                                 ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════════════════╝${NC}\n"

echo -e "  ${GREEN}✓ Successful:${NC} $SUCCESS_COUNT"
echo -e "  ${BLUE}○ Skipped:${NC}    $SKIP_COUNT"
echo -e "  ${RED}✗ Errors:${NC}     $ERROR_COUNT"

if [[ $ERROR_COUNT -eq 0 ]]; then
    echo -e "\n${GREEN}✅ All symlinks created successfully!${NC}\n"
else
    echo -e "\n${YELLOW}⚠️  Installation completed with errors. Please review the output above.${NC}\n"
fi

if [[ -d "$BACKUP_DIR" ]]; then
    echo -e "${CYAN}📁 Backups saved to:${NC} $BACKUP_DIR\n"
fi

echo -e "${MAGENTA}Next steps:${NC}"
echo -e "  1. Restart your terminal or run: ${CYAN}source ~/.zshrc${NC}"
echo -e "  2. Run ${CYAN}nvim${NC} and wait for plugins to install"
echo -e "  3. Run ${CYAN}tmux${NC} and press ${CYAN}Ctrl-A + I${NC} to install plugins"
echo -e "  4. Run ${CYAN}theme${NC} to sync your system theme\n"

# Exit with appropriate code
exit $ERROR_COUNT
