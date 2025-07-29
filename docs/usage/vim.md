# Neovim Commands

## Daily Commands

```bash
EDITING                 NAVIGATION              AI ASSIST
v file     Open file    <l>ff    Find files    <l>cc    AI chat
:w         Save         <l>fg    Grep text     <l>co    Optimize
:q         Quit         <l>fb    Buffers       <l>ct    Gen tests
:wq        Save+quit    gd       Go to def     <l>ce    Explain
ZZ         Save+quit    gr       References    <l>cf    Fix bugs
<C-s>      Save         K        Hover docs    <l>ca    AI menu

PRODUCTIVITY           CODE OPS               DEBUGGING
<C-t>      Smart menu   <l>lf    Format       <l>db    Breakpoint
<l>z       Zen mode     <l>la    Actions      <l>dc    Continue
<l>te      Terminal     <l>lr    Rename       <l>di    Step into
<l>tg      LazyGit      <l>ld    Diagnostics  <l>do    Step over
<l>mp      Toggle MD    gI       Implement    <l>dr    REPL
```

## AI Commands

### Models
| Model | Shortcut | Strengths | API Key |
|-------|----------|-----------|---------|
| **Ollama** (Local) | `<leader>cal` | Privacy, Fast, No key needed | None |
| **Claude** (Anthropic) | `<leader>caa` | Best reasoning, Complex tasks | `ANTHROPIC_API_KEY` |
| **GPT-4** (OpenAI) | `<leader>cao` | Creative, Broad knowledge | `OPENAI_API_KEY` |
| **Copilot** (GitHub) | `<leader>cac` | Integrated, Real-time | Via Copilot.vim |

### AI Commands
| Command | Purpose | Mode | Example |
|---------|---------|------|---------|
| `<leader>cc` | Open AI chat | Normal/Visual | Ask any coding question |
| `<leader>ca` | Action palette | Normal/Visual | Show all AI actions |
| `<leader>co` | Optimize code | Visual | Select slow code → optimize |
| `<leader>ce` | Explain code | Visual | Select complex code → explain |
| `<leader>ct` | Generate tests | Visual | Select function → create tests |
| `<leader>cf` | Fix bugs | Visual | Select buggy code → fix |
| `<leader>cr` | Code review | Visual | Select code → review |
| `<leader>cm` | Add comments | Visual | Select code → document |
| `<leader>cl` | Toggle chat | Normal | Show/hide chat window |

### Chat Commands
```vim
/file           " Insert current file
/buffer         " Insert current buffer  
/symbols        " Browse and insert symbols
/fetch <url>    " Fetch and discuss URL content
/now            " Insert current date/time
/help           " Show all commands
```

## Context Menu

### Categories (`<C-t>` to open)
| Category | Key | Contains |
|----------|-----|----------|
| **Files** | `f` | Find, Recent, Browser, New |
| **Buffers** | `b` | List, Delete, Only, Close |
| **Code** | `c` | LSP actions, Format, Rename |
| **AI** | `a` | Chat, Actions, Models |
| **Git** | `g` | Status, Diff, Log, LazyGit |
| **Terminal** | `t` | New, LazyGit, Commands |
| **Settings** | `s` | Options, Plugins, Health |

### Menu Keys

```vim
<C-t>         " Context menu
<leader>m     " Main menu
<leader>M     " Mode-specific menu
<RightMouse>  " Menu at cursor
```

## Completion

### Triggers

- Automatic when typing
- `<C-Space>` manual trigger
- `.` or `->` for members
- `/` or `./` for paths

### Navigation

| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `<Tab>` | Accept completion | `<C-n>` | Next item |
| `<S-Tab>` | Previous item | `<C-p>` | Previous item |
| `<CR>` | Confirm selection | `<C-e>` | Cancel |
| `<C-f>` | Scroll docs down | `<C-b>` | Scroll docs up |

### Sources

