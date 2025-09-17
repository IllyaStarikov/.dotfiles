#!/usr/bin/env zsh

# Advanced Dotfiles Documentation Generator
# Generates a complete mirror of configuration files with enhanced navigation
# Supports directory browsing, search, and comprehensive documentation

set -euo pipefail

# ════════════════════════════════════════════════════════════════════════════
# Configuration
# ════════════════════════════════════════════════════════════════════════════

SCRIPT_DIR="$(cd "$(dirname "${0}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"
SRC_DIR="$ROOT_DIR/src"
OUTPUT_DIR="$SCRIPT_DIR/dist"
ASSETS_DIR="$OUTPUT_DIR/assets"
DATA_DIR="$OUTPUT_DIR/data"

# File categories and their patterns
typeset -a CONFIG_PATTERNS=(
    "*.lua:Lua Configuration"
    "*.vim:Vim Script"
    "*.toml:TOML Configuration"
    "*.conf:Configuration File"
    "*.sh:Shell Script"
    "*.zsh:Zsh Script"
    "*.bash:Bash Script"
    "*.json:JSON Data"
    "*.yaml:YAML Configuration"
    "*.yml:YAML Configuration"
    "gitconfig:Git Configuration"
    "gitignore:Git Ignore"
    "*rc:RC File"
)

# Directories to exclude from scanning
EXCLUDE_DIRS=".git .github node_modules .cache backup temp tmp"

# ════════════════════════════════════════════════════════════════════════════
# Utility Functions
# ════════════════════════════════════════════════════════════════════════════

log() {
    echo "[$(date +'%H:%M:%S')] $*"
}

error() {
    echo "[ERROR] $*" >&2
    exit 1
}

# Create necessary directories
setup_directories() {
    log "Setting up output directories..."
    mkdir -p "$OUTPUT_DIR"
    mkdir -p "$ASSETS_DIR"/{css,js,icons}
    mkdir -p "$DATA_DIR"
    mkdir -p "$OUTPUT_DIR/files"
}

# Get file language for syntax highlighting
get_file_language() {
    local file="$1"
    local ext="${file##*.}"
    local name="$(basename "$file")"
    
    case "$ext" in
        lua) echo "lua" ;;
        vim) echo "vim" ;;
        sh|bash|zsh) echo "bash" ;;
        conf|toml) echo "toml" ;;
        json) echo "json" ;;
        yaml|yml) echo "yaml" ;;
        py) echo "python" ;;
        js) echo "javascript" ;;
        md) echo "markdown" ;;
        *) 
            case "$name" in
                *gitconfig*) echo "ini" ;;
                *gitignore*) echo "gitignore" ;;
                *rc) echo "bash" ;;
                *) echo "plaintext" ;;
            esac
            ;;
    esac
}

# Get file category
get_file_category() {
    local file="$1"
    local name="$(basename "$file")"
    
    # Check path-based categories
    if [[ "$file" == *"/neovim/"* ]]; then
        echo "Neovim"
    elif [[ "$file" == *"/zsh/"* ]]; then
        echo "Shell"
    elif [[ "$file" == *"/git/"* ]]; then
        echo "Git"
    elif [[ "$file" == *"/tmux"* ]]; then
        echo "Terminal"
    elif [[ "$file" == *"/alacritty/"* ]]; then
        echo "Terminal"
    elif [[ "$file" == *"/scripts/"* ]]; then
        echo "Scripts"
    elif [[ "$file" == *"/theme-switcher/"* ]]; then
        echo "Themes"
    elif [[ "$file" == *"/snippets/"* ]]; then
        echo "Snippets"
    else
        # Fallback to extension-based
        case "${file##*.}" in
            lua|vim) echo "Editor" ;;
            sh|bash|zsh) echo "Scripts" ;;
            conf|toml) echo "Configuration" ;;
            *) echo "Other" ;;
        esac
    fi
}

