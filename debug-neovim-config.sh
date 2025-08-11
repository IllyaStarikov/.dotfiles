#!/usr/bin/env bash
# Debug script to check Neovim config status

echo "=== Checking Neovim config status ==="
echo

echo "1. Current directory:"
pwd
echo

echo "2. Git status:"
git status --short | head -5
echo

echo "3. Checking src/neovim directory:"
ls -la src/neovim/
echo

echo "4. Checking if config is in git:"
git ls-tree HEAD:src/neovim | grep config
echo

echo "5. Trying to restore config from git:"
git restore src/neovim/config/ 2>&1
echo

echo "6. Checking src/neovim again after restore:"
ls -la src/neovim/
echo

echo "7. Checking for any git issues:"
git fsck --no-dangling 2>&1 | head -10
echo

echo "8. Force checkout of the config directory:"
git checkout HEAD -- src/neovim/config/ 2>&1
echo

echo "9. Final check of src/neovim:"
ls -la src/neovim/
echo

echo "10. Count of config files that should exist:"
git ls-files src/neovim/config/ | wc -l
echo

echo "11. Count of config files that actually exist:"
find src/neovim/config -type f 2>/dev/null | wc -l
echo

echo "=== End of diagnostic ==="