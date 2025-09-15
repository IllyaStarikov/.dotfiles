# Neovim Configuration

Modern Neovim setup with < 300ms startup, AI integration, and 80+ plugins managed by lazy.nvim.

## Features
- **Performance**: < 300ms startup, < 200MB RAM
- **AI Integration**: CodeCompanion, Avante, Ollama support
- **Modern Editing**: Blink.cmp completion, Treesitter, 20+ LSPs
- **Beautiful UI**: TokyoNight theme synced with macOS appearance

## Directory Structure
```
config/
├── core/       # Options, performance, search
├── keymaps/    # Organized key bindings
├── lsp/        # 20+ language servers
├── plugins/    # 80+ plugin configs
├── ui/         # Theme and appearance
└── utils/      # Shared utilities
snippets/       # Language snippets
```

## Quick Start
```bash
# Installation (plugins auto-install on first run)
ln -sf ~/.dotfiles/src/neovim ~/.config/nvim
nvim

# Health check
:checkhealth

# Plugin management
:Lazy              # Plugin manager UI
:Lazy profile      # Performance profiling
:Mason             # LSP installer
```

## Key Bindings
- `<leader>f` - File operations (Telescope)
- `<leader>l` - LSP functions
- `<leader>g` - Git operations
- `<leader>a` - AI assistant
- `<C-p>` - Find files
- `K` - Hover documentation

## Language Support
**Web**: TypeScript, JavaScript, HTML, CSS
**Systems**: Rust, C/C++, Go, Zig
**Scripting**: Python, Ruby, Bash, Lua
**Data**: YAML, TOML, JSON, XML
**Docs**: Markdown, LaTeX

## AI Features
- **CodeCompanion**: Multi-model support (GPT-4, Claude, Gemini)
- **Avante**: Advanced code generation
- **Ollama**: Local AI models
- Configure with environment variables or `:CodeCompanion setup`

## Performance
- Lazy loading with event triggers
- Disabled unused providers (saves 70ms)
- Compiled Lua modules
- Async operations

## Customization
- Add plugins in `config/plugins/`
- Configure LSPs in `config/lsp/servers.lua`
- Custom keymaps in `config/keymaps/`
- Work overrides via `.dotfiles.private/`

## Troubleshooting

**Slow startup**: `:Lazy profile` to identify slow plugins

**LSP issues**: `:LspInfo` and `:Mason` for server status

**Completion not working**: Check `:lua =vim.lsp.get_clients()`

**Theme issues**: Verify `theme` command and `$MACOS_THEME`

## Lessons Learned
- Blink.cmp is 10x faster than nvim-cmp
- Disabling providers (python3, ruby) saves 70ms
- Lazy loading after `VeryLazy` event prevents UI blocking
- Work detection via hostname prevents config conflicts