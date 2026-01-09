# Neovim Keybindings

> **Complete keybinding reference for Neovim**

## Leader Key: `Space`

All custom commands use the Space key as leader. Keybindings are organized by prefix.

## Leader Key Prefixes

| Prefix | Category |
|--------|----------|
| `<leader>a` | AI (CodeCompanion) |
| `<leader>b` | Buffer |
| `<leader>c` | Code (symbols, LSP, run) |
| `<leader>d` | Debug (DAP) |
| `<leader>e` | Editor (zen, toggles) |
| `<leader>f` | Find (Telescope) |
| `<leader>g` | Git |
| `<leader>l` | Language (filetype-specific) |
| `<leader>n` | Notes (scratch, notifications) |
| `<leader>o` | Open (explorer, terminal) |
| `<leader>q` | Quickfix |
| `<leader>w` | Window |

---

## AI (`<leader>a`)

| Keys | Action |
|------|--------|
| `<leader>ac` | Chat |
| `<leader>aa` | Actions palette |
| `<leader>ai` | Inline assistance |
| `<leader>ae` | Explain code (visual) |
| `<leader>ar` | Review code (visual) |
| `<leader>ao` | Optimize code (visual) |
| `<leader>af` | Fix bug (visual) |
| `<leader>at` | Generate tests (visual) |
| `<leader>am` | Add comments (visual) |
| `<leader>an` | New chat |
| `<leader>al` | Toggle chat |
| `<leader>as` | Stop |
| `<leader>a1` | Small model |
| `<leader>a2` | Medium model |
| `<leader>a3` | Large model |
| `<leader>a?` | List models |
| `<leader>aM` | Use MLX (macOS) |
| `<leader>aO` | Use Ollama (macOS) |
| `<leader>aX` | Start MLX server (macOS) |

## Buffer (`<leader>b`)

| Keys | Action |
|------|--------|
| `<leader>bd` | Delete buffer |
| `<leader>bD` | Delete all buffers |
| `<leader>bo` | Delete other buffers |
| `<leader>bb` | List buffers |
| `<leader>b1-9` | Go to buffer 1-9 |

## Code (`<leader>c`)

| Keys | Action |
|------|--------|
| `<leader>cr` | Run file |
| `<leader>cm` | Make (pick target) |
| `<leader>cM` | Make (default) |
| `<leader>cs` | Symbol outline |
| `<leader>cS` | Symbol navigator |
| `<leader>cn` | Next symbol |
| `<leader>cp` | Previous symbol |
| `<leader>cN` | Next symbol (parent) |
| `<leader>cP` | Previous symbol (parent) |
| `<leader>cg` | Go to symbol |
| `<leader>cf` | Find symbols |
| `<leader>ca` | Code action |
| `<leader>cR` | Rename |
| `<leader>ch` | Hover |
| `<leader>cd` | Go to definition |
| `<leader>cD` | Go to declaration |
| `<leader>ci` | Go to implementation |
| `<leader>ct` | Go to type definition |

## Debug (`<leader>d`)

| Keys | Action |
|------|--------|
| `<leader>db` | Toggle breakpoint |
| `<leader>dB` | Conditional breakpoint |
| `<leader>dlp` | Log point |
| `<leader>dc` | Continue/Start |
| `<leader>dr` | Restart |
| `<leader>dt` | Terminate |
| `<leader>dq` | Close |
| `<leader>ds` | Step over |
| `<leader>di` | Step into |
| `<leader>do` | Step out |
| `<leader>dj` | Down stack frame |
| `<leader>dk` | Up stack frame |
| `<leader>dR` | Open REPL |
| `<leader>dE` | Evaluate expression |
| `<leader>dbc` | Clear breakpoints |
| `<leader>dbl` | List breakpoints |
| `<leader>drl` | Run last config |
| `<leader>dro` | Run to cursor |
| `<leader>du` | Toggle UI |
| `<leader>dU` | Open UI |
| `<leader>dC` | Close UI |
| `<leader>de` | Evaluate under cursor |
| `<leader>dS` | Sidebar (scopes) |
| `<leader>dF` | Sidebar (frames) |
| `<leader>dh` | Hover variables |
| `<leader>dp` | Preview variables |
| `<leader>dvt` | Toggle virtual text |

