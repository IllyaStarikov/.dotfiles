#!/usr/bin/env zsh
# init.zsh - Unified entry point for the ZSH library
#
# DESCRIPTION:
#   Single-line sourcing for all dotfiles scripts. Auto-detects DOTFILES
#   directory and loads core modules (colors, utils, logging, die).
#
# USAGE:
#   source "${0:A:h:h}/lib/init.zsh"   # From src/scripts/
#   source "${0:A:h}/lib/init.zsh"     # From src/setup/
#   source "$DOTFILES/src/lib/init.zsh" # If DOTFILES is set
#
# LOADED MODULES:
#   - colors   : Terminal colors, styles, and colorize()
#   - utils    : File ops, command checks, OS detection
#   - logging  : Structured logging with levels
#   - die      : Error handling and exit functions

# Auto-detect DOTFILES if not set
# Use ${DOTFILES:-} to handle set -u (nounset) in bash
if [[ -z "${DOTFILES:-}" ]]; then
  # Resolve symlinks and get the real path to this file
  local init_path="${0:A}"
  # init.zsh is at src/lib/init.zsh, so DOTFILES is 3 levels up
  export DOTFILES="${init_path:h:h:h}"
fi

# Verify DOTFILES exists
if [[ ! -d "$DOTFILES" ]]; then
  echo "ERROR: DOTFILES directory not found: $DOTFILES" >&2
  return 1
fi

# Source the library loader
source "${DOTFILES}/src/lib/lib.zsh" || {
  echo "ERROR: Failed to load lib.zsh" >&2
  return 1
}

# Load core modules
lib_load_core
