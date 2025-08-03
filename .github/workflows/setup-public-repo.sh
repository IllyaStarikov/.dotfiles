#!/bin/bash
# Script to prepare repository for CI by removing private submodule references

set -euo pipefail

echo "Preparing repository for CI build..."

# Remove the private submodule entry from .gitmodules
echo "Removing private submodule from .gitmodules..."
if git config --file=.gitmodules --get-regexp '^submodule\..*\.path$' | grep -q '.dotfiles.private'; then
    git config --file=.gitmodules --remove-section 'submodule..dotfiles.private' || true
fi

# Remove the private submodule from .git/config if it exists
echo "Removing private submodule from git config..."
if git config --get-regexp '^submodule\..*\.path$' | grep -q '.dotfiles.private'; then
    git config --remove-section 'submodule..dotfiles.private' || true
fi

# Remove the submodule directory if it exists
echo "Removing private submodule directory..."
if [[ -d ".dotfiles.private" ]]; then
    rm -rf .dotfiles.private
fi

# Remove from git index if present
echo "Removing from git index..."
if git ls-files --error-unmatch .dotfiles.private &>/dev/null; then
    git rm --cached .dotfiles.private || true
fi

# Clean up .git/modules if it exists
if [[ -d ".git/modules/.dotfiles.private" ]]; then
    echo "Cleaning up .git/modules..."
    rm -rf ".git/modules/.dotfiles.private"
fi

# Now initialize and update only the public submodules
echo "Initializing and updating public submodules..."
git submodule init
git submodule update --recursive

echo "Repository prepared for CI build"