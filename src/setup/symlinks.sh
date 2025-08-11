#!/usr/bin/env bash
# ════════════════════════════════════════════════════════════════════════════════
# 🔗 DOTFILES SYMLINK CREATOR
# ════════════════════════════════════════════════════════════════════════════════
# Creates all necessary symlinks from the dotfiles repository to home directory
# ════════════════════════════════════════════════════════════════════════════════

set -uo pipefail  # Don't exit on error, continue creating other symlinks

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DOTFILES_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
readonly BACKUP_DIR="$HOME/.dotfiles.backups/$(date +%Y%m%d_%H%M%S)"

# Colors
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

# Counters
declare -i created=0
declare -i skipped=0
declare -i backed_up=0

# Helper functions
info() { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[⚠]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1" >&2; }

# Create a symlink with backup if needed
create_link() {
    local source="$1"
    local target="$2"
    local name="$3"
    
    echo "  Attempting to link: $name"
    echo "    From: $source"
    echo "    To:   $target"
    
    # Check if source exists
    if [[ ! -e "$source" ]]; then
        error "    ✗ Source not found (skipping)"
        ((skipped++))
        return 1
    fi
    
    # If target already exists
    if [[ -e "$target" || -L "$target" ]]; then
        # If it's already the correct symlink, skip
        if [[ -L "$target" ]] && [[ "$(readlink "$target")" == "$source" ]]; then
            info "    ✓ Already linked correctly (skipping)"
            ((skipped++))
            return 0
        fi
        
        # Backup existing file/directory
        mkdir -p "$BACKUP_DIR"
        mv "$target" "$BACKUP_DIR/$(basename "$target")" 2>/dev/null || {
            error "    ✗ Failed to backup existing file"
            return 1
        }
        warn "    ⚠ Backed up existing file"
        ((backed_up++))
    fi
    
    # Create parent directory if needed
    mkdir -p "$(dirname "$target")" 2>/dev/null || {
        error "    ✗ Failed to create parent directory"
        return 1
    }
    
    # Create symlink
    if ln -sf "$source" "$target" 2>/dev/null; then
        info "    ✓ Successfully linked"
        ((created++))
    else
        error "    ✗ Failed to create symlink"
        return 1
    fi
    echo ""  # Add spacing between items
}

# Main execution
main() {
    echo "════════════════════════════════════════════════════════════════════"
    echo "       🔗 Creating Dotfile Symlinks"
    echo "════════════════════════════════════════════════════════════════════"
    echo ""
    
    # Debug: Show dotfiles directory
    info "Dotfiles directory: $DOTFILES_DIR"
    
    # Core dotfiles
    create_link "$DOTFILES_DIR/src/zsh/zshrc" "$HOME/.zshrc" "Zsh config"
    create_link "$DOTFILES_DIR/src/zsh/zshenv" "$HOME/.zshenv" "Zsh environment"
    create_link "$DOTFILES_DIR/src/tmux.conf" "$HOME/.tmux.conf" "tmux config"
    
    # Git configurations
    create_link "$DOTFILES_DIR/src/git/gitconfig" "$HOME/.gitconfig" "Git config"
    create_link "$DOTFILES_DIR/src/git/gitignore" "$HOME/.gitignore" "Global gitignore"
    create_link "$DOTFILES_DIR/src/git/gitmessage" "$HOME/.gitmessage" "Git commit template"
    
    # Config directory items
    mkdir -p "$HOME/.config"
    
    # Alacritty
    mkdir -p "$HOME/.config/alacritty"
    create_link "$DOTFILES_DIR/src/alacritty.toml" "$HOME/.config/alacritty/alacritty.toml" "Alacritty config"
    
    # Neovim
    mkdir -p "$HOME/.config/nvim"
    mkdir -p "$HOME/.config/nvim/lua"
    
    # Check if Neovim config exists in the expected location
    if [[ ! -d "$DOTFILES_DIR/src/neovim/config" ]]; then
        warn "Neovim config directory not found at $DOTFILES_DIR/src/neovim/config"
        warn "Attempting to restore from git..."
        (cd "$DOTFILES_DIR" && git restore src/neovim/config/ 2>/dev/null) || warn "Could not restore config from git"
    fi
    
    # Main init.lua
    if [[ -f "$DOTFILES_DIR/src/neovim/init.lua" ]]; then
        create_link "$DOTFILES_DIR/src/neovim/init.lua" "$HOME/.config/nvim/init.lua" "Neovim init"
    else
        warn "Neovim init.lua not found at $DOTFILES_DIR/src/neovim/init.lua"
    fi
    
    # Lua config directory
    if [[ -d "$DOTFILES_DIR/src/neovim/config" ]]; then
        create_link "$DOTFILES_DIR/src/neovim/config" "$HOME/.config/nvim/lua/config" "Neovim config"
    else
        error "Neovim config directory still missing after restore attempt"
        error "Please run: cd $DOTFILES_DIR && git checkout HEAD -- src/neovim/config/"
    fi
    
    # Neovim snippets
    if [[ -d "$DOTFILES_DIR/src/neovim/snippets" ]]; then
        create_link "$DOTFILES_DIR/src/neovim/snippets" "$HOME/.config/nvim/lua/snippets" "Neovim snippets"
    fi
    
    # Neovim spell files
    mkdir -p "$HOME/.config/nvim/spell"
    create_link "$DOTFILES_DIR/src/spell/spell.txt" "$HOME/.config/nvim/spell/en.utf-8.add" "Custom dictionary"
    if [[ -f "$DOTFILES_DIR/src/spell/spell.txt.spl" ]]; then
        create_link "$DOTFILES_DIR/src/spell/spell.txt.spl" "$HOME/.config/nvim/spell/en.utf-8.add.spl" "Dictionary index"
    fi
    
    # Starship
    create_link "$DOTFILES_DIR/src/zsh/starship.toml" "$HOME/.config/starship.toml" "Starship prompt"
    
    # WezTerm (if exists)
    if [[ -d "$DOTFILES_DIR/src/wezterm" ]]; then
        create_link "$DOTFILES_DIR/src/wezterm" "$HOME/.config/wezterm" "WezTerm config"
    fi
    
    # LaTeX
    create_link "$DOTFILES_DIR/src/latexmkrc" "$HOME/.latexmkrc" "LaTeX config"
    
    # Scripts
    mkdir -p "$HOME/.local/bin"
    for script in "$DOTFILES_DIR/src/scripts"/*; do
        if [[ -f "$script" && -x "$script" ]]; then
            name=$(basename "$script")
            create_link "$script" "$HOME/.local/bin/$name" "Script: $name"
        fi
    done
    
    # Tmuxinator (if exists)
    if [[ -d "$DOTFILES_DIR/src/tmuxinator" ]]; then
        create_link "$DOTFILES_DIR/src/tmuxinator" "$HOME/.config/tmuxinator" "Tmuxinator templates"
    fi
    
    # Legacy Vim support (if exists)
    if [[ -f "$DOTFILES_DIR/src/vimrc" ]]; then
        create_link "$DOTFILES_DIR/src/vimrc" "$HOME/.vimrc" "Vim config"
    fi
    if [[ -d "$DOTFILES_DIR/src/vim" ]]; then
        create_link "$DOTFILES_DIR/src/vim" "$HOME/.vim" "Vim directory"
    fi
    
    # Summary
    echo ""
    echo "════════════════════════════════════════════════════════════════════"
    echo "✨ Symlink Summary:"
    echo "   Created: $created"
    echo "   Skipped: $skipped"
    echo "   Backed up: $backed_up"
    if [[ $backed_up -gt 0 ]]; then
        echo ""
        echo "   Backups saved to: $BACKUP_DIR"
    fi
    echo "════════════════════════════════════════════════════════════════════"
}

main "$@"