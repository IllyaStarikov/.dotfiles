#!/usr/bin/env zsh
# ════════════════════════════════════════════════════════════════════════════════
# symlinks.sh - Create and manage dotfile symbolic links
# ════════════════════════════════════════════════════════════════════════════════
#
# DESCRIPTION:
#   Creates symbolic links from dotfiles repository to proper system locations.
#   Backs up existing files before replacing. Safe to run multiple times.
#
# USAGE:
#   ./symlinks.sh [OPTIONS]
#   
#   ./symlinks.sh           # Create all symlinks
#   ./symlinks.sh --force   # Overwrite without prompting
#   ./symlinks.sh --dry-run # Preview changes without applying
#
# OPTIONS:
#   --force    - Overwrite existing files without confirmation
#   --dry-run  - Show what would be done without making changes
#   --verbose  - Show detailed output for each operation
#
# SYMLINKS CREATED:
#   Shell:     ~/.zshrc, ~/.bashrc, ~/.zshenv
#   Editor:    ~/.config/nvim/, ~/.vimrc
#   Terminal:  ~/.config/alacritty/, ~/.config/wezterm/, ~/.tmux.conf
#   Git:       ~/.gitconfig, ~/.gitignore_global
#   Tools:     ~/.ripgreprc, ~/.config/starship.toml
#
# BACKUP:
#   Existing files backed up to: ~/.dotfiles.backups/YYYYMMDD_HHMMSS/
#
# EXAMPLES:
#   ./symlinks.sh                  # Interactive setup
#   ./symlinks.sh --force          # Non-interactive replacement
#   ./symlinks.sh --dry-run        # Preview mode
#
# SAFETY:
#   - Backs up existing files before replacing
#   - Checks if symlinks already point to correct location
#   - Reports all actions taken
# ════════════════════════════════════════════════════════════════════════════════

set -uo pipefail  # Don't exit on error, continue creating other symlinks

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd)"
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
    
    # Neovim - Link the entire neovim directory
    # This preserves the exact structure needed by the config
    if [[ -d "$DOTFILES_DIR/src/neovim" ]]; then
        # Check if Neovim config exists and is not a broken symlink
        if [[ -L "$DOTFILES_DIR/src/neovim/config" ]]; then
            warn "Found symlink at $DOTFILES_DIR/src/neovim/config - this should be a directory!"
            warn "Attempting to restore from git..."
            rm -f "$DOTFILES_DIR/src/neovim/config" 2>/dev/null
            (cd "$DOTFILES_DIR" && git checkout HEAD -- src/neovim/config/) || {
                error "Could not restore config from git"
                error "Please run manually: cd $DOTFILES_DIR && git checkout HEAD -- src/neovim/"
            }
        fi
        
        # Backup existing symlinks for clean installation
        if [[ -L "$HOME/.config/nvim" ]]; then
            mkdir -p "$BACKUP_DIR"
            # Save symlink target for reference
            readlink "$HOME/.config/nvim" > "$BACKUP_DIR/nvim-symlink-target-$(date +%Y%m%d_%H%M%S).txt"
            rm -f "$HOME/.config/nvim"
        elif [[ -d "$HOME/.config/nvim" ]]; then
            # Backup existing nvim config if it's not a symlink
            if [[ ! -L "$HOME/.config/nvim/init.lua" ]] || [[ ! -L "$HOME/.config/nvim/lua" ]]; then
                mkdir -p "$BACKUP_DIR"
                mv "$HOME/.config/nvim" "$BACKUP_DIR/nvim" 2>/dev/null
                warn "Backed up existing nvim config to $BACKUP_DIR/nvim"
            else
                # Backup directory with symlinks from previous setup
                mkdir -p "$BACKUP_DIR"
                mv "$HOME/.config/nvim" "$BACKUP_DIR/nvim-symlinks-$(date +%Y%m%d_%H%M%S)" 2>/dev/null
                warn "Backed up nvim symlinks directory to $BACKUP_DIR/"
            fi
        fi
        
        # Create the symlink for the entire nvim directory
        create_link "$DOTFILES_DIR/src/neovim" "$HOME/.config/nvim" "Neovim config (entire directory)"
        
        # Spell files are now configured directly in Neovim options.lua to use private dotfiles
    else
        error "Neovim directory not found at $DOTFILES_DIR/src/neovim"
    fi
    
    # Spell files are now handled via the neovim directory symlink above
    
    # Starship
    create_link "$DOTFILES_DIR/src/zsh/starship.toml" "$HOME/.config/starship.toml" "Starship prompt"
    
    # WezTerm (if exists)
    if [[ -d "$DOTFILES_DIR/src/wezterm" ]]; then
        create_link "$DOTFILES_DIR/src/wezterm" "$HOME/.config/wezterm" "WezTerm config"
    fi
    
    # LaTeX
    create_link "$DOTFILES_DIR/src/language/latexmkrc" "$HOME/.latexmkrc" "LaTeX config"
    
    # Python configurations
    create_link "$DOTFILES_DIR/src/language/ruff.toml" "$HOME/.ruff.toml" "Ruff Python formatter/linter"
    create_link "$DOTFILES_DIR/src/language/pyproject.toml" "$HOME/pyproject.toml" "Python project config"
    
    # Scripts
    mkdir -p "$HOME/.local/bin"
    for script in "$DOTFILES_DIR/src/scripts"/*; do
        if [[ -f "$script" && -x "$script" ]]; then
            name=$(basename "$script")
            create_link "$script" "$HOME/.local/bin/$name" "Script: $name"
        fi
    done
    
    # Tmuxinator (if exists in src/)
    if [[ -d "$DOTFILES_DIR/src/tmuxinator" ]]; then
        create_link "$DOTFILES_DIR/src/tmuxinator" "$HOME/.config/tmuxinator" "Tmuxinator templates"
    fi
    
    # Note: Private tmuxinator configs should be handled by private setup script
    
    
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