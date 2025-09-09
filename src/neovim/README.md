# 🚀 Neovim Configuration

A modern, performant, and feature-rich Neovim configuration built with Lua and lazy.nvim. Designed for rapid development workflows with enterprise-level reliability and sub-300ms startup times.

## ✨ Features

### 🎯 Performance First
- **Ultra-fast startup**: < 300ms cold start
- **Lazy loading**: Plugins load on-demand
- **Memory efficient**: < 200MB RAM usage
- **Smart caching**: Optimized for large codebases

### 🤖 AI-Powered Development
- **CodeCompanion**: Multi-model AI assistant (GPT-4, Claude, Gemini)
- **Local AI**: Ollama integration for offline assistance
- **Avante**: Advanced AI code generation
- **Context-aware**: Project-specific AI behaviors

### 💡 Modern Editing Experience
- **Blink.cmp**: Lightning-fast completion engine
- **Treesitter**: Advanced syntax highlighting and navigation
- **LSP**: 20+ language servers with zero-config setup
- **Telescope**: Blazing fast fuzzy finder
- **Which-key**: Interactive keybinding discovery

### 🎨 Beautiful Interface
- **TokyoNight**: Consistent theming across all tools
- **Auto-theming**: Syncs with macOS dark/light mode
- **Ligatures**: Programming font enhancements
- **Status line**: Rich information display
- **Markdown**: Live preview and enhanced editing

## 📁 Directory Structure

```
src/neovim/
├── init.lua                    # Entry point with path detection
├── config/                     # Modular configuration (44 files)
│   ├── core/                   # Core Vim settings
│   │   ├── init.lua           # Core module loader
│   │   ├── options.lua        # Vim options and settings
│   │   ├── performance.lua    # Performance optimizations
│   │   ├── backup.lua         # Backup and undo configuration
│   │   ├── folding.lua        # Code folding settings
│   │   ├── indentation.lua    # Smart indentation rules
│   │   └── search.lua         # Search and replace settings
│   ├── keymaps/               # Organized key bindings
│   │   ├── core.lua          # Basic Vim keymaps
│   │   ├── editing.lua       # Text editing shortcuts
│   │   ├── navigation.lua    # Movement and jumping
│   │   ├── plugins.lua       # Plugin-specific keys
│   │   ├── lsp.lua          # LSP keybindings
│   │   └── debug.lua        # Debugging shortcuts
│   ├── lsp/                  # Language Server Protocol
│   │   ├── init.lua         # LSP configuration loader
│   │   └── servers.lua      # Individual server configs
│   ├── plugins/             # Plugin configurations
│   │   ├── init.lua         # Plugin organization overview
│   │   ├── completion.lua   # Blink.cmp setup
│   │   ├── ai.lua          # AI assistant configuration
│   │   ├── snippets.lua    # Code snippet engine
│   │   ├── markview.lua    # Markdown preview
│   │   ├── snacks.lua      # Quality-of-life utilities
│   │   ├── vimtex.lua      # LaTeX support
│   │   └── typr.lua        # Typing practice
│   ├── ui/                  # User interface
│   │   ├── init.lua        # UI module loader
│   │   ├── theme.lua       # Theme management
│   │   ├── appearance.lua  # Visual settings
│   │   └── ligatures.lua   # Font ligature support
│   └── utils/              # Utility functions
│       └── init.lua        # Shared utilities
├── snippets/               # Language-specific snippets
│   ├── lua.snippets       # Lua code snippets
│   ├── python.snippets    # Python snippets
│   ├── javascript.snippets # JS/TS snippets
│   └── markdown.snippets  # Markdown helpers
└── spell/                 # Custom spell files (symlinked)
    ├── en.utf-8.add      # Personal dictionary
    └── programming.utf-8.add # Programming terms
```

## 🔧 Core Components

### Plugin Manager: lazy.nvim
Modern plugin manager with lazy loading, lockfile support, and performance profiling.

```lua
-- Example plugin specification
{
  "nvim-telescope/telescope.nvim",
  dependencies = { "nvim-lua/plenary.nvim" },
  keys = {
    { "<C-p>", ":Telescope find_files<CR>", desc = "Find Files" }
  },
  config = function()
    require("telescope").setup({})
  end
}
```

### Language Support (54+ Plugins)

| Category | Plugins | Features |
|----------|---------|----------|
| **Core** | lazy.nvim, plenary.nvim | Plugin management, utilities |
| **Navigation** | Telescope, aerial.nvim, oil.nvim | Fuzzy finding, symbols, file explorer |
| **Editing** | blink.cmp, LuaSnip, treesitter | Completion, snippets, syntax |
| **LSP** | nvim-lspconfig, mason.nvim | Language servers, auto-install |
| **Git** | gitsigns.nvim, fugitive.vim | Git integration, diffs |
| **AI** | CodeCompanion, avante.nvim | AI assistance, code generation |
| **UI** | which-key, tokyonight.nvim | Key hints, theming |
| **Languages** | vimtex, markdown, rust-tools | LaTeX, Markdown, Rust |
| **Utils** | snacks.nvim, conform.nvim | Utilities, formatting |

