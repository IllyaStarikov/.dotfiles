#!/usr/bin/env zsh
# Theme validation script - ensures all themes have required files
# Validates theme completeness and symlink integrity for theme switcher
# JSON-driven: reads theme list from config/themes.json

set -euo pipefail

# ANSI color codes for user feedback
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Path detection for theme directory location
SCRIPT_DIR="${0:A:h}"
THEMES_JSON="${SCRIPT_DIR}/../../config/themes.json"

# Core files that every theme must provide
REQUIRED_FILES=(
  "alacritty.toml"
  "tmux.conf"
  "starship.toml"
  "wezterm.lua"
  "colors.sh"
)

# Additional files that enhance theme functionality
OPTIONAL_FILES=(
  "vim.vim"
  "kitty.conf"
)

# Check if jq is available
has_jq() {
  command -v jq &>/dev/null
}

# Get all theme names from JSON (family_variant format)
get_all_themes_from_json() {
  if ! has_jq; then
    echo "tokyonight_day tokyonight_night tokyonight_moon tokyonight_storm"
    return
  fi

  jq -r '.families | to_entries[] | .key as $family | .value.variants | keys[] | "\($family)_\(.)"' "$THEMES_JSON" 2>/dev/null | tr '\n' ' '
}

# Get family names from JSON
get_families_from_json() {
  if ! has_jq; then
    echo "tokyonight"
    return
  fi

  jq -r '.families | keys[]' "$THEMES_JSON" 2>/dev/null | tr '\n' ' '
}

# Convert theme name (family_variant) to directory path (family/variant)
get_theme_path() {
  local theme_name="$1"
  local family="${theme_name%%_*}"
  local variant="${theme_name#*_}"
  echo "$SCRIPT_DIR/$family/$variant"
}

echo "Validating theme configurations..."
echo "===================================="
echo ""

# Check JSON config
if [[ -f "$THEMES_JSON" ]]; then
  echo -e "${GREEN}[OK]${NC} themes.json found at $THEMES_JSON"
  if has_jq; then
    FAMILY_COUNT=$(jq '.families | length' "$THEMES_JSON" 2>/dev/null || echo "?")
    THEME_COUNT=$(jq '[.families[].variants | length] | add' "$THEMES_JSON" 2>/dev/null || echo "?")
    echo -e "     Families: ${CYAN}$FAMILY_COUNT${NC}, Total variants: ${CYAN}$THEME_COUNT${NC}"
  fi
else
  echo -e "${RED}[ERROR]${NC} themes.json not found at $THEMES_JSON"
fi
echo ""

# Counters for validation summary statistics
TOTAL_THEMES=0
VALID_THEMES=0
INVALID_THEMES=0
MISSING_THEMES=0

# Get expected themes from JSON
EXPECTED_THEMES=($(get_all_themes_from_json))

echo "Checking theme directories..."
echo "-----------------------------"

# Process each expected theme from JSON
for theme_name in "${EXPECTED_THEMES[@]}"; do
  theme_dir="$(get_theme_path "$theme_name")"
  TOTAL_THEMES=$((TOTAL_THEMES + 1))

  if [[ ! -d "$theme_dir" ]]; then
    echo -e "${RED}[MISSING]${NC} $theme_name - directory not found"
    MISSING_THEMES=$((MISSING_THEMES + 1))
    continue
  fi

  THEME_VALID=true
  MISSING_FILES=()

  # Verify all required configuration files exist
  for file in "${REQUIRED_FILES[@]}"; do
    if [[ ! -f "$theme_dir/$file" ]]; then
      THEME_VALID=false
      MISSING_FILES+=("$file")
    fi
  done

  # Display results
  if [[ "$THEME_VALID" == true ]]; then
    echo -e "${GREEN}[OK]${NC} $theme_name"
    VALID_THEMES=$((VALID_THEMES + 1))

    # Report presence of optional enhancements
    for file in "${OPTIONAL_FILES[@]}"; do
      if [[ -f "$theme_dir/$file" ]]; then
        echo -e "     ${GREEN}+${NC} Has optional $file"
      fi
    done
  else
    echo -e "${RED}[INVALID]${NC} $theme_name"
    INVALID_THEMES=$((INVALID_THEMES + 1))

    echo -e "     ${RED}Missing files:${NC}"
    for file in "${MISSING_FILES[@]}"; do
      echo -e "       ${RED}- $file${NC}"
    done
  fi
