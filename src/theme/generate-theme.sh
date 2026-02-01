#!/usr/bin/env zsh
# generate-theme.sh - Generate app configs from colors.json + templates
#
# USAGE:
#   generate-theme.sh <family> <variant> [app]
#   generate-theme.sh tokyonight storm          # Generate all configs
#   generate-theme.sh tokyonight storm tmux     # Generate only tmux
#
# This script reads colors.json and applies it to templates to generate
# app-specific configuration files.

set -euo pipefail

SCRIPT_DIR="${0:A:h}"
TEMPLATES_DIR="$SCRIPT_DIR/templates"

# Get theme mode from themes.json
get_theme_mode() {
  local family="$1"
  local variant="$2"
  local themes_json="$SCRIPT_DIR/../../config/themes.json"

  if command -v jq &>/dev/null && [[ -f "$themes_json" ]]; then
    jq -r ".families.\"$family\".variants.\"$variant\".mode // \"dark\"" "$themes_json" 2>/dev/null
  else
    # Fallback: guess from variant name
    if [[ "$variant" =~ (day|light|latte) ]]; then
      echo "light"
    else
      echo "dark"
    fi
  fi
}

# Generate config from template by substituting {{variables}}
generate_from_template() {
  local template_file="$1"
  local colors_json="$2"
  local theme_name="$3"
  local colorscheme_name="${4:-}"  # Optional: for neovim colorscheme name

  if [[ ! -f "$template_file" ]]; then
    echo "Error: Template not found: $template_file" >&2
    return 1
  fi

  if [[ ! -f "$colors_json" ]]; then
    echo "Error: colors.json not found: $colors_json" >&2
    return 1
  fi

  # Create temp file for sed script
  local sed_file
  sed_file=$(mktemp)

  # Build sed script
  echo "s|{{THEME_NAME}}|$theme_name|g" >> "$sed_file"
  [[ -n "$colorscheme_name" ]] && echo "s|{{COLORSCHEME_NAME}}|$colorscheme_name|g" >> "$sed_file"

  # Read all color keys from JSON and build sed replacements
  # IMPORTANT: Use ascii_downcase to normalize hex colors - tmux has issues with uppercase hex
  jq -r 'to_entries | .[] | select(.key != "name") | "s|{{\(.key)}}|\(.value | ascii_downcase)|g"' "$colors_json" >> "$sed_file"

  # Apply all substitutions
  sed -f "$sed_file" "$template_file"

  # Cleanup
  rm -f "$sed_file"
}

# Main function
main() {
  local family="${1:-}"
  local variant="${2:-}"
  local app="${3:-all}"  # Optional: specific app to generate

  if [[ -z "$family" || -z "$variant" ]]; then
    echo "Usage: $(basename "$0") <family> <variant> [app]" >&2
    echo "Example: $(basename "$0") tokyonight storm" >&2
    exit 1
  fi

  local theme_dir="$SCRIPT_DIR/$family/$variant"
  local colors_json="$theme_dir/colors.json"

  if [[ ! -f "$colors_json" ]]; then
    echo "Error: colors.json not found at $colors_json" >&2
    exit 1
  fi

  local theme_name
  theme_name=$(jq -r '.name // "Unknown"' "$colors_json" 2>/dev/null)

  local mode
  mode=$(get_theme_mode "$family" "$variant")

  # Neovim colors directory
  local nvim_colors_dir="$SCRIPT_DIR/../neovim/colors"
  local colorscheme_name="${family}_${variant}"

  # Generate configs based on app parameter
  case "$app" in
    all)
      generate_from_template "$TEMPLATES_DIR/tmux.conf" "$colors_json" "$theme_name"     > "$theme_dir/tmux.conf"
      generate_from_template "$TEMPLATES_DIR/alacritty.toml" "$colors_json" "$theme_name" > "$theme_dir/alacritty.toml"
      generate_from_template "$TEMPLATES_DIR/kitty.conf" "$colors_json" "$theme_name"    > "$theme_dir/kitty.conf"
      generate_from_template "$TEMPLATES_DIR/wezterm.lua" "$colors_json" "$theme_name"   > "$theme_dir/wezterm.lua"
      generate_from_template "$TEMPLATES_DIR/colors.sh" "$colors_json" "$theme_name"     > "$theme_dir/colors.sh"

      # Use light or dark starship template based on mode
      if [[ "$mode" == "light" ]]; then
        generate_from_template "$TEMPLATES_DIR/starship-light.toml" "$colors_json" "$theme_name" > "$theme_dir/starship.toml"
      else
        generate_from_template "$TEMPLATES_DIR/starship-dark.toml" "$colors_json" "$theme_name" > "$theme_dir/starship.toml"
      fi

      # Generate Neovim colorscheme
      if [[ -f "$TEMPLATES_DIR/neovim.lua" ]]; then
        mkdir -p "$nvim_colors_dir"
        generate_from_template "$TEMPLATES_DIR/neovim.lua" "$colors_json" "$theme_name" "$colorscheme_name" > "$nvim_colors_dir/${colorscheme_name}.lua"
      fi

      echo "Generated all configs for $theme_name in $theme_dir"
      ;;
    tmux)
      generate_from_template "$TEMPLATES_DIR/tmux.conf" "$colors_json" "$theme_name"
      ;;
    alacritty)
      generate_from_template "$TEMPLATES_DIR/alacritty.toml" "$colors_json" "$theme_name"
      ;;
    kitty)
      generate_from_template "$TEMPLATES_DIR/kitty.conf" "$colors_json" "$theme_name"
      ;;
    wezterm)
      generate_from_template "$TEMPLATES_DIR/wezterm.lua" "$colors_json" "$theme_name"
      ;;
    starship)
      if [[ "$mode" == "light" ]]; then
        generate_from_template "$TEMPLATES_DIR/starship-light.toml" "$colors_json" "$theme_name"
      else
        generate_from_template "$TEMPLATES_DIR/starship-dark.toml" "$colors_json" "$theme_name"
      fi
      ;;
    colors)
      generate_from_template "$TEMPLATES_DIR/colors.sh" "$colors_json" "$theme_name"
      ;;
    neovim)
      mkdir -p "$nvim_colors_dir"
      generate_from_template "$TEMPLATES_DIR/neovim.lua" "$colors_json" "$theme_name" "$colorscheme_name"
      ;;
    *)
      echo "Unknown app: $app" >&2
      echo "Valid apps: all, tmux, alacritty, kitty, wezterm, starship, colors, neovim" >&2
      exit 1
      ;;
  esac
}

main "$@"
