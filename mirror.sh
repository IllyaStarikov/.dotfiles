#!/usr/bin/env bash

# ═══════════════════════════════════════════════════════════════════════════════
# Dotfiles Perfect Mirror Generator
# ═══════════════════════════════════════════════════════════════════════════════
# Creates an exact HTML mirror of the dotfiles directory structure with:
# - Exact directory hierarchy preservation
# - ls-style file listings with permissions, size, date
# - Syntax-highlighted file viewing
# - Comprehensive navigation and search
# ═══════════════════════════════════════════════════════════════════════════════

set -euo pipefail

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
SRC_DIR="$ROOT_DIR/src"
OUTPUT_DIR="$SCRIPT_DIR/dist"

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# ═══════════════════════════════════════════════════════════════════════════════
# Core Functions
# ═══════════════════════════════════════════════════════════════════════════════

log() {
    echo -e "${BLUE}[$(date +'%H:%M:%S')]${NC} $*"
}

success() {
    echo -e "${GREEN}✓${NC} $*"
}

warn() {
    echo -e "${YELLOW}⚠${NC} $*"
}

# Initialize output directory
init_output() {
    log "Initializing output directory..."
    rm -rf "$OUTPUT_DIR"
    mkdir -p "$OUTPUT_DIR"
    mkdir -p "$OUTPUT_DIR/src"
    success "Output directory created: $OUTPUT_DIR"
}

# Get file language for syntax highlighting
get_language() {
    local file="$1"
    local name="$(basename "$file")"
    local ext="${name##*.}"
    
    case "$ext" in
        lua) echo "lua" ;;
        vim) echo "vim" ;;
        sh|bash|zsh) echo "bash" ;;
        py) echo "python" ;;
        js) echo "javascript" ;;
        ts) echo "typescript" ;;
        jsx) echo "jsx" ;;
        tsx) echo "tsx" ;;
        json) echo "json" ;;
        yaml|yml) echo "yaml" ;;
        toml|conf) echo "toml" ;;
        md) echo "markdown" ;;
        html) echo "html" ;;
        css) echo "css" ;;
        xml) echo "xml" ;;
        c) echo "c" ;;
        cpp|cc) echo "cpp" ;;
        h|hpp) echo "cpp" ;;
        rs) echo "rust" ;;
        go) echo "go" ;;
        rb) echo "ruby" ;;
        pl) echo "perl" ;;
        sql) echo "sql" ;;
        *) 
            case "$name" in
                *gitconfig*) echo "ini" ;;
                *gitignore*) echo "gitignore" ;;
                *Dockerfile*) echo "dockerfile" ;;
                *Makefile*) echo "makefile" ;;
                *rc|.*rc) echo "bash" ;;
                *) echo "plaintext" ;;
            esac
            ;;
    esac
}

# Get file permissions in ls -la format
get_permissions() {
    local file="$1"
    if [[ "$(uname)" == "Darwin" ]]; then
        stat -f "%Sp" "$file"
    else
        stat -c "%A" "$file"
    fi
}

# Get file size in human readable format
get_size() {
    local file="$1"
    if [[ -d "$file" ]]; then
        echo "-"
    elif [[ "$(uname)" == "Darwin" ]]; then
        local size=$(stat -f "%z" "$file")
        format_size "$size"
    else
        stat -c "%s" "$file" | numfmt --to=iec-i --suffix=B
    fi
}

# Format size in human readable format
format_size() {
    local size="$1"
    if (( size < 1024 )); then
        echo "${size}B"
    elif (( size < 1048576 )); then
        echo "$((size / 1024))K"
    elif (( size < 1073741824 )); then
        echo "$((size / 1048576))M"
    else
        echo "$((size / 1073741824))G"
    fi
}

# Get file modification time
get_mtime() {
    local file="$1"
    if [[ "$(uname)" == "Darwin" ]]; then
        stat -f "%Sm" -t "%b %e %H:%M" "$file"
    else
        stat -c "%y" "$file" | cut -d' ' -f1
    fi
}

# Get file owner
get_owner() {
    local file="$1"
    if [[ "$(uname)" == "Darwin" ]]; then
        stat -f "%Su" "$file"
    else
        stat -c "%U" "$file"
    fi
}

