#!/usr/bin/env zsh
# Theme validation script - ensures all themes have required files
# Validates theme completeness and symlink integrity for theme switcher
# Based on Google Shell Style Guide: https://google.github.io/styleguide/shellguide.html

set -euo pipefail

# ANSI color codes for user feedback
# Provides visual distinction for validation results
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Path detection for theme directory location
# Uses BASH_SOURCE for compatibility with sourced execution
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Core files that every theme must provide
# These ensure complete application coverage for theme switching
REQUIRED_FILES=(
  "alacritty.toml"
  "tmux.conf"
  "starship.toml"
  "wezterm.lua"
  "colors.sh"
)

# Additional files that enhance theme functionality
# Not required but provide extended editor support
OPTIONAL_FILES=(
  "vim.vim"
)

echo "🔍 Validating theme configurations..."
echo "===================================="
echo ""

# Counters for validation summary statistics
# Provides clear overview of theme directory health
TOTAL_THEMES=0
VALID_THEMES=0
INVALID_THEMES=0

# Process each theme directory for completeness
# Checks both required files and symlink integrity
for theme_dir in "$SCRIPT_DIR"/tokyonight_*; do
  if [[ -d "$theme_dir" ]]; then
    THEME_NAME=$(basename "$theme_dir")
    TOTAL_THEMES=$((TOTAL_THEMES + 1))

    echo "Checking theme: $THEME_NAME"

    THEME_VALID=true
    MISSING_FILES=()

    # Verify all required configuration files exist
    # Missing files prevent theme from working across all applications
    for file in "${REQUIRED_FILES[@]}"; do
      if [[ ! -f "$theme_dir/$file" ]]; then
        THEME_VALID=false
        MISSING_FILES+=("$file")
      fi
    done

    # Display results
    if [[ "$THEME_VALID" == true ]]; then
      echo -e "  ${GREEN}✅ Valid${NC}"
      VALID_THEMES=$((VALID_THEMES + 1))

      # Report presence of optional enhancements
      # These provide additional functionality but aren't required
      for file in "${OPTIONAL_FILES[@]}"; do
        if [[ -f "$theme_dir/$file" ]]; then
          echo -e "  ${GREEN}+${NC} Has optional $file"
        fi
      done
    else
      echo -e "  ${RED}❌ Invalid${NC}"
      INVALID_THEMES=$((INVALID_THEMES + 1))

      echo -e "  ${RED}Missing files:${NC}"
      for file in "${MISSING_FILES[@]}"; do
        echo -e "    ${RED}- $file${NC}"
      done
    fi

    # Detect unexpected files that might indicate issues
    # Helps maintain clean theme directory structure
    while IFS= read -r -d '' file; do
      relative_file="${file#$theme_dir/}"
      is_expected=false

      for expected in "${REQUIRED_FILES[@]}" "${OPTIONAL_FILES[@]}"; do
        if [[ "$relative_file" == "$expected" ]]; then
          is_expected=true
          break
        fi
      done

      if [[ "$is_expected" == false ]] && [[ "$relative_file" != "README.md" ]]; then
        echo -e "  ${YELLOW}⚠️  Unexpected file: $relative_file${NC}"
      fi
    done < <(find "$theme_dir" -type f -print0)

    echo ""
  fi
done

# Display validation summary with color-coded results
# Provides quick overview of theme directory health
echo "===================================="
echo "Summary:"
echo "  Total themes:   $TOTAL_THEMES"
echo -e "  Valid themes:   ${GREEN}$VALID_THEMES${NC}"
if [[ $INVALID_THEMES -gt 0 ]]; then
  echo -e "  Invalid themes: ${RED}$INVALID_THEMES${NC}"
else
  echo -e "  Invalid themes: ${GREEN}0${NC}"
fi

# Verify active theme symlinks are in place
# These symlinks are created by switch-theme.sh and consumed by applications
echo ""
echo "Checking theme symlinks..."
if [[ -L "$HOME/.config/alacritty/theme.toml" ]]; then
  echo -e "  ${GREEN}✅${NC} Alacritty theme symlink exists"
else
  echo -e "  ${YELLOW}⚠️${NC}  No Alacritty theme symlink (run switch-theme.sh to create)"
fi

if [[ -L "$HOME/.config/tmux/theme.conf" ]]; then
  echo -e "  ${GREEN}✅${NC} Tmux theme symlink exists"
else
  echo -e "  ${YELLOW}⚠️${NC}  No Tmux theme symlink (run switch-theme.sh to create)"
fi

# Exit with status code indicating validation results
# Non-zero exit allows integration with CI/CD pipelines
if [[ $INVALID_THEMES -gt 0 ]]; then
  echo ""
  echo -e "${RED}Validation failed. Fix missing files before using theme switcher.${NC}"
  exit 1
else
  echo ""
  echo -e "${GREEN}✅ All themes validated successfully!${NC}"
  exit 0
fi
