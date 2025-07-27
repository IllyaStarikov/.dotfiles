# Neovim Usage Guide

## Command/Shortcut Reference Table

### Core Navigation & Editing
| Key | Action | Mode | Description |
|-----|--------|------|-------------|
| `<Space>` | Leader Key | Normal | Primary command prefix |
| `j/k` | Down/Up (wrapped) | Normal | Smart navigation on wrapped text |
| `0/$` | Start/End of wrapped line | Normal | Navigate wrapped lines properly |
| `<Tab>` | Next buffer | Normal | Cycle through open buffers |
| `<S-Tab>` | Previous buffer | Normal | Cycle backwards through buffers |
| `<leader>w` | Save file | Normal | Quick save |
| `<leader>q` | Quit | Normal | Quick quit |
| `<leader>x` | Save & quit | Normal | Save and exit |
| `<leader>c` | Close buffer | Normal | Smart buffer deletion |
| `<leader>d` | Delete without yank | Normal | Delete to black hole register |

### File Management & Search
| Key | Action | Mode | Description |
|-----|--------|------|-------------|
| `<C-p>` | Find files | Normal | Telescope file finder |
| `<leader>ff` | Find files | Normal | Modern file search |
| `<leader>fF` | Find files + hidden | Normal | Include hidden files |
| `<leader>fr` | Recent files | Normal | Quick access to recent |
| `<leader>fg` | Live grep | Normal | Real-time text search |
| `<leader>fG` | Live grep + hidden | Normal | Search in hidden files |
| `<leader>f/` | Grep word under cursor | Normal | Quick word search |
| `<leader>f;` | Resume last picker | Normal | Continue last search |
| `<leader>o` | Open Oil file manager | Normal | Directory navigation |
| `-` | Open Oil | Normal | Quick file browser |
| `<leader>n` | Toggle NERDTree | Normal | File tree (fallback) |

### Window Management
| Key | Action | Mode | Description |
|-----|--------|------|-------------|
| `<up/down/left/right>` | Navigate windows | Normal | Arrow key navigation |
| `<C-h/j/k/l>` | Smart window navigation | Normal | Vim/tmux aware |
| `<leader>z` | Zen mode | Normal | Distraction-free coding |
| `<leader>Z` | Zen zoom | Normal | Focus current window |

### Git Integration
| Key | Action | Mode | Description |
|-----|--------|------|-------------|
| `<leader>gg` | LazyGit | Normal | Full git interface |
| `<leader>gb` | Git blame | Normal | Blame current line |
| `<leader>gB` | Git browse | Normal | Open in browser |
| `<leader>gf` | Git files | Normal | Browse git files |
| `<leader>gs` | Git status | Normal | Pick from git status |
| `<leader>gc` | Git commits | Normal | Browse commit history |

### AI Assistant (CodeCompanion)
| Key | Action | Mode | Description |
|-----|--------|------|-------------|
| `<leader>cc` | Open chat | Normal/Visual | AI chat interface |
| `<leader>ca` | Action palette | Normal/Visual | Available AI actions |
| `<leader>ci` | Inline assistance | Normal/Visual | Context-aware help |
| `<leader>cr` | Code review | Visual | Review selected code |
| `<leader>co` | Optimize code | Visual | Improve performance |
| `<leader>cm` | Add comments | Visual | Document code |
| `<leader>ct` | Generate tests | Visual | Create unit tests |
| `<leader>ce` | Explain code | Visual | Understand code |
| `<leader>cf` | Fix bugs | Visual | Debug assistance |

### Snacks.nvim Power Features
| Key | Action | Mode | Description |
|-----|--------|------|-------------|
| `<leader>.` | Scratch buffer | Normal | Toggle scratch pad |
| `<leader>tt` | Terminal | Normal | Toggle terminal |
| `<leader>tf` | Float terminal | Normal | Floating terminal |
| `<leader>sd` | Dashboard | Normal | Start screen |
| `<leader>bd` | Delete buffer | Normal | Smart buffer deletion |
| `<leader>bD` | Delete all buffers | Normal | Clear all buffers |
| `<leader>bo` | Delete other buffers | Normal | Keep only current |

### LaTeX Integration (VimTeX)
| Key | Action | Mode | Description |
|-----|--------|------|-------------|
| `<leader>ll` | Toggle compilation | Normal | Start/stop LaTeX compile |
| `<leader>lv` | View PDF | Normal | Open PDF viewer |
| `<leader>lk` | Clean aux files | Normal | Remove build files |
| `<leader>lt` | Toggle TOC | Normal | Table of contents |
| `<leader>le` | Show errors | Normal | LaTeX error list |

### Debugging (DAP)
| Key | Action | Mode | Description |
|-----|--------|------|-------------|
| `<leader>db` | Toggle breakpoint | Normal | Set/unset breakpoint |
| `<leader>dc` | Continue | Normal | Start/continue debug |
| `<leader>ds` | Step over | Normal | Debug step over |
| `<leader>di` | Step into | Normal | Debug step into |
| `<leader>do` | Step out | Normal | Debug step out |
| `<leader>du` | Toggle DAP UI | Normal | Debug interface |

