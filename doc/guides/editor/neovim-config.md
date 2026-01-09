# Neovim Configuration Structure

> **Comprehensive guide to the modular Neovim configuration**

This configuration uses a modular Lua architecture designed for maintainability, performance, and extensibility.

## Directory Structure

```
~/.dotfiles/src/neovim/
├── init.lua                    # Entry point with path detection
├── config/                     # Main configuration modules
│   ├── core/                   # Core settings
│   │   ├── options.lua         # Vim options
│   │   ├── globals.lua         # Global variables
│   │   └── performance.lua     # Performance optimizations
│   ├── keymaps/                # Key bindings (modular)
│   │   ├── core.lua            # Essential mappings
│   │   ├── navigation.lua      # Movement mappings
│   │   ├── editing.lua         # Text manipulation
│   │   ├── lsp.lua             # Language server mappings
│   │   ├── plugins.lua         # Plugin-specific mappings
│   │   └── debug.lua           # DAP debugging mappings
│   ├── lsp/                    # Language server configs
│   │   ├── init.lua            # LSP setup
│   │   ├── servers.lua         # Server configurations
│   │   └── handlers.lua        # Custom handlers
│   ├── plugins/                # Plugin specifications
│   │   ├── editor.lua          # Editor enhancements
│   │   ├── ui.lua              # UI plugins
│   │   ├── coding.lua          # Coding tools
│   │   └── ...                 # Other plugin groups
│   ├── ui/                     # UI configuration
│   │   └── theme.lua           # Theme switching
│   └── utils/                  # Utility functions
│       └── helpers.lua         # Common helpers
├── snippets/                   # Language-specific snippets
│   ├── lua.lua
│   ├── python.lua
│   └── ...
└── spell/                      # Spell files
```

## Module Overview

### Entry Point (`init.lua`)

The main entry point that:
1. Detects if running from dotfiles or standard location
2. Sets up runtime paths
3. Loads configuration modules in correct order
4. Handles work-specific overrides if present

```lua
-- Key initialization order:
-- 1. Path detection
-- 2. Options (core settings)
-- 3. Lazy.nvim bootstrap
-- 4. Plugin loading
-- 5. Keymaps
-- 6. Autocommands
-- 7. Work overrides (if exists)
```

### Core Configuration

#### `core/options.lua`

Essential Neovim settings:

```lua
-- Example settings
vim.opt.number = true           -- Line numbers
vim.opt.relativenumber = true   -- Relative line numbers
vim.opt.expandtab = true        -- Spaces instead of tabs
vim.opt.shiftwidth = 2          -- Indent width
vim.opt.tabstop = 2             -- Tab width
vim.opt.smartindent = true      -- Smart indentation
vim.opt.termguicolors = true    -- True color support
vim.opt.undofile = true         -- Persistent undo
vim.opt.updatetime = 250        -- Faster updates
vim.opt.timeoutlen = 300        -- Key sequence timeout
```

#### `core/globals.lua`

Global variables and leader keys:

```lua
vim.g.mapleader = " "           -- Space as leader
vim.g.maplocalleader = " "      -- Local leader
```

#### `core/performance.lua`

Performance optimizations:

```lua
-- Disable built-in plugins not needed
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- Large file handling
vim.g.large_file_threshold = 512 * 1024  -- 512KB
```

### Keymaps

Organized by functionality (see [Keybindings Reference](../../usage/keybindings/neovim.md)):

| File | Purpose |
|------|---------|
| `core.lua` | Essential mappings (save, quit, clipboard) |
| `navigation.lua` | Window, buffer, and code navigation |
| `editing.lua` | Text manipulation and indentation |
| `lsp.lua` | Go to definition, references, etc. |
| `plugins.lua` | Telescope, file explorer, git |
| `debug.lua` | DAP breakpoints and stepping |

### LSP Configuration

#### `lsp/servers.lua`

Language server configurations:

```lua
-- Servers are configured with Mason
local servers = {
  lua_ls = {
    settings = {
      Lua = {
        diagnostics = { globals = { "vim" } },
      },
    },
  },
  pyright = {},
  ts_ls = {},
  rust_analyzer = {},
  -- ... 20+ more languages
}
```

#### Supported Languages

| Language | Server | Formatter |
|----------|--------|-----------|
| Lua | lua_ls | stylua |
| Python | pyright | ruff |
| TypeScript | ts_ls | prettier |
| Rust | rust_analyzer | rustfmt |
| Go | gopls | gofmt |
| C/C++ | clangd | clang-format |

### Plugin System

Uses lazy.nvim for plugin management:

#### `plugins.lua`

Main plugin specifications (80+ plugins):