# Get file metadata
get_file_metadata() {
    local file="$1"
    local relative_path="${file#$SRC_DIR/}"
    local size=$(wc -c < "$file" 2>/dev/null || echo "0")
    local lines=$(wc -l < "$file" 2>/dev/null || echo "0")
    local modified=$(stat -f "%Sm" -t "%Y-%m-%d %H:%M" "$file" 2>/dev/null || echo "Unknown")
    
    echo "{
        \"path\": \"$relative_path\",
        \"name\": \"$(basename "$file")\",
        \"size\": $size,
        \"lines\": $lines,
        \"modified\": \"$modified\",
        \"language\": \"$(get_file_language "$file")\",
        \"category\": \"$(get_file_category "$file")\"
    }"
}

# ════════════════════════════════════════════════════════════════════════════
# File Discovery and Processing
# ════════════════════════════════════════════════════════════════════════════

# Build exclude pattern for find command
build_exclude_pattern() {
    local pattern=""
    for dir in $EXCLUDE_DIRS; do
        pattern="$pattern -name $dir -prune -o"
    done
    echo "$pattern"
}

# Discover all configuration files
discover_files() {
    log "Discovering configuration files..."
    local exclude_pattern=$(build_exclude_pattern)
    local files_json="["
    local first=true
    
    # Find all files, excluding certain directories
    while IFS= read -r file; do
        if [[ -f "$file" ]]; then
            # Skip binary files
            if file "$file" | grep -q "text"; then
                if [[ "$first" == "false" ]]; then
                    files_json="$files_json,"
                fi
                files_json="$files_json$(get_file_metadata "$file")"
                first=false
            fi
        fi
    done < <(eval "find '$SRC_DIR' $exclude_pattern -type f -print")
    
    files_json="$files_json]"
    echo "$files_json" > "$DATA_DIR/files.json"
    log "Discovered $(echo "$files_json" | grep -o '"path"' | wc -l) files"
}

# Generate directory tree structure
generate_tree() {
    log "Generating directory tree..."
    
    # Use tree command if available, otherwise use find
    if command -v tree &> /dev/null; then
        tree -J -a -I '.git|node_modules|*.pyc|__pycache__|.DS_Store' "$SRC_DIR" > "$DATA_DIR/tree.json"
    else
        # Fallback to custom tree generation
        generate_custom_tree "$SRC_DIR" > "$DATA_DIR/tree.json"
    fi
}

