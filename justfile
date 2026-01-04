# Dotfiles task runner
# Usage: just <recipe>

set shell := ["zsh", "-cu"]

# Default: show available commands
default:
    @just --list

# ─────────────────────────────────────────────────────────────
# Testing
# ─────────────────────────────────────────────────────────────

# Run quick test suite (< 30s)
test:
    ./test/runner.zsh --quick

# Run unit tests only
test-unit:
    ./test/runner.zsh --unit

# Run full test suite
test-full:
    ./test/runner.zsh --full

# ─────────────────────────────────────────────────────────────
# Code Quality
# ─────────────────────────────────────────────────────────────

# Format all code with fixy
fmt:
    ./src/scripts/fixy src/

# Run shellcheck on shell scripts
lint:
    shellcheck src/**/*.sh src/**/*.zsh

# ─────────────────────────────────────────────────────────────
# Setup & Maintenance
# ─────────────────────────────────────────────────────────────

# Run full setup
setup:
    ./src/setup/setup.sh

# Create/update symlinks only
symlinks:
    ./src/setup/symlinks.sh

# Update packages and plugins
update:
    ./src/scripts/update-dotfiles

# ─────────────────────────────────────────────────────────────
# Theme
# ─────────────────────────────────────────────────────────────

# Auto-detect theme from macOS appearance
theme:
    ./src/scripts/theme

# Switch to light theme
theme-day:
    ./src/scripts/theme day

# Switch to dark theme
theme-night:
    ./src/scripts/theme night
