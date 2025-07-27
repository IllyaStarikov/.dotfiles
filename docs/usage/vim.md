# Neovim Reference

## Daily Commands
```
FILES                   TEXT                    CODE
<leader>ff Find file    ciw Change word        <leader>la Code action
<leader>fg Grep text    yy  Copy line          <leader>lf Format
<leader>fr Recent       dd  Delete line        gd  Go to definition
<leader>fb Buffers      p   Paste              K   Show docs
:w  Save               u   Undo               <leader>lr Rename
:q  Quit               .   Repeat             <leader>ld Diagnostics

GIT                    AI                      NAVIGATION
<leader>gg LazyGit     <leader>cc Chat        Ctrl+o Back
<leader>gb Blame       <leader>ca Actions     Ctrl+i Forward
<leader>gd Diff        <leader>ci Inline      gg Top
<leader>gs Status      <leader>cr Review      G  Bottom
]g  Next change        <leader>ce Explain     *  Search word
[g  Prev change        <leader>cf Fix         n  Next match
```

## Navigation

| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `h/j/k/l` | ←/↓/↑/→ | `0/$` | Line start/end |
| `w/b` | Word →/← | `^` | First char |
| `W/B` | WORD →/← | `gg/G` | File top/bottom |
| `e/ge` | Word end →/← | `{/}` | Paragraph ↑/↓ |
| `f{char}` | Find → char | `%` | Matching bracket |
| `F{char}` | Find ← char | `H/M/L` | Screen top/mid/bot |
| `t{char}` | Till → char | `Ctrl+d/u` | Half page ↓/↑ |
| `T{char}` | Till ← char | `Ctrl+f/b` | Full page ↓/↑ |

## Editing

| Command | Action | Command | Action |
|---------|--------|---------|--------|
| `i/a` | Insert before/after | `I/A` | Insert line start/end |
| `o/O` | New line below/above | `r` | Replace char |
| `x/X` | Delete char →/← | `s` | Substitute char |
| `dd` | Delete line | `D` | Delete to line end |
| `cc` | Change line | `C` | Change to line end |
| `yy` | Yank line | `Y` | Yank line |
| `p/P` | Paste after/before | `u/Ctrl+r` | Undo/Redo |
| `.` | Repeat last | `J` | Join lines |

## Text Objects

| Object | Meaning | Example | Object | Meaning | Example |
|--------|---------|---------|---|--------|---------|---------|
| `iw/aw` | inner/a word | `diw` | `i"/a"` | inner/around " | `ci"` |
| `iW/aW` | inner/a WORD | `daW` | `i'/a'` | inner/around ' | `ya'` |
| `is/as` | inner/a sentence | `dis` | `` i`/a` `` | inner/around ` | `` di` `` |
| `ip/ap` | inner/a paragraph | `yap` | `i(/a(` | inner/around () | `da(` |
| `it/at` | inner/a tag | `cit` | `i{/a{` | inner/around {} | `ci{` |
| `ib/ab` | inner/a block | `dab` | `i[/a[` | inner/around [] | `ya[` |

## Search & Replace

| Command | Action | Command | Action |
|---------|--------|---------|--------|
| `/pattern` | Search forward | `?pattern` | Search backward |
| `n/N` | Next/prev match | `*/#` | Search word →/← |
| `gn` | Next match + select | `gN` | Prev match + select |
| `:s/old/new/` | Replace line | `:%s/old/new/g` | Replace all |
| `:s/old/new/gc` | Replace confirm | `&` | Repeat substitution |
| `<leader>/` | Buffer search | `<leader>sr` | Search & replace |

## Files & Buffers

| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `<leader>ff` | Find files | `<leader>fr` | Recent files |
| `<leader>fg` | Grep files | `<leader>fb` | List buffers |
| `<leader>fn` | New file | `<leader>fs` | Save file |
| `<Tab>` | Next buffer | `<S-Tab>` | Prev buffer |
| `<leader>c` | Close buffer | `<leader>C` | Force close |
| `:e file` | Edit file | `:b name` | Switch buffer |
| `:ls` | List buffers | `:b#` | Toggle buffer |