```lua
return {
  -- Essential
  { "folke/lazy.nvim" },

  -- UI
  { "folke/tokyonight.nvim", priority = 1000 },
  { "nvim-lualine/lualine.nvim" },

  -- Editor
  { "nvim-telescope/telescope.nvim" },
  { "folke/snacks.nvim" },

  -- Coding
  { "saghen/blink.cmp" },
  { "nvim-treesitter/nvim-treesitter" },

  -- AI
  { "olimorris/codecompanion.nvim" },
}
```

#### Plugin Categories

| Category | Key Plugins |
|----------|-------------|
| Completion | blink.cmp, LuaSnip |
| Fuzzy Finding | Telescope, fzf-lua |
| File Management | oil.nvim, snacks.explorer |
| Git | gitsigns, lazygit |
| AI | CodeCompanion, Avante |
| LSP | nvim-lspconfig, Mason |
| Treesitter | nvim-treesitter |
| UI | tokyonight, lualine |
| Debugging | nvim-dap, nvim-dap-ui |

### Autocommands (`autocmds.lua`)

Automated behaviors:

```lua
-- Highlight on yank
vim.api.nvim_create_autocmd("TextYankPost", {
  callback = function()
    vim.highlight.on_yank()
  end,
})

-- Auto-format on save
vim.api.nvim_create_autocmd("BufWritePre", {
  callback = function()
    vim.lsp.buf.format({ async = false })
  end,
})

-- Skeleton templates for new files
vim.api.nvim_create_autocmd("BufNewFile", {
  pattern = "*.py",
  callback = function()
    -- Insert Python template
  end,
})
```

### Custom Commands (`commands.lua`)

Productivity commands:

| Command | Description |
|---------|-------------|
| `:Format` | Format current buffer |
| `:LspRestart` | Restart LSP servers |
| `:Telescope` | Open fuzzy finder |
| `:Mason` | Manage LSP servers |

## Adding New Configuration

### Adding a New Plugin

1. Add to `config/plugins.lua` or category file:

```lua
{
  "author/plugin-name",
  event = "VeryLazy",  -- Lazy load
  config = function()
    require("plugin-name").setup({
      -- options
    })
  end,
}
```

2. Run `:Lazy sync` to install

### Adding New Keymaps

1. Identify the appropriate file in `config/keymaps/`
2. Add the mapping:

```lua
vim.keymap.set("n", "<leader>xx", function()
  -- action
end, { desc = "Description for which-key" })
```

### Adding a New LSP Server

1. Add to `config/lsp/servers.lua`:

```lua
servers.new_server = {
  settings = {
    -- server-specific settings
  },
}
```

2. Install via Mason: `:MasonInstall new_server`

### Adding Snippets

1. Create/edit file in `snippets/`:

```lua
-- snippets/python.lua
return {
  s("def", {
    t("def "), i(1, "name"), t("("), i(2), t("):"),
    t({ "", "    " }), i(0),
  }),
}
```

## Architecture Decisions

### Why Modular?

1. **Maintainability** - Find and fix issues quickly
2. **Performance** - Lazy-load only what's needed
3. **Flexibility** - Enable/disable features easily
4. **Clarity** - Clear separation of concerns

### Why Lazy Loading?

```lua
-- Bad: Loads immediately
{ "heavy-plugin" }

-- Good: Loads on command
{ "heavy-plugin", cmd = "HeavyCommand" }

-- Good: Loads on filetype
{ "python-plugin", ft = "python" }

-- Good: Loads on keymap
{ "plugin", keys = { { "<leader>x", "<cmd>PluginCmd<cr>" } } }
```

### Error Handling

All configurations use pcall for graceful degradation:

```lua
local ok, module = pcall(require, "module")
if not ok then
  vim.notify("Failed to load module", vim.log.levels.WARN)
  return
end
```

## Diagnostics

### Health Check

```vim
:checkhealth
```

### Startup Profiling

```bash
nvim --startuptime /tmp/startup.log
```

### Plugin Profiling

```vim
:Lazy profile
```

### LSP Status

```vim
:LspInfo
:Mason
```

### Debug Logging

```bash
nvim -V9 /tmp/nvim.log
```

## Performance Targets

| Metric | Target |
|--------|--------|
| Startup time | < 150ms |
| Plugin loading | < 500ms |
| LSP attach | < 1s |
| Memory usage | < 200MB |

## Work Overrides

The configuration supports work-specific overrides via `.dotfiles.private/`:

```lua
-- Loaded if present
~/.dotfiles/.dotfiles.private/companies/*/neovim/
```

This allows company-specific LSP configs, keymaps, and plugins without affecting the main configuration.

---

<p align="center">
  <a href="README.md">← Back to Editor Guides</a>
</p>
