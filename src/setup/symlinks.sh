#!/usr/bin/env bash
# ════════════════════════════════════════════════════════════════════════════════
# 🔗 DOTFILES SYMLINK CREATOR
# ════════════════════════════════════════════════════════════════════════════════
# Creates all necessary symlinks from the dotfiles repository to home directory
# ════════════════════════════════════════════════════════════════════════════════

set -euo pipefail

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
    
    # Check if source exists
    if [[ ! -e "$source" ]]; then
        warn "Source not found: $source (skipping $name)"
        ((skipped++))
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
    
    # Main init.lua
    create_link "$DOTFILES_DIR/src/neovim/init.lua" "$HOME/.config/nvim/init.lua" "Neovim init"
    
    # Lua config directory
    create_link "$DOTFILES_DIR/src/neovim/config" "$HOME/.config/nvim/lua/config" "Neovim config"
    
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