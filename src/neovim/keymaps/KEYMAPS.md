# Custom Keymaps

## Leader Key Prefixes

| Prefix | Category |
|--------|----------|
| `a` | AI (CodeCompanion) |
| `b` | Buffer |
| `c` | Code (symbols, LSP, run) |
| `d` | Debug (DAP) |
| `e` | Editor (zen, toggles) |
| `f` | Find (Telescope) |
| `g` | Git |
| `l` | Language (filetype-specific) |
| `n` | Notes (notifications) |
| `o` | Open (explorer, terminal) |
| `q` | Quickfix |
| `w` | Window |
| `x` | Scratch |

---

## AI (`<leader>a`)

| Key | Action |
|-----|--------|
| `ac` | Chat |
| `aa` | Actions palette |
| `ai` | Inline assistance |
| `ae` | Explain code (visual) |
| `ar` | Review code (visual) |
| `ao` | Optimize code (visual) |
| `af` | Fix bug (visual) |
| `at` | Generate tests (visual) |
| `am` | Add comments (visual) |
| `an` | New chat |
| `al` | Toggle chat |
| `as` | Stop |
| `a1` | Small model |
| `a2` | Medium model |
| `a3` | Large model |
| `a?` | List models |
| `aM` | Use MLX (macOS) |
| `aO` | Use Ollama (macOS) |
| `aX` | Start MLX server (macOS) |

## Buffer (`<leader>b`)

| Key | Action |
|-----|--------|
| `bd` | Delete buffer |
| `bD` | Delete all buffers |
| `bo` | Delete other buffers |
| `bb` | List buffers |
| `b1-9` | Go to buffer 1-9 |

## Code (`<leader>c`)

| Key | Action |
|-----|--------|
| `cr` | Run file |
| `cm` | Make (pick target) |
| `cM` | Make (default) |
| `cs` | Symbol outline |
| `cS` | Symbol navigator |
| `cn` | Next symbol |
| `cp` | Previous symbol |
| `cN` | Next symbol (parent) |
| `cP` | Previous symbol (parent) |
| `cg` | Go to symbol |
| `cf` | Find symbols |
| `ca` | Code action |
| `cR` | Rename |
| `ch` | Hover |
| `cd` | Go to definition |
| `cD` | Go to declaration |
| `ci` | Go to implementation |
| `ct` | Go to type definition |

## Debug (`<leader>d`)

| Key | Action |
|-----|--------|
| `db` | Toggle breakpoint |
| `dB` | Conditional breakpoint |
| `dlp` | Log point |
| `dc` | Continue/Start |
| `dr` | Restart |
| `dt` | Terminate |
| `dq` | Close |
| `ds` | Step over |
| `di` | Step into |
| `do` | Step out |
| `dj` | Down stack frame |
| `dk` | Up stack frame |
| `dR` | Open REPL |
| `dE` | Evaluate expression |
| `dbc` | Clear breakpoints |
| `dbl` | List breakpoints |
| `drl` | Run last config |
| `dro` | Run to cursor |
| `du` | Toggle UI |
| `dU` | Open UI |
| `dC` | Close UI |
| `de` | Evaluate under cursor |
| `dS` | Sidebar (scopes) |
| `dF` | Sidebar (frames) |
| `dh` | Hover variables |
| `dp` | Preview variables |
| `dvt` | Toggle virtual text |

## Editor (`<leader>e`)

| Key | Action |
|-----|--------|
| `ez` | Zen mode |
| `eZ` | Zen zoom |
| `ew` | Toggle wrap |
| `es` | Toggle spell |
| `en` | Toggle line numbers |
| `er` | Toggle relative numbers |
| `eh` | Toggle search highlight |
| `ed` | Toggle diagnostics |
| `ec` | Toggle conceal |

## Find (`<leader>f`)

| Key | Action |
|-----|--------|
| `ff` | Files |
| `fF` | Files (+hidden) |
| `fr` | Recent files |
| `fd` | Dotfiles/config |
| `fp` | Plugin files |
| `fg` | Grep |
| `fG` | Grep (+hidden) |
| `f/` | Word under cursor |
| `fb` | Buffers |
| `fm` | Marks |
| `fj` | Jump list |
| `f;` | Resume last |
| `f:` | Command history |
| `fh` | Help |
| `fc` | Commands |
| `fk` | Keymaps |
| `fs` | Document symbols |
| `fS` | Workspace symbols |
| `fie` | Insert emoji |
| `fim` | Insert math symbol |
| `fig` | Insert gitmoji |

