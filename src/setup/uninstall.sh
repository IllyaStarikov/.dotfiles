#!/usr/bin/env zsh
# uninstall.sh - Remove dotfile symlinks and optionally restore backups
#
# DESCRIPTION:
#   Removes symbolic links created by symlinks.sh. Only removes symlinks
#   that point to the dotfiles repository - never deletes actual files.
#   Based on Google Shell Style Guide: https://google.github.io/styleguide/shellguide.html
#
# USAGE:
#   ./uninstall.sh [OPTIONS]
#
#   ./uninstall.sh             # Remove symlinks only
#   ./uninstall.sh --restore   # Remove symlinks and restore from backup
#   ./uninstall.sh --full      # Remove symlinks and ~/.dotfiles directory
#   ./uninstall.sh --dry-run   # Preview what would be removed
#
# OPTIONS:
#   --dry-run   Show what would be done without making changes
#   --restore   After removing symlinks, restore from most recent backup
#   --full      Also remove the ~/.dotfiles directory itself
#   --help      Show this help message
#
# SYMLINKS REMOVED:
#   Shell:     ~/.zshrc, ~/.zshenv, ~/.tmux.conf
#   Editor:    ~/.config/nvim/
#   Terminal:  ~/.config/alacritty/, ~/.config/wezterm/, ~/.config/kitty/
#   Git:       ~/.gitconfig, ~/.gitignore, ~/.gitmessage
#   Tools:     ~/.ripgreprc, ~/.editorconfig, ~/.config/starship.toml
#   Scripts:   ~/.local/bin/* (only symlinks to dotfiles)
#
# SAFETY:
#   - Only removes symlinks pointing to dotfiles repository
#   - Never deletes actual files or directories
#   - Verifies symlink targets before removal

set -uo pipefail

# Configuration
readonly SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd)"
readonly DOTFILES_DIR="$(dirname "$(dirname "$SCRIPT_DIR")")"
readonly BACKUP_DIR="$HOME/.dotfiles.backups"

# Load library (provides colors: $RED, $GREEN, $YELLOW, $BLUE, $NC)
source "${DOTFILES_DIR}/src/lib/init.zsh"

# Flags
DRY_RUN=false
RESTORE=false
FULL=false

# Counters
declare -i removed=0
declare -i skipped=0
declare -i restored=0

# Utility functions
info() { echo -e "${GREEN}[✓]${NC} $1"; }
warn() { echo -e "${YELLOW}[⚠]${NC} $1"; }
error() { echo -e "${RED}[✗]${NC} $1" >&2; }
dry() { echo -e "${BLUE}[DRY]${NC} $1"; }

# Show help message
show_help() {
  head -35 "$0" | tail -33 | sed 's/^# //' | sed 's/^#//'
  exit 0
}

# Remove a symlink if it points to dotfiles
# Args:
#   $1 - Path to potential symlink
# Returns: 0 on success, 1 if skipped
remove_link() {
  local target="$1"

  # Skip if doesn't exist
  if [[ ! -e "$target" && ! -L "$target" ]]; then
    return 1
  fi

  # Skip if not a symlink
  if [[ ! -L "$target" ]]; then
    warn "Not a symlink (skipping): $target"
    ((skipped++))
    return 1
  fi

  # Get symlink target
  local link_target
  link_target="$(readlink "$target")"

  # Only remove if it points to our dotfiles
  if [[ "$link_target" != "$DOTFILES_DIR"* ]]; then
    warn "Not a dotfiles symlink (skipping): $target -> $link_target"
    ((skipped++))
    return 1
  fi

  # Remove the symlink
  if $DRY_RUN; then
    dry "Would remove: $target -> $link_target"
    ((removed++))
  else
    rm -f "$target" && {
      info "Removed: $target"
      ((removed++))
    } || {
      error "Failed to remove: $target"
      return 1
    }
  fi
}

