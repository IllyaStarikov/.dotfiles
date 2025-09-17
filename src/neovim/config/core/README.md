# /src/neovim/config/core - Neovim Core Settings

## 1. What's in this directory and how to use it

This directory contains the foundational Neovim settings that configure editor behavior, performance optimizations, and basic functionality. These are loaded first before any plugins or custom configurations.

### Files in this directory:

```
core/
├── init.lua        # Module loader (364B)
├── options.lua     # Editor options (2.5KB)
├── performance.lua # Speed optimizations (1.9KB)
├── backup.lua      # Backup/swap settings (641B)
├── folding.lua     # Code folding config (386B)
├── indentation.lua # Tab/space settings (310B)
└── search.lua      # Search behavior (325B)
```

### How to use:

```lua
-- These are automatically loaded by config/init.lua
require('config.core')  -- Loads all core modules

-- Or load individually
require('config.core.options')
require('config.core.performance')

-- Check current settings
:set option?           -- View option value
:verbose set option?   -- See where it was set
```

### Load order matters:

1. **performance.lua** - Disable unused features first
2. **options.lua** - Set general options
3. **indentation.lua** - Configure tabs/spaces
4. **search.lua** - Search behavior
5. **folding.lua** - Code folding
6. **backup.lua** - Backup/swap files

## 2. Why this directory exists

### Purpose:

Core settings form the foundation that everything else builds upon. Wrong settings here can break plugins, slow down the editor, or cause unexpected behavior.

### Why separate files:

1. **Logical grouping** - Related settings together
2. **Easy debugging** - Isolate problem areas
3. **Selective loading** - Can disable specific modules
4. **Clear documentation** - Each file has focused purpose
5. **Performance** - Load only what's needed

### Why loaded first:

- **Dependencies** - Plugins expect certain settings
- **Performance** - Disable features before they load
- **Consistency** - Same behavior regardless of plugins
- **Debugging** - Core works even if plugins fail

### Why these specific settings:

- **options.lua** - User preferences and editor behavior
- **performance.lua** - Critical for sub-300ms startup
- **backup.lua** - Prevent data loss
- **folding.lua** - Navigate large files efficiently
- **indentation.lua** - Consistent code formatting
- **search.lua** - Powerful text navigation

## 3. Comprehensive overview

### Module Details:

#### init.lua - Module Loader

```lua
-- Simple loader that requires all core modules
require('config.core.performance')  -- Must be first!
require('config.core.options')
require('config.core.backup')
-- etc...
```

#### options.lua - Editor Options

Key settings:

- **Line numbers**: Hybrid (relative + absolute current)
- **Mouse**: Enabled in all modes
- **Splits**: Open right and below
- **Scrolling**: 8-line offset
- **Wrapping**: Disabled by default
- **Hidden buffers**: Enabled for better workflow
- **Undo**: Persistent across sessions

#### performance.lua - Speed Optimizations

Critical optimizations:

```lua
-- Disable unused providers (saves ~50ms)
g.loaded_python_provider = 0
g.loaded_ruby_provider = 0
g.loaded_node_provider = 0
g.loaded_perl_provider = 0

-- Disable built-in plugins (saves ~20ms)
g.loaded_gzip = 1
g.loaded_tarPlugin = 1
g.loaded_zipPlugin = 1

-- Large file optimizations
opt.synmaxcol = 1000  -- Syntax highlighting column limit
opt.maxmempattern = 2000  -- Pattern memory limit

-- LSP logging
vim.lsp.set_log_level("ERROR")  -- Reduce log spam
```

#### backup.lua - Data Protection

```lua
opt.backup = false      -- No backup files
opt.writebackup = false -- No backup during write
opt.swapfile = false    -- No swap files
opt.undofile = true     -- Persistent undo
opt.undodir = vim.fn.stdpath('data') .. '/undo'
```

#### folding.lua - Code Folding

```lua
opt.foldenable = true
opt.foldlevelstart = 99  -- Start unfolded
opt.foldmethod = 'expr'  -- Use treesitter
opt.foldexpr = 'nvim_treesitter#foldexpr()'
```

#### indentation.lua - Tab/Space Settings

```lua
opt.expandtab = true    -- Spaces instead of tabs
opt.shiftwidth = 2      -- 2-space indents
opt.tabstop = 2         -- Tab width
opt.smartindent = true  -- Auto-indent
```

#### search.lua - Search Configuration

```lua
opt.ignorecase = true   -- Case-insensitive
opt.smartcase = true    -- Unless uppercase used
opt.hlsearch = true     -- Highlight matches
opt.incsearch = true    -- Show matches while typing
```

### Performance Impact:

- **Startup time**: ~15ms for all core modules
- **Memory usage**: < 1MB
- **Disabled features save**: ~70ms startup time
- **Python provider check**: ~30ms if not cached

## 4. LLM Guidance

### For AI Assistants:

When modifying core settings, understand:

1. **Load order is critical** - Performance must be first
2. **Settings cascade** - Later settings override earlier
3. **Plugin dependencies** - Many plugins assume defaults
4. **Performance impact** - Every setting affects startup
5. **User experience** - Core defines how Neovim feels

### Adding new settings:

```lua
-- Always document why
-- WRONG: Just set the option
opt.something = true

-- RIGHT: Explain the reasoning
-- Enable something because it improves X by Y%
-- This fixes issue Z that occurs when...
opt.something = true
```

### Testing changes:

```bash
# Profile startup time
nvim --startuptime /tmp/startup.log

# Check specific module
nvim -c "lua require('config.core.performance')" -c "q"

# Verify no errors
nvim --headless -c "checkhealth" -c "q"
```

### Common patterns:

