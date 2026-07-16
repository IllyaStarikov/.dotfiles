# Neovim Configuration

Modern Neovim setup with < 300ms startup, AI integration, and ~54 plugins managed by lazy.nvim.

## Features

- **Performance**: < 300ms startup, < 200MB RAM
- **AI Integration**: CodeCompanion chat + Minuet inline completion, local MLX/Ollama backends
- **Modern Editing**: Blink.cmp completion, Treesitter, 20+ LSPs
- **Beautiful UI**: TokyoNight theme synced with macOS appearance

## Directory Structure

```
src/neovim/
├── core/              # Core settings (7 files)
│   ├── init.lua       # Module loader
│   ├── options.lua    # Editor options (incl. spellfile from the private repo)
│   ├── performance.lua # Speed optimizations
│   ├── backup.lua     # Backup/swap/undo settings
│   ├── folding.lua    # Code folding config
│   ├── indentation.lua # Tab/space settings
│   └── search.lua     # Search behavior
├── keymaps/           # Key binding definitions (6 files)
│   ├── core.lua       # Essential mappings
│   ├── navigation.lua # Buffer, window, and file navigation
│   ├── editing.lua    # Text editing enhancements
│   ├── lsp.lua        # LSP and diagnostic mappings
│   ├── plugins.lua    # Plugin-specific mappings
│   └── debug.lua      # DAP debugging mappings
├── plugins/           # Plugin configs (10 files)
│   ├── ai.lua         # CodeCompanion setup
│   ├── completion.lua # Blink.cmp config
│   ├── init.lua       # Module notes
│   ├── markdown-editing.lua # Markdown editing helpers (markdown.nvim)
│   ├── markdown-render.lua  # In-buffer rendering (render-markdown.nvim)
│   ├── markdown-preview.lua # Browser preview (markdown-preview.nvim)
│   ├── minuet.lua     # Minuet AI inline completion
│   ├── snacks.lua     # Quality-of-life utilities (explorer, lazygit, zen, scratch)
│   ├── snippets.lua   # LuaSnip config
│   └── vimtex.lua     # LaTeX support
├── snippets/          # Language-specific snippets (10 files)
├── init.lua           # Entry point with path detection
├── autocmds.lua       # Autocommands, skeleton files, style-guide indentation
├── commands.lua       # Custom commands
├── error-handler.lua  # Error handling
├── fixy.lua           # Production auto-formatter
├── gitsigns.lua       # Git signs configuration
├── keymaps.lua        # Keymap module loader (sets leader, loads keymaps/*)
├── logging.lua        # Logging utilities (level via $NVIM_LOG_LEVEL)
├── lsp.lua            # LSP configurations (20+ servers)
├── plugins.lua        # Plugin specifications (~54 plugins)
├── telescope.lua      # Telescope configuration
├── ui.lua             # Theme and appearance
├── utils.lua          # Utility functions
├── work.lua           # Work detection utilities
└── work-init.lua      # Work-specific initialization
```

> **Config-loading gotcha**: `gitsigns.lua` and `telescope.lua` share their names
> with plugin Lua modules, and the plugin's runtimepath wins over the
> `package.path` entries `init.lua` adds. They are therefore loaded by explicit
> path (`dofile`) in `plugins.lua`, never via `require()`/`load_config()`.

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

- `<leader>f` - Find (Telescope)
- `<leader>c` - Code (symbols, LSP, run)
- `<leader>g` - Git operations
- `<leader>a` - AI assistant (CodeCompanion)
- `<leader>o` - Open (explorer, terminal)
- `<C-p>` - Find files
- `K` - Hover documentation

Full reference: [keymaps/KEYMAPS.md](keymaps/KEYMAPS.md)

## Language Support

**Web**: TypeScript, JavaScript, HTML, CSS
**Systems**: Rust, C/C++, Go, Zig
**Scripting**: Python, Ruby, Bash, Lua
**Data**: YAML, TOML, JSON, XML
**Docs**: Markdown, LaTeX

## Treesitter

The `nvim-treesitter` spec is pinned to the **main** branch (the repo's default
branch is the legacy master, which uses a removed API). On main there are no
highlight/indent modules: parsers are installed with
`require("nvim-treesitter").install({...})` and highlighting is enabled
per-buffer by a `FileType` autocmd calling `vim.treesitter.start()` (see the
spec in `plugins.lua`). Parser builds require the `tree-sitter` CLI
(`brew install tree-sitter-cli`) plus a C compiler. Markdown folds
intentionally come from the runtime ftplugin (`g.markdown_folding`, see
`core/folding.lua`), not treesitter.

## AI Features

- **CodeCompanion**: chat, inline assistance, and code actions (`<leader>a*`)
- **Minuet**: AI inline completion suggestions
- **Backends**: local MLX server or Ollama (`<leader>aM` / `<leader>aO`),
  model size switching via `<leader>a1`-`a3`

## Performance

- Lazy loading with event triggers
- Disabled unused providers (saves 70ms)
- Async operations
- Profile with `:Lazy profile` and `nvim --startuptime /tmp/startup.log`

## Auto-Formatting (fixy.lua)

Silent, robust formatting integrated with the repo-wide `fixy` formatter:

```vim
:Fixy          " Format current file
:FixyAuto      " Toggle auto-format
:FixyStatus    " Show status
:FixyDebug     " Toggle debug mode
```

## Customization

- Add plugin specs in `plugins.lua`, complex configs in `plugins/`
- Configure LSPs in `lsp.lua`
- Custom keymaps in `keymaps/`
- Work overrides via `.dotfiles.private/`

## Troubleshooting

**Slow startup**: `:Lazy profile` to identify slow plugins

**LSP issues**: `:LspInfo` and `:Mason` for server status

**Completion not working**: Check `:lua =vim.lsp.get_clients()`

**Theme issues**: Verify `theme` command and `$MACOS_THEME`

**Treesitter issues**: `:checkhealth nvim-treesitter`; `:TSReset` resets the
current buffer; `:TSLog` shows installer logs

**Debug logging**: start with `NVIM_LOG_LEVEL=DEBUG nvim`; logs go to
`~/.local/state/nvim/work-debug.log` (see `logging.lua`)

## Lessons Learned

- Blink.cmp is much faster than nvim-cmp
- Disabling providers (python3, ruby) saves 70ms
- Lazy loading after `VeryLazy` event prevents UI blocking
- Work detection via hostname prevents config conflicts
- Never name a config module after a plugin's Lua module (see gotcha above)

## Related Documentation

- [Plugin List](plugins/README.md)
- [Keymaps Guide](keymaps/README.md)
- [Core Settings](core/README.md)
- [Snippets](snippets/README.md)
- [Main Dotfiles](../../README.md)