## Git (`<leader>g`)

| Key | Action |
|-----|--------|
| `gg` | Lazygit |
| `gG` | Lazygit (file dir) |
| `gb` | Blame line |
| `gB` | Browse in GitHub |
| `gf` | Git files |
| `gs` | Status |
| `gc` | Commits |
| `gC` | Buffer commits |
| `gd` | Diff |

## Language (`<leader>l`)

### LaTeX (`<leader>ll`)

| Key | Action |
|-----|--------|
| `llc` | Compile |
| `llv` | View PDF |
| `lls` | Stop |
| `llt` | TOC |
| `llk` | Clean |
| `llK` | Clean all |
| `lli` | Info |
| `llr` | Reverse search |
| `llb` | Bold (visual) |
| `lli` | Italic (visual) |
| `ll$` | Math mode (visual) |

### Markdown (`<leader>lm`)

| Key | Action |
|-----|--------|
| `lmp` | Toggle preview |
| `lmf` | Toggle folding |
| `lme` | Toggle auto-expand folds |

## Notes (`<leader>n`)

| Key | Action |
|-----|--------|
| `nh` | Notification history |
| `nd` | Dismiss notifications |
| `nD` | Dashboard |

## Open (`<leader>o`)

| Key | Action |
|-----|--------|
| `oe` | Explorer |
| `oE` | Explorer (file dir) |
| `of` | Explorer float |
| `oo` | Oil |
| `ot` | Terminal |
| `oT` | Terminal float |
| `os` | Terminal split |
| `ov` | Terminal vsplit |
| `otp` | Python terminal |
| `otn` | Node terminal |

## Quickfix (`<leader>q`)

| Key | Action |
|-----|--------|
| `qo` | Open quickfix |
| `qc` | Close quickfix |
| `qn` | Next item |
| `qp` | Previous item |
| `ql` | Open location list |
| `qL` | Close location list |
| `qf` | Find in quickfix |

## Scratch (`<leader>x`)

| Key | Action |
|-----|--------|
| `xx` | Toggle scratch (current ft or markdown) |
| `xn` | New scratch (pick filetype) |
| `xs` | Select scratch |
| `xl` | List scratches |

Scratch buffers persist in `~/.local/share/nvim/scratch/` and auto-save.
The filetype picker sorts by most-used filetypes.

## Window (`<leader>w`)

| Key | Action |
|-----|--------|
| `w-` | Split horizontal |
| `w\|` | Split vertical |
| `wd` | Close window |
| `wo` | Close other windows |
| `w=` | Equal size |
| `wn` | New tab |
| `wc` | Close tab |
| `wO` | Close other tabs |
| `wl` | Next tab |
| `wh` | Previous tab |

---

## Non-Leader Keymaps

### Navigation

| Key | Action |
|-----|--------|
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

| Key | Action |
|-----|--------|
| `gf` | Go to file (with line number) |
| `gw` | Open file in new window |
| `gv` | Open file in vsplit |
| `gs` | Open file in split |
| `gt` | Open file in new tab |
| `-` | Open explorer |

### LSP

| Key | Action |
|-----|--------|
| `Ctrl+]` | Go to definition |
| `Ctrl+\` | Find references |
| `Ctrl+[` | Hover |

### Editing

| Key | Action |
|-----|--------|
| `<` / `>` (visual) | Indent and stay in visual |
| `Alt+j/k` | Move line down/up |
| `J` / `K` (visual) | Move selection down/up |
| `p` (visual) | Paste without yanking |
| `Q` | Play macro q |
| `J` | Join lines (cursor stays) |

### Clipboard

| Key | Action |
|-----|--------|
| `<leader>y` | Yank to system clipboard |
| `<leader>Y` | Yank line to clipboard |
| `<leader>p` | Paste without yanking |
| `<leader>d` | Delete without yanking |
| `Cmd+c` | Copy (macOS) |
| `Cmd+v` | Paste (macOS) |

### Scroll Centering

| Key | Action |
|-----|--------|
| `Ctrl+d/u` | Scroll and center |
| `n` / `N` | Search and center |
| `*` / `#` | Word search and center |

### Misc

| Key | Action |
|-----|--------|
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