# Find and restore from most recent backup
restore_backup() {
  if [[ ! -d "$BACKUP_DIR" ]]; then
    warn "No backup directory found at $BACKUP_DIR"
    return 1
  fi

  # Find most recent backup
  local latest
  latest="$(ls -1t "$BACKUP_DIR" 2>/dev/null | head -1)"

  if [[ -z "$latest" ]]; then
    warn "No backups found in $BACKUP_DIR"
    return 1
  fi

  local backup_path="$BACKUP_DIR/$latest"
  echo ""
  info "Restoring from backup: $backup_path"

  # Restore each file
  for file in "$backup_path"/*; do
    [[ -e "$file" ]] || continue
    local basename
    basename="$(basename "$file")"
    local restore_target="$HOME/$basename"

    # Handle .config items specially
    if [[ "$basename" == "nvim" ]]; then
      restore_target="$HOME/.config/nvim"
    elif [[ "$basename" == "alacritty.toml" ]]; then
      restore_target="$HOME/.config/alacritty/alacritty.toml"
    elif [[ "$basename" == "starship.toml" ]]; then
      restore_target="$HOME/.config/starship.toml"
    elif [[ "$basename" == "wezterm" ]]; then
      restore_target="$HOME/.config/wezterm"
    elif [[ "$basename" == "kitty" ]]; then
      restore_target="$HOME/.config/kitty"
    fi

    if $DRY_RUN; then
      dry "Would restore: $file -> $restore_target"
      ((restored++))
    else
      # Create parent directory if needed
      mkdir -p "$(dirname "$restore_target")"
      cp -r "$file" "$restore_target" && {
        info "Restored: $restore_target"
        ((restored++))
      } || {
        error "Failed to restore: $restore_target"
      }
    fi
  done
}

# Main execution
main() {
  # Parse arguments
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --dry-run) DRY_RUN=true ;;
      --restore) RESTORE=true ;;
      --full) FULL=true ;;
      --help|-h) show_help ;;
      *)
        error "Unknown option: $1"
        echo "Use --help for usage information"
        exit 1
        ;;
    esac
    shift
  done

  echo "════════════════════════════════════════════════════════════════════"
  echo "       🗑️  Uninstalling Dotfiles"
  if $DRY_RUN; then
    echo "       (DRY RUN - no changes will be made)"
  fi
  echo "════════════════════════════════════════════════════════════════════"
  echo ""

  info "Dotfiles directory: $DOTFILES_DIR"
  echo ""

  # Remove shell config symlinks
  echo "Removing shell configurations..."
  remove_link "$HOME/.zshrc"
  remove_link "$HOME/.zshenv"
  remove_link "$HOME/.tmux.conf"
  echo ""

  # Remove git config symlinks
  echo "Removing git configurations..."
  remove_link "$HOME/.gitconfig"
  remove_link "$HOME/.gitignore"
  remove_link "$HOME/.gitmessage"
  echo ""

  # Remove editor/terminal config symlinks
  echo "Removing editor and terminal configurations..."
  remove_link "$HOME/.config/nvim"
  remove_link "$HOME/.config/alacritty/alacritty.toml"
  remove_link "$HOME/.config/wezterm"
  remove_link "$HOME/.config/kitty"
  remove_link "$HOME/.config/starship.toml"
  echo ""

  # Remove tool config symlinks
  echo "Removing tool configurations..."
  remove_link "$HOME/.ripgreprc"
  remove_link "$HOME/.editorconfig"
  remove_link "$HOME/.latexmkrc"
  remove_link "$HOME/.ruff.toml"
  remove_link "$HOME/pyproject.toml"
  echo ""

  # Remove script symlinks
  echo "Removing script symlinks from ~/.local/bin/..."
  if [[ -d "$HOME/.local/bin" ]]; then
    for script in "$HOME/.local/bin"/*; do
      [[ -L "$script" ]] || continue
      local script_target
      script_target="$(readlink "$script")"
      if [[ "$script_target" == "$DOTFILES_DIR/src/scripts"* ]]; then
        remove_link "$script"
      fi
    done
  fi
  echo ""

  # Remove tmuxinator if it's a symlink
  remove_link "$HOME/.config/tmuxinator"

  # Restore from backup if requested
  if $RESTORE; then
    restore_backup
  fi

  # Remove dotfiles directory if --full
  if $FULL; then
    echo ""
    if $DRY_RUN; then
      dry "Would remove directory: $DOTFILES_DIR"
    else
      warn "Removing dotfiles directory: $DOTFILES_DIR"
      rm -rf "$DOTFILES_DIR" && info "Removed: $DOTFILES_DIR"
    fi
  fi

  # Summary
  echo ""
  echo "════════════════════════════════════════════════════════════════════"
  echo "✨ Uninstall Summary:"
  echo "   Removed: $removed symlinks"
  echo "   Skipped: $skipped"
  if $RESTORE; then
    echo "   Restored: $restored files"
  fi
  if $DRY_RUN; then
    echo ""
    echo "   This was a dry run. Use without --dry-run to apply changes."
  fi
  if [[ -d "$BACKUP_DIR" ]] && ! $RESTORE; then
    echo ""
    echo "   Backups available at: $BACKUP_DIR"
    echo "   Use --restore to restore from most recent backup"
  fi
  echo "════════════════════════════════════════════════════════════════════"
}

main "$@"
