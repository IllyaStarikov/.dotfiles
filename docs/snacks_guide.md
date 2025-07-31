# Snacks.nvim Reference

## Features

**Picker**: Live search (1000 result limit), frecency sorting, smart exclusions (.git, node_modules)  
**Dashboard**: Cached sections, instant actions, auto-keyed shortcuts (1-9, a-z)  
**Scrolling**: 120ms duration, 60ms repeat, smart buffer filtering  
**Terminal**: Instant opening, filetype detection, quick commands (git, python)

## Keybindings

### File Operations

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>ff` | Find Files | Blazing fast file search |
| `<leader>fF` | Find Files + Hidden | Include hidden files |
| `<leader>fr` | Recent Files | Quick access to recent files |
| `<leader>fg` | Live Grep | Real-time text search |
| `<leader>fG` | Live Grep + Hidden | Search in hidden files |
| `<leader>f/` | Grep Word | Search word under cursor |
| `<leader>f;` | Resume Picker | Continue last search |

### Specialized Pickers

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>fd` | Config Files | Search Neovim config |
| `<leader>fp` | Plugin Files | Search plugin directories |
| `<leader>fv` | Vim Runtime | Search Neovim runtime |
| `<leader>fj` | Jumps | Navigate jump list |
| `<leader>fm` | Marks | Quick mark navigation |
| `<leader>fq` | Quickfix | Navigate quickfix list |

### Scratch Buffers

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>.` | Toggle Scratch | General scratch buffer |
| `<leader>sn` | Notes Scratch | Dedicated notes buffer |
| `<leader>st` | Todo Scratch | Markdown todo buffer |
| `<leader>sc` | Code Scratch | Lua code buffer |

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
| `<leader>e` | Explorer | Open file explorer in current directory |
| `<leader>E` | Explorer (file dir) | Open explorer in current file's directory |

The Snacks file explorer is a modern, picker-based file browser that replaces traditional tree-style explorers like NERDTree. It provides:
- **Fast navigation**: Fuzzy search through files and directories
- **Preview support**: See file contents before opening
- **Multi-select**: Select multiple files with `<Tab>`
- **Integrated actions**: Create, rename, delete files without leaving the explorer

### Git

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>gg` | LazyGit | Full git interface |
| `<leader>gG` | LazyGit (file dir) | Git from file directory |
| `<leader>gb` | Git Blame | Blame current line |
| `<leader>gB` | Git Browse | Open in browser |
| `<leader>gf` | Git Files | Pick from git files |
| `<leader>gs` | Git Status | Pick from git status |
| `<leader>gc` | Git Commits | Browse commits |

### Buffers

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>bd` | Delete Buffer | Smart buffer deletion |
| `<leader>bD` | Delete All | Delete all buffers |
| `<leader>bo` | Delete Others | Keep only current |
| `<leader>bh` | Delete Hidden | Clean hidden buffers |
| `<leader>bu` | Delete Unnamed | Clean unnamed buffers |

### Toggles

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>tw` | Toggle Wrap | Line wrapping |
| `<leader>tS` | Toggle Spell | Spell checking |
| `<leader>tn` | Toggle Numbers | Line numbers |
| `<leader>tr` | Toggle Relative | Relative numbers |
| `<leader>ti` | Toggle Indent | Indent guides |
| `<leader>td` | Toggle Dim | Focus dimming |
| `<leader>tD` | Toggle Diagnostics | LSP diagnostics |

### Navigation

| Key | Action | Description |
|-----|--------|-------------|
| `[s` / `]s` | Prev/Next Scope | Navigate code scopes |
| `[S` / `]S` | Scope Edges | Jump to scope boundaries |
| `ii` / `ai` | Text Objects | Inner/around scope |

### Focus Mode

| Key | Action | Description |
|-----|--------|-------------|
| `<leader>z` | Zen Mode | Distraction-free coding |
| `<leader>Z` | Zen Zoom | Focus on current window |
| `<leader>sd` | Dashboard | Return to start screen |

## Performance

**Smart highlighting**: 100ms debounce, normal mode only, auto-fold opening  
**Status column**: Essential signs only, git integration, 100ms refresh  
**Big files**: 1MB threshold, auto-disable heavy features (syntax, spell, folds)  
**Exclusions**: .git, node_modules, __pycache__, build, dist, .next, .vscode  
**Animations**: 150ms duration, outQuart easing, smart buffer filtering

## Tips

- **Multi-select**: Use `<Tab>` in pickers
- **Quick grep**: `<leader>f/` greps word under cursor
- **Resume search**: `<leader>f;` continues last picker
- **Visual search**: Select text and use `<leader>fg`
- **Scope jumps**: Use `[s`/`]s` to jump between code blocks
- **Terminal git**: `<leader>tg` for instant git status