```lua
-- Conditional settings
if vim.fn.has('mac') == 1 then
  -- macOS-specific settings
end

-- Safe provider detection
local python3_path = vim.fn.exepath('python3')
if python3_path ~= '' then
  g.python3_host_prog = python3_path
else
  g.loaded_python3_provider = 1  -- Disable if not found
end

-- Defer non-critical settings
vim.defer_fn(function()
  -- Settings that can wait
end, 100)
```

## 5. Lessons Learned

### What NOT to do:

#### ❌ Don't set conflicting options

```lua
-- BAD - These conflict
opt.compatible = true    -- Vi compatible mode
opt.nocompatible = true  -- Modern Vim mode

-- GOOD - Neovim is always nocompatible
-- Don't set either, it's the default
```

#### ❌ Don't load providers unnecessarily

```lua
-- BAD - Checking providers that aren't used
g.python3_host_prog = '/usr/bin/python3'
-- This causes a 30ms delay even if not using Python plugins

-- GOOD - Disable if not needed
g.loaded_python3_provider = 1
```

#### ❌ Don't enable expensive features

```lua
-- BAD - Slows down scrolling
opt.cursorcolumn = true  -- Highlights column
opt.relativenumber = true -- Without lazy redraw
opt.cursorline = true    -- With complex syntax

-- GOOD - Be selective
opt.cursorline = true    -- Only horizontal
opt.lazyredraw = false   -- Don't use, causes issues
```

### Known Issues:

#### Issue: Startup takes > 300ms

**Symptom**: Slow Neovim launch
**Cause**: Providers being checked
**Fix**: Disable unused providers

```lua
-- Add to performance.lua
g.loaded_python_provider = 0  -- Python 2
g.loaded_ruby_provider = 0
g.loaded_node_provider = 0
g.loaded_perl_provider = 0
```

#### Issue: Matchit plugin errors

**Symptom**: "Matchit.vim already loaded" errors
**Cause**: Trying to manually load built-in plugin
**Fix**: Don't load it, Neovim includes it

```lua
-- REMOVED: vim.cmd('runtime macros/matchit.vim')
-- It's built-in since Neovim 0.8
```

#### Issue: netrw security warning

**Symptom**: Security warning about rm command
**Cause**: netrw uses shell commands for file operations
**Fix**: Use safe, explicit command

```lua
-- Safe version with proper flags
g.netrw_localrmdir = "rm -rf"
-- The -f prevents prompts, -r for recursive
-- Netrw validates paths, but we use safest form
```

#### Issue: Verbose logging creates vimlog.txt

**Symptom**: Unexpected vimlog.txt file appears
**Cause**: Verbose mode accidentally enabled
**Fix**: Reset verbose settings

```lua
-- Only reset if not explicitly set via command line
if vim.v.verbose == 0 then
  vim.opt.verbose = 0
  vim.opt.verbosefile = ""
end
```

### Failed Approaches:

1. **lazyredraw = true** - Caused visual glitches
   - Thought it would improve performance
   - Actually made scrolling jumpy
   - Some plugins incompatible

2. **clipboard = unnamedplus** - Slowed everything
   - 50ms+ delay on every yank/paste
   - System clipboard integration overhead
   - Now only set when needed

3. **foldmethod = syntax** - Too slow
   - Took 100ms+ on large files
   - Now use treesitter expression folding
   - Much faster and more accurate

4. **synmaxcol = 0** - Killed performance
   - Unlimited syntax highlighting
   - 10-second delays on long lines
   - Now limited to 1000 columns

### Performance Discoveries:

1. **Provider detection order matters**

   ```lua
   -- Fast: Check executable first
   if vim.fn.exepath('python3') ~= '' then

   -- Slow: Let Neovim search
   g.python3_host_prog = 'python3'
   ```

2. **Defer non-critical autocmds**

   ```lua
   vim.defer_fn(function()
     -- Clear messages after startup
   end, 100)  -- 100ms delay doesn't affect UX
   ```

3. **Built-in plugins add 70ms**
   - Each plugin ~5-10ms
   - Most never used
   - Disabling all saves significant time

### Best Practices:

1. **Profile everything**

   ```bash
   nvim --startuptime startup.log
   grep "core" startup.log  # Check core module times
   ```

2. **Document provider requirements**

   ```lua
   -- Python3 needed for:
   -- - Ultisnips (if used)
   -- - Some LSP servers
   -- Disable if not using these
   ```

3. **Use has() for compatibility**

   ```lua
   if vim.fn.has('nvim-0.9') == 1 then
     -- 0.9+ only features
   end
   ```

4. **Group related settings**
   ```lua
   -- Window behavior
   opt.splitbelow = true
   opt.splitright = true
   opt.equalalways = false
   ```

## Troubleshooting

### Debug Commands:

```vim
" Check where option was set
:verbose set option?

" View all changed options
:set

" Profile startup
:StartupTime

" Check module load time
:lua print(vim.inspect(require('config.core')))
```

### Common Problems:

1. **Slow startup**
   - Run `:checkhealth provider`
   - Disable unused providers
   - Check `:StartupTime`

2. **Settings not taking effect**
   - Check load order
   - Look for plugin overrides
   - Use `:verbose set option?`

3. **Unexpected behavior**
   - Temporarily disable performance.lua
   - Check if built-in plugin needed
   - Review recent changes

## Related Documentation

- [Neovim Config](../../README.md) - Main configuration
- [Performance Guide](../performance.md) - Optimization tips
- [Options Documentation](https://neovim.io/doc/user/options.html)
- [Provider Documentation](https://neovim.io/doc/user/provider.html)
- [Startup Optimization](https://github.com/neovim/neovim/wiki/FAQ#startup-time)
