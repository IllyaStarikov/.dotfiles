#!/usr/bin/env bash

# Build script to generate HTML files for dotfiles website
# Creates individual HTML pages for each configuration file

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
OUTPUT_DIR="$SCRIPT_DIR/public"

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Copy static files
echo -e "${BLUE}Copying static files...${NC}"
cp "$SCRIPT_DIR/index.html" "$OUTPUT_DIR/"
cp "$SCRIPT_DIR/styles.css" "$OUTPUT_DIR/"
cp "$SCRIPT_DIR/scripts.js" "$OUTPUT_DIR/"

# Function to create config page HTML
create_config_page() {
    local config_name="$1"
    local config_path="$2"
    local title="$3"
    local output_file="$4"
    
    # Read the actual config file
    local content=""
    if [[ -f "$ROOT_DIR/$config_path" ]]; then
        content=$(cat "$ROOT_DIR/$config_path" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g')
    else
        content="# File not found: $config_path"
    fi
    
    # Determine file type for syntax highlighting
    local lang="plaintext"
    case "$config_path" in
        *.lua) lang="lua" ;;
        *.sh|*.bash|*.zsh) lang="bash" ;;
        *.conf|*.toml) lang="toml" ;;
        *.vim|*vimrc) lang="vim" ;;
        *.json) lang="json" ;;
        *.yaml|*.yml) lang="yaml" ;;
        *.html) lang="html" ;;
        *.py) lang="python" ;;
        *.js) lang="javascript" ;;
        *gitconfig|*gitignore) lang="ini" ;;
        *zshrc|*zshenv) lang="bash" ;;
        *tmux.conf) lang="bash" ;;
    esac
    
    cat > "$output_file" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>${title} - Dotfiles Configuration</title>
    <link rel="stylesheet" href="styles.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/themes/prism-tomorrow.min.css">
    <style>
        body { padding: 0; }
        .config-header {
            background: var(--bg-secondary);
            border-bottom: 1px solid var(--border-color);
            padding: 2rem 0;
        }
        .config-title {
            font-size: 2rem;
            margin-bottom: 0.5rem;
        }
        .config-path {
            color: var(--text-secondary);
            font-family: monospace;
            font-size: 0.875rem;
        }
        .config-content {
            padding: 2rem 0;
        }
        .back-link {
            display: inline-block;
            margin-bottom: 1rem;
            color: var(--accent-color);
            text-decoration: none;
        }
        .back-link:hover {
            text-decoration: underline;
        }
        pre[class*="language-"] {
            background: var(--code-bg);
            border: 1px solid var(--border-color);
            border-radius: var(--radius);
        }
        .copy-button {
            position: absolute;
            top: 0.5rem;
            right: 0.5rem;
            padding: 0.25rem 0.75rem;
            background: var(--accent-color);
            color: white;
            border: none;
            border-radius: var(--radius);
            cursor: pointer;
            font-size: 0.875rem;
        }
        .copy-button:hover {
            background: var(--accent-hover);
        }
        .code-wrapper {
            position: relative;
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="nav-container">
            <a href="index.html" class="nav-logo">~/.dotfiles</a>
            <ul class="nav-menu">
                <li><a href="index.html#features">Features</a></li>
                <li><a href="index.html#configs">Configs</a></li>
                <li><a href="index.html#install">Install</a></li>
                <li><a href="https://github.com/IllyaStarikov/.dotfiles" target="_blank">GitHub</a></li>
            </ul>
        </div>
    </nav>

    <div class="config-header">
        <div class="container">
            <a href="index.html#configs" class="back-link">← Back to configs</a>
            <h1 class="config-title">${title}</h1>
            <div class="config-path">${config_path}</div>
        </div>
    </div>

    <div class="config-content">
        <div class="container">
            <div class="code-wrapper">
                <button class="copy-button" onclick="copyCode()">Copy</button>
                <pre><code class="language-${lang}" id="code-content">${content}</code></pre>
            </div>
        </div>
    </div>

    <footer class="footer">
        <div class="container">
            <div class="footer-bottom">
                <p>© 2024 • <a href="https://github.com/IllyaStarikov/.dotfiles">View on GitHub</a></p>
            </div>
        </div>
    </footer>

    <script src="https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/prism.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/components/prism-lua.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/components/prism-bash.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/components/prism-vim.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/components/prism-toml.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/components/prism-yaml.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/components/prism-json.min.js"></script>
    <script>
        function copyCode() {
            const code = document.getElementById('code-content').textContent;
            navigator.clipboard.writeText(code).then(() => {
                const button = document.querySelector('.copy-button');
                button.textContent = 'Copied!';
                setTimeout(() => {
                    button.textContent = 'Copy';
                }, 2000);
            });
        }
    </script>
</body>
</html>
EOF
}

# Configuration files to generate
# Format: output_file|config_path|title
configs="
nvim_init.html|src/neovim/init.lua|Neovim Configuration
nvim_plugins.html|src/neovim/config/plugins.lua|Plugin Configuration
nvim_keymaps.html|src/neovim/config/keymaps.lua|Keybindings
nvim_lsp.html|src/neovim/config/lsp/init.lua|LSP Configuration
alacritty.html|src/alacritty/alacritty.toml|Alacritty Terminal
tmux.html|src/tmux.conf|Tmux Configuration
zshrc.html|src/zsh/zshrc|Zsh Configuration
starship.html|src/zsh/starship.toml|Starship Prompt
gitconfig.html|src/git/gitconfig|Git Configuration
gitignore.html|src/git/gitignore|Global Gitignore
vimrc.html|src/vimrc|Vim Configuration
latexmkrc.html|src/latexmkrc|LaTeX Configuration"

