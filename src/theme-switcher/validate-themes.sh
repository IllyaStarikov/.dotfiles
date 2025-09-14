#!/usr/bin/env zsh
# Theme validation script - ensures all themes have required files

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
THEMES_DIR="$SCRIPT_DIR/themes"

# Required files for each theme
REQUIRED_FILES=(
    "alacritty.toml"
    "tmux.conf"
    "starship.toml"
)

# Optional files
OPTIONAL_FILES=(
    "vim.vim"
)

echo "🔍 Validating theme configurations..."
echo "===================================="
echo ""

# Check if themes directory exists
if [[ ! -d "$THEMES_DIR" ]]; then
    echo -e "${RED}❌ Themes directory not found: $THEMES_DIR${NC}"
    exit 1
fi

# Track validation results
TOTAL_THEMES=0
VALID_THEMES=0
INVALID_THEMES=0

# Validate each theme
for theme_dir in "$THEMES_DIR"/*; do
    if [[ -d "$theme_dir" ]]; then
        THEME_NAME=$(basename "$theme_dir")
        TOTAL_THEMES=$((TOTAL_THEMES + 1))
        
        echo "Checking theme: $THEME_NAME"
        
        THEME_VALID=true
        MISSING_FILES=()
        
        # Check required files
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
            
            # Check optional files
            for file in "${OPTIONAL_FILES[@]}"; do
                if [[ -f "$theme_dir/$file" ]]; then
                    echo -e "  ${GREEN}+${NC} Has $file"
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
        
        # Check for extra/unexpected files
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

# Summary
echo "===================================="
echo "Summary:"
echo "  Total themes:   $TOTAL_THEMES"
echo -e "  Valid themes:   ${GREEN}$VALID_THEMES${NC}"
if [[ $INVALID_THEMES -gt 0 ]]; then
    echo -e "  Invalid themes: ${RED}$INVALID_THEMES${NC}"
else
    echo -e "  Invalid themes: ${GREEN}0${NC}"
fi

# Check for symlink integrity
echo ""
echo "Checking theme symlinks..."
if [[ -L "$HOME/.config/alacritty/theme.toml" ]]; then
    echo -e "  ${GREEN}✅${NC} Alacritty theme symlink exists"
else
    echo -e "  ${YELLOW}⚠️${NC}  No Alacritty theme symlink"
fi

if [[ -L "$HOME/.config/tmux/theme.conf" ]]; then
    echo -e "  ${GREEN}✅${NC} Tmux theme symlink exists"
else
    echo -e "  ${YELLOW}⚠️${NC}  No Tmux theme symlink"
fi

# Exit with appropriate code
if [[ $INVALID_THEMES -gt 0 ]]; then
    exit 1
else
    echo ""
    echo -e "${GREEN}✅ All themes validated successfully!${NC}"
    exit 0
fi