# /src/neovim/keymaps - Neovim Key Bindings

## 1. What's in this directory and how to use it

This directory contains organized key mapping configurations for Neovim, separated by functionality to maintain clarity and avoid conflicts. Each file defines mappings for specific contexts or features.

### Files in this directory:

```
keymaps/
├── core.lua        # Essential mappings and fixes (3.0KB)
├── editing.lua     # Text manipulation keys (1.2KB)
├── navigation.lua  # Movement and jumping (3.5KB)
├── lsp.lua        # Language server mappings (937B)
├── debug.lua      # Debugging keybindings (3.9KB)
└── plugins.lua    # Plugin-specific mappings (16KB)
```

### How to use:

```lua
-- Key mappings are automatically loaded by config system
-- Check current mappings
:Telescope keymaps
:verbose map <key>

-- Add custom mappings
vim.keymap.set("n", "<leader>xx", function() end, { desc = "Description" })

-- Unmap a key
vim.keymap.del("n", "<leader>xx")

-- Check if key is mapped
:map <leader>
```

### Key notation:

- `<leader>` = Space key (configured globally)
- `<C-x>` = Ctrl+x
- `<M-x>` = Alt/Meta+x
- `<D-x>` = Cmd+x (macOS)
- `<S-x>` = Shift+x
- `<CR>` = Enter/Return
- `<Esc>` = Escape
- `<Tab>` = Tab key

## 2. Why this directory exists

### Purpose:

Key mappings are the interface between thought and action in Neovim. Well-organized keymaps reduce cognitive load, prevent RSI, and make complex operations effortless.

### Why separate files:

1. **Avoid conflicts** - Clear namespace separation
2. **Easy discovery** - Find mappings by category
3. **Conditional loading** - Disable categories if needed
4. **Documentation** - Self-documenting structure
5. **Debugging** - Isolate mapping issues

### Why these categories:

- **core.lua** - Universal mappings everyone needs
- **editing.lua** - Text manipulation efficiency
- **navigation.lua** - Fast movement patterns
- **lsp.lua** - Consistent IDE-like features
- **debug.lua** - Debugging workflow
- **plugins.lua** - Feature-specific bindings

### Why this loading order:

1. Core mappings first (foundation)
2. Editing/navigation (basic operations)
3. LSP mappings (development features)
4. Plugin mappings last (can override if needed)

## 3. Comprehensive overview

### Core Mappings (core.lua):

#### System Fixes:

```lua
-- Fix VIMRUNTIME for health checks
if not vim.env.VIMRUNTIME then
    -- Sets runtime path for proper functioning
end

-- Common typos
:W  → :w   -- Save
:Q  → :q   -- Quit
:Wq → :wq  -- Save and quit
```

#### Essential Operations:

```lua
-- Quick save (works in all modes)
<C-s>        -- Save file
<C-a>        -- Select all
<Esc>        -- Clear search highlight

-- Clipboard operations
<leader>y    -- Yank to system clipboard
<leader>Y    -- Yank line to clipboard
<leader>p    -- Paste without yanking (greatest remap ever)

-- macOS integration
<D-c>        -- Cmd+C copy
<D-v>        -- Cmd+V paste

-- Delete without yanking
<leader>d    -- Delete to black hole register
```

### Editing Mappings (editing.lua):

#### Text Manipulation:

```lua
-- Line operations
<M-j>        -- Move line down
<M-k>        -- Move line up
<M-d>        -- Duplicate line

-- Word operations
ciw          -- Change inner word
daw          -- Delete around word
yiw          -- Yank inner word

-- Indentation
>            -- Indent in visual mode
<            -- Dedent in visual mode
>>           -- Indent line
<<           -- Dedent line
```

### Navigation Mappings (navigation.lua):

#### Movement Patterns:

```lua
-- Window navigation
<C-h>        -- Move to left window
<C-j>        -- Move to down window
<C-k>        -- Move to up window
<C-l>        -- Move to right window

-- Buffer navigation
<S-h>        -- Previous buffer
<S-l>        -- Next buffer
<leader>bd   -- Delete buffer

-- Quick jumps
<leader>h    -- Jump to beginning of line
<leader>l    -- Jump to end of line
gg           -- Go to top
G            -- Go to bottom
```

#### Search Navigation:

```lua
n            -- Next search result (centered)
N            -- Previous search result (centered)
*            -- Search word under cursor
#            -- Search word backwards
<C-d>        -- Half page down (centered)
<C-u>        -- Half page up (centered)
```

