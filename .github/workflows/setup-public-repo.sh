#!/bin/bash
# Script to prepare repository for CI by using public-only gitmodules

set -euo pipefail

echo "Preparing repository for CI build..."

# Replace .gitmodules with the public-only version
echo "Replacing .gitmodules with public-only version..."
if [[ -f ".gitmodules.public" ]]; then
    cp .gitmodules.public .gitmodules
    echo "Using public-only .gitmodules"
else
    echo "ERROR: .gitmodules.public not found!"
    exit 1
fi

# Remove any existing git submodule configuration
echo "Cleaning git submodule configuration..."
rm -rf .git/modules/
git config --local --remove-section submodule..dotfiles.private 2>/dev/null || true

# Remove the private submodule directory if it exists
echo "Removing private submodule directory..."
rm -rf .dotfiles.private

# Now initialize and update only the public submodules
echo "Initializing and updating public submodules..."
git submodule init
git submodule update --recursive

echo "Repository prepared for CI build"