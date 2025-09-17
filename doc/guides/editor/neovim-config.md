# Neovim Configuration Modules

This directory contains the modular Lua configuration for Neovim, organized for maintainability and performance.

## Module Overview

### Core Configuration

- **init.lua** - Main entry point that loads all modules in the correct order
- **options.lua** - Core Neovim options (indentation, UI, performance settings)
- **keymaps.lua** - All key mappings organized by functionality
- **autocmds.lua** - Autocommands for file processing, syntax, and skeleton templates
- **commands.lua** - Custom commands for productivity (buffer management, search, etc.)
- **plugins.lua** - Plugin specifications using lazy.nvim
- **theme.lua** - Dynamic theme switching based on system appearance

### LSP & Completion

- **lsp.lua** - Language Server Protocol configuration with Mason
- **blink.lua** - Ultra-fast completion engine configuration
- **luasnip.lua** - Snippet engine setup

### Plugin Configurations

- **codecompanion.lua** - AI assistant integration (Ollama, Claude, OpenAI, Copilot)
- **dap.lua** - Debug Adapter Protocol for debugging support
- **gitsigns.lua** - Git integration in the sign column
- **markview.lua** - Enhanced markdown preview with custom symbols
- **menu.lua** - Context-aware menu system
- **oil.lua** - File manager configuration
- **snacks.lua** - Modern QoL suite (dashboard, picker, terminal, etc.)
- **telescope.lua** - Fuzzy finder configuration
- **typr.lua** - Typing practice game
- **vimtex.lua** - LaTeX environment configuration

## Architecture Decisions

1. **Lazy Loading**: Plugins are loaded on-demand to optimize startup time
2. **Modular Design**: Each concern is separated into its own module
3. **Performance First**: Heavy features are disabled for large files
4. **Error Handling**: All configurations use pcall for graceful degradation
5. **Theme Integration**: Automatic theme detection with manual override support

## Adding New Modules

1. Create a new file in `lua/config/` with a descriptive name
2. Add proper documentation header explaining the module's purpose
3. Export a `setup()` function if initialization is needed
4. Load the module from the appropriate location (init.lua or plugins.lua)

## Diagnostics

- Run `:checkhealth` for comprehensive diagnostics
- Check `:messages` for any error messages during startup
- Use `:LspInfo` to check LSP client status
