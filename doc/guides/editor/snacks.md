# Snacks.nvim Guide

> **Modern quality-of-life improvements for Neovim** - A collection of small but powerful utilities that enhance your daily workflow.

[Official Documentation](https://github.com/folke/snacks.nvim)

## Overview

Snacks.nvim is a comprehensive suite of QoL (Quality of Life) improvements for Neovim. In this configuration, we use Snacks for:

- **File Explorer** - Modern, picker-based file browsing
- **Dashboard** - Beautiful start screen with quick actions  
- **Terminal Integration** - Floating and split terminals
- **Git Integration** - LazyGit and git utilities
- **Buffer Management** - Smart buffer deletion
- **Scratch Buffers** - Temporary note-taking
- **Notifications** - Beautiful notification system
- **Utilities** - Zen mode, toggles, and more

**Note**: Due to integration considerations, we use Telescope for file/text searching operations while leveraging Snacks for its excellent UI components and utilities.

## Key Features

### File Explorer
The Snacks file explorer provides a modern, fuzzy-searchable alternative to traditional tree explorers:

- **Instant search** - Type to filter files and directories
- **Preview support** - See file contents before opening
- **Integrated actions** - Create, rename, delete without leaving the explorer
- **Smart navigation** - Remembers your last location

### Dashboard
A beautiful, customizable start screen that appears when you open Neovim without a file:

- **Quick actions** - Single-key shortcuts to common tasks
- **Recent files** - Fast access to your work
- **Project switching** - Jump between projects
- **Startup time** - Shows how fast Neovim loaded

### Terminal Integration  
Seamless terminal integration within Neovim:

- **Multiple layouts** - Float, split, or vsplit
- **Persistent sessions** - Terminals stay alive in background
- **Quick commands** - Pre-configured for git, Python, Node.js
- **Smart focus** - Automatically focuses terminal when opened

## Complete Keybindings

### File Operations (Using Telescope)

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>ff` | Find Files | Fast fuzzy file search |
| `<leader>fF` | Find Files + Hidden | Include hidden files |
| `<leader>fr` | Recent Files | Quick access to recent files |
| `<leader>fg` | Live Grep | Search text in all files |
| `<leader>fG` | Live Grep + Hidden | Search including hidden files |
| `<leader>f/` | Grep Word | Search word under cursor |
| `<leader>f;` | Resume Search | Continue last search |
| `<leader>fb` | Browse Buffers | Switch between open files |
| `<leader>fh` | Help Tags | Search Neovim help |
| `<leader>fc` | Commands | Browse available commands |
| `<leader>fk` | Keymaps | Search keybindings |

### Scratch Buffers

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>.` | Toggle Scratch | Quick temporary buffer |
| `<leader>S` | Select Scratch | Choose from existing scratches |

### Terminal

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>tt` | Toggle Terminal | Main terminal |
| `<leader>tf` | Float Terminal | Floating terminal |
| `<leader>ts` | Split Terminal | Horizontal split |
| `<leader>tv` | VSplit Terminal | Vertical split |
| `<leader>tg` | Git Terminal | `git status` terminal |
| `<leader>tp` | Python Terminal | Python REPL |

### File Explorer

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>e` | Explorer | Open file explorer |
| `<leader>E` | Explorer (file dir) | Open in current file's directory |
| `<leader>o` | Open Explorer | Alternative binding |
| `<leader>O` | Float Explorer | Open in floating window |
| `-` | Open Explorer | Quick access (like vim-vinegar) |

**Explorer Navigation**:
- **Type to search** - Instantly filter files and directories
- **Tab** - Select/deselect files for bulk operations  
- **Enter** - Open file or directory
- **Backspace** - Go to parent directory
- **Ctrl+v** - Open in vertical split
- **Ctrl+x** - Open in horizontal split
- **Ctrl+t** - Open in new tab
- **a** - Create new file
- **A** - Create new directory
- **r** - Rename file/directory
- **d** - Delete file/directory
- **y** - Copy file path
- **Y** - Copy absolute path

### Git Integration

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>gg` | LazyGit | Full git interface |
| `<leader>gG` | LazyGit (cwd) | LazyGit from file's directory |
| `<leader>gb` | Git Blame Line | Show blame for current line |
| `<leader>gB` | Git Browse | Open file/line in browser |
| `<leader>gf` | Git Files | Browse files tracked by git |
| `<leader>gs` | Git Status | Browse changed files |
| `<leader>gc` | Git Commits | Browse commit history |
| `<leader>gC` | Buffer Commits | Commits for current file |

**LazyGit Tips**:
- Use `?` for help inside LazyGit
- `Tab` to switch between panels
- `x` to open command menu
- `Enter` to stage/unstage files
- `c` to commit, `P` to push

### Buffer Management

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>bd` | Delete Buffer | Smart delete (keeps window layout) |
| `<leader>bD` | Delete All Buffers | Clear all buffers |
| `<leader>bo` | Delete Other Buffers | Keep only current buffer |

**Smart Buffer Deletion**: Unlike `:bd`, Snacks' buffer delete preserves your window layout and switches to a sensible buffer instead of closing the window.

### Toggles & Settings

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>tw` | Toggle Wrap | Line wrapping on/off |
| `<leader>tS` | Toggle Spell | Spell checking on/off |
| `<leader>tn` | Toggle Line Numbers | Absolute line numbers |
| `<leader>tr` | Toggle Relative Numbers | Relative line numbers |
| `<leader>th` | Toggle Search Highlight | Clear search highlights |
| `<leader>tD` | Toggle Diagnostics | LSP diagnostics on/off |

**Toggle Indicators**: When you toggle a setting, a notification appears showing the new state.

### Utilities

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>un` | Dismiss Notifications | Clear all notifications |
| `<leader>nh` | Notification History | View past notifications |

### Focus & Zen Mode

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>z` | Toggle Zen Mode | Distraction-free coding |
| `<leader>Z` | Zen Zoom | Focus current window only |
| `<leader>sd` | Show Dashboard | Return to start screen |

**Zen Mode Features**:
- Hides all UI elements except your code
- Centers the text for comfortable reading
- Disables distracting plugins
- Perfect for focused writing or coding sessions

## Configuration Details

### Performance Optimizations

Snacks.nvim is designed for speed and includes several performance optimizations:

### Big File Handling
- Files over 1MB automatically disable heavy features
- Syntax highlighting, spell check, and folds are turned off
- Ensures smooth editing of large files

### Smart Exclusions
- Automatically ignores: `.git`, `node_modules`, `__pycache__`, `build`, `dist`
- Speeds up file searching and navigation
- Reduces memory usage

### Lazy Loading
- Modules load only when needed
- Dashboard loads instantly without blocking
- Terminals start in background

### Integration with Other Plugins

Works seamlessly with:

- **Telescope** - We use Telescope for file/grep operations
- **LSP** - Full LSP support in all Snacks windows
- **Treesitter** - Syntax highlighting in previews
- **Git Signs** - Git status in file explorer

### Customization

You can customize Snacks.nvim behavior in `~/.config/nvim/lua/config/plugins/snacks.lua`:

```lua
-- Example: Change dashboard header
dashboard = {
  preset = {
    header = [[
    Your Custom ASCII Art Here
    ]],
  },
}

-- Example: Modify file explorer
explorer = {
  win = {
    width = 40,  -- Wider explorer
    position = "right",  -- Open on right side
  },
}
```

## Pro Tips

### File Navigation
1. **Quick switching**: Use `<leader>fr` for recent files - faster than browsing
2. **Project files**: `<leader>gf` shows only git-tracked files, filtering out noise
3. **Smart explorer**: Type partial filenames in explorer to jump instantly

### Terminal Workflow  
1. **Persistent terminals**: Your terminal sessions stay alive when hidden
2. **Quick commands**: `<leader>tg` for git status, `<leader>tp` for Python REPL
3. **Multiple terminals**: Open different terminals for different tasks

### Productivity Boosters
1. **Scratch buffers**: Use `<leader>.` for quick notes that won't clutter your workspace
2. **Zen mode**: `<leader>z` when you need to focus on just the code
3. **Smart notifications**: Important messages stay visible, others auto-hide

### Git Integration
1. **LazyGit power**: `<leader>gg` gives you a full Git UI - learn it once, use everywhere
2. **Quick blame**: `<leader>gb` shows who changed the current line
3. **Browser integration**: `<leader>gB` opens the file on GitHub/GitLab

## Common Workflows

### Starting Your Day
```vim
" 1. Open Neovim - see dashboard
nvim
" 2. Press 'r' on dashboard for recent files
" 3. Or press 'f' to find files
" 4. Or press '.' to browse files
```

### Quick File Edits
```vim
" 1. Open explorer in current directory
<leader>e
" 2. Type to filter files
config
" 3. Press Enter to open
" 4. Make edits
" 5. Delete buffer when done
<leader>bd
```

### Git Workflow
```vim
" 1. Check git status
<leader>gg
" 2. Stage changes (space)
" 3. Commit (c)
" 4. Push (P)
" 5. Exit (q)
```

### Terminal Tasks
```vim
" Run tests in floating terminal
<leader>tf
npm test<CR>

" Check git status quickly
<leader>tg

" Python debugging
<leader>tp
>>> import mymodule
>>> mymodule.test()
```

## Troubleshooting

**Explorer not opening**: Ensure Snacks is loaded - check `:Lazy` for status

**Dashboard not showing**: Check if you're opening a file directly - dashboard only shows when opening Neovim without arguments

**Terminal issues**: Make sure your shell is properly configured in your Neovim settings

**Notifications piling up**: Use `<leader>un` to dismiss all notifications

---

> **Remember**: Snacks.nvim is about small quality-of-life improvements that add up to a significantly better editing experience. Take time to learn the keybindings - they'll become muscle memory quickly!