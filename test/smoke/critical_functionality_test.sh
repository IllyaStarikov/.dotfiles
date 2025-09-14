#!/usr/bin/env zsh
# Smoke Tests - Critical Functionality
# Quick tests to verify essential features are working

set -euo pipefail

source "$(dirname "$0")/../lib/test_helpers.zsh"

readonly DEBUG="${DEBUG:-0}"

#######################################
# Test critical dotfiles functionality
#######################################
echo -e "${BLUE}=== Smoke Tests - Critical Functionality ===${NC}"

test_case "Dotfiles directory structure is intact"
required_dirs=(
    "$DOTFILES_DIR/src"
    "$DOTFILES_DIR/src/neovim"
    "$DOTFILES_DIR/src/zsh"
    "$DOTFILES_DIR/src/scripts"
    "$DOTFILES_DIR/src/theme-switcher"
    "$DOTFILES_DIR/test"
)

missing_dirs=()
for dir in "${required_dirs[@]}"; do
    [[ ! -d "$dir" ]] && missing_dirs+=("$dir")
done

if [[ ${#missing_dirs[@]} -eq 0 ]]; then
    pass
else
    fail "Missing directories: ${missing_dirs[*]}"
fi

test_case "Essential configuration files exist"
essential_files=(
    "$DOTFILES_DIR/src/neovim/init.lua"
    "$DOTFILES_DIR/src/zsh/zshrc"
    "$DOTFILES_DIR/src/tmux.conf"
    "$DOTFILES_DIR/src/git/gitconfig"
    "$DOTFILES_DIR/src/theme-switcher/switch-theme.sh"
)

missing_files=()
for file in "${essential_files[@]}"; do
    [[ ! -f "$file" ]] && missing_files+=("$(basename $file)")
done

if [[ ${#missing_files[@]} -eq 0 ]]; then
    pass
else
    fail "Missing files: ${missing_files[*]}"
fi

test_case "Neovim can start without crashes"
if timeout 5 nvim --headless -c "qa!" 2>/dev/null; then
    pass
else
    fail "Neovim crashes on startup"
fi

test_case "Zsh configuration loads without errors"
if zsh -n "$DOTFILES_DIR/src/zsh/zshrc" 2>/dev/null; then
    pass
else
    fail "Zsh configuration has syntax errors"
fi

test_case "Theme switcher is executable"
if [[ -x "$DOTFILES_DIR/src/theme-switcher/switch-theme.sh" ]]; then
    pass
else
    fail "Theme switcher is not executable"
fi

test_case "Git is configured with user information"
git_user=$(git config --global user.name 2>/dev/null || echo "")
git_email=$(git config --global user.email 2>/dev/null || echo "")

if [[ -n "$git_user" ]] && [[ -n "$git_email" ]]; then
    pass
else
    skip "Git user not configured (not critical for smoke test)"
fi

test_case "Critical scripts have no syntax errors"
critical_scripts=(
    "$DOTFILES_DIR/src/scripts/update-dotfiles"
    "$DOTFILES_DIR/src/scripts/theme"
    "$DOTFILES_DIR/src/scripts/fixy"
)

script_errors=0
for script in "${critical_scripts[@]}"; do
    if [[ -f "$script" ]]; then
        # Detect shell type from shebang
        shebang=$(head -n1 "$script")
        if [[ "$shebang" == *"zsh"* ]]; then
            zsh -n "$script" 2>/dev/null || ((script_errors++))
        elif [[ "$shebang" == *"bash"* ]]; then
            bash -n "$script" 2>/dev/null || ((script_errors++))
        fi
    fi
done

if [[ $script_errors -eq 0 ]]; then
    pass
else
    fail "$script_errors scripts have syntax errors"
fi

test_case "tmux configuration is valid"
if tmux -f "$DOTFILES_DIR/src/tmux.conf" new-session -d -s test_smoke 2>/dev/null; then
    tmux kill-session -t test_smoke 2>/dev/null
    pass
else
    fail "tmux configuration is invalid"
fi

# Print smoke test summary
echo -e "\n${GREEN}=== Smoke Test Summary ===${NC}"
echo "Critical functionality verified"