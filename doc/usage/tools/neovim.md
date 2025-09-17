# Neovim Reference

> **Modern text editor configuration and usage**

## Quick Start

```bash
# Open Neovim
nvim
v                # Alias

# Open file/directory
nvim file.py
nvim .          # Open file explorer

# With options
nvim -R file    # Read-only
nvim +10 file   # Jump to line 10
nvim +/pattern  # Search for pattern
```

## Core Concepts

### Modes

| Mode    | Key   | Purpose                 |
| ------- | ----- | ----------------------- |
| Normal  | `ESC` | Navigation and commands |
| Insert  | `i`   | Text input              |
| Visual  | `v`   | Text selection          |
| Command | `:`   | Ex commands             |
| Replace | `R`   | Replace text            |

### Configuration Structure

```
~/.config/nvim/
├── init.lua              # Entry point
├── lua/
│   └── config/
│       ├── options.lua   # Editor settings
│       ├── keymaps.lua   # Key mappings
│       ├── plugins.lua   # Plugin specs
│       ├── lsp.lua       # Language servers
│       └── ...          # Other modules
└── lazy-lock.json        # Plugin versions
```

## Essential Commands

### File Operations

| Command      | Action              |
| ------------ | ------------------- |
| `:w`         | Save file           |
| `:q`         | Quit                |
| `:wq`        | Save and quit       |
| `:q!`        | Quit without saving |
| `:e file`    | Open file           |
| `:w newname` | Save as             |
| `:wa`        | Save all buffers    |
| `:qa`        | Quit all            |

### Navigation

| Key       | Action                       |
| --------- | ---------------------------- |
| `h/j/k/l` | Left/Down/Up/Right           |
| `w/b`     | Next/Previous word           |
| `0/$`     | Start/End of line            |
| `gg/G`    | Top/Bottom of file           |
| `{/}`     | Previous/Next paragraph      |
| `%`       | Matching bracket             |
| `*/#`     | Search word forward/backward |

### Editing

| Key     | Action                       |
| ------- | ---------------------------- |
| `i/a`   | Insert before/after cursor   |
| `I/A`   | Insert at start/end of line  |
| `o/O`   | New line below/above         |
| `x/X`   | Delete char forward/backward |
| `dd`    | Delete line                  |
| `yy`    | Copy line                    |
| `p/P`   | Paste after/before           |
| `u/C-r` | Undo/Redo                    |

## Plugin Ecosystem

### Package Manager (lazy.nvim)

```vim
:Lazy               # Open lazy UI
:Lazy sync         # Update plugins
:Lazy log          # View update log
:Lazy restore      # Restore from lockfile
```

### Key Plugins

| Plugin        | Purpose             | Key Command  |
| ------------- | ------------------- | ------------ |
| Telescope     | Fuzzy finder        | `<leader>ff` |
| Treesitter    | Syntax highlighting | Auto         |
| LSP           | Language support    | `gd`, `K`    |
| Blink.cmp     | Completion          | `Tab`        |
| Snacks.nvim   | QoL features        | Various      |
| CodeCompanion | AI assistance       | `<leader>cc` |

## File Navigation

### Telescope

```vim
<leader>ff    # Find files
<leader>fg    # Live grep
<leader>fb    # Browse buffers
<leader>fh    # Help tags
<leader>fo    # Recent files
<leader>fc    # Grep current word
```

### File Explorer

```vim
<leader>e     # Toggle explorer
-            # Go to parent directory
<CR>         # Open file/directory
a            # Create new file
d            # Delete
r            # Rename
```

## Code Intelligence

### LSP Features

| Key          | Action                   |
| ------------ | ------------------------ |
| `gd`         | Go to definition         |
| `gr`         | Find references          |
| `gi`         | Go to implementation     |
| `gt`         | Go to type definition    |
| `K`          | Show hover docs          |
| `<leader>ca` | Code actions             |
| `<leader>rn` | Rename symbol            |
| `[d/]d`      | Previous/Next diagnostic |

### Completion

| Key       | Action             |
| --------- | ------------------ |
| `Tab`     | Accept completion  |
| `C-n/C-p` | Next/Previous item |
| `C-e`     | Cancel completion  |
| `C-f`     | Scroll docs down   |
| `C-b`     | Scroll docs up     |

## AI Integration

### CodeCompanion

