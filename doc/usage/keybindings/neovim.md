# Neovim Keybindings

> **Complete keybinding reference for Neovim**

## Leader Key: `Space`

## Navigation

### File Navigation

| Keys | Action | Context |
|------|--------|---------|
| `<leader>ff` | Find files | Telescope |
| `<leader>fF` | Find files (hidden) | Include hidden files |
| `<leader>fg` | Live grep | Search in files |
| `<leader>fG` | Live grep (hidden) | Include hidden files |
| `<leader>fb` | Browse buffers | Open buffers |
| `<leader>fr` | Recent files | History |
| `<leader>fs` | Search symbols | LSP symbols |
| `<leader>fh` | Help tags | Vim help |
| `<leader>fc` | Commands | Command palette |
| `<leader>fk` | Keymaps | Browse keymaps |
| `<leader>fp` | Plugin files | Browse plugins |
| `<leader>fd` | Config files | Neovim config |
| `<leader>f/` | Grep word | Under cursor |
| `<leader>f:` | Command history | Recent commands |
| `<leader>f;` | Resume | Last picker |
| `<leader>fj` | Jumplist | Navigation history |
| `<leader>fm` | Marks | All marks |
| `<leader>fq` | Quickfix | Quickfix list |
| `<leader>fl` | Location list | Location list |
| `<C-p>` | Quick find files | Alternative to `<leader>ff` |

### Code Navigation

| Keys | Action | Mode |
|------|--------|------|
| `gd` | Go to definition | Normal |
| `gD` | Go to declaration | Normal |
| `gi` | Go to implementation | Normal |
| `gr` | Find references | Normal |
| `gt` | Go to type definition | Normal |
| `K` | Hover documentation | Normal |
| `[d` | Previous diagnostic | Normal |
| `]d` | Next diagnostic | Normal |

### Buffer Navigation

| Keys | Action |
|------|--------|
| `<S-h>` | Previous buffer |
| `<S-l>` | Next buffer |
| `<Tab>` | Next buffer |
| `<S-Tab>` | Previous buffer |
| `[b` | Previous buffer |
| `]b` | Next buffer |
| `<leader>bd` | Delete buffer |
| `<leader>bD` | Delete all buffers |
| `<leader>bo` | Delete other buffers |

### Window Management

| Keys | Action |
|------|--------|
| `<C-h>` | Navigate left |
| `<C-j>` | Navigate down |
| `<C-k>` | Navigate up |
| `<C-l>` | Navigate right |
| `<C-w>s` | Split horizontal |
| `<C-w>v` | Split vertical |
| `<C-w>q` | Close window |
| `<C-w>=` | Equal size |
| `<A-h>` | Resize left |
| `<A-l>` | Resize right |
| `<A-j>` | Resize down |
| `<A-k>` | Resize up |

## Editing

### Text Manipulation

| Keys | Action | Mode |
|------|--------|------|
| `<leader>/` | Toggle comment | Normal/Visual |
| `gcc` | Comment line | Normal |
| `gc` | Comment motion | Normal |
| `<leader>f` | Format file/selection | Normal/Visual |
| `<leader>rn` | Rename symbol | Normal |
| `J` | Join lines | Normal |
| `<A-j>` | Move line down | Normal/Insert |
| `<A-k>` | Move line up | Normal/Insert |

### Surround Operations

| Keys | Action | Example |
|------|--------|---------|
| `ys{motion}{char}` | Add surround | `ysiw"` - surround word with quotes |
| `ds{char}` | Delete surround | `ds"` - delete quotes |
| `cs{old}{new}` | Change surround | `cs"'` - change quotes to single |

### Multiple Cursors

| Keys | Action |
|------|--------|
| `<C-n>` | Select word/next occurrence |
| `<C-x>` | Skip occurrence |
| `<C-p>` | Previous occurrence |

## Code Actions

### LSP Actions

| Keys | Action |
|------|--------|
| `<leader>la` | Code actions |
| `<leader>lf` | Format |
| `<leader>li` | LSP info |
| `<leader>lj` | Next diagnostic |
| `<leader>lk` | Previous diagnostic |
| `<leader>ll` | Code lens |
| `<leader>lr` | Rename |
| `<leader>ls` | Document symbols |
| `<leader>lS` | Workspace symbols |

### AI Assistant