## Windows & Tabs

| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `<C-w>v` | Vertical split | `<C-w>s` | Horizontal split |
| `<C-w>c` | Close window | `<C-w>o` | Close others |
| `<C-h/j/k/l>` | Navigate windows | `<C-w>w` | Cycle windows |
| `<C-w>H/J/K/L` | Move window | `<C-w>=` | Equal size |
| `<C-w></>` | Width -/+ | `<C-w>-/+` | Height -/+ |
| `<leader>sv` | Split vertical | `<leader>sh` | Split horizontal |
| `:tabnew` | New tab | `gt/gT` | Next/prev tab |

## LSP Commands

| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `gd` | Go to definition | `gD` | Go to declaration |
| `gr` | Find references | `gi` | Go to implementation |
| `gy` | Go to type def | `K` | Show hover docs |
| `<leader>la` | Code actions | `<leader>lr` | Rename |
| `<leader>lf` | Format | `<leader>li` | LSP info |
| `<leader>ld` | Diagnostics | `<leader>ll` | Line diagnostics |
| `]d/[d` | Next/prev diagnostic | `<leader>lq` | Quickfix list |

## AI Assistant

| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `<leader>cc` | Open chat | `<leader>ci` | Inline assist |
| `<leader>ca` | Actions menu | `<leader>cr` | Code review |
| `<leader>ce` | Explain code | `<leader>cf` | Fix bugs |
| `<leader>co` | Optimize | `<leader>ct` | Generate tests |
| `<leader>cm` | Add comments | `<leader>cd` | Generate docs |
| `<leader>cs` | Stop generation | `<leader>cl` | Toggle chat |

### AI Adapters
| Key | Adapter | Key | Adapter |
|-----|---------|---|-----|---------|
| `<leader>cal` | Local Ollama | `<leader>caa` | Anthropic Claude |
| `<leader>cao` | OpenAI | `<leader>cac` | GitHub Copilot |

## Git Integration

| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `<leader>gg` | LazyGit | `<leader>gs` | Git status |
| `<leader>gb` | Blame line | `<leader>gB` | Blame buffer |
| `<leader>gd` | Diff this | `<leader>gD` | Diff view |
| `]g/[g` | Next/prev hunk | `<leader>gp` | Preview hunk |
| `<leader>gr` | Reset hunk | `<leader>gR` | Reset buffer |
| `<leader>gu` | Undo stage | `<leader>gS` | Stage buffer |

## Terminal

| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `<C-\>` | Toggle terminal | `<leader>tt` | Terminal below |
| `<leader>tv` | Terminal right | `<C-w>N` | Terminal normal mode |
| `<Esc><Esc>` | Exit terminal | `:term` | New terminal |

## Folding

| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `za` | Toggle fold | `zo/zc` | Open/close fold |
| `zR/zM` | Open/close all | `zj/zk` | Next/prev fold |
| `zd` | Delete fold | `zE` | Delete all folds |

## Marks & Jumps

| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `m{a-z}` | Set local mark | `m{A-Z}` | Set global mark |
| `'{mark}` | Jump to mark line | `` `{mark}`` | Jump to mark pos |
| `''` | Last jump line | ``` `` ``` | Last jump pos |
| `<C-o>` | Jump back | `<C-i>` | Jump forward |
| `:jumps` | List jumps | `:marks` | List marks |

## Macros & Registers

| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `q{reg}` | Record macro | `q` | Stop recording |
| `@{reg}` | Play macro | `@@` | Repeat macro |
| `"{reg}y` | Yank to register | `"{reg}p` | Paste from register |
| `:reg` | List registers | `"+` | System clipboard |
| `"0` | Yank register | `"1-9` | Delete registers |

## Visual Mode

| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `v` | Char visual | `V` | Line visual |
| `<C-v>` | Block visual | `gv` | Reselect |
| `o/O` | Other end | `I/A` | Insert start/end |
| `>/<` | Indent/dedent | `=` | Auto indent |
| `u/U` | Lower/uppercase | `~` | Toggle case |

