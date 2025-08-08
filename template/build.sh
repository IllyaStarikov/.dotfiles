#!/usr/bin/env bash

# Build script to generate HTML template files for dotfiles.starikov.io
# This script creates HTML files that embed GitHub code views for each dotfile

set -euo pipefail

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Base directories
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
SRC_DIR="$ROOT_DIR/src"
TEMPLATE_DIR="$SCRIPT_DIR"

# GitHub repository info
GITHUB_USER="IllyaStarikov"
GITHUB_REPO=".dotfiles"
GITHUB_BRANCH="master"

# Function to create HTML template
create_html_template() {
    local filename="$1"
    local filepath="$2"
    local title="$3"
    local output_file="$4"
    
    # URL encode the GitHub path
    local encoded_path=$(echo "$filepath" | sed 's/ /%20/g')
    local github_url="https://github.com/${GITHUB_USER}/${GITHUB_REPO}/blob/${GITHUB_BRANCH}/${encoded_path}"
    local encoded_url=$(python3 -c "import urllib.parse; print(urllib.parse.quote('$github_url', safe=''))")
    
    cat > "$output_file" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${title}</title>
    <script src="https://dotfiles.starikov.io/template/analytics.js"></script>
</head>
<body>
    <script src="https://emgithub.com/embed-v2.js?target=${encoded_url}&style=default&type=code&showBorder=on&showLineNumbers=on&showFileMeta=on&showFullPath=on&showCopy=on"></script>
</body>
</html>
EOF
}

# Function to process a dotfile
process_dotfile() {
    local src_file="$1"
    local html_name="$2"
    local title="$3"
    
    if [[ -f "$src_file" ]]; then
        local output_file="${TEMPLATE_DIR}/${html_name}.html"
        local relative_path="${src_file#$ROOT_DIR/}"
        
        echo -e "${BLUE}Creating${NC} ${html_name}.html for ${GREEN}${title}${NC}"
        create_html_template "$(basename "$src_file")" "$relative_path" "$title" "$output_file"
    else
        echo -e "${YELLOW}Warning:${NC} $src_file not found, skipping ${html_name}.html"
    fi
}

echo -e "${GREEN}Building HTML templates for dotfiles.starikov.io${NC}\n"

# Define dotfiles to process
# Format: source_file|html_name|title
declare -a DOTFILES=(
    "src/alacritty.toml|alacritty|alacritty.toml"
    "src/gitconfig|gitconfig|gitconfig"
    "src/gitignore|gitignore|gitignore"
    "src/tmux.conf|tmux|tmux.conf"
    "src/zshrc|zshrc|zshrc"
    "src/zshenv|zshenv|zshenv"
    "src/lua/init.lua|nvim|init.lua"
    "src/latexmkrc|latexmkrc|latexmkrc"
    "src/i3_config|i3_config|i3_config"
    "src/vimrc|vimrc|vimrc"
    "src/starship.toml|starship|starship.toml"
    "src/lua/config/plugins.lua|plugins|plugins.lua"
    "src/lua/config/keymaps.lua|keymaps|keymaps.lua"
    "src/lua/config/lsp.lua|lsp|lsp.lua"
)

# Process each dotfile
for entry in "${DOTFILES[@]}"; do
    IFS='|' read -r src_file html_name title <<< "$entry"
    process_dotfile "$ROOT_DIR/$src_file" "$html_name" "$title"
done

# Special case for complex configs that might want custom handling
echo -e "\n${BLUE}Processing special configurations...${NC}"

# Neovim configuration directory
if [[ -d "$SRC_DIR/lua/config" ]]; then
    echo -e "${GREEN}Found${NC} Neovim Lua configuration directory"
fi

# Count generated files
generated_count=$(find "$TEMPLATE_DIR" -name "*.html" -not -name "index.html" | wc -l)
echo -e "\n${GREEN}✓ Generated ${generated_count} HTML template files${NC}"

# Check for missing templates referenced in README
echo -e "\n${BLUE}Checking README references...${NC}"
if [[ -f "$ROOT_DIR/README.md" ]]; then
    # Extract template links from README
    grep -oE 'template/[a-zA-Z0-9_-]+\.html' "$ROOT_DIR/README.md" | sort -u | while read -r template_ref; do
        template_file="$ROOT_DIR/$template_ref"
        if [[ ! -f "$template_file" ]]; then
            echo -e "${RED}Missing:${NC} $template_ref (referenced in README)"
        fi
    done
fi

echo -e "\n${GREEN}Build complete!${NC}"
echo -e "${BLUE}Note:${NC} Remember to commit and push changes for them to appear on dotfiles.starikov.io"