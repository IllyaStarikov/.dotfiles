#!/usr/bin/env zsh
# regenerate-all.sh - Regenerate all theme configs from templates
#
# USAGE:
#   regenerate-all.sh          # Regenerate all themes
#   regenerate-all.sh --check  # Check which themes need regeneration

set -eo pipefail

SCRIPT_DIR="${0:A:h}"
GENERATE_SCRIPT="$SCRIPT_DIR/generate-theme.sh"

# Check if generate script exists
if [[ ! -x "$GENERATE_SCRIPT" ]]; then
  echo "Error: generate-theme.sh not found or not executable" >&2
  exit 1
fi

main() {
  local check_only=false
  [[ "${1:-}" == "--check" ]] && check_only=true

  local count=0
  local errors=0

  for colors_json in "$SCRIPT_DIR"/*/*/colors.json; do
    if [[ -f "$colors_json" ]]; then
      local theme_dir=$(dirname "$colors_json")
      local variant=$(basename "$theme_dir")
      local family=$(basename "$(dirname "$theme_dir")")

      # Skip templates
      [[ "$family" == "templates" ]] && continue

      if $check_only; then
        echo "Would regenerate: $family/$variant"
      else
        echo -n "Regenerating $family/$variant... "
        if "$GENERATE_SCRIPT" "$family" "$variant" >/dev/null 2>&1; then
          echo "OK"
          count=$((count + 1))
        else
          echo "FAILED"
          errors=$((errors + 1))
        fi
      fi
    fi
  done

  if ! $check_only; then
    echo ""
    echo "Regenerated $count themes ($errors errors)"
  fi
}

main "$@"