### Keybindings Philosophy

Organized by functionality with mnemonic prefixes:

```lua
-- File operations
<leader>f   -- Find/Files (Telescope)
<leader>ff  -- Find files
<leader>fg  -- Find grep
<leader>fb  -- Find buffers

-- LSP operations  
<leader>l   -- LSP functions
<leader>ld  -- Go to definition
<leader>lr  -- Rename symbol
<leader>lf  -- Format document

-- Git operations
<leader>g   -- Git functions
<leader>gs  -- Git status
<leader>gc  -- Git commit
<leader>gd  -- Git diff
```

## 🚀 Quick Start

### Prerequisites
- Neovim 0.9.0+
- Git
- A C compiler (for Treesitter)
- ripgrep (for Telescope grep)
- Node.js (for some LSP servers)

### Installation
1. **Automated** (recommended):
   ```bash
   ~/.dotfiles/src/setup/setup.sh
   ```

2. **Manual**:
   ```bash
   # Create symlink
   ln -sf ~/.dotfiles/src/neovim ~/.config/nvim
   
   # Start Neovim (plugins will auto-install)
   nvim
   ```

### First Run
1. **Plugin Installation**: Lazy.nvim will automatically install all plugins
2. **LSP Setup**: Mason will install language servers on demand
3. **Treesitter**: Parsers install when opening supported file types
4. **AI Setup** (optional): Configure API keys for AI features

## 🎨 Theme System

### TokyoNight Integration
Automatically syncs with macOS appearance and other tools:

```lua
-- Theme detection
vim.g.tokyonight_style = os.getenv("MACOS_THEME") or "night"

-- Available variants
"day"    -- Light theme
"night"  -- Dark theme (default)
"moon"   -- Darker variant
"storm"  -- Blue-tinted dark
```

### Theme Switching
```bash
# Quick theme changes
theme day     # Light mode
theme night   # Dark mode
theme moon    # Darker variant
theme storm   # Blue variant

# Auto-detect from macOS
theme         # Uses system appearance
```

## 💻 Language Support

### Supported Languages
- **Web**: TypeScript, JavaScript, HTML, CSS, JSON
- **Systems**: Rust, C/C++, Go, Zig
- **Scripting**: Python, Ruby, Bash, Lua
- **Data**: YAML, TOML, XML, CSV
- **Docs**: Markdown, LaTeX, Plain text
- **Mobile**: Swift, Kotlin, Dart/Flutter
- **Other**: Docker, Terraform, GraphQL

### LSP Configuration
Zero-config LSP setup with automatic server installation:

```lua
-- Servers auto-install on file open
local servers = {
  "pyright",        -- Python
  "rust_analyzer",  -- Rust  
  "tsserver",       -- TypeScript
  "clangd",         -- C/C++
  "gopls",          -- Go
  "lua_ls",         -- Lua
}
```

## 🔍 Key Features Deep Dive

### 1. Completion Engine (Blink.cmp)
- **Speed**: 10x faster than nvim-cmp
- **Sources**: LSP, snippets, buffer, path, cmdline
- **Fuzzy**: Intelligent fuzzy matching
- **Preselect**: Smart completion selection

### 2. AI Integration (CodeCompanion)
- **Multi-model**: GPT-4, Claude, Gemini, local Ollama
- **Context**: Project-aware conversations
- **Inline**: Direct code assistance
- **Chat**: Dedicated AI chat buffer

### 3. File Explorer (Oil.nvim)
- **Buffer-based**: Edit filesystem like text
- **Actions**: Built-in file operations
- **Preview**: Quick file preview
- **Integration**: Works with other plugins

### 4. Search (Telescope)
- **Files**: Fast file finding with preview
- **Grep**: Live grep with results
- **Symbols**: LSP symbol navigation
- **Git**: Git file and commit search
- **Extensible**: Custom pickers

## ⚡ Performance Optimizations

### Startup Time Targets
- **Cold start**: < 300ms
- **Plugin loading**: < 500ms  
- **Memory usage**: < 200MB
- **File opening**: < 50ms

### Optimization Techniques
1. **Lazy Loading**: Plugins load on first use
2. **Minimal Core**: Essential-only startup config
3. **Caching**: Compiled configurations
4. **Background Jobs**: Non-blocking operations

### Performance Monitoring
```bash
# Profile startup time
nvim --startuptime /tmp/startup.log

# Plugin load times  
:Lazy profile

# Memory usage
:lua print(vim.inspect(vim.api.nvim_list_uis()))
```

## 🔧 Configuration Patterns

### Module Loading
Safe module loading with error handling:

```lua
local utils = require("config.utils")

-- Safe require with fallback
local ok, module = utils.safe_require("optional.module")
if ok then
  module.setup({})
end
```