1. LSP (highest priority)
2. Snippets (LuaSnip)
3. Path
4. Buffer

## LSP

### Commands
| Command | Purpose | Command | Purpose |
|---------|---------|---------|---------|
| `gd` | Go to definition | `gr` | Find references |
| `gD` | Go to declaration | `gI` | Go to implementation |
| `K` | Hover documentation | `<F2>` | Rename symbol |
| `<F4>` | Code actions | `gl` | Show diagnostics |
| `[d` | Previous diagnostic | `]d` | Next diagnostic |

### Language Servers
| Language | Server | Features |
|----------|--------|----------|
| **Python** | pyright | Type checking, IntelliSense, Refactoring |
| **C/C++** | clangd (LLVM) | Completion, Diagnostics, Formatting |
| **TypeScript/JS** | ts_ls | Full TS/JS support, JSX/TSX |
| **Lua** | lua_ls | Neovim API, Diagnostics |
| **Markdown** | marksman | Links, References, TOC |
| **LaTeX** | texlab | Completion, Build, Preview |
| **Rust** | rust_analyzer | Cargo integration, Inlay hints |
| **Go** | gopls | Modules, Formatting, Tests |

## File Navigation

### Picker
| Command | Purpose |
|---------|---------|
| `<leader>ff` | Find files |
| `<leader>fg` | Live grep |
| `<leader>fb` | Browse buffers |
| `<leader>fr` | Recent files |
| `<leader>fs` | Search symbols |
| `<leader>fh` | Command history |

### File Explorer
| Command | Purpose | Command | Purpose |
|---------|---------|---------|---------|
| `<leader>e` | Toggle tree | `a` | Create file |
| `d` | Delete | `r` | Rename |
| `x` | Cut | `c` | Copy |
| `p` | Paste | `y` | Copy name |

## Keybindings

### Window Management
| Command | Purpose | Command | Purpose |
|---------|---------|---------|---------|
| `<C-w>s` | Split horizontal | `<C-w>v` | Split vertical |
| `<C-w>q` | Close window | `<C-w>o` | Only window |
| `<C-h/j/k/l>` | Navigate windows | `<C-w>=` | Equal size |
| `<A-h/l>` | Resize horizontal | `<A-j/k>` | Resize vertical |

### Buffer Operations
| Command | Purpose | Command | Purpose |
|---------|---------|---------|---------|
| `<leader>bd` | Delete buffer | `<leader>bo` | Buffer only |
| `<S-h>` | Previous buffer | `<S-l>` | Next buffer |
| `<leader>bp` | Pin buffer | `<leader>bP` | Delete non-pinned |

### Text Objects & Motions
| Object | Meaning | Example |
|--------|---------|---------|
| `iw/aw` | Inner/around word | `ciw` - change word |
| `i"/a"` | Inner/around quotes | `di"` - delete in quotes |
| `i{/a{` | Inner/around braces | `va{` - select block |
| `ip/ap` | Inner/around paragraph | `dip` - delete paragraph |
| `it/at` | Inner/around tag | `cit` - change tag content |

## Debugging

### Debug Commands
| Command | Purpose | Command | Purpose |
|---------|---------|---------|---------|
| `<leader>db` | Toggle breakpoint | `<leader>dB` | Conditional break |
| `<leader>dc` | Start/Continue | `<leader>dC` | Run to cursor |
| `<leader>di` | Step into | `<leader>do` | Step over |
| `<leader>dO` | Step out | `<leader>dr` | Toggle REPL |
| `<leader>dl` | Run last | `<leader>dt` | Terminate |
| `<leader>dh` | Hover value | `<leader>dp` | Preview value |
| `<leader>df` | Frames (stack) | `<leader>ds` | Scopes |

### Debuggers

- Python: debugpy
- JavaScript/TypeScript: node2, chrome
- C/C++: lldb, gdb  
- Rust: lldb/gdb via CodeLLDB
- Go: delve
- Java: jdtls