```vim
<leader>cc    # Open chat
<leader>ca    # Show actions menu
<leader>cs    # Create scratch buffer

" With selection
<leader>co    # Optimize code
<leader>cf    # Fix issues
<leader>ce    # Explain code
<leader>cr    # Review code
```

## Git Integration

### Fugitive

```vim
:Git          # Git status
:Git add %    # Stage current file
:Git commit   # Commit
:Git push     # Push changes
:Gdiffsplit   # View diff
:Gblame       # View blame
```

### Gitsigns

| Key          | Action        |
| ------------ | ------------- |
| `]c`         | Next hunk     |
| `[c`         | Previous hunk |
| `<leader>hs` | Stage hunk    |
| `<leader>hr` | Reset hunk    |
| `<leader>hp` | Preview hunk  |
| `<leader>hb` | Blame line    |

## Window Management

### Splits

| Key         | Action           |
| ----------- | ---------------- |
| `C-w s`     | Horizontal split |
| `C-w v`     | Vertical split   |
| `C-w c`     | Close window     |
| `C-w o`     | Close others     |
| `C-h/j/k/l` | Navigate windows |
| `C-w =`     | Equal size       |
| `C-w _`     | Max height       |
| `C-w \|`    | Max width        |

### Tabs

| Command     | Action       |
| ----------- | ------------ |
| `:tabnew`   | New tab      |
| `:tabnext`  | Next tab     |
| `:tabprev`  | Previous tab |
| `:tabclose` | Close tab    |
| `gt`        | Next tab     |
| `gT`        | Previous tab |

## Advanced Features

### Macros

```vim
qa           # Record macro to register 'a'
" ... actions ...
q            # Stop recording
@a           # Play macro 'a'
@@           # Repeat last macro
100@a        # Play macro 100 times
```

### Marks

```vim
ma           # Set mark 'a'
`a           # Jump to mark 'a'
'a           # Jump to line of mark 'a'
:marks       # List all marks
```

### Registers

```vim
"ay          # Yank to register 'a'
"ap          # Paste from register 'a'
"+y          # Yank to system clipboard
"+p          # Paste from system clipboard
:reg         # View all registers
```

### Search and Replace

```vim
/pattern     # Search forward
?pattern     # Search backward
n/N          # Next/Previous match
:s/old/new/  # Replace in line
:%s/old/new/g # Replace in file
:%s/old/new/gc # Replace with confirm
```

## Customization

### Options

```lua
-- In ~/.config/nvim/lua/config/options.lua
vim.opt.number = true         -- Line numbers
vim.opt.relativenumber = true -- Relative numbers
vim.opt.expandtab = true      -- Spaces not tabs
vim.opt.shiftwidth = 2        -- Indent size
```

### Keymaps

```lua
-- In ~/.config/nvim/lua/config/keymaps.lua
vim.keymap.set('n', '<leader>w', ':w<CR>')
vim.keymap.set('n', '<leader>q', ':q<CR>')
```

### Autocommands

```lua
-- In ~/.config/nvim/lua/config/autocmds.lua
vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.opt_local.shiftwidth = 4
  end,
})
```

## Troubleshooting

### Health Check

```vim
:checkhealth          # Full health check
:checkhealth lsp      # Check specific module
:checkhealth provider # Check providers
```

### Debug Mode

```bash
# Start with minimal config
nvim -u NONE

# With verbose logging
nvim -V9nvim.log

# Profile startup
nvim --startuptime startup.log
```

### Common Issues

| Issue           | Solution             |
| --------------- | -------------------- |
| Slow startup    | Check `:StartupTime` |
| Plugin errors   | `:Lazy sync`         |
| LSP not working | `:LspInfo`           |
| Colors wrong    | Check `$TERM`        |

## Performance Tips

### Fast Navigation

1. Use **relative numbers** for quick jumps: `5j`, `10k`
2. Use **marks** for file positions: `ma`, `` `a ``
3. Use **Telescope** over file explorer: `<leader>ff`
4. Use **Harpoon** for frequent files

### Efficient Editing

1. **Dot repeat**: `.` repeats last change
2. **Text objects**: `ci"` change inside quotes
3. **Multiple cursors**: Visual block mode `C-v`
4. **Macros**: Record repetitive tasks

### Plugin Optimization

1. **Lazy loading**: Plugins load on demand
2. **Compiled**: Treesitter parsers are compiled
3. **Cached**: Telescope uses cache
4. **Native**: LSP is built-in

---

<p align="center">
  <a href="../README.md">← Back to Tools</a>
</p>
