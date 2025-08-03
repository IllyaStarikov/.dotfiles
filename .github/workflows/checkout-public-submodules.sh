#!/bin/bash
# Script to checkout only public submodules in CI

set -euo pipefail

echo "Initializing and updating only public submodules..."

# Get list of all submodules
git config --file .gitmodules --get-regexp path | while read path_key path
do
    # Extract the submodule name from the path key
    # Format is: submodule.NAME.path
    name=$(echo "$path_key" | sed 's/^submodule\.\(.*\)\.path$/\1/')
    
    # Skip the private submodule
    if [[ "$name" == ".dotfiles.private" ]]; then
        echo "Skipping private submodule: $name"
        continue
    fi
    
    echo "Initializing submodule: $name"
    git submodule init -- "$path"
    git submodule update --recursive -- "$path"
done

echo "Public submodules updated successfully"