| Keys | Action | Mode |
|------|--------|------|
| `<leader>cc` | Open chat | Normal/Visual |
| `<leader>ca` | AI actions menu | Normal/Visual |
| `<leader>ce` | Explain code | Visual |
| `<leader>co` | Optimize code | Visual |
| `<leader>ct` | Generate tests | Visual |
| `<leader>cf` | Fix bugs | Visual |
| `<leader>cr` | Code review | Visual |
| `<leader>cm` | Add comments | Visual |
| `<leader>ci` | Inline assist | Normal/Visual |

## Debugging

| Keys | Action |
|------|--------|
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint |
| `<leader>dc` | Continue/Start |
| `<leader>di` | Step into |
| `<leader>do` | Step over |
| `<leader>dO` | Step out |
| `<leader>dr` | Toggle REPL |
| `<leader>dl` | Run last |
| `<leader>dt` | Terminate |
| `<leader>du` | Toggle UI |

## Git Integration

| Keys | Action |
|------|--------|
| `<leader>gg` | LazyGit |
| `<leader>gG` | LazyGit (file dir) |
| `<leader>gb` | Git blame line |
| `<leader>gB` | Git browse |
| `<leader>gf` | Git files (Telescope) |
| `<leader>gs` | Git status (Telescope) |
| `<leader>gc` | Git commits (Telescope) |
| `<leader>gC` | Buffer commits (Telescope) |
| `[c` | Previous hunk |
| `]c` | Next hunk |
| `<leader>hs` | Stage hunk |
| `<leader>hr` | Reset hunk |
| `<leader>hp` | Preview hunk |

## UI Toggles

| Keys | Action |
|------|--------|
| `<leader>e` | File explorer (Snacks) |
| `<leader>E` | Explorer (current file dir) |
| `<leader>o` | Open file explorer |
| `<leader>O` | Explorer (float) |
| `-` | Open file explorer |
| `<leader>.` | Toggle scratch buffer |
| `<leader>S` | Select scratch buffer |
| `<leader>sd` | Dashboard |
| `<leader>z` | Toggle Zen mode |
| `<leader>Z` | Zen zoom |
| `<leader>tw` | Toggle wrap |
| `<leader>tS` | Toggle spell |
| `<leader>un` | Dismiss notifications |
| `<leader>nh` | Notification history |
| `<C-t>` | Context menu |

## Terminal

| Keys | Action |
|------|--------|
| `<leader>tt` | Toggle terminal |
| `<leader>tf` | Float terminal |
| `<leader>ts` | Split terminal |
| `<leader>tv` | Vertical terminal |
| `<leader>tg` | Git status terminal |
| `<leader>tp` | Python terminal |
| `<leader>tn` | Node terminal |
| `<C-\><C-n>` | Exit terminal mode |

## Search & Replace

| Keys | Action |
|------|--------|
| `/` | Search forward |
| `?` | Search backward |
| `*` | Search word under cursor |
| `#` | Search word backward |
| `n` | Next match |
| `N` | Previous match |
| `<leader>sr` | Search and replace |
| `<leader>sw` | Search word |

## Marks & Registers

| Keys | Action |
|------|--------|
| `m{a-z}` | Set local mark |
| `m{A-Z}` | Set global mark |
| `'{mark}` | Jump to mark |
| `"` | Register prefix |
| `"+` | System clipboard |
| `"0` | Yank register |

## Completion (Insert Mode)

| Keys | Action |
|------|--------|
| `<Tab>` | Accept/Next |
| `<S-Tab>` | Previous |
| `<C-n>` | Next item |
| `<C-p>` | Previous item |
| `<C-y>` | Confirm |
| `<C-e>` | Cancel |
| `<C-Space>` | Trigger manually |
| `<C-f>` | Scroll docs down |
| `<C-b>` | Scroll docs up |

## Special Modes

### Visual Mode

| Keys | Action |
|------|--------|
| `v` | Character-wise |
| `V` | Line-wise |
| `<C-v>` | Block-wise |
| `gv` | Reselect |
| `o` | Other end |
| `>` | Indent |
| `<` | Unindent |

### Command Mode

| Keys | Action |
|------|--------|
| `:` | Command mode |
| `<C-p>` | Previous command |
| `<C-n>` | Next command |
| `<C-a>` | Beginning |
| `<C-e>` | End |

## Quick Actions

| Keys | Action |
|------|--------|
| `<C-s>` | Save file |
| `<leader>q` | Quit |
| `<leader>w` | Save |
| `<leader>wa` | Save all |
| `<leader>qq` | Quit all |
| `ZZ` | Save and quit |
| `ZQ` | Quit without saving |

---

<p align="center">
  <a href="README.md">← Back to Keybindings</a>
</p>