# /src/neovim/config - Neovim Configuration Modules

> **Modular Neovim configuration** - Core settings, keymaps, plugins, LSP, and UI components

This directory contains the modular configuration system for Neovim, organized into logical components for maintainability and performance.

## 📁 Directory Structure

```
config/
├── core/              # Core Neovim settings
│   ├── globals.lua    # Global variables
│   ├── init.lua       # Core initialization
│   └── options.lua    # Vim options
├── keymaps/           # Key binding definitions
│   ├── editing.lua    # Text editing keys
│   ├── init.lua       # Keymap loader
│   ├── navigation.lua # Movement keys
│   ├── plugins.lua    # Plugin-specific keys
│   └── windows.lua    # Window management
├── lsp/               # Language server configurations
│   ├── handlers.lua   # LSP handlers
│   ├── init.lua       # LSP initialization
│   ├── keymaps.lua    # LSP key bindings
│   └── servers.lua    # Server configurations
├── plugins/           # Plugin specifications
│   ├── ai.lua         # AI assistants
│   ├── coding.lua     # Coding tools
│   ├── editor.lua     # Editor enhancements
│   ├── git.lua        # Git integration
│   ├── init.lua       # Plugin loader
│   ├── lsp.lua        # LSP plugins
│   ├── treesitter.lua # Syntax highlighting
│   └── ui.lua         # UI components
├── ui/                # User interface settings
│   ├── colors.lua     # Color schemes
│   ├── init.lua       # UI initialization
│   └── statusline.lua # Status line config
├── utils/             # Utility functions
│   ├── init.lua       # Utility loader
│   └── helpers.lua    # Helper functions
├── autocmds.lua       # Auto commands (47KB)
├── blink-setup.lua    # Blink.cmp configuration
├── commands.lua       # Custom commands
├── conform.lua        # Formatter configuration
├── dap.lua           # Debug adapter protocol
├── debug.lua         # Debug utilities
├── error-handler.lua # Error handling
├── fixy.lua          # Auto-formatter (16KB)
├── gitsigns.lua      # Git signs configuration
├── health.lua        # Health checks
├── keymaps.lua       # Legacy keymaps
├── lazy.lua          # Plugin manager setup
├── menu.lua          # Context menus (31KB)
└── plugins.lua       # Plugin specifications (37KB)
```

## 🔧 Core Modules

### autocmds.lua

**Auto Commands** - Event-driven automation

- File type detection
- Auto-save functionality
- Cursor restoration
- Terminal settings
- Format on save
- Highlight on yank

### fixy.lua

**Production Auto-Formatter** - Silent, robust formatting

- **Silent operation**: No "file reloaded" notifications
- **Multi-layer suppression**: Handles all notification systems
- **Cursor preservation**: Maintains position
- **Error handling**: Timeouts, validation, race prevention
- **Debug mode**: Optional logging to `/tmp/fixy.log`

Commands:

```vim
:Fixy          " Format current file
:FixyAuto      " Toggle auto-format
:FixyStatus    " Show status
:FixyDebug     " Toggle debug mode
```

### plugins.lua

**Plugin Specifications** - 500+ plugin references

- Lazy loading configurations
- Dependency management
- Event-based loading
- Performance optimizations

Key plugins:

- **lazy.nvim** - Plugin manager
- **telescope.nvim** - Fuzzy finder
- **nvim-treesitter** - Syntax highlighting
- **mason.nvim** - LSP installer
- **blink.cmp** - Ultra-fast completion
- **avante.nvim** - AI chat interface

### menu.lua

**Context Menus** - Right-click and command menus

- File operations
- Git actions
- LSP commands
- Buffer management
- Custom actions

## 📂 Subdirectories

### /core

Foundation settings:

- **globals.lua** - Leader key, Python paths, etc.
- **options.lua** - Line numbers, tabs, search, etc.
- **init.lua** - Core module loader

### /keymaps

Organized key bindings:

- **editing.lua** - Cut, copy, paste, undo
- **navigation.lua** - Movement, search, jumps
- **plugins.lua** - Plugin-specific bindings
- **windows.lua** - Splits, tabs, buffers

### /lsp

Language Server Protocol:

- **servers.lua** - Server configurations for 20+ languages
- **handlers.lua** - Hover, signature, diagnostics
- **keymaps.lua** - Go to definition, references, etc.
- **init.lua** - LSP initialization and setup

### /plugins

Plugin categories:

- **ai.lua** - Avante, CodeCompanion, Copilot
- **coding.lua** - Completion, snippets, formatting
- **editor.lua** - File explorer, search, replace
- **git.lua** - Gitsigns, fugitive, diffview
- **lsp.lua** - Mason, lspconfig, diagnostics
- **treesitter.lua** - Syntax, folding, context
- **ui.lua** - Themes, statusline, notifications

### /ui

Visual configuration:

- **colors.lua** - TokyoNight theme setup
- **statusline.lua** - Lualine configuration
- **init.lua** - UI component initialization

### /utils

Helper functions:

- **helpers.lua** - Common utility functions
- **init.lua** - Utility module loader

## ⚡ Performance Features

### Lazy Loading

```lua
-- Example lazy-loaded plugin
{
  "telescope.nvim",
  cmd = "Telescope",
  keys = { "<leader>ff", "<leader>fg" },
  dependencies = { "plenary.nvim" },
}
```

### Conditional Loading

```lua
-- Load only on specific file types
{
  "markdown-preview.nvim",
  ft = { "markdown" },
  build = "cd app && npm install",
}
```

### Startup Optimization

- Deferred loading for non-essential plugins
- Compiled Lua modules
- Minimal initial configuration
- < 300ms startup time

## 🔌 Plugin Management

### Adding Plugins

1. Add specification to appropriate file in `plugins/`
2. Configure in relevant config file
3. Add keymaps if needed
4. Test loading and performance

### Removing Plugins

1. Remove from plugin specification
2. Remove configuration
3. Remove keymaps
4. Run `:Lazy clean`

## 🎯 Configuration Patterns

### Module Structure

```lua
local M = {}

M.setup = function()
  -- Configuration code
end

return M
```

### Lazy Specification

```lua
return {
  "author/plugin",
  event = "VeryLazy",
  config = function()
    require("plugin").setup({
      -- options
    })
  end,
}
```

### Keymap Definition

```lua
vim.keymap.set("n", "<leader>xx", function()
  -- Action
end, { desc = "Description" })
```

## 🐛 Debugging

### Health Check

```vim
:checkhealth
```

### Plugin Profiling

```vim
:Lazy profile
```

### LSP Info

```vim
:LspInfo
:Mason
```

### Debug Logging

```lua
-- Enable debug in debug.lua
vim.g.debug_mode = true
```

## 💡 Tips & Tricks

1. **Reload Config**: `:source %` in any Lua file
2. **Plugin Update**: `:Lazy update`
3. **Clean Plugins**: `:Lazy clean`
4. **Profile Startup**: `nvim --startuptime log.txt`
5. **Check Mappings**: `:Telescope keymaps`

## 🔗 Integration Points

### With Private Repo

- Work-specific LSP servers
- Custom snippets
- Additional plugins
- Override configurations

### With Theme System

- Reads `MACOS_THEME` environment variable
- Applies appropriate colorscheme
- Updates on theme switch

## 📚 Related Documentation

- [Neovim Configuration](../README.md)
- [Plugin List](plugins/README.md)
- [LSP Setup](lsp/README.md)
- [Keymaps Guide](keymaps/README.md)
- [Main Dotfiles](../../../README.md)