# ═══════════════════════════════════════════════════════════════════════════════
# HTML Generation
# ═══════════════════════════════════════════════════════════════════════════════

# Generate CSS styles
generate_css() {
    cat > "$OUTPUT_DIR/style.css" << 'EOF'
/* Dotfiles Mirror Styles - Perfect ls-style listing */

:root {
    /* Light theme */
    --bg: #ffffff;
    --bg-alt: #f8f9fa;
    --fg: #24292e;
    --fg-dim: #6a737d;
    --border: #e1e4e8;
    --link: #0366d6;
    --link-hover: #0056b3;
    --code-bg: #f6f8fa;
    --selection: #b3d4fc;
    
    /* Syntax colors */
    --syntax-comment: #6a737d;
    --syntax-keyword: #d73a49;
    --syntax-string: #032f62;
    --syntax-number: #005cc5;
    --syntax-function: #6f42c1;
    --syntax-variable: #e36209;
}

@media (prefers-color-scheme: dark) {
    :root {
        --bg: #0d1117;
        --bg-alt: #161b22;
        --fg: #c9d1d9;
        --fg-dim: #8b949e;
        --border: #30363d;
        --link: #58a6ff;
        --link-hover: #79c0ff;
        --code-bg: #161b22;
        --selection: #3392ff44;
        
        --syntax-comment: #8b949e;
        --syntax-keyword: #ff7b72;
        --syntax-string: #a5d6ff;
        --syntax-number: #79c0ff;
        --syntax-function: #d2a8ff;
        --syntax-variable: #ffa657;
    }
}

* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: 'SF Mono', Monaco, 'Cascadia Code', 'Roboto Mono', Consolas, 'Courier New', monospace;
    font-size: 14px;
    line-height: 1.6;
    color: var(--fg);
    background: var(--bg);
}

/* Container */
.container {
    max-width: 1400px;
    margin: 0 auto;
    padding: 20px;
}

/* Header */
header {
    border-bottom: 1px solid var(--border);
    padding: 20px 0;
    margin-bottom: 20px;
}

h1 {
    font-size: 24px;
    font-weight: 600;
    margin-bottom: 10px;
}

.breadcrumb {
    font-size: 14px;
    color: var(--fg-dim);
}

.breadcrumb a {
    color: var(--link);
    text-decoration: none;
}

.breadcrumb a:hover {
    text-decoration: underline;
}

.breadcrumb span {
    margin: 0 5px;
    color: var(--fg-dim);
}

/* Stats bar */
.stats {
    display: flex;
    gap: 30px;
    padding: 15px 0;
    border-bottom: 1px solid var(--border);
    margin-bottom: 20px;
    font-size: 13px;
    color: var(--fg-dim);
}

.stat {
    display: flex;
    align-items: center;
    gap: 8px;
}

.stat-value {
    color: var(--fg);
    font-weight: 600;
}

/* File listing table */
.listing {
    width: 100%;
    font-family: 'SF Mono', Monaco, 'Cascadia Code', monospace;
    font-size: 13px;
    border-collapse: collapse;
}

.listing th {
    text-align: left;
    padding: 8px 12px;
    border-bottom: 2px solid var(--border);
    background: var(--bg-alt);
    font-weight: 600;
    color: var(--fg-dim);
    position: sticky;
    top: 0;
    z-index: 10;
}

.listing td {
    padding: 6px 12px;
    border-bottom: 1px solid var(--border);
    white-space: nowrap;
}

.listing tr:hover {
    background: var(--bg-alt);
}

/* File type specific styling */
.permissions {
    font-family: monospace;
    letter-spacing: 0.5px;
    color: var(--fg-dim);
}

.size {
    text-align: right;
    color: var(--fg-dim);
}

.owner {
    color: var(--fg-dim);
}

.mtime {
    color: var(--fg-dim);
}

.name {
    font-weight: 500;
}

.name a {
    color: var(--link);
    text-decoration: none;
    display: flex;
    align-items: center;
    gap: 6px;
}

.name a:hover {
    text-decoration: underline;
}

/* File icons */
.icon {
    width: 16px;
    height: 16px;
    display: inline-block;
    flex-shrink: 0;
}