## VimTeX for LaTeX

### Compilation & Preview
| Command | Purpose | Command | Purpose |
|---------|---------|---------|---------|
| `\ll` | Start compilation | `\lk` | Stop compilation |
| `\lv` | View PDF | `\lr` | Reverse search |
| `\le` | Show errors | `\lo` | Show output |
| `\lc` | Clean aux files | `\lC` | Full clean |
| `\lt` | Table of contents | `\li` | Info |

### LaTeX Text Objects
| Object | Meaning | Example |
|--------|---------|---------|
| `ic/ac` | Commands | `dic` - delete command |
| `id/ad` | Delimiters | `cad` - change with delims |
| `ie/ae` | Environments | `vie` - select env content |
| `i$/a$` | Math mode | `da$` - delete math |
| `iP/aP` | Sections | `vaP` - select section |

## Markview Markdown

### Markdown Rendering

| Feature | Description | Visual |
|---------|-------------|---------|
| **Headings** | Chevron-styled labels | ❯ H1, ❯❯ H2, ❯❯❯ H3 |
| **Code blocks** | Syntax highlighted with labels | Language indicators |
| **Tables** | Clean ASCII borders | Aligned columns |
| **Lists** | Elegant Unicode bullets | ◆ +list, ▸ -list, ★ *list |
| **Links** | Concealed with indicators | ◈ hyperlinks |
| **Bold/Italic** | Proper font styling | **bold**, *italic* |
| **Checkboxes** | Interactive toggles | ☐ todo, ✅ done |
| **Callouts** | Styled notes with emojis | ℹ️ NOTE, 💡 TIP, ⚡ WARNING |

### Markview Commands
| Command | Purpose |
|---------|---------|  
| `<leader>mp` | Toggle between rich preview and ligatures |
| Auto-enabled | For .md, .markdown, .qmd files |
| `conceallevel=2` | Rich preview mode (default) |
| `conceallevel=0` | Ligature mode (see raw markdown) |
| Insert mode | Auto-disables markview for editing |

### Smart Toggle Feature
- **Rich Preview Mode**: Beautiful rendering with concealment
- **Ligature Mode**: Raw markdown with Lilex font ligatures
- **Insert Mode**: Markview auto-disables for distraction-free editing
- **Normal Mode**: Markview auto-enables for rich preview
- Preserves your preference per buffer

## Theme & UI

### Theme Controls
| Command | Purpose |
|---------|---------|
| `:colorscheme` | Show current theme |
| `:Lazy load` | Reload theme plugins |
| System preference | Auto-switches dark/light |

### UI Features

- Automatic theme switching
- Animations (120ms)
- Indentation guides
- Git signs in gutter
- Diagnostic signs
- Breadcrumbs
- Statusline

## Productivity

### Snacks.nvim Suite
| Feature | Command | Description |
|---------|---------|-------------|
| Dashboard | Start Neovim | Recent files, projects |
| Terminal | `<leader>te` | Floating terminal |
| Git | `<leader>tg` | LazyGit integration |
| Zen Mode | `<leader>z` | Distraction-free |
| Notifications | Automatic | Alerts |
| Big File | Automatic | Large file handling |
| Rename | `<leader>lr` | Rename with preview |

### Session Management
| Command | Purpose |
|---------|---------|
| `:SessionSave` | Save current session |
| `:SessionLoad` | Load session |
| Auto-save | On exit if session exists |

### Marks & Registers
| Command | Purpose | Command | Purpose |
|---------|---------|---------|---------|
| `m{a-z}` | Set mark | `'{a-z}` | Jump to mark |
| `"ay` | Yank to reg a | `"ap` | Paste from a |
| `:marks` | List marks | `:reg` | List registers |

## Plugin Management