# Custom tree generation (fallback)
generate_custom_tree() {
    local dir="$1"
    local prefix="$2"
    
    echo "["
    local first=true
    for item in "$dir"/*; do
        if [[ ! "$first" == "true" ]]; then echo ","; fi
        first=false
        
        local name="$(basename "$item")"
        if [[ -d "$item" ]]; then
            echo "{\"type\":\"directory\",\"name\":\"$name\",\"contents\":"
            generate_custom_tree "$item" "  $prefix"
            echo "}"
        else
            local size=$(wc -c < "$item" 2>/dev/null || echo "0")
            echo "{\"type\":\"file\",\"name\":\"$name\",\"size\":$size}"
        fi
    done
    echo "]"
}

# Process individual file to HTML
process_file() {
    local file="$1"
    local relative_path="${file#$SRC_DIR/}"
    local output_file="$OUTPUT_DIR/files/${relative_path}.html"
    local output_dir="$(dirname "$output_file")"
    
    # Create output directory
    mkdir -p "$output_dir"
    
    # Read and escape file content
    local content=""
    if [[ -f "$file" ]]; then
        content=$(cat "$file" | sed 's/&/\&amp;/g; s/</\&lt;/g; s/>/\&gt;/g; s/"/\&quot;/g; s/'"'"'/\&#39;/g')
    fi
    
    # Get metadata
    local language=$(get_file_language "$file")
    local category=$(get_file_category "$file")
    local lines=$(wc -l < "$file" 2>/dev/null || echo "0")
    local size=$(wc -c < "$file" 2>/dev/null || echo "0")
    
    # Generate HTML
    cat > "$output_file" << EOF
<!DOCTYPE html>
<html lang="en" data-theme="auto">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$(basename "$file") - Dotfiles</title>
    <link rel="stylesheet" href="/assets/css/main.css">
    <link rel="stylesheet" href="/assets/css/prism-tomorrow.css">
</head>
<body>
    <div class="layout">
        <nav class="sidebar" id="sidebar">
            <div class="sidebar-header">
                <h2>~/.dotfiles</h2>
                <button class="sidebar-toggle" id="sidebar-toggle">☰</button>
            </div>
            <div class="search-box">
                <input type="text" id="search-input" placeholder="Search files...">
            </div>
            <div class="file-tree" id="file-tree">
                <!-- Populated by JavaScript -->
            </div>
        </nav>
        
        <main class="content">
            <div class="breadcrumb">
                <a href="/">Home</a> / 
                ${relative_path//\// / }
            </div>
            
            <div class="file-header">
                <h1>$(basename "$file")</h1>
                <div class="file-meta">
                    <span class="category-badge category-${category,,}">${category}</span>
                    <span class="meta-item">📝 ${lines} lines</span>
                    <span class="meta-item">💾 ${size} bytes</span>
                    <span class="meta-item">🔤 ${language}</span>
                </div>
            </div>
            
            <div class="file-actions">
                <button onclick="copyToClipboard()" class="btn btn-primary">📋 Copy</button>
                <button onclick="downloadFile()" class="btn">⬇️ Download</button>
                <a href="https://github.com/IllyaStarikov/.dotfiles/blob/main/src/${relative_path}" 
                   class="btn" target="_blank">🔗 View on GitHub</a>
            </div>
            
            <div class="code-container">
                <pre class="line-numbers"><code class="language-${language}" id="code-content">${content}</code></pre>
            </div>
        </main>
    </div>
    
    <script>
        const filePath = '${relative_path}';
        const fileContent = \`${content}\`;
    </script>
    <script src="/assets/js/prism.js"></script>
    <script src="/assets/js/app.js"></script>
</body>
</html>
EOF
}

# Process all discovered files
process_all_files() {
    log "Processing files..."
    local count=0
    
    # Read files from discovery
    while IFS= read -r file; do
        if [[ -f "$file" ]]; then
            process_file "$file"
            ((count++))
            if ((count % 10 == 0)); then
                echo -n "."
            fi
        fi
    done < <(find "$SRC_DIR" -type f)
    
    echo ""
    log "Processed $count files"
}

# ════════════════════════════════════════════════════════════════════════════
# Asset Generation
# ════════════════════════════════════════════════════════════════════════════

# Generate main CSS
generate_css() {
    log "Generating CSS..."
    cat > "$ASSETS_DIR/css/main.css" << 'EOF'
/* Modern Dotfiles Documentation Styles */

:root {
    --bg-primary: #ffffff;
    --bg-secondary: #f8f9fa;
    --bg-tertiary: #e9ecef;
    --text-primary: #212529;
    --text-secondary: #6c757d;
    --text-tertiary: #adb5bd;
    --border-color: #dee2e6;
    --accent-primary: #0066cc;
    --accent-secondary: #0052a3;
    --success: #28a745;
    --warning: #ffc107;
    --danger: #dc3545;
    --info: #17a2b8;
    
    --sidebar-width: 280px;
    --header-height: 60px;
    --font-mono: 'SF Mono', Monaco, 'Cascadia Code', 'Roboto Mono', monospace;
    --font-sans: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
}

[data-theme="dark"] {
    --bg-primary: #1a1b26;
    --bg-secondary: #24283b;
    --bg-tertiary: #292e42;
    --text-primary: #c0caf5;
    --text-secondary: #a9b1d6;
    --text-tertiary: #565f89;
    --border-color: #3b4261;
    --accent-primary: #7aa2f7;
    --accent-secondary: #7dcfff;
}

* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: var(--font-sans);
    background: var(--bg-primary);
    color: var(--text-primary);
    line-height: 1.6;
}

/* Layout */
.layout {
    display: flex;
    min-height: 100vh;
}

/* Sidebar */
.sidebar {
    width: var(--sidebar-width);
    background: var(--bg-secondary);
    border-right: 1px solid var(--border-color);
    position: fixed;
    height: 100vh;
    overflow-y: auto;
    transition: transform 0.3s ease;
}

.sidebar-header {
    padding: 1.5rem;
    border-bottom: 1px solid var(--border-color);
    display: flex;
    justify-content: space-between;
    align-items: center;
}

.sidebar-header h2 {
    font-size: 1.25rem;
    font-weight: 700;
    font-family: var(--font-mono);
}

.sidebar-toggle {
    display: none;
    background: none;
    border: none;
    font-size: 1.5rem;
    cursor: pointer;
    color: var(--text-primary);
}

