# 🍿 Snacks.nvim Power User Guide

## ⚡ Performance Optimizations Applied

### 🚀 **High-Speed Picker**
- **Live search** with 1000 result limit for instant feedback
- **Frecency boost** for recently/frequently used files
- **Smart exclusions**: `.git`, `node_modules`, cache files excluded
- **Optimized layouts**: 60% height, 80% width, minimal borders
- **Advanced keybindings**: `<C-j/k>` navigation, `<Tab>` multi-select

### 🎯 **Lightning Dashboard** 
- **Cached sections** with dynamic recent files
- **Instant actions** for common workflows
- **Minimal header** for fast loading
- **Auto-keyed shortcuts** (1-9, a-z, A-Z)

### 🎬 **Ultra-Smooth Scrolling**
- **120ms total duration** (vs 250ms default)
- **60ms repeat animation** for rapid scrolling
- **Smart buffer filtering** (skips huge files >10k lines)
- **Optimized easing**: `outQuart` for snappy feel

### 🖥️ **High-Performance Terminal**
- **No backdrop** for instant opening
- **Smart filetype** detection
- **Quick commands**: Git, Python, Node terminals
- **Fast navigation**: `<C-q>` to hide, `<C-\\>` normal mode

## 🎯 **Power User Keybindings**

### 📂 **File Operations**
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>ff` | Find Files | Blazing fast file search |
| `<leader>fF` | Find Files + Hidden | Include hidden files |
| `<leader>fr` | Recent Files | Quick access to recent files |
| `<leader>fg` | Live Grep | Real-time text search |
| `<leader>fG` | Live Grep + Hidden | Search in hidden files |
| `<leader>f/` | Grep Word | Search word under cursor |
| `<leader>f;` | Resume Picker | Continue last search |

### 🗂️ **Specialized Pickers**
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>fd` | Config Files | Search Neovim config |
| `<leader>fp` | Plugin Files | Search plugin directories |
| `<leader>fv` | Vim Runtime | Search Neovim runtime |
| `<leader>fj` | Jumps | Navigate jump list |
| `<leader>fm` | Marks | Quick mark navigation |
| `<leader>fq` | Quickfix | Navigate quickfix list |

### 📋 **Scratch Buffers**
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>.` | Toggle Scratch | General scratch buffer |
| `<leader>sn` | Notes Scratch | Dedicated notes buffer |
| `<leader>st` | Todo Scratch | Markdown todo buffer |
| `<leader>sc` | Code Scratch | Lua code buffer |

### 💻 **Terminal Commands**
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>tt` | Toggle Terminal | Main terminal |
| `<leader>tf` | Float Terminal | Floating terminal |
| `<leader>ts` | Split Terminal | Horizontal split |
| `<leader>tv` | VSplit Terminal | Vertical split |
| `<leader>tg` | Git Terminal | `git status` terminal |
| `<leader>tp` | Python Terminal | Python REPL |

### 🌐 **Git Integration**
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>gg` | LazyGit | Full git interface |
| `<leader>gG` | LazyGit (file dir) | Git from file directory |
| `<leader>gb` | Git Blame | Blame current line |
| `<leader>gB` | Git Browse | Open in browser |
| `<leader>gf` | Git Files | Pick from git files |
| `<leader>gs` | Git Status | Pick from git status |
| `<leader>gc` | Git Commits | Browse commits |

### 📦 **Buffer Management**
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>bd` | Delete Buffer | Smart buffer deletion |
| `<leader>bD` | Delete All | Delete all buffers |
| `<leader>bo` | Delete Others | Keep only current |
| `<leader>bh` | Delete Hidden | Clean hidden buffers |
| `<leader>bu` | Delete Unnamed | Clean unnamed buffers |

### ⚡ **Toggle Utilities**
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>tw` | Toggle Wrap | Line wrapping |
| `<leader>tS` | Toggle Spell | Spell checking |
| `<leader>tn` | Toggle Numbers | Line numbers |
| `<leader>tr` | Toggle Relative | Relative numbers |
| `<leader>ti` | Toggle Indent | Indent guides |
| `<leader>td` | Toggle Dim | Focus dimming |
| `<leader>tD` | Toggle Diagnostics | LSP diagnostics |

### 🎯 **Scope Navigation**
| Key | Action | Description |
|-----|--------|-------------|
| `[s` / `]s` | Prev/Next Scope | Navigate code scopes |
| `[S` / `]S` | Scope Edges | Jump to scope boundaries |
| `ii` / `ai` | Text Objects | Inner/around scope |

### 🧘 **Focus & Zen**
| Key | Action | Description |
|-----|--------|-------------|
| `<leader>z` | Zen Mode | Distraction-free coding |
| `<leader>Z` | Zen Zoom | Focus on current window |
| `<leader>sd` | Dashboard | Return to start screen |

## 🎨 **Visual Enhancements**

### 🌈 **Smart Highlighting**
- **100ms debounce** for instant reference highlighting
- **Normal mode only** for performance
- **Auto-fold opening** when navigating references

### 📊 **Status Column**
- **Essential signs only**: marks, LSP signs
- **Git integration**: GitSign, MiniDiffSign support
- **100ms refresh rate** for balanced performance

### 🎭 **Focus Features**
- **Subtle dimming** for non-active scopes
- **Smart filtering** (5-50 line scope range)
- **Performance optimized** for large files

## 🔧 **Performance Features**

### 📁 **Big File Handling**
- **1MB threshold** for big file detection
- **Auto-disable** heavy features (syntax, spell, folds)
- **Manual fold method** for large files

### 🗂️ **Smart Exclusions**
Automatically excludes performance-heavy directories:
- `.git`, `node_modules`, `__pycache__`
- `build`, `dist`, `.next`, `.vscode`
- `*.cache`, `*.log` files

### ⚡ **Optimized Animations**
- **150ms duration** for snappy feel
- **60fps smoothness** 
- **outQuart easing** for professional feel
- **Smart buffer filtering** for performance

## 🚀 **Pro Tips**

1. **Multi-select in pickers**: Use `<Tab>` to select multiple items
2. **Quick grep**: `<leader>f/` instantly greps word under cursor
3. **Resume search**: `<leader>f;` continues your last picker session
4. **Contextual explorer**: `<leader>E` opens explorer in file's directory
5. **Visual selection search**: Select text and use `<leader>fg` to grep it
6. **Terminal shortcuts**: `<leader>tg` for instant git status
7. **Smart notifications**: `<leader>nd` clears and shows history
8. **Scope navigation**: Use `[s`/`]s` to jump between code blocks

This configuration is optimized for **maximum speed and minimal distractions** while providing **power user workflows** for professional development!