## Plugin Commands

### Telescope
| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `<leader>ff` | Find files | `<leader>fg` | Live grep |
| `<leader>fb` | Buffers | `<leader>fh` | Help tags |
| `<leader>fo` | Old files | `<leader>fc` | Commands |
| `<leader>fk` | Keymaps | `<leader>fs` | Git status |
| `<leader>gc` | Git commits | `<leader>gC` | Git branches |

### LazyGit
| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `<leader>gg` | Open LazyGit | `q` | Quit |
| `?` | Help | `x` | Menu |
| `<space>` | Stage | `d` | Delete |
| `c` | Commit | `p` | Pull |
| `P` | Push | `<tab>` | Switch panel |

### Snacks.nvim
| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `<leader>sd` | Dashboard | `<leader>sD` | Force dashboard |
| `<leader>.` | Toggle scratch | `<leader>S` | Select scratch |
| `<leader>sn` | Notes scratch | `<leader>st` | Todo scratch |
| `<leader>sc` | Code scratch | `<leader>e` | Explorer |
| `<leader>E` | Explorer (file dir) | `<leader>N` | NERDTree fallback |
| `<leader>z` | Zen mode | `<leader>Z` | Zoom window |
| `<leader>bd` | Delete buffer | `<leader>bD` | Delete all buffers |
| `<leader>bo` | Delete others | `<leader>bh` | Delete hidden |
| `<leader>bu` | Delete unnamed | `<leader>rn` | Rename file |
| `<leader>un` | Dismiss notifications | `<leader>nh` | Notification history |
| `<leader>nd` | Clear & show history | `<leader>pp` | Profiler pick |
| `<leader>pP` | Profiler scratch | `<leader>pd` | Debug inspect |
| `<leader>pD` | Debug backtrace | `<leader>vh` | Next reference |
| `<leader>vH` | Prev reference | `[s/]s` | Prev/next scope |
| `[S/]S` | Prev/next scope edge | |

### DAP (Debugging)
| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `<F5>` | Continue | `<F10>` | Step over |
| `<F11>` | Step into | `<F12>` | Step out |
| `<leader>db` | Toggle breakpoint | `<leader>dB` | Conditional break |
| `<leader>dr` | Open REPL | `<leader>dl` | Run last |
| `<leader>du` | Toggle UI | `<leader>dt` | Terminate |

### Menu System
| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `<C-t>` | Context menu | `<leader>m` | Main menu |
| `<leader>mf` | File menu | `<leader>mg` | Git menu |
| `<leader>mc` | Code menu | `<leader>ma` | AI menu |
| `<RightMouse>` | Mouse menu | `q` | Close menu |

## Commands

| Command | Action | Command | Action |
|---------|--------|---------|--------|
| `:Lazy` | Plugin manager | `:Mason` | LSP installer |
| `:LspInfo` | LSP status | `:Telescope` | Fuzzy finder |
| `:Neotree` | File tree | `:LazyGit` | Git UI |
| `:CodeCompanion` | AI chat | `:TodoTelescope` | Find TODOs |
| `:checkhealth` | Health check | `:messages` | Show messages |

## Settings

| Command | Action | Command | Action |
|---------|--------|---------|--------|
| `:set nu!` | Toggle numbers | `:set wrap!` | Toggle wrap |
| `:set paste!` | Toggle paste | `:set list!` | Toggle whitespace |
| `:set ic!` | Toggle ignorecase | `:set hls!` | Toggle highlight |
| `:syntax on/off` | Toggle syntax | `:noh` | Clear highlight |

## Tips
- `<leader>` = Space
- `jk` or `kj` = Escape in insert mode
- `.` repeats last change
- `u` undo, `Ctrl+r` redo
- `:w !sudo tee %` to save with sudo
- `:%s//new/g` replaces last search
- `cgn` to change next search match
- `q:` for command history
- `@:` to repeat last command