## Editor (`<leader>e`)

| Keys | Action |
|------|--------|
| `<leader>ez` | Zen mode |
| `<leader>eZ` | Zen zoom |
| `<leader>ew` | Toggle wrap |
| `<leader>es` | Toggle spell |
| `<leader>en` | Toggle line numbers |
| `<leader>er` | Toggle relative numbers |
| `<leader>eh` | Toggle search highlight |
| `<leader>ed` | Toggle diagnostics |
| `<leader>ec` | Toggle conceal |

## Find (`<leader>f`)

| Keys | Action |
|------|--------|
| `<leader>ff` | Files |
| `<leader>fF` | Files (+hidden) |
| `<leader>fr` | Recent files |
| `<leader>fd` | Dotfiles/config |
| `<leader>fp` | Plugin files |
| `<leader>fg` | Grep |
| `<leader>fG` | Grep (+hidden) |
| `<leader>f/` | Word under cursor |
| `<leader>fb` | Buffers |
| `<leader>fm` | Marks |
| `<leader>fj` | Jump list |
| `<leader>f;` | Resume last |
| `<leader>f:` | Command history |
| `<leader>fh` | Help |
| `<leader>fc` | Commands |
| `<leader>fk` | Keymaps |
| `<leader>fs` | Document symbols |
| `<leader>fS` | Workspace symbols |
| `<leader>fie` | Insert emoji |
| `<leader>fim` | Insert math symbol |
| `<leader>fig` | Insert gitmoji |

## Git (`<leader>g`)

| Keys | Action |
|------|--------|
| `<leader>gg` | Lazygit |
| `<leader>gG` | Lazygit (file dir) |
| `<leader>gb` | Blame line |
| `<leader>gB` | Browse in GitHub |
| `<leader>gf` | Git files |
| `<leader>gs` | Status |
| `<leader>gc` | Commits |
| `<leader>gC` | Buffer commits |
| `<leader>gd` | Diff |

## Language (`<leader>l`)

### LaTeX (`<leader>ll`)

| Keys | Action |
|------|--------|
| `<leader>llc` | Compile |
| `<leader>llv` | View PDF |
| `<leader>lls` | Stop |
| `<leader>llt` | TOC |
| `<leader>llk` | Clean |
| `<leader>llK` | Clean all |
| `<leader>lli` | Info |
| `<leader>llr` | Reverse search |
| `<leader>llb` | Bold (visual) |
| `<leader>lli` | Italic (visual) |
| `<leader>ll$` | Math mode (visual) |

### Markdown (`<leader>lm`)

| Keys | Action |
|------|--------|
| `<leader>lmp` | Toggle preview |
| `<leader>lmf` | Toggle folding |
| `<leader>lme` | Toggle auto-expand folds |

## Notes (`<leader>n`)

| Keys | Action |
|------|--------|
| `<leader>nn` | New scratch |
| `<leader>ns` | Select scratch |
| `<leader>nh` | Notification history |
| `<leader>nd` | Dismiss notifications |
| `<leader>nD` | Dashboard |

## Open (`<leader>o`)

| Keys | Action |
|------|--------|
| `<leader>oe` | Explorer |
| `<leader>oE` | Explorer (file dir) |
| `<leader>of` | Explorer float |
| `<leader>oo` | Oil |
| `<leader>ot` | Terminal |
| `<leader>oT` | Terminal float |
| `<leader>os` | Terminal split |
| `<leader>ov` | Terminal vsplit |
| `<leader>otp` | Python terminal |
| `<leader>otn` | Node terminal |

## Quickfix (`<leader>q`)