# Generate HTML files for each config
echo -e "${BLUE}Generating configuration pages...${NC}"
echo "$configs" | grep -v '^$' | while IFS='|' read -r output_file config_path title; do
    # Create subdirectories if needed
    output_dir=$(dirname "$OUTPUT_DIR/$output_file")
    mkdir -p "$output_dir"
    
    echo -e "  ${GREEN}✓${NC} Generating $output_file"
    create_config_page "$(basename "$output_file" .html)" "$config_path" "$title" "$OUTPUT_DIR/$output_file"
done

# Generate theme pages
echo -e "${BLUE}Generating theme documentation...${NC}"

# Create themes overview page
cat > "$OUTPUT_DIR/themes.html" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Theme System - Dotfiles</title>
    <link rel="stylesheet" href="styles.css">
    <style>
        .theme-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
            gap: 2rem;
            margin: 2rem 0;
        }
        .theme-card {
            background: var(--bg-secondary);
            padding: 1.5rem;
            border-radius: var(--radius);
            border: 1px solid var(--border-color);
        }
        .theme-preview {
            display: flex;
            gap: 0.5rem;
            margin-top: 1rem;
        }
        .color-swatch {
            width: 30px;
            height: 30px;
            border-radius: 4px;
            border: 1px solid var(--border-color);
        }
    </style>
</head>
<body>
    <nav class="navbar">
        <div class="nav-container">
            <a href="index.html" class="nav-logo">~/.dotfiles</a>
            <ul class="nav-menu">
                <li><a href="index.html#features">Features</a></li>
                <li><a href="index.html#configs">Configs</a></li>
                <li><a href="index.html#install">Install</a></li>
                <li><a href="https://github.com/IllyaStarikov/.dotfiles" target="_blank">GitHub</a></li>
            </ul>
        </div>
    </nav>

    <div class="container" style="padding: 2rem 1.5rem;">
        <h1>Theme System</h1>
        <p>Automatic theme switching that syncs across all applications based on system appearance.</p>
        
        <h2>How It Works</h2>
        <p>The theme switcher script detects macOS appearance changes and automatically updates configurations for:</p>
        <ul>
            <li>Neovim colorscheme</li>
            <li>Alacritty terminal colors</li>
            <li>Tmux status bar</li>
            <li>Bat syntax highlighter</li>
            <li>Starship prompt</li>
        </ul>

        <h2>Available Themes</h2>
        <div class="theme-grid">
            <div class="theme-card">
                <h3>🌙 TokyoNight Night</h3>
                <p>Deep blue theme, perfect for late night coding sessions.</p>
                <div class="theme-preview">
                    <div class="color-swatch" style="background: #1a1b26;"></div>
                    <div class="color-swatch" style="background: #24283b;"></div>
                    <div class="color-swatch" style="background: #7aa2f7;"></div>
                    <div class="color-swatch" style="background: #9ece6a;"></div>
                </div>
            </div>
            <div class="theme-card">
                <h3>⛈️ TokyoNight Storm</h3>
                <p>Darker variant with higher contrast for better readability.</p>
                <div class="theme-preview">
                    <div class="color-swatch" style="background: #24283b;"></div>
                    <div class="color-swatch" style="background: #1f2335;"></div>
                    <div class="color-swatch" style="background: #7aa2f7;"></div>
                    <div class="color-swatch" style="background: #9ece6a;"></div>
                </div>
            </div>
            <div class="theme-card">
                <h3>🌕 TokyoNight Moon</h3>
                <p>Softer dark theme with purple accents.</p>
                <div class="theme-preview">
                    <div class="color-swatch" style="background: #222436;"></div>
                    <div class="color-swatch" style="background: #1e2030;"></div>
                    <div class="color-swatch" style="background: #82aaff;"></div>
                    <div class="color-swatch" style="background: #c3e88d;"></div>
                </div>
            </div>
            <div class="theme-card">
                <h3>☀️ TokyoNight Day</h3>
                <p>Light theme for daytime use with excellent contrast.</p>
                <div class="theme-preview">
                    <div class="color-swatch" style="background: #e1e2e7;"></div>
                    <div class="color-swatch" style="background: #f6f6f8;"></div>
                    <div class="color-swatch" style="background: #2e7de9;"></div>
                    <div class="color-swatch" style="background: #587539;"></div>
                </div>
            </div>
        </div>

        <h2>Usage</h2>
        <pre><code class="language-bash"># Automatic switching (detects system appearance)
theme

# Manual switching
theme dark   # Use dark theme (night variant)
theme light  # Use light theme (day variant)
theme night  # Use TokyoNight Night
theme storm  # Use TokyoNight Storm
theme moon   # Use TokyoNight Moon
theme day    # Use TokyoNight Day</code></pre>
    </div>

    <footer class="footer">
        <div class="container">
            <div class="footer-bottom">
                <p>© 2024 • <a href="https://github.com/IllyaStarikov/.dotfiles">View on GitHub</a></p>
            </div>
        </div>
    </footer>
</body>
</html>
EOF

echo -e "  ${GREEN}✓${NC} Generated themes.html"

# Create symlinks for other referenced pages
ln -sf themes.html "$OUTPUT_DIR/tokyonight.html" 2>/dev/null || true
ln -sf themes.html "$OUTPUT_DIR/theme-switcher.html" 2>/dev/null || true

echo -e "\n${GREEN}Build complete!${NC}"
echo -e "Output directory: ${BLUE}$OUTPUT_DIR${NC}"
echo -e "To preview: ${YELLOW}cd $OUTPUT_DIR && python3 -m http.server 8000${NC}"