### LSP Mappings (lsp.lua):

#### Code Intelligence:

```lua
gd           -- Go to definition
gD           -- Go to declaration
gi           -- Go to implementation
gr           -- Go to references
K            -- Hover documentation
<C-k>        -- Signature help

-- Code actions
<leader>ca   -- Code action
<leader>rn   -- Rename symbol
<leader>f    -- Format document
```

### Debug Mappings (debug.lua):

#### DAP (Debug Adapter Protocol):

```lua
<F5>         -- Continue/Start debugging
<F10>        -- Step over
<F11>        -- Step into
<F12>        -- Step out
<leader>b    -- Toggle breakpoint
<leader>B    -- Set conditional breakpoint
<leader>dr   -- Toggle REPL
<leader>dl   -- Run last
```

### Plugin Mappings (plugins.lua):

#### Telescope:

```lua
<leader>ff   -- Find files
<leader>fg   -- Live grep
<leader>fb   -- Browse buffers
<leader>fh   -- Help tags
<leader>fo   -- Recent files
<leader>fx   -- Diagnostics
```

#### File Explorer:

```lua
<leader>e    -- Toggle file tree
<leader>o    -- Focus file tree
-            -- Open parent directory
```

#### Git Integration:

```lua
<leader>gg   -- LazyGit
<leader>gj   -- Next hunk
<leader>gk   -- Previous hunk
<leader>gp   -- Preview hunk
<leader>gr   -- Reset hunk
<leader>gs   -- Stage hunk
```

#### AI Assistants:

```lua
<leader>aa   -- Avante ask
<leader>ae   -- Avante edit
<leader>ar   -- Avante refresh
<leader>cc   -- CodeCompanion chat
<leader>ca   -- CodeCompanion actions
```

## 4. LLM Guidance

### For AI Assistants:

When working with keymaps, understand:

1. **Leader key is Space** - Most custom mappings use `<leader>`
2. **Mode matters** - n=normal, i=insert, v=visual, x=visual-block
3. **Silent by default** - Use `silent = true` to avoid command echo
4. **Descriptions required** - Always add `desc` for discoverability
5. **Check conflicts** - Use `:verbose map` before adding

### Adding new mappings:

```lua
-- Template for new mapping
vim.keymap.set(
    "n",                              -- Mode(s)
    "<leader>xx",                     -- Key combination
    function() end,                   -- Action (function or command)
    {
        desc = "Clear description",   -- Required for which-key
        noremap = true,               -- Don't allow remapping
        silent = true,                -- Don't echo command
        buffer = nil,                 -- nil = global, number = buffer-specific
    }
)
```

### Best practices:

```lua
-- Use functions for complex operations
vim.keymap.set("n", "<leader>x", function()
    -- Complex logic here
    local result = compute_something()
    if result then
        vim.cmd("echo 'Success'")
    end
end, { desc = "Complex operation" })

-- Group related mappings
local function setup_git_mappings()
    local map = vim.keymap.set
    map("n", "<leader>gs", ":Git status<CR>", { desc = "Git status" })
    map("n", "<leader>gc", ":Git commit<CR>", { desc = "Git commit" })
end
```

## 5. Lessons Learned

### What NOT to do:

#### ❌ Don't override essential Vim keys

```lua
-- BAD - Breaks core functionality
vim.keymap.set("n", "j", function() print("j pressed") end)
vim.keymap.set("n", "dd", ":echo 'deleted'<CR>")

-- GOOD - Use leader or unused combinations
vim.keymap.set("n", "<leader>j", function() print("custom") end)
```

#### ❌ Don't use conflicting plugin mappings

```lua
-- BAD - Multiple plugins might use same key
vim.keymap.set("n", "<C-n>", ":NvimTreeToggle<CR>")
vim.keymap.set("n", "<C-n>", ":Telescope find_files<CR>")

-- GOOD - Consistent namespace
vim.keymap.set("n", "<leader>e", ":NvimTreeToggle<CR>")
vim.keymap.set("n", "<leader>ff", ":Telescope find_files<CR>")
```

#### ❌ Don't forget mode differences

```lua
-- BAD - Wrong mode
vim.keymap.set("n", "<C-c>", '"+y')  -- Copy in normal mode??

-- GOOD - Visual mode for copy
vim.keymap.set("v", "<C-c>", '"+y')  -- Copy in visual mode
```