| Keys | Action |
|------|--------|
| `<leader>qo` | Open quickfix |
| `<leader>qc` | Close quickfix |
| `<leader>qn` | Next item |
| `<leader>qp` | Previous item |
| `<leader>ql` | Open location list |
| `<leader>qL` | Close location list |
| `<leader>qf` | Find in quickfix |

## Window (`<leader>w`)

| Keys | Action |
|------|--------|
| `<leader>w-` | Split horizontal |
| `<leader>w\|` | Split vertical |
| `<leader>wd` | Close window |
| `<leader>wo` | Close other windows |
| `<leader>w=` | Equal size |
| `<leader>wn` | New tab |
| `<leader>wc` | Close tab |
| `<leader>wO` | Close other tabs |
| `<leader>wl` | Next tab |
| `<leader>wh` | Previous tab |

---

## Non-Leader Keymaps

### Navigation

| Keys | Action |
|------|--------|
| `Ctrl+h/j/k/l` | Window navigation |
| `Ctrl+Up/Down` | Resize height |
| `Ctrl+Left/Right` | Resize width |
| `Tab` / `S-Tab` | Next/prev buffer |
| `S-h` / `S-l` | Next/prev buffer |
| `[b` / `]b` | Next/prev buffer |
| `[t` / `]t` | Next/prev tab |
| `[q` / `]q` | Next/prev quickfix |
| `[l` / `]l` | Next/prev location |
| `[w` / `]w` | Next/prev diagnostic |
| `[W` / `]W` | Next/prev error |

### File Navigation

| Keys | Action |
|------|--------|
| `gf` | Go to file (with line number) |
| `gw` | Open file in new window |
| `gv` | Open file in vsplit |
| `gs` | Open file in split |
| `gt` | Open file in new tab |
| `-` | Open explorer |

### LSP

| Keys | Action |
|------|--------|
| `gd` | Go to definition |
| `gD` | Go to declaration |
| `gi` | Go to implementation |
| `gr` | Go to references |
| `K` | Hover documentation |
| `Ctrl+]` | Go to definition |
| `Ctrl+\` | Find references |
| `Ctrl+[` | Hover |

### Editing

| Keys | Action |
|------|--------|
| `<` / `>` (visual) | Indent and stay in visual |
| `Alt+j/k` | Move line down/up |
| `J` / `K` (visual) | Move selection down/up |
| `p` (visual) | Paste without yanking |
| `Q` | Play macro q |
| `J` | Join lines (cursor stays) |

### Clipboard

| Keys | Action |
|------|--------|
| `<leader>y` | Yank to system clipboard |
| `<leader>Y` | Yank line to clipboard |
| `<leader>p` | Paste without yanking |
| `<leader>d` | Delete without yanking |
| `Cmd+c` | Copy (macOS) |
| `Cmd+v` | Paste (macOS) |

### Scroll Centering

| Keys | Action |
|------|--------|
| `Ctrl+d/u` | Scroll and center |
| `n` / `N` | Search and center |
| `*` / `#` | Word search and center |

### Completion (Insert Mode)

| Keys | Action |
|------|--------|
| `Tab` | Accept/Next |
| `S-Tab` | Previous |
| `Ctrl+n` | Next item |
| `Ctrl+p` | Previous item |
| `Ctrl+y` | Confirm |
| `Ctrl+e` | Cancel |
| `Ctrl+Space` | Trigger manually |
| `Ctrl+f` | Scroll docs down |
| `Ctrl+b` | Scroll docs up |

### Misc

| Keys | Action |
|------|--------|
| `Ctrl+s` | Save |
| `Ctrl+a` | Select all |
| `Esc` | Clear search highlight |
| `<leader><leader>` | Select to end of line |
| `<leader>sw` | Replace word under cursor |
| `<leader>cp` | Copy full path |
| `,cs` | Copy relative path |
| `,cl` | Copy absolute path |
| `F5` | Run Python file / DAP continue |
| `F10` | DAP step over |
| `F11` | DAP step into |
| `F12` | DAP step out |

---

<p align="center">
  <a href="README.md">← Back to Keybindings</a>
</p>
