#!/usr/bin/env bash
# ════════════════════════════════════════════════════════════════════════════════
# 🔗 DOTFILES SYMLINK CREATOR
# ════════════════════════════════════════════════════════════════════════════════
# Creates all necessary symlinks from the dotfiles repository to home directory
# ════════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly DOTFILES_DIR="$(dirname "$SCRIPT_DIR")"
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
    
    # Check if source exists
    if [[ ! -e "$source" ]]; then
        error "Source not found: $source"
        return 1
    fi
    
    # If target already exists
    if [[ -e "$target" || -L "$target" ]]; then
        # If it's already the correct symlink, skip
        if [[ -L "$target" ]] && [[ "$(readlink "$target")" == "$source" ]]; then
            ((skipped++))
            return 0
        fi
        
        # Backup existing file/directory
        mkdir -p "$BACKUP_DIR"
        mv "$target" "$BACKUP_DIR/$(basename "$target")"
        warn "Backed up existing $name to $BACKUP_DIR"
        ((backed_up++))
    fi
    
    # Create parent directory if needed
    mkdir -p "$(dirname "$target")"
    
    # Create symlink
    ln -sf "$source" "$target"
    info "Linked $name"
    ((created++))
}

# Main execution
main() {
    echo "════════════════════════════════════════════════════════════════════"
    echo "       🔗 Creating Dotfile Symlinks"
    echo "════════════════════════════════════════════════════════════════════"
    echo ""
    
    # Core dotfiles
    create_link "$DOTFILES_DIR/zsh/zshrc" "$HOME/.zshrc" "Zsh config"
    create_link "$DOTFILES_DIR/zsh/zshenv" "$HOME/.zshenv" "Zsh environment"
    create_link "$DOTFILES_DIR/tmux.conf" "$HOME/.tmux.conf" "tmux config"
    
    # Git configurations
    create_link "$DOTFILES_DIR/git/gitconfig" "$HOME/.gitconfig" "Git config"
    create_link "$DOTFILES_DIR/git/gitignore" "$HOME/.gitignore" "Global gitignore"
    create_link "$DOTFILES_DIR/git/gitmessage" "$HOME/.gitmessage" "Git commit template"
    
    # Config directory items
    mkdir -p "$HOME/.config"
    
    # Alacritty
    create_link "$DOTFILES_DIR/alacritty" "$HOME/.config/alacritty" "Alacritty config"
    
    # Neovim
    mkdir -p "$HOME/.config/nvim"
    create_link "$DOTFILES_DIR/init.lua" "$HOME/.config/nvim/init.lua" "Neovim init"
    create_link "$DOTFILES_DIR/lua" "$HOME/.config/nvim/lua" "Neovim Lua configs"
    
    # Neovim spell files
    mkdir -p "$HOME/.config/nvim/spell"
    create_link "$DOTFILES_DIR/spell.txt" "$HOME/.config/nvim/spell/en.utf-8.add" "Custom dictionary"
    if [[ -f "$DOTFILES_DIR/spell.txt.spl" ]]; then
        create_link "$DOTFILES_DIR/spell.txt.spl" "$HOME/.config/nvim/spell/en.utf-8.add.spl" "Dictionary index"
    fi
    
    # Starship
    create_link "$DOTFILES_DIR/zsh/starship.toml" "$HOME/.config/starship.toml" "Starship prompt"
    
    # WezTerm
    create_link "$DOTFILES_DIR/wezterm" "$HOME/.config/wezterm" "WezTerm config"
    
    # LaTeX
    create_link "$DOTFILES_DIR/latexmkrc" "$HOME/.latexmkrc" "LaTeX config"
    
    # Scripts
    mkdir -p "$HOME/.local/bin"
    for script in "$DOTFILES_DIR/scripts"/*; do
        if [[ -f "$script" && -x "$script" ]]; then
            name=$(basename "$script")
            create_link "$script" "$HOME/.local/bin/$name" "Script: $name"
        fi
    done
    
    # Tmuxinator
    create_link "$DOTFILES_DIR/tmuxinator" "$HOME/.config/tmuxinator" "Tmuxinator templates"
    
    # Legacy Vim support
    create_link "$DOTFILES_DIR/vimrc" "$HOME/.vimrc" "Vim config"
    create_link "$DOTFILES_DIR/vim" "$HOME/.vim" "Vim directory"
    
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