done

# Check for orphaned directories (not in JSON)
echo ""
echo "Checking for orphaned theme directories..."
echo "-------------------------------------------"
ORPHANED=0
# Check family/variant structure
for family_dir in "$SCRIPT_DIR"/*/; do
  if [[ -d "$family_dir" ]]; then
    family=$(basename "$family_dir")
    # Skip non-family items
    [[ "$family" == *.sh ]] && continue
    [[ "$family" == *.md ]] && continue

    for variant_dir in "$family_dir"/*/; do
      if [[ -d "$variant_dir" ]]; then
        variant=$(basename "$variant_dir")
        theme_name="${family}_${variant}"

        # Check if this theme is in expected list
        is_expected=false
        for expected in "${EXPECTED_THEMES[@]}"; do
          if [[ "$theme_name" == "$expected" ]]; then
            is_expected=true
            break
          fi
        done

        if [[ "$is_expected" == false ]]; then
          echo -e "${YELLOW}[ORPHAN]${NC} $family/$variant - not in themes.json"
          ORPHANED=$((ORPHANED + 1))
        fi
      fi
    done
  fi
done

if [[ $ORPHANED -eq 0 ]]; then
  echo -e "${GREEN}[OK]${NC} No orphaned directories"
fi

# Display validation summary
echo ""
echo "===================================="
echo "Summary:"
echo "  Total themes in JSON: $TOTAL_THEMES"
echo -e "  Valid themes:         ${GREEN}$VALID_THEMES${NC}"
if [[ $INVALID_THEMES -gt 0 ]]; then
  echo -e "  Invalid themes:       ${RED}$INVALID_THEMES${NC}"
else
  echo -e "  Invalid themes:       ${GREEN}0${NC}"
fi
if [[ $MISSING_THEMES -gt 0 ]]; then
  echo -e "  Missing directories:  ${YELLOW}$MISSING_THEMES${NC}"
else
  echo -e "  Missing directories:  ${GREEN}0${NC}"
fi
if [[ $ORPHANED -gt 0 ]]; then
  echo -e "  Orphaned directories: ${YELLOW}$ORPHANED${NC}"
fi

# Verify active theme symlinks are in place
echo ""
echo "Checking theme symlinks..."
if [[ -L "$HOME/.config/alacritty/theme.toml" ]]; then
  target=$(readlink "$HOME/.config/alacritty/theme.toml")
  echo -e "  ${GREEN}[OK]${NC} Alacritty -> $(basename "$(dirname "$target")")"
else
  echo -e "  ${YELLOW}[WARN]${NC} No Alacritty theme symlink"
fi

if [[ -L "$HOME/.config/tmux/theme.conf" ]]; then
  target=$(readlink "$HOME/.config/tmux/theme.conf")
  echo -e "  ${GREEN}[OK]${NC} Tmux -> $(basename "$(dirname "$target")")"
else
  echo -e "  ${YELLOW}[WARN]${NC} No Tmux theme symlink"
fi

# Exit with status code indicating validation results
if [[ $INVALID_THEMES -gt 0 ]] || [[ $MISSING_THEMES -gt 0 ]]; then
  echo ""
  echo -e "${RED}Validation failed. Some themes need attention.${NC}"
  exit 1
else
  echo ""
  echo -e "${GREEN}All themes validated successfully!${NC}"
  exit 0
fi