/* Search */
.search-box {
    padding: 1rem;
    border-bottom: 1px solid var(--border-color);
}

.search-box input {
    width: 100%;
    padding: 0.5rem 1rem;
    background: var(--bg-primary);
    border: 1px solid var(--border-color);
    border-radius: 6px;
    color: var(--text-primary);
    font-size: 0.875rem;
}

.search-box input:focus {
    outline: none;
    border-color: var(--accent-primary);
}

/* File Tree */
.file-tree {
    padding: 1rem;
}

.tree-item {
    margin: 0.25rem 0;
}

.tree-item a {
    display: flex;
    align-items: center;
    padding: 0.375rem 0.75rem;
    color: var(--text-secondary);
    text-decoration: none;
    border-radius: 4px;
    transition: all 0.2s;
    font-size: 0.875rem;
}

.tree-item a:hover {
    background: var(--bg-tertiary);
    color: var(--text-primary);
}

.tree-item a.active {
    background: var(--accent-primary);
    color: white;
}

.tree-item .icon {
    margin-right: 0.5rem;
    font-size: 1rem;
}

.tree-directory {
    font-weight: 600;
}

.tree-directory > .tree-content {
    margin-left: 1.25rem;
}

.tree-toggle {
    display: inline-block;
    width: 1rem;
    margin-right: 0.25rem;
    cursor: pointer;
    user-select: none;
}

/* Main Content */
.content {
    margin-left: var(--sidebar-width);
    flex: 1;
    padding: 2rem;
    max-width: 1200px;
}

/* Breadcrumb */
.breadcrumb {
    margin-bottom: 2rem;
    color: var(--text-secondary);
    font-size: 0.875rem;
}

.breadcrumb a {
    color: var(--accent-primary);
    text-decoration: none;
}

.breadcrumb a:hover {
    text-decoration: underline;
}

/* File Header */
.file-header {
    margin-bottom: 2rem;
    padding-bottom: 1rem;
    border-bottom: 1px solid var(--border-color);
}

.file-header h1 {
    font-family: var(--font-mono);
    font-size: 1.75rem;
    margin-bottom: 0.5rem;
}

.file-meta {
    display: flex;
    gap: 1rem;
    flex-wrap: wrap;
    align-items: center;
}

.category-badge {
    padding: 0.25rem 0.75rem;
    border-radius: 12px;
    font-size: 0.75rem;
    font-weight: 600;
    text-transform: uppercase;
}

