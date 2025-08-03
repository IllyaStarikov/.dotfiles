#!/bin/bash
# Script to prepare repository for CI by removing private submodule references

set -euo pipefail

echo "Preparing repository for CI build..."

# Remove the private submodule from .gitmodules
echo "Removing private submodule from .gitmodules..."
git config --file=.gitmodules --remove-section submodule..dotfiles.private || true

# Remove the private submodule from .git/config
echo "Removing private submodule from git config..."
git config --remove-section submodule..dotfiles.private || true

# Remove the submodule directory
echo "Removing private submodule directory..."
rm -rf .dotfiles.private

# Remove from git index
echo "Removing from git index..."
git rm --cached .dotfiles.private || true

# Now update the remaining submodules
echo "Updating public submodules..."
git submodule update --init --recursive

echo "Repository prepared for CI build"