### Toggle Utilities
| Key | Action | Mode | Description |
|-----|--------|------|-------------|
| `<leader>tw` | Toggle wrap | Normal | Line wrapping |
| `<leader>tS` | Toggle spell | Normal | Spell checking |
| `<leader>tn` | Toggle numbers | Normal | Line numbers |
| `<leader>tr` | Toggle relative | Normal | Relative numbers |
| `<leader>ti` | Toggle indent guides | Normal | Indent visualization |
| `<leader>td` | Toggle dim | Normal | Focus dimming |
| `<leader>tD` | Toggle diagnostics | Normal | LSP diagnostics |

### Menu System
| Key | Action | Mode | Description |
|-----|--------|------|-------------|
| `<C-t>` | Context menu | Normal | Smart context-aware menu |
| `<leader>m` | Main menu | Normal | All menu categories |
| `<leader>M` | Context menu | Normal | Context-specific menu |
| `<RightMouse>` | Context menu | Normal | Menu at mouse position |

## Quick Reference

### Essential Commands
- `:W`, `:Q`, `:Wq` - Common typo corrections automatically mapped
- `:Lazy` - Plugin manager interface
- `:Mason` - LSP server manager
- `:Telescope` - Fuzzy finder commands
- `:CodeCompanion` - AI assistant commands

### Visual Mode Operations
- `J/K` - Move selected lines up/down
- `</>` - Indent/outdent (stays in visual mode)
- `p` - Paste without yanking deleted text
- `ga` - EasyAlign text alignment

### Insert Mode Shortcuts
- `<Down>/<Up>` - Navigate wrapped lines properly
- `<C-o>` prefix - Execute normal mode command

### Terminal Mode
- `<Esc>` - Exit terminal mode to normal mode
- `<leader>tt` - Quick terminal toggle

## About

This Neovim configuration is a modern, performance-optimized setup built entirely in Lua. It features:

- **Lightning-fast startup** with lazy loading
- **AI-powered coding** via CodeCompanion with multiple LLM support
- **Smart completion** using Blink.cmp for ultra-fast LSP integration
- **Quality of life** improvements via Snacks.nvim
- **Professional LaTeX** environment with VimTeX
- **Integrated debugging** with nvim-dap
- **Dynamic theming** that follows macOS appearance

## Additional Usage Info

### Plugin Ecosystem
The configuration uses lazy.nvim for plugin management, ensuring optimal startup performance through lazy loading and bytecode compilation.

### LSP Configuration
Language servers are automatically installed and configured via Mason. Supported languages include:
- TypeScript/JavaScript (tsserver)
- Python (pyright)
- Lua (lua_ls)
- Rust (rust_analyzer)
- Go (gopls)
- And many more...

### AI Integration
CodeCompanion supports multiple AI providers:
- Local Ollama (default, no API key needed)
- Anthropic Claude (set ANTHROPIC_API_KEY)
- OpenAI GPT (set OPENAI_API_KEY)
- GitHub Copilot (uses existing auth)

### Performance Features
- Sub-100ms startup time
- Smart file exclusions for large files
- Optimized syntax highlighting
- Efficient buffer management
- Cached completion results

## Further Command Explanations

### Snacks.nvim Commands
The Snacks plugin provides a comprehensive suite of utilities:
- **Dashboard**: Fast startup screen with recent files and quick actions
- **Picker**: High-performance file search with frecency tracking
- **Terminal**: Instant terminal access with smart keybindings
- **Git**: LazyGit integration for visual git operations
- **Buffers**: Smart buffer management with cleanup utilities

### Telescope Advanced Usage
- Use `<Tab>` in pickers to select multiple items
- `<C-q>` sends results to quickfix list
- `<C-x>` opens selection in horizontal split
- `<C-v>` opens selection in vertical split
- `<C-t>` opens selection in new tab

### Oil.nvim File Management
- `-` opens Oil in current file's directory
- `g?` shows help in Oil buffer
- `<CR>` opens file/enters directory
- `-` goes up one directory
- `g.` toggles hidden files

## Theory & Background

### Vi Mode Philosophy
The configuration maintains Vim's modal editing philosophy while adding modern conveniences. The vi-mode is deeply integrated, with consistent keybindings across all contexts.

### Lazy Loading Strategy
Plugins are loaded only when needed:
- UI plugins load on specific events
- Syntax plugins load on file type detection
- Heavy plugins load on first command usage

### Theme Integration
The configuration automatically detects macOS light/dark mode and switches themes accordingly. This extends to:
- Neovim colorscheme
- Terminal colors
- Git diff highlighting
- UI element contrast

## Good to Know / Lore / History

### Evolution from Vimscript
This configuration represents a complete migration from Vimscript to Lua (completed July 2025), modernizing a setup that evolved over many years.

### Plugin Choices
- **Telescope over FZF**: Better Neovim integration and Lua performance
- **Blink.cmp over nvim-cmp**: 10x faster completion engine
- **Snacks over multiple plugins**: Unified, optimized plugin suite
- **Oil over traditional explorers**: Edit directories like buffers

### Performance Milestones
- Original Vimscript config: ~300ms startup
- Initial Lua migration: ~150ms startup
- Current optimized config: <100ms startup

### Hidden Features
- The menu system (`<C-t>`) adapts based on context
- Scratch buffers persist between sessions
- Git integration includes GitHub CLI support
- Debug configurations support multiple languages
- Theme switching affects the entire terminal ecosystem

### Pro Tips
1. Use `<leader>.` for quick notes that persist
2. Visual mode + AI commands = instant code improvement
3. `<C-t>` in any context shows relevant actions
4. Telescope resume (`<leader>f;`) maintains search state
5. Oil.nvim lets you rename files with standard Vim commands