.category-neovim { background: #61afef; color: white; }
.category-shell { background: #98c379; color: white; }
.category-git { background: #e06c75; color: white; }
.category-terminal { background: #c678dd; color: white; }
.category-themes { background: #d19a66; color: white; }
.category-scripts { background: #56b6c2; color: white; }
.category-editor { background: #61afef; color: white; }
.category-configuration { background: #abb2bf; color: #282c34; }
.category-snippets { background: #e5c07b; color: #282c34; }
.category-other { background: var(--bg-tertiary); color: var(--text-primary); }

.meta-item {
    color: var(--text-secondary);
    font-size: 0.875rem;
}

/* File Actions */
.file-actions {
    display: flex;
    gap: 1rem;
    margin-bottom: 2rem;
}

.btn {
    padding: 0.5rem 1rem;
    background: var(--bg-tertiary);
    color: var(--text-primary);
    border: 1px solid var(--border-color);
    border-radius: 6px;
    cursor: pointer;
    font-size: 0.875rem;
    text-decoration: none;
    display: inline-flex;
    align-items: center;
    gap: 0.5rem;
    transition: all 0.2s;
}

.btn:hover {
    background: var(--bg-secondary);
    transform: translateY(-1px);
}

.btn-primary {
    background: var(--accent-primary);
    color: white;
    border-color: var(--accent-primary);
}

.btn-primary:hover {
    background: var(--accent-secondary);
    border-color: var(--accent-secondary);
}

/* Code Container */
.code-container {
    background: var(--bg-secondary);
    border: 1px solid var(--border-color);
    border-radius: 8px;
    overflow: hidden;
}

.code-container pre {
    margin: 0;
    padding: 1.5rem;
    overflow-x: auto;
    font-family: var(--font-mono);
    font-size: 0.875rem;
    line-height: 1.5;
}

.code-container code {
    font-family: inherit;
}

/* Line Numbers */
pre.line-numbers {
    position: relative;
    padding-left: 3.8em;
    counter-reset: linenumber;
}

pre.line-numbers > code {
    position: relative;
    white-space: inherit;
}

.line-numbers .line-numbers-rows {
    position: absolute;
    pointer-events: none;
    top: 0;
    font-size: 100%;
    left: -3.8em;
    width: 3em;
    letter-spacing: -1px;
    border-right: 1px solid var(--border-color);
    user-select: none;
}

.line-numbers-rows > span {
    display: block;
    counter-increment: linenumber;
}

.line-numbers-rows > span:before {
    content: counter(linenumber);
    color: var(--text-tertiary);
    display: block;
    padding-right: 0.8em;
    text-align: right;
}

/* Home Page Grid */
.home-grid {
    display: grid;
    grid-template-columns: repeat(auto-fill, minmax(300px, 1fr));
    gap: 1.5rem;
    margin-top: 2rem;
}

.card {
    background: var(--bg-secondary);
    border: 1px solid var(--border-color);
    border-radius: 8px;
    padding: 1.5rem;
    transition: all 0.3s;
}

.card:hover {
    transform: translateY(-4px);
    box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.card h3 {
    margin-bottom: 0.5rem;
    display: flex;
    align-items: center;
    gap: 0.5rem;
}

.card-icon {
    font-size: 1.5rem;
}

.card-stats {
    display: flex;
    gap: 1rem;
    margin-top: 1rem;
    padding-top: 1rem;
    border-top: 1px solid var(--border-color);
    font-size: 0.875rem;
    color: var(--text-secondary);
}

/* Statistics Dashboard */
.stats-container {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
    gap: 1rem;
    margin: 2rem 0;
}

.stat-card {
    background: var(--bg-secondary);
    padding: 1.5rem;
    border-radius: 8px;
    text-align: center;
}

.stat-value {
    font-size: 2rem;
    font-weight: 700;
    color: var(--accent-primary);
}

.stat-label {
    color: var(--text-secondary);
    font-size: 0.875rem;
    text-transform: uppercase;
    letter-spacing: 0.05em;
}

/* Responsive */
@media (max-width: 768px) {
    .sidebar {
        transform: translateX(-100%);
    }
    
    .sidebar.active {
        transform: translateX(0);
    }
    
    .sidebar-toggle {
        display: block;
    }
    
    .content {
        margin-left: 0;
        padding: 1rem;
    }
    
    .file-actions {
        flex-direction: column;
    }
    
    .btn {
        width: 100%;
        justify-content: center;
    }
}

/* Animations */
@keyframes fadeIn {
    from { opacity: 0; transform: translateY(10px); }
    to { opacity: 1; transform: translateY(0); }
}

.fade-in {
    animation: fadeIn 0.3s ease;
}

/* Scrollbar */
::-webkit-scrollbar {
    width: 8px;
    height: 8px;
}

::-webkit-scrollbar-track {
    background: var(--bg-secondary);
}

::-webkit-scrollbar-thumb {
    background: var(--text-tertiary);
    border-radius: 4px;
}

::-webkit-scrollbar-thumb:hover {
    background: var(--text-secondary);
}
EOF
}

# Generate main JavaScript
generate_js() {
    log "Generating JavaScript..."
    cat > "$ASSETS_DIR/js/app.js" << 'EOF'
// Dotfiles Documentation App

class DotfilesApp {
    constructor() {
        this.initializeTheme();
        this.loadFileTree();
        this.initializeSearch();
        this.initializeSidebar();
        this.initializeCodeFeatures();
    }

    // Theme Management
    initializeTheme() {
        const stored = localStorage.getItem('theme');
        const theme = stored || (window.matchMedia('(prefers-color-scheme: dark)').matches ? 'dark' : 'light');
        document.documentElement.setAttribute('data-theme', theme);
        
        // Listen for system theme changes
        window.matchMedia('(prefers-color-scheme: dark)').addEventListener('change', (e) => {
            if (!localStorage.getItem('theme')) {
                document.documentElement.setAttribute('data-theme', e.matches ? 'dark' : 'light');
            }
        });
    }

    // File Tree
    async loadFileTree() {
        try {
            const response = await fetch('/data/files.json');
            const files = await response.json();
            this.renderFileTree(files);
        } catch (error) {
            console.error('Failed to load file tree:', error);
        }
    }

    renderFileTree(files) {
        const container = document.getElementById('file-tree');
        if (!container) return;

        // Group files by directory
        const tree = this.buildTreeStructure(files);
        container.innerHTML = this.renderTreeHTML(tree);
        
        // Add expand/collapse functionality
        container.querySelectorAll('.tree-toggle').forEach(toggle => {
            toggle.addEventListener('click', (e) => {
                e.stopPropagation();
                const parent = toggle.closest('.tree-directory');
                parent.classList.toggle('collapsed');
                toggle.textContent = parent.classList.contains('collapsed') ? '▶' : '▼';
            });
        });
    }

    buildTreeStructure(files) {
        const tree = {};
        
        files.forEach(file => {
            const parts = file.path.split('/');
            let current = tree;
            
            parts.forEach((part, index) => {
                if (index === parts.length - 1) {
                    // It's a file
                    current[part] = file;
                } else {
                    // It's a directory
                    if (!current[part]) {
                        current[part] = {};
                    }
                    current = current[part];
                }
            });
        });
        
        return tree;
    }

    renderTreeHTML(tree, level = 0) {
        let html = '';
        
        Object.keys(tree).sort().forEach(key => {
            const value = tree[key];
            
            if (value.path) {
                // It's a file
                const icon = this.getFileIcon(value.name);
                html += `
                    <div class="tree-item" style="padding-left: ${level * 20}px">
                        <a href="/files/${value.path}.html">
                            <span class="icon">${icon}</span>
                            <span>${value.name}</span>
                        </a>
                    </div>
                `;
            } else {
                // It's a directory
                html += `
                    <div class="tree-directory">
                        <div class="tree-item" style="padding-left: ${level * 20}px">
                            <span class="tree-toggle">▼</span>
                            <span class="icon">📁</span>
                            <span>${key}</span>
                        </div>
                        <div class="tree-content">
                            ${this.renderTreeHTML(value, level + 1)}
                        </div>
                    </div>
                `;
            }
        });
        
        return html;
    }

    getFileIcon(filename) {
        const ext = filename.split('.').pop();
        const icons = {
            'lua': '🌙',
            'vim': '📝',
            'sh': '🐚',
            'bash': '🐚',
            'zsh': '🐚',
            'conf': '⚙️',
            'toml': '📋',
            'json': '📊',
            'yaml': '📄',
            'yml': '📄',
            'md': '📖',
            'txt': '📄',
            'gitignore': '🚫',
            'gitconfig': '🔧'
        };
        
        if (filename.includes('gitconfig')) return '🔧';
        if (filename.includes('gitignore')) return '🚫';
        if (filename.endsWith('rc')) return '⚙️';
        
        return icons[ext] || '📄';
    }

    // Search
    initializeSearch() {
        const searchInput = document.getElementById('search-input');
        if (!searchInput) return;

        let searchTimeout;
        searchInput.addEventListener('input', (e) => {
            clearTimeout(searchTimeout);
            searchTimeout = setTimeout(() => {
                this.performSearch(e.target.value);
            }, 300);
        });
    }

    async performSearch(query) {
        if (!query) {
            this.loadFileTree();
            return;
        }

        try {
            const response = await fetch('/data/files.json');
            const files = await response.json();
            
            const filtered = files.filter(file => {
                return file.name.toLowerCase().includes(query.toLowerCase()) ||
                       file.path.toLowerCase().includes(query.toLowerCase());
            });
            
            this.renderSearchResults(filtered);
        } catch (error) {
            console.error('Search failed:', error);
        }
    }

    renderSearchResults(files) {
        const container = document.getElementById('file-tree');
        if (!container) return;

        if (files.length === 0) {
            container.innerHTML = '<div class="no-results">No files found</div>';
            return;
        }

        let html = '<div class="search-results">';
        files.forEach(file => {
            const icon = this.getFileIcon(file.name);
            html += `
                <div class="tree-item">
                    <a href="/files/${file.path}.html">
                        <span class="icon">${icon}</span>
                        <span>${file.path}</span>
                    </a>
                </div>
            `;
        });
        html += '</div>';
        
        container.innerHTML = html;
    }

    // Sidebar
    initializeSidebar() {
        const toggle = document.getElementById('sidebar-toggle');
        const sidebar = document.getElementById('sidebar');
        
        if (toggle && sidebar) {
            toggle.addEventListener('click', () => {
                sidebar.classList.toggle('active');
            });
            
            // Close sidebar when clicking outside on mobile
            document.addEventListener('click', (e) => {
                if (window.innerWidth <= 768) {
                    if (!sidebar.contains(e.target) && !toggle.contains(e.target)) {
                        sidebar.classList.remove('active');
                    }
                }
            });
        }
    }

    // Code Features
    initializeCodeFeatures() {
        // Copy to clipboard
        window.copyToClipboard = () => {
            const content = document.getElementById('code-content');
            if (content) {
                navigator.clipboard.writeText(content.textContent).then(() => {
                    this.showToast('Copied to clipboard!');
                });
            }
        };

        // Download file
        window.downloadFile = () => {
            const content = document.getElementById('code-content');
            if (content && window.filePath) {
                const blob = new Blob([content.textContent], { type: 'text/plain' });
                const url = window.URL.createObjectURL(blob);
                const a = document.createElement('a');
                a.href = url;
                a.download = window.filePath.split('/').pop();
                a.click();
                window.URL.revokeObjectURL(url);
                this.showToast('Download started!');
            }
        };
    }

    // Toast notifications
    showToast(message) {
        const toast = document.createElement('div');
        toast.className = 'toast fade-in';
        toast.textContent = message;
        toast.style.cssText = `
            position: fixed;
            bottom: 2rem;
            right: 2rem;
            background: var(--accent-primary);
            color: white;
            padding: 1rem 1.5rem;
            border-radius: 8px;
            z-index: 9999;
        `;
        
        document.body.appendChild(toast);
        
        setTimeout(() => {
            toast.style.opacity = '0';
            setTimeout(() => toast.remove(), 300);
        }, 3000);
    }
}

// Initialize app when DOM is ready
document.addEventListener('DOMContentLoaded', () => {
    new DotfilesApp();
});
EOF
}

# Generate index.html
generate_index() {
    log "Generating index.html..."
    cat > "$OUTPUT_DIR/index.html" << 'EOF'
<!DOCTYPE html>
<html lang="en" data-theme="auto">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <meta name="description" content="Comprehensive dotfiles documentation with file browser, search, and syntax highlighting">
    <title>Dotfiles - Complete Configuration Reference</title>
    <link rel="stylesheet" href="/assets/css/main.css">
</head>
<body>
    <div class="layout">
        <nav class="sidebar" id="sidebar">
            <div class="sidebar-header">
                <h2>~/.dotfiles</h2>
                <button class="sidebar-toggle" id="sidebar-toggle">☰</button>
            </div>
            <div class="search-box">
                <input type="text" id="search-input" placeholder="Search files...">
            </div>
            <div class="file-tree" id="file-tree">
                <!-- Populated by JavaScript -->
            </div>
        </nav>
        
        <main class="content">
            <header class="page-header">
                <h1>Dotfiles Configuration Reference</h1>
                <p>Complete documentation and browser for all configuration files</p>
            </header>
            
            <div class="stats-container">
                <div class="stat-card">
                    <div class="stat-value" id="total-files">-</div>
                    <div class="stat-label">Total Files</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value" id="total-lines">-</div>
                    <div class="stat-label">Lines of Code</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value" id="total-size">-</div>
                    <div class="stat-label">Total Size</div>
                </div>
                <div class="stat-card">
                    <div class="stat-value" id="categories">-</div>
                    <div class="stat-label">Categories</div>
                </div>
            </div>
            
            <section class="featured-section">
                <h2>Featured Configurations</h2>
                <div class="home-grid">
                    <div class="card">
                        <h3><span class="card-icon">🌙</span> Neovim</h3>
                        <p>Modern Neovim configuration with LSP, completion, and 80+ plugins</p>
                        <div class="card-stats">
                            <span>📁 15+ files</span>
                            <span>📝 2000+ lines</span>
                        </div>
                    </div>
                    
                    <div class="card">
                        <h3><span class="card-icon">🐚</span> Shell</h3>
                        <p>Zsh configuration with Zinit, custom functions, and aliases</p>
                        <div class="card-stats">
                            <span>📁 8 files</span>
                            <span>📝 800+ lines</span>
                        </div>
                    </div>
                    
                    <div class="card">
                        <h3><span class="card-icon">💻</span> Terminal</h3>
                        <p>Alacritty and tmux configurations for the perfect terminal experience</p>
                        <div class="card-stats">
                            <span>📁 5 files</span>
                            <span>📝 600+ lines</span>
                        </div>
                    </div>
                    
                    <div class="card">
                        <h3><span class="card-icon">🎨</span> Themes</h3>
                        <p>Automatic theme switching system with multiple color schemes</p>
                        <div class="card-stats">
                            <span>📁 10+ themes</span>
                            <span>📝 500+ lines</span>
                        </div>
                    </div>
                    
                    <div class="card">
                        <h3><span class="card-icon">🔧</span> Git</h3>
                        <p>Git configuration with aliases, hooks, and global gitignore</p>
                        <div class="card-stats">
                            <span>📁 4 files</span>
                            <span>📝 400+ lines</span>
                        </div>
                    </div>
                    
                    <div class="card">
                        <h3><span class="card-icon">📜</span> Scripts</h3>
                        <p>Utility scripts for system maintenance and automation</p>
                        <div class="card-stats">
                            <span>📁 12+ scripts</span>
                            <span>📝 1000+ lines</span>
                        </div>
                    </div>
                </div>
            </section>
            
            <section class="quick-links">
                <h2>Quick Links</h2>
                <ul>
                    <li><a href="/files/neovim/init.lua.html">📝 Neovim Configuration</a></li>
                    <li><a href="/files/zsh/zshrc.html">🐚 Zsh Configuration</a></li>
                    <li><a href="/files/tmux.conf.html">💻 Tmux Configuration</a></li>
                    <li><a href="/files/alacritty/alacritty.toml.html">🖥️ Alacritty Terminal</a></li>
                    <li><a href="/files/git/gitconfig.html">🔧 Git Configuration</a></li>
                    <li><a href="/files/theme-switcher/switch-theme.sh.html">🎨 Theme Switcher</a></li>
                </ul>
            </section>
        </main>
    </div>
    
    <script>
        // Load statistics
        fetch('/data/files.json')
            .then(res => res.json())
            .then(files => {
                document.getElementById('total-files').textContent = files.length;
                
                const totalLines = files.reduce((sum, file) => sum + (file.lines || 0), 0);
                document.getElementById('total-lines').textContent = totalLines.toLocaleString();
                
                const totalSize = files.reduce((sum, file) => sum + (file.size || 0), 0);
                const sizeInKB = (totalSize / 1024).toFixed(1);
                document.getElementById('total-size').textContent = sizeInKB + ' KB';
                
                const categories = new Set(files.map(f => f.category));
                document.getElementById('categories').textContent = categories.size;
            });
    </script>
    <script src="/assets/js/app.js"></script>
</body>
</html>
EOF
}

# ════════════════════════════════════════════════════════════════════════════
# Main Execution
# ════════════════════════════════════════════════════════════════════════════

main() {
    log "Starting Dotfiles Documentation Generator"
    log "Output directory: $OUTPUT_DIR"
    
    # Setup
    setup_directories
    
    # Discovery
    discover_files
    generate_tree
    
    # Generate assets
    generate_css
    generate_js
    generate_index
    
    # Process files
    process_all_files
    
    # Copy additional assets if they exist
    if [[ -f "$SCRIPT_DIR/prism.js" ]]; then
        cp "$SCRIPT_DIR/prism.js" "$ASSETS_DIR/js/"
    fi
    if [[ -f "$SCRIPT_DIR/prism-tomorrow.css" ]]; then
        cp "$SCRIPT_DIR/prism-tomorrow.css" "$ASSETS_DIR/css/"
    fi
    
    log "✅ Generation complete!"
    log "📁 Output: $OUTPUT_DIR"
    log "🚀 To preview: cd $OUTPUT_DIR && python3 -m http.server 8000"
}

# Run main function
main "$@"