### Known Issues:

#### Issue: macOS Cmd key not working

**Symptom**: `<D-c>` mappings don't work
**Cause**: Terminal doesn't pass Cmd key to Neovim
**Fix**: Use terminal that supports it (Kitty, Alacritty with config)

```lua
-- Only works in GUI or specific terminals
if vim.fn.has("gui_running") or vim.env.TERM_PROGRAM == "WezTerm" then
    vim.keymap.set("n", "<D-c>", '"+y')
end
```

#### Issue: Leader key timeout

**Symptom**: Mappings timeout too quickly
**Cause**: Default timeoutlen too short
**Fix**: Adjust timeout

```lua
vim.o.timeoutlen = 1000  -- 1 second timeout for leader
vim.o.ttimeoutlen = 0    -- No timeout for escape sequences
```

#### Issue: Paste in insert mode loses position

**Symptom**: Cursor jumps after paste
**Cause**: Default paste behavior
**Fix**: Use proper insert mode paste

```lua
-- Better insert mode paste
vim.keymap.set("i", "<C-v>", "<C-r><C-p>+", { desc = "Paste properly" })
```

### Failed Approaches:

1. **Single huge keymaps file** - Became unmaintainable
   - 1000+ lines in one file
   - Impossible to find mappings
   - Now split by functionality

2. **Auto-generated mappings** - Too magic
   - Tried generating from config
   - Lost explicit control
   - Direct definition is clearer

3. **Mode-specific files** - Wrong abstraction
   - Separated by mode (normal.lua, insert.lua)
   - Related functions split apart
   - Functionality grouping better

4. **Numberpad navigation** - Conflicts
   - Tried using numpad for navigation
   - Conflicts with number input
   - Terminal compatibility issues

### Best Practices Discovered:

1. **Always add descriptions**

   ```lua
   -- Shows in which-key and Telescope
   { desc = "Clear, actionable description" }
   ```

2. **Use functions for complex mappings**

   ```lua
   -- Easier to debug and maintain
   local function my_complex_action()
       -- Logic here
   end
   vim.keymap.set("n", "<leader>x", my_complex_action)
   ```

3. **Group with which-key**

   ```lua
   -- Visual grouping in which-key popup
   ["<leader>g"] = { name = "+git" },
   ["<leader>f"] = { name = "+find" },
   ```

4. **Buffer-local when appropriate**
   ```lua
   -- Only in specific filetypes
   vim.api.nvim_create_autocmd("FileType", {
       pattern = "python",
       callback = function()
           vim.keymap.set("n", "<leader>r", ":!python %<CR>", { buffer = 0 })
       end,
   })
   ```

### Performance Insights:

1. **Lazy-load plugin mappings**

   ```lua
   -- Only create mapping when plugin loads
   keys = {
       { "<leader>gg", "<cmd>LazyGit<cr>", desc = "LazyGit" }
   }
   ```

2. **Avoid expensive mapping functions**

   ```lua
   -- BAD - Runs on every keypress
   vim.keymap.set("n", "j", function()
       -- Expensive computation
   end)
   ```

3. **Use native commands when possible**
   ```lua
   -- Faster than Lua function
   vim.keymap.set("n", "<leader>w", ":w<CR>")
   ```

## Troubleshooting

### Debug Commands:

```vim
" Show all mappings
:map

" Show specific key mapping
:verbose map <leader>ff

" Show mappings for mode
:nmap    " Normal mode
:imap    " Insert mode
:vmap    " Visual mode

" Find mapping conflicts
:Telescope keymaps

" Check which-key groups
:WhichKey <leader>
```

### Common Problems:

1. **Mapping doesn't work**

   ```lua
   -- Check if key is already mapped
   :verbose map <your-key>
   -- Check correct mode
   -- Verify no typos in key notation
   ```

2. **Timeout issues**

   ```lua
   -- Increase timeout
   vim.o.timeoutlen = 1500
   ```

3. **Terminal limitations**
   ```lua
   -- Some keys don't work in terminal
   -- Test with :Telescope keymaps
   ```

## Related Documentation

- [Core Config](../core/README.md) - Vim options
- [Plugins Config](../plugins/README.md) - Plugin specifications
- [Main Neovim Config](../README.md) - Overview
- [Vim Keymap Docs](https://neovim.io/doc/user/map.html)
- [Key Notation](https://neovim.io/doc/user/intro.html#key-notation)
