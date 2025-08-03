#!/bin/bash
# Script to checkout only public submodules in CI

set -euo pipefail

echo "Initializing and updating only public submodules..."

# Initialize submodules
git submodule init

# Update only the public submodules (skip .dotfiles.private)
git config --local submodule.".dotfiles.private".update none

# Update all other submodules
git submodule update --recursive

echo "Public submodules updated successfully"