### Plugin Configuration
Consistent plugin setup pattern:

```lua
{
  "plugin/name",
  dependencies = { "required/dependency" },
  event = "VeryLazy",  -- Lazy load trigger
  keys = {             -- Key-based loading
    { "<leader>x", ":Command<CR>", desc = "Description" }
  },
  config = function()
    require("plugin").setup({
      -- Configuration options
    })
  end
}
```

### Work Integration
Support for work-specific overrides:

```lua
-- Load work-specific configuration
local work_config = "~/.dotfiles/.dotfiles.private/nvim/init.lua"
if vim.fn.filereadable(work_config) == 1 then
  dofile(work_config)
end
```

## 🧪 Testing & Health

### Health Checks
Built-in health monitoring:

```vim
:checkhealth           " Full system check
:checkhealth nvim      " Core Neovim health
:checkhealth lsp       " LSP configuration
:checkhealth mason     " LSP server status
```

### Performance Testing
```bash
# Run Neovim tests
~/.dotfiles/test/test functional/nvim

# Quick health check
nvim +checkhealth +qall
```

### Common Issues
1. **Slow startup**: Check `:Lazy profile` for slow plugins
2. **LSP not working**: Run `:LspInfo` and `:Mason`
3. **Completion issues**: Check `:lua =vim.lsp.buf_get_clients()`
4. **Theme problems**: Verify `MACOS_THEME` environment variable

## 🔧 Customization

### Adding Languages
1. Add LSP server to `config/lsp/servers.lua`
2. Add Treesitter parser to `plugins.lua`
3. Create snippets in `snippets/language.snippets`
4. Add formatter to `conform.lua` config

### Custom Keybindings
Add to appropriate keymap file:

```lua
-- In config/keymaps/custom.lua
vim.keymap.set("n", "<leader>x", function()
  -- Custom functionality
end, { desc = "Custom command" })
```

### Plugin Addition
Add to `config/plugins.lua`:

```lua
{
  "author/plugin-name",
  event = "VeryLazy",
  config = function()
    require("plugin-name").setup({})
  end
}
```

## 📚 Documentation

### Internal Docs
- **Function docs**: Lua LSP provides inline documentation
- **Plugin help**: `:help plugin-name` for most plugins
- **Keybindings**: `<leader>?` to show all keybindings

### External Resources
- [Neovim Documentation](https://neovim.io/doc/)
- [Lua Guide](https://neovim.io/doc/user/lua-guide.html)
- [Lazy.nvim](https://github.com/folke/lazy.nvim)
- [LSP Configuration](https://github.com/neovim/nvim-lspconfig)

## 🚀 Advanced Usage

### AI-Assisted Development
```lua
-- Start AI chat
:CodeCompanionChat

-- Inline assistance  
:CodeCompanionActions

-- Generate tests
:CodeCompanion create tests for this function
```

### LaTeX Editing
Full LaTeX support with VimTeX:
- **Compilation**: Automatic PDF generation  
- **Completion**: LaTeX command completion
- **Navigation**: Table of contents, labels
- **Preview**: PDF preview integration

### Markdown Workflow
Enhanced markdown editing:
- **Live preview**: Real-time rendered preview
- **Tables**: Easy table editing and formatting
- **Links**: Link completion and validation
- **Math**: LaTeX math support

## 🔧 Maintenance

### Updates
```bash
# Update all plugins
:Lazy update

# Update LSP servers  
:Mason update

# Update Treesitter parsers
:TSUpdate
```

### Cleanup
```bash
# Remove unused plugins
:Lazy clean

# Clear cache
rm -rf ~/.local/share/nvim/
```

### Backup
Configuration is version controlled, but data backup:
```bash
# Backup Neovim data
cp -r ~/.local/share/nvim ~/.local/share/nvim.backup
```

## 🎯 Future Enhancements

### Planned Features
- **Multi-cursor editing**: Advanced multi-cursor support
- **Database integration**: SQL query support
- **DevOps tooling**: Kubernetes/Docker integration  
- **Testing framework**: Enhanced test runner
- **Collaboration**: Real-time editing support

### Community Contributions
- Fork the repository
- Create feature branch
- Add comprehensive tests
- Submit pull request with clear description

## 🤝 Contributing

### Development Setup
```bash
# Clone with submodules
git clone --recursive https://github.com/user/dotfiles

# Run tests
~/.dotfiles/test/test unit/nvim

# Check code style
stylua --check src/neovim/
```

### Code Style
- **Lua**: Follow stylua formatting
- **Comments**: Document complex functions
- **Modules**: One feature per module
- **Error handling**: Use pcall for external calls

---

**Performance**: Sub-300ms startup | **Plugins**: 54+ modern tools | **Languages**: 20+ supported | **AI**: Multi-model support

*This configuration represents years of refinement for maximum productivity while maintaining simplicity and reliability.*