### Lazy.nvim Commands
| Command | Purpose |
|---------|---------|
| `:Lazy` | Open plugin manager |
| `:Lazy sync` | Update all plugins |
| `:Lazy install` | Install missing |
| `:Lazy clean` | Remove unused |
| `:Lazy profile` | Startup profiling |
| `:Lazy health` | Check plugin health |

### Key Plugins
- **lazy.nvim** - Plugin manager (45ms total startup)
- **blink.cmp** - Completions (<1ms response)
- **snacks.nvim** - Productivity suite
- **codecompanion.nvim** - AI integration
- **nvim-treesitter** - Syntax highlighting
- **mason.nvim** - LSP installer
- **vimtex** - LaTeX support
- **conform.nvim** - Formatting (stop_after_first)
- **nvim-dap** - Debugging
- **markview.nvim** - Beautiful markdown

## 💎 Formatting & Linting

### Conform.nvim Configuration
**Smart formatting with stop_after_first strategy**

| Language | Formatters | Priority Order |
|----------|------------|----------------|
| **Python** | isort, black | First available wins |
| **JavaScript/TypeScript** | prettier | Single formatter |
| **HTML/CSS** | prettier | Single formatter |
| **JSON/YAML** | prettier | Single formatter |
| **Markdown** | prettier | Single formatter |
| **Lua** | stylua | Single formatter |

### Format Commands
| Command | Purpose |
|---------|---------|
| `<leader>lf` | Format file/selection |
| `:ConformInfo` | Show active formatters |
| Auto-format | On save (500ms timeout) |

## Pro Tips

### Optimizations

1. Lazy loading
2. Compiled configs
3. Caching
4. Async operations

### Power User Techniques
```vim
" Quick macro recording
qa{commands}q  " Record to register a
@a             " Play macro
@@             " Repeat last macro

" Advanced search/replace
:%s/old/new/gc " Interactive replace
:g/pattern/d   " Delete matching lines
:v/pattern/d   " Delete non-matching

" Multiple cursors (via visual block)
<C-v>          " Visual block mode
I              " Insert at start
A              " Append at end
```

### Workflow Tips

1. Use `<C-t>` for context menus
2. Master text objects (`ciw`, `da{`, `vi"`)
3. Learn marks for navigation
4. Use AI for boilerplate
5. Use macros for repetitive edits
6. Toggle markdown with `<leader>mp`

## Troubleshooting

### Common Issues
| Problem | Solution |
|---------|----------|
| Slow startup | Run `:Lazy profile` to find culprit |
| No completions | Check `:LspStatus` and `:Lazy load blink.cmp` |
| Missing icons | Install Lilex: `brew install --cask font-lilex-nerd-font` |
| Ligatures not working | Toggle with `<leader>mp` or check font installation |
| LSP not working | Run `:LspInstallEssential` then restart |
| Plugin errors | `:Lazy clean` then `:Lazy sync` |
| Markdown ugly | Ensure Lilex font is installed |

### Health Checks
```vim
:checkhealth          " Full system check
:checkhealth lsp      " LSP specific
:checkhealth mason    " Package manager
:Lazy health          " Plugin health
:ConformInfo          " Formatter status
```

### Debug Commands
```vim
:LspInfo              " LSP server info
:LspLog               " LSP error log
:messages             " Vim messages
:Notifications        " Recent notifications
```

## Font & Rendering

### Lilex Nerd Font

- **Programming Ligatures**: `=>`, `->`, `::`, `!=`, `<=`, `>=`, `===`, `<=>`, `...`, `||`, `&&`, `<<`, `>>`, `|>`, `<|`
- **Icons**: Complete Nerd Font icon set for devicons, file types, git symbols
- **Size**: 18pt for optimal readability
- **Features**: Modern coding font with excellent ligature support and comprehensive symbol coverage

### Font Configuration
```lua
-- GUI settings (Neovide, VimR)
vim.opt.guifont = "Lilex Nerd Font:h18"

-- Terminal settings
-- Alacritty: Lilex Nerd Font
-- Size: 18.0
```

