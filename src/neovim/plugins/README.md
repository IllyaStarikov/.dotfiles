# Neovim Plugin Configuration

Manages 80+ plugins with lazy loading for < 300ms startup.

## Files

- `plugins/` - Complex plugin configs
  - `ai.lua` - CodeCompanion setup
  - `completion.lua` - Blink.cmp config
  - `markview.lua` - Markdown preview
  - `snippets.lua` - LuaSnip config
  - `vimtex.lua` - LaTeX support

## Plugin Management

```vim
:Lazy              " Plugin manager UI
:Lazy sync         " Update all plugins
:Lazy profile      " Startup performance
```

## Key Plugins

### Essential (Always Loaded)

- **lazy.nvim** - Plugin manager
- **plenary.nvim** - Lua utilities
- **nvim-web-devicons** - File icons

### UI & Navigation

- **telescope.nvim** - Fuzzy finder (`<leader>ff`)
- **neo-tree.nvim** - File explorer (`<leader>e`)
- **lualine.nvim** - Status line
- **bufferline.nvim** - Tab line

### Code Intelligence

- **nvim-treesitter** - Syntax highlighting
- **blink.cmp** - Completion (6x faster than nvim-cmp)
- **nvim-lspconfig** - LSP setup
- **mason.nvim** - LSP installer

### Git Integration

- **gitsigns.nvim** - Git decorations
- **vim-fugitive** - Git commands
- **diffview.nvim** - Diff viewer

### AI Assistants

- **avante.nvim** - AI coding assistant
- **codecompanion.nvim** - Local Ollama integration
- **copilot.vim** - GitHub Copilot

## Performance Tips

### Lazy Loading

```lua
-- Load on event
event = "VeryLazy"

-- Load on command
cmd = "Telescope"

-- Load on filetype
ft = "python"

-- Load on keypress
keys = { "<leader>ff" }
```

### Common Issues

**Tab key conflicts**: Blink.cmp handles all Tab behavior to prevent conflicts with snippets.

**Slow startup**: Check with `:Lazy profile`. Plugins loading > 50ms should be lazy-loaded.

**Memory usage**: Disable semantic tokens if using > 500MB.

## Quick Reference

| Key          | Plugin        | Action        |
| ------------ | ------------- | ------------- |
| `<leader>ff` | Telescope     | Find files    |
| `<leader>fg` | Telescope     | Live grep     |
| `<leader>e`  | Neo-tree      | File explorer |
| `<leader>gg` | LazyGit       | Git UI        |
| `<leader>cc` | CodeCompanion | AI chat       |

See `plugins.lua` at `src/neovim/plugins.lua` for full specifications.