.icon-dir { color: #54aeff; }
.icon-file { color: var(--fg-dim); }
.icon-lua { color: #000080; }
.icon-vim { color: #019733; }
.icon-sh { color: #89e051; }
.icon-git { color: #f14e32; }
.icon-conf { color: #6d8086; }
.icon-md { color: #083fa1; }
.icon-json { color: #cbcb41; }
.icon-yaml { color: #cb171e; }

/* Directory indicator */
.dir-name {
    font-weight: 600;
    color: var(--link);
}

.dir-name::after {
    content: '/';
    color: var(--fg-dim);
}

/* File viewer */
.file-viewer {
    margin-top: 30px;
}

.file-header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    padding: 12px 16px;
    background: var(--bg-alt);
    border: 1px solid var(--border);
    border-bottom: none;
    border-radius: 6px 6px 0 0;
}

.file-info {
    display: flex;
    gap: 20px;
    font-size: 13px;
    color: var(--fg-dim);
}

.file-actions {
    display: flex;
    gap: 10px;
}

.btn {
    padding: 4px 12px;
    background: var(--bg);
    border: 1px solid var(--border);
    border-radius: 4px;
    color: var(--fg);
    font-size: 12px;
    cursor: pointer;
    text-decoration: none;
    display: inline-flex;
    align-items: center;
    gap: 4px;
}

.btn:hover {
    background: var(--bg-alt);
}

.btn-primary {
    background: var(--link);
    color: white;
    border-color: var(--link);
}

.btn-primary:hover {
    background: var(--link-hover);
    border-color: var(--link-hover);
}

/* Code block */
.code-wrapper {
    border: 1px solid var(--border);
    border-radius: 0 0 6px 6px;
    overflow: hidden;
    background: var(--code-bg);
}

pre {
    margin: 0;
    padding: 16px;
    overflow-x: auto;
    background: var(--code-bg);
}

code {
    font-family: 'SF Mono', Monaco, 'Cascadia Code', monospace;
    font-size: 13px;
    line-height: 1.5;
}

/* Line numbers */
.line-numbers {
    counter-reset: line;
}

.line-numbers .line::before {
    counter-increment: line;
    content: counter(line);
    display: inline-block;
    width: 3em;
    margin-right: 1em;
    color: var(--fg-dim);
    text-align: right;
    user-select: none;
}

/* Search box */
.search-container {
    margin-bottom: 20px;
}

.search-box {
    width: 100%;
    max-width: 400px;
    padding: 8px 12px;
    font-size: 14px;
    font-family: inherit;
    background: var(--bg);
    color: var(--fg);
    border: 1px solid var(--border);
    border-radius: 4px;
}

.search-box:focus {
    outline: none;
    border-color: var(--link);
}

/* Tree view */
.tree-view {
    font-family: monospace;
    line-height: 1.4;
    padding: 20px;
    background: var(--code-bg);
    border: 1px solid var(--border);
    border-radius: 6px;
    overflow-x: auto;
}

.tree-line {
    white-space: pre;
}

.tree-link {
    color: var(--link);
    text-decoration: none;
}

.tree-link:hover {
    text-decoration: underline;
}

/* Responsive */
@media (max-width: 768px) {
    .container {
        padding: 10px;
    }
    
    .listing {
        font-size: 12px;
    }
    
    .listing th,
    .listing td {
        padding: 4px 8px;
    }
    
    .owner,
    .permissions {
        display: none;
    }
    
    .stats {
        flex-wrap: wrap;
        gap: 15px;
    }
}

/* Syntax highlighting */
.token.comment { color: var(--syntax-comment); }
.token.keyword { color: var(--syntax-keyword); }
.token.string { color: var(--syntax-string); }
.token.number { color: var(--syntax-number); }
.token.function { color: var(--syntax-function); }
.token.variable { color: var(--syntax-variable); }
EOF
    success "Generated style.css"
}

# Generate JavaScript
generate_js() {
    cat > "$OUTPUT_DIR/script.js" << 'EOF'
// Dotfiles Mirror - Interactive Features

class DotfilesMirror {
    constructor() {
        this.initSearch();
        this.initCopyButtons();
        this.initKeyboardShortcuts();
        this.updateStats();
    }

    // Initialize search functionality
    initSearch() {
        const searchBox = document.getElementById('search');
        if (!searchBox) return;

        searchBox.addEventListener('input', (e) => {
            const query = e.target.value.toLowerCase();
            const rows = document.querySelectorAll('.listing tbody tr');
            
            rows.forEach(row => {
                const name = row.querySelector('.name').textContent.toLowerCase();
                const match = name.includes(query);
                row.style.display = match ? '' : 'none';
            });
            
            this.updateStats(query);
        });
    }

    // Initialize copy to clipboard
    initCopyButtons() {
        document.querySelectorAll('.copy-btn').forEach(btn => {
            btn.addEventListener('click', () => {
                const code = document.querySelector('pre code');
                if (code) {
                    navigator.clipboard.writeText(code.textContent).then(() => {
                        const original = btn.textContent;
                        btn.textContent = 'Copied!';
                        setTimeout(() => {
                            btn.textContent = original;
                        }, 2000);
                    });
                }
            });
        });
    }

    // Keyboard shortcuts
    initKeyboardShortcuts() {
        document.addEventListener('keydown', (e) => {
            // / to focus search
            if (e.key === '/' && !e.ctrlKey && !e.metaKey) {
                const search = document.getElementById('search');
                if (search && document.activeElement !== search) {
                    e.preventDefault();
                    search.focus();
                }
            }
            
            // Escape to clear search
            if (e.key === 'Escape') {
                const search = document.getElementById('search');
                if (search) {
                    search.value = '';
                    search.dispatchEvent(new Event('input'));
                }
            }
        });
    }

    // Update statistics
    updateStats(filter = '') {
        const rows = document.querySelectorAll('.listing tbody tr');
        let visible = 0;
        let totalSize = 0;
        
        rows.forEach(row => {
            if (row.style.display !== 'none') {
                visible++;
                const sizeText = row.querySelector('.size')?.textContent || '0';
                // Parse size (simplified)
                const match = sizeText.match(/(\d+)([KMGT]?)/);
                if (match) {
                    let size = parseInt(match[1]);
                    const unit = match[2];
                    if (unit === 'K') size *= 1024;
                    else if (unit === 'M') size *= 1024 * 1024;
                    else if (unit === 'G') size *= 1024 * 1024 * 1024;
                    totalSize += size;
                }
            }
        });
        
        // Update displayed stats
        const itemCount = document.getElementById('item-count');
        const totalCount = document.getElementById('total-count');
        
        if (itemCount && totalCount) {
            itemCount.textContent = visible;
            if (filter) {
                totalCount.textContent = `of ${rows.length}`;
            } else {
                totalCount.textContent = '';
            }
        }
    }

    // Format file size
    formatSize(bytes) {
        if (bytes === 0) return '0B';
        const k = 1024;
        const sizes = ['B', 'K', 'M', 'G'];
        const i = Math.floor(Math.log(bytes) / Math.log(k));
        return Math.round(bytes / Math.pow(k, i)) + sizes[i];
    }
}

// Initialize when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    new DotfilesMirror();
});

// Syntax highlighting with Prism
if (typeof Prism !== 'undefined') {
    Prism.highlightAll();
}
EOF
    success "Generated script.js"
}

# Generate directory index HTML
generate_directory_index() {
    local dir="$1"
    local relative_path="${dir#$SRC_DIR}"
    relative_path="${relative_path#/}"
    
    local output_dir="$OUTPUT_DIR/src"
    if [[ -n "$relative_path" ]]; then
        output_dir="$OUTPUT_DIR/src/$relative_path"
    fi
    mkdir -p "$output_dir"
    
    local output_file="$output_dir/index.html"
    local title="/${relative_path:-src}"
    
    # Generate breadcrumb
    local breadcrumb="<a href=\"/\">~/.dotfiles</a>"
    if [[ -n "$relative_path" ]]; then
        local path=""
        IFS='/' read -ra PARTS <<< "$relative_path"
        for part in "${PARTS[@]}"; do
            if [[ -n "$path" ]]; then
                path="$path/$part"
            else
                path="$part"
            fi
            breadcrumb="$breadcrumb <span>/</span> <a href=\"/src/$path/\">$part</a>"
        done
    else
        breadcrumb="$breadcrumb <span>/</span> <a href=\"/src/\">src</a>"
    fi
    
    # Start HTML
    cat > "$output_file" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$title - Dotfiles Mirror</title>
    <link rel="stylesheet" href="/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/themes/prism-tomorrow.min.css">
</head>
<body>
    <div class="container">
        <header>
            <h1>Directory Listing: $title</h1>
            <div class="breadcrumb">$breadcrumb</div>
        </header>
        
        <div class="search-container">
            <input type="text" id="search" class="search-box" placeholder="Filter files... (press / to focus)">
        </div>
        
        <div class="stats">
            <div class="stat">
                <span class="stat-label">Items:</span>
                <span class="stat-value" id="item-count">0</span>
                <span id="total-count"></span>
            </div>
            <div class="stat">
                <span class="stat-label">Total Size:</span>
                <span class="stat-value" id="total-size">calculating...</span>
            </div>
            <div class="stat">
                <span class="stat-label">Last Modified:</span>
                <span class="stat-value">$(date '+%Y-%m-%d %H:%M')</span>
            </div>
        </div>
        
        <table class="listing">
            <thead>
                <tr>
                    <th>Permissions</th>
                    <th>Size</th>
                    <th>Owner</th>
                    <th>Modified</th>
                    <th>Name</th>
                </tr>
            </thead>
            <tbody>
EOF
    
    # Add parent directory link if not at root
    if [[ -n "$relative_path" ]]; then
        cat >> "$output_file" << EOF
                <tr>
                    <td class="permissions">drwxr-xr-x</td>
                    <td class="size">-</td>
                    <td class="owner">$(whoami)</td>
                    <td class="mtime">-</td>
                    <td class="name"><a href="../"><span class="icon icon-dir">📁</span> ..</a></td>
                </tr>
EOF
    fi
    
    # List directories first
    local item_count=0
    local total_size=0
    
    for item in "$dir"/*; do
        [[ -e "$item" ]] || continue
        
        local name="$(basename "$item")"
        [[ "$name" == ".*" ]] && continue
        
        if [[ -d "$item" ]]; then
            local perms="$(get_permissions "$item")"
            local size="-"
            local owner="$(get_owner "$item")"
            local mtime="$(get_mtime "$item")"
            
            cat >> "$output_file" << EOF
                <tr>
                    <td class="permissions">$perms</td>
                    <td class="size">$size</td>
                    <td class="owner">$owner</td>
                    <td class="mtime">$mtime</td>
                    <td class="name"><a href="$name/" class="dir-name"><span class="icon icon-dir">📁</span> $name</a></td>
                </tr>
EOF
            ((item_count++))
        fi
    done
    
    # List files
    for item in "$dir"/*; do
        [[ -e "$item" ]] || continue
        
        local name="$(basename "$item")"
        [[ "$name" == ".*" ]] && continue
        
        if [[ -f "$item" ]]; then
            local perms="$(get_permissions "$item")"
            local size="$(get_size "$item")"
            local owner="$(get_owner "$item")"
            local mtime="$(get_mtime "$item")"
            local icon="📄"
            
            # Choose icon based on file type
            case "$name" in
                *.lua) icon="🌙" ;;
                *.sh|*.bash|*.zsh) icon="🐚" ;;
                *.vim) icon="📝" ;;
                *.conf|*.toml) icon="⚙️" ;;
                *.json) icon="📊" ;;
                *.yaml|*.yml) icon="📋" ;;
                *.md) icon="📖" ;;
                *git*) icon="🔧" ;;
            esac
            
            cat >> "$output_file" << EOF
                <tr>
                    <td class="permissions">$perms</td>
                    <td class="size">$size</td>
                    <td class="owner">$owner</td>
                    <td class="mtime">$mtime</td>
                    <td class="name"><a href="$name.html"><span class="icon icon-file">$icon</span> $name</a></td>
                </tr>
EOF
            ((item_count++))
        fi
    done
    
    # Close HTML
    cat >> "$output_file" << EOF
            </tbody>
        </table>
    </div>
    
    <script>
        // Update item count
        document.getElementById('item-count').textContent = '$item_count';
    </script>
    <script src="/script.js"></script>
</body>
</html>
EOF
    
    success "Generated index for $title ($item_count items)"
}

# Generate file viewer HTML
generate_file_viewer() {
    local file="$1"
    local relative_path="${file#$SRC_DIR}"
    relative_path="${relative_path#/}"
    
    local output_file="$OUTPUT_DIR/src/$relative_path.html"
    local output_dir="$(dirname "$output_file")"
    mkdir -p "$output_dir"
    
    local name="$(basename "$file")"
    local dir_path="$(dirname "$relative_path")"
    local language="$(get_language "$file")"
    
    # File metadata
    local perms="$(get_permissions "$file")"
    local size="$(get_size "$file")"
    local lines="$(wc -l < "$file" 2>/dev/null || echo "0")"
    local mtime="$(get_mtime "$file")"
    
    # Generate breadcrumb
    local breadcrumb="<a href=\"/\">~/.dotfiles</a> <span>/</span> <a href=\"/src/\">src</a>"
    if [[ "$dir_path" != "." ]]; then
        local path=""
        IFS='/' read -ra PARTS <<< "$dir_path"
        for part in "${PARTS[@]}"; do
            if [[ -n "$path" ]]; then
                path="$path/$part"
            else
                path="$part"
            fi
            breadcrumb="$breadcrumb <span>/</span> <a href=\"/src/$path/\">$part</a>"
        done
    fi
    breadcrumb="$breadcrumb <span>/</span> <span>$name</span>"
    
    # Read and escape file content
    local content=""
    if [[ -f "$file" ]]; then
        # Add line numbers and escape HTML
        content=$(awk '{printf "<span class=\"line\">%s</span>\n", $0}' "$file" | \
                  sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g')
    fi
    
    # Generate HTML
    cat > "$output_file" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$name - Dotfiles Mirror</title>
    <link rel="stylesheet" href="/style.css">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/themes/prism-tomorrow.min.css">
</head>
<body>
    <div class="container">
        <header>
            <h1>$name</h1>
            <div class="breadcrumb">$breadcrumb</div>
        </header>
        
        <div class="file-viewer">
            <div class="file-header">
                <div class="file-info">
                    <span>$perms</span>
                    <span>$size</span>
                    <span>$lines lines</span>
                    <span>$language</span>
                    <span>$mtime</span>
                </div>
                <div class="file-actions">
                    <button class="btn copy-btn">📋 Copy</button>
                    <a href="https://github.com/IllyaStarikov/.dotfiles/blob/main/src/$relative_path" 
                       class="btn" target="_blank">🔗 GitHub</a>
                    <a href="./" class="btn">📁 Directory</a>
                </div>
            </div>
            <div class="code-wrapper">
                <pre class="line-numbers"><code class="language-$language">$content</code></pre>
            </div>
        </div>
    </div>
    
    <script src="https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/prism.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/components/prism-$language.min.js"></script>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/prism/1.29.0/plugins/line-numbers/prism-line-numbers.min.js"></script>
    <script src="/script.js"></script>
</body>
</html>
EOF
}

# Generate tree view
generate_tree_view() {
    local output_file="$OUTPUT_DIR/tree.html"
    
    log "Generating tree view..."
    
    cat > "$output_file" << 'EOF'
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Directory Tree - Dotfiles Mirror</title>
    <link rel="stylesheet" href="/style.css">
</head>
<body>
    <div class="container">
        <header>
            <h1>Directory Tree</h1>
            <div class="breadcrumb">
                <a href="/">~/.dotfiles</a> <span>/</span> <span>tree</span>
            </div>
        </header>
        
        <div class="tree-view">
EOF
    
    # Generate tree using tree command or custom implementation
    if command -v tree &> /dev/null; then
        cd "$SRC_DIR"
        tree -H '.' -L 4 --charset utf-8 -I '.git|.DS_Store|*.pyc|__pycache__' \
             -n --nolinks | sed 's/<[^>]*>//g' | \
             sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g' >> "$output_file"
    else
        # Fallback to find-based tree
        echo "<pre>" >> "$output_file"
        find "$SRC_DIR" -type d -name ".git" -prune -o -print | \
            sed "s|$SRC_DIR||" | sort | \
            awk '
                BEGIN { depth = 0 }
                {
                    path = $0
                    gsub(/[^\/]/, "", path)
                    new_depth = length(path)
                    
                    if (new_depth > depth) {
                        for (i = depth; i < new_depth; i++) {
                            printf "│   "
                        }
                    }
                    
                    name = $0
                    gsub(/.*\//, "", name)
                    if (name == "") name = "src"
                    
                    printf "├── %s\n", name
                    depth = new_depth
                }
            ' >> "$output_file"
        echo "</pre>" >> "$output_file"
    fi
    
    cat >> "$output_file" << 'EOF'
        </div>
    </div>
    <script src="/script.js"></script>
</body>
</html>
EOF
    
    success "Generated tree view"
}

# Generate main index
generate_main_index() {
    local output_file="$OUTPUT_DIR/index.html"
    
    log "Generating main index..."
    
    # Count statistics
    local total_files=$(find "$SRC_DIR" -type f | wc -l)
    local total_dirs=$(find "$SRC_DIR" -type d | wc -l)
    local total_size=$(du -sh "$SRC_DIR" 2>/dev/null | cut -f1)
    local total_lines=$(find "$SRC_DIR" -type f -exec wc -l {} + 2>/dev/null | tail -1 | awk '{print $1}')
    
    cat > "$output_file" << EOF
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dotfiles Mirror - Complete Configuration Reference</title>
    <link rel="stylesheet" href="/style.css">
    <style>
        .hero {
            text-align: center;
            padding: 60px 20px;
            background: var(--bg-alt);
            border-bottom: 1px solid var(--border);
            margin: -20px -20px 40px -20px;
        }
        .hero h1 {
            font-size: 48px;
            margin-bottom: 20px;
        }
        .hero p {
            font-size: 18px;
            color: var(--fg-dim);
            max-width: 600px;
            margin: 0 auto 30px;
        }
        .stats-grid {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
            gap: 20px;
            margin: 40px 0;
        }
        .stat-card {
            background: var(--bg-alt);
            padding: 20px;
            border-radius: 8px;
            border: 1px solid var(--border);
            text-align: center;
        }
        .stat-card .value {
            font-size: 32px;
            font-weight: 700;
            color: var(--link);
        }
        .stat-card .label {
            font-size: 14px;
            color: var(--fg-dim);
            margin-top: 5px;
        }
        .quick-links {
            display: grid;
            grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
            gap: 15px;
            margin: 40px 0;
        }
        .quick-link {
            display: flex;
            align-items: center;
            gap: 10px;
            padding: 15px;
            background: var(--bg);
            border: 1px solid var(--border);
            border-radius: 6px;
            text-decoration: none;
            color: var(--fg);
            transition: all 0.2s;
        }
        .quick-link:hover {
            background: var(--bg-alt);
            transform: translateY(-2px);
            box-shadow: 0 4px 8px rgba(0,0,0,0.1);
        }
        .quick-link .icon {
            font-size: 24px;
        }
        .quick-link .text {
            flex: 1;
        }
        .quick-link .title {
            font-weight: 600;
            display: block;
        }
        .quick-link .desc {
            font-size: 12px;
            color: var(--fg-dim);
        }
    </style>
</head>
<body>
    <div class="container">
        <div class="hero">
            <h1>~/.dotfiles</h1>
            <p>Complete mirror of all configuration files with perfect directory structure preservation</p>
            <div class="file-actions">
                <a href="/src/" class="btn btn-primary">📁 Browse Files</a>
                <a href="/tree.html" class="btn">🌳 Tree View</a>
                <a href="https://github.com/IllyaStarikov/.dotfiles" class="btn" target="_blank">🔗 GitHub</a>
            </div>
        </div>
        
        <div class="stats-grid">
            <div class="stat-card">
                <div class="value">$total_files</div>
                <div class="label">Files</div>
            </div>
            <div class="stat-card">
                <div class="value">$total_dirs</div>
                <div class="label">Directories</div>
            </div>
            <div class="stat-card">
                <div class="value">$total_size</div>
                <div class="label">Total Size</div>
            </div>
            <div class="stat-card">
                <div class="value">$(echo $total_lines | sed ':a;s/\B[0-9]\{3\}\>/,&/;ta')</div>
                <div class="label">Lines of Code</div>
            </div>
        </div>
        
        <h2>Quick Access</h2>
        <div class="quick-links">
            <a href="/src/neovim/" class="quick-link">
                <span class="icon">🌙</span>
                <div class="text">
                    <span class="title">Neovim</span>
                    <span class="desc">Modern IDE configuration</span>
                </div>
            </a>
            <a href="/src/zsh/" class="quick-link">
                <span class="icon">🐚</span>
                <div class="text">
                    <span class="title">Shell</span>
                    <span class="desc">Zsh with Zinit and Starship</span>
                </div>
            </a>
            <a href="/src/tmux.conf.html" class="quick-link">
                <span class="icon">💻</span>
                <div class="text">
                    <span class="title">Tmux</span>
                    <span class="desc">Terminal multiplexer</span>
                </div>
            </a>
            <a href="/src/alacritty/" class="quick-link">
                <span class="icon">🖥️</span>
                <div class="text">
                    <span class="title">Alacritty</span>
                    <span class="desc">GPU-accelerated terminal</span>
                </div>
            </a>
            <a href="/src/git/" class="quick-link">
                <span class="icon">🔧</span>
                <div class="text">
                    <span class="title">Git</span>
                    <span class="desc">Version control config</span>
                </div>
            </a>
            <a href="/src/theme-switcher/" class="quick-link">
                <span class="icon">🎨</span>
                <div class="text">
                    <span class="title">Themes</span>
                    <span class="desc">Auto theme switching</span>
                </div>
            </a>
            <a href="/src/scripts/" class="quick-link">
                <span class="icon">🛠️</span>
                <div class="text">
                    <span class="title">Scripts</span>
                    <span class="desc">Utility scripts</span>
                </div>
            </a>
            <a href="/src/setup/" class="quick-link">
                <span class="icon">📦</span>
                <div class="text">
                    <span class="title">Setup</span>
                    <span class="desc">Installation scripts</span>
                </div>
            </a>
        </div>
        
        <h2>Recent Activity</h2>
        <table class="listing">
            <thead>
                <tr>
                    <th>File</th>
                    <th>Modified</th>
                    <th>Size</th>
                </tr>
            </thead>
            <tbody>
EOF
    
    # Add 10 most recently modified files
    find "$SRC_DIR" -type f -exec stat -f "%m %N" {} \; 2>/dev/null | \
        sort -rn | head -10 | while read -r timestamp filepath; do
        local name="${filepath#$SRC_DIR/}"
        local size="$(get_size "$filepath")"
        local mtime="$(get_mtime "$filepath")"
        local href="/src/${name}.html"
        
        cat >> "$output_file" << EOF
                <tr>
                    <td class="name"><a href="$href">$name</a></td>
                    <td class="mtime">$mtime</td>
                    <td class="size">$size</td>
                </tr>
EOF
    done
    
    cat >> "$output_file" << EOF
            </tbody>
        </table>
    </div>
    
    <script src="/script.js"></script>
</body>
</html>
EOF
    
    success "Generated main index"
}

# Process directory recursively
process_directory() {
    local dir="$1"
    
    # Generate index for this directory
    generate_directory_index "$dir"
    
    # Process files in this directory
    for file in "$dir"/*; do
        if [[ -f "$file" ]]; then
            generate_file_viewer "$file"
        elif [[ -d "$file" ]]; then
            # Recursively process subdirectories
            process_directory "$file"
        fi
    done
}

# ═══════════════════════════════════════════════════════════════════════════════
# Main Execution
# ═══════════════════════════════════════════════════════════════════════════════

main() {
    log "Starting Dotfiles Perfect Mirror Generator"
    log "Source: $SRC_DIR"
    log "Output: $OUTPUT_DIR"
    
    # Initialize
    init_output
    
    # Generate static assets
    generate_css
    generate_js
    
    # Generate main index
    generate_main_index
    
    # Generate tree view
    generate_tree_view
    
    # Process entire src directory
    log "Processing directory structure..."
    process_directory "$SRC_DIR"
    
    # Summary
    local file_count=$(find "$OUTPUT_DIR" -name "*.html" | wc -l)
    local total_size=$(du -sh "$OUTPUT_DIR" | cut -f1)
    
    echo ""
    echo "═══════════════════════════════════════════════════════════════════"
    success "Mirror generation complete!"
    echo "  📁 Files generated: $file_count"
    echo "  💾 Total size: $total_size"
    echo "  📍 Output directory: $OUTPUT_DIR"
    echo ""
    echo "  To view locally:"
    echo "    cd $OUTPUT_DIR && python3 -m http.server 8000"
    echo "    Open: http://localhost:8000"
    echo "═══════════════════════════════════════════════════════════════════"
}

# Run if executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi