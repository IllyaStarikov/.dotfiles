# Blink.cmp Configuration

> **Our specific configuration and customizations for the Blink.cmp completion engine**

[Official Documentation](https://github.com/Saghen/blink.cmp)

## Why Blink.cmp?

We chose Blink.cmp over nvim-cmp for:

- **Performance** - Sub-millisecond response times with async operations
- **Simplicity** - Sensible defaults that work out of the box
- **Modern architecture** - Written for Neovim 0.10+ with latest APIs

## Our Configuration

### Performance Optimizations

```lua
-- Located in: lua/config/plugins/completion.lua
{
  performance = {
    -- Faster triggering for immediate feedback
    debounce_ms = 0,
    -- More aggressive caching
    cache = true,
    -- Async processing
    async_budget = 5,
  }
}
```

### Custom Keybindings

Our setup differs from defaults:

| Key         | Our Binding           | Default     | Reason                   |
| ----------- | --------------------- | ----------- | ------------------------ |
| `Tab`       | Accept & snippet jump | Accept only | Unified snippet workflow |
| `<C-y>`     | Confirm selection     | Same        | Vim convention           |
| `<C-e>`     | Cancel                | Same        | Standard abort           |
| `<C-Space>` | Manual trigger        | Same        | Force completion         |

### Source Priorities

```lua
sources = {
  -- Our priority order (differs from default)
  default = { 'lsp', 'snippets', 'path', 'buffer' },

  -- Custom for specific contexts
  providers = {
    lsp = {
      -- Prefer LSP for code
      score_offset = 100,
    },
    path = {
      -- Boost paths in strings
      score_offset = 10,
      opts = {
        trailing_slash = true,
        label_trailing_slash = false,
      }
    }
  }
}
```

### Integration with LuaSnip

```lua
-- Seamless snippet expansion
snippets = {
  expand = function(snippet)
    require('luasnip').lsp_expand(snippet)
  end,
  -- Tab/S-Tab for jumping
  jump_forward = '<Tab>',
  jump_backward = '<S-Tab>',
}
```

## Unique Features We Enable

### 1. Frecency Boost

```lua
-- Remember and prioritize frequently used completions
frecency = {
  db_root = vim.fn.stdpath('data') .. '/blink-frecency',
  max_entries = 2048,
}
```

### 2. Smart Auto-Brackets

```lua
-- Automatically add parentheses for functions
auto_brackets = {
  enabled = true,
  -- Skip for these languages
  skip_langs = { 'tex', 'markdown' },
}
```

### 3. Documentation Window

```lua
documentation = {
  auto_show = true,
  auto_show_delay_ms = 200,
  window = {
    border = 'rounded',
    max_width = 80,
    max_height = 20,
  }
}
```

## Performance Comparison

In our environment:

| Metric              | Blink.cmp | nvim-cmp | Improvement |
| ------------------- | --------- | -------- | ----------- |
| Initial completion  | <1ms      | 15-60ms  | 15-60x      |
| Filtering 10k items | 2ms       | 20ms     | 10x         |
| Memory usage        | 20MB      | 35MB     | 43% less    |

## Troubleshooting Our Setup

### Issue: Completions not appearing

```vim
" Check status
:Blink

" Verify sources
:lua print(vim.inspect(require('blink.cmp').get_sources()))
```

### Issue: Slow in large files

```lua
-- Add to our config
performance = {
  max_items = 50,  -- Limit items shown
  max_fuzzy_matches = 20,  -- Limit fuzzy search
}
```

### Issue: Conflicts with other plugins

```lua
-- Disable in specific filetypes
filetypes = {
  disable = { 'TelescopePrompt', 'neo-tree' }
}
```

## Extending Our Configuration

### Adding Custom Sources

```lua
-- In lua/config/plugins/completion.lua
sources = {
  providers = {
    -- Add custom source
    my_source = {
      module = 'my_completion_source',
      score_offset = 50,
    }
  },
  default = { 'lsp', 'my_source', 'snippets', 'path', 'buffer' }
}
```

### Custom Formatting

```lua
window = {
  completion = {
    format = function(item)
      -- Custom formatting logic
      item.label = item.label .. ' ' .. item.source
      return item
    end
  }
}
```

## References

- [Official Blink.cmp Documentation](https://cmp.saghen.dev/)
- [Our full configuration](https://github.com/starikov/.dotfiles/blob/main/src/neovim/config/plugins/completion.lua)
- [Performance benchmarks](https://github.com/Saghen/blink.cmp#benchmarks)

---

<p align="center">
  <a href="../README.md">← Back to Guides</a>
</p>
