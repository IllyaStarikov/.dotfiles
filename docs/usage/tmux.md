# Tmux Reference

## Daily Commands
```
SESSION                WINDOW                  PANE
tmux new -s name       C-a c     New          C-a |    V-split
tmux a -t name         C-a n/p   Next/prev    C-a -    H-split
tmux ls                C-a 0-9   Jump to #    C-a h/j/k/l Navigate
C-a d     Detach       C-a w     List         C-a z    Zoom
C-a s     Switch       C-a ,     Rename       C-a x    Kill
C-a $     Rename       C-a &     Kill         C-a !    Break to window

COPY MODE              MISC                    RESIZE
C-a [     Enter        C-a ?     Bindings     C-a H/J/K/L  By 5
v         Select       C-a :     Command      C-a C-h/j/k/l By 1
y         Yank         C-a r     Reload       Hold C-a + arrows
C-a ]     Paste        C-a t     Time
```

## Session Management

| Command | Action | Key | Action |
|---------|--------|-----|--------|
| `tmux` | New session | `C-a d` | Detach |
| `tmux new -s name` | Named session | `C-a D` | Choose detach |
| `tmux a` | Attach last | `C-a S` | Choose session |
| `tmux a -t name` | Attach named | `C-a s` | New session |
| `tmux ls` | List sessions | `C-a $` | Rename session |
| `tmux kill-session -t` | Kill session | `C-a (` | Previous session |
| `tmux kill-server` | Kill all | `C-a )` | Next session |

## Window Management

| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `C-a c` | New window | `C-a n` | Next window |
| `C-a ,` | Rename window | `C-a p` | Previous window |
| `C-a w` | List windows | `C-a l` | Last window |
| `C-a &` | Kill window | `C-a X` | Kill without confirm |
| `C-a 0-9` | Go to window # | `Tab` | Last window |
| `C-a C-p` | Previous window | `C-a C-n` | Next window |
| `C-a <` | Swap window left | `C-a >` | Swap window right |

## Pane Management

| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `C-a |` | Split vertical | `C-a -` | Split horizontal |
| `C-a \` | Alt split vertical | `C-a _` | Alt split horizontal |
| `C-a x` | Kill pane | `C-a z` | Toggle zoom |
| `C-a h/j/k/l` | Navigate | `C-a o` | Next pane |
| `C-a q` | Show numbers | `C-a ;` | Last pane |
| `C-a !` | Break to window | `C-a m` | Maximize/restore |
| `C-a {/}` | Swap panes | `C-a Space` | Next layout |

## Copy Mode

| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `C-a [` | Enter copy | `q` | Exit |
| `v` | Start selection | `V` | Line selection |
| `C-v` | Rectangle selection | `y` | Copy to clipboard |
| `Enter` | Copy & exit | `MouseDrag` | Copy with mouse |
| `h/j/k/l` | Navigate | `w/b` | Word forward/back |
| `/` | Search forward | `?` | Search backward |
| `n/N` | Next/prev match | `C-a ]` | Paste from clipboard |

## Resize Panes

| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `C-a H` | Left 5 | `C-a L` | Right 5 |
| `C-a J` | Down 5 | `C-a K` | Up 5 |
| `C-a C-h` | Left 1 | `C-a C-l` | Right 1 |
| `C-a C-j` | Down 1 | `C-a C-k` | Up 1 |

## Commands

| Command | Action | Command | Action |
|---------|--------|---------|--------|
| `:new-window` | Create window | `:kill-pane` | Close pane |
| `:split-window -h` | V-split | `:split-window -v` | H-split |
| `:list-sessions` | Show sessions | `:list-windows` | Show windows |
| `:source ~/.tmux.conf` | Reload | `:setw -g mode-keys vi` | Vi mode |

## Configuration

| Setting | Value | Purpose |
|---------|-------|---------|
| `prefix` | `C-a` | Command prefix |
| `base-index` | `1` | Start from 1 |
| `mouse` | `on` | Enable mouse |
| `mode-keys` | `vi` | Vi bindings |
| `history-limit` | `50000` | Scrollback |
| `renumber-windows` | `on` | Auto renumber |

## Tmuxinator

| Command | Action | Alias | Action |
|---------|--------|-------|--------|
| `tmuxinator new` | Create project | `tx new` | Short form |
| `tmuxinator start` | Launch project | `txs` | Start |
| `tmuxinator edit` | Edit config | `txe` | Edit |
| `tmuxinator list` | Show projects | `txl` | List |
| `tmuxinator delete` | Remove project | `tx delete` | Delete |

## Tmuxinator Config
```yaml
name: project
root: ~/projects/app
windows:
  - editor:
      layout: main-vertical
      panes:
        - vim
        - guard
  - server: rails s
  - logs: tail -f log/development.log
```

## Plugins (TPM)

| Key | Action | Plugin | Purpose |
|-----|--------|--------|---------|
| `prefix + I` | Install | `tmux-resurrect` | Save/restore |
| `prefix + U` | Update | `tmux-continuum` | Auto-save |
| `prefix + C-s` | Save | `tmux-yank` | System clipboard |
| `prefix + C-r` | Restore | `tmux-copycat` | Better search |

## Layouts

| Key | Layout | Key | Layout |
|-----|--------|-----|--------|
| `C-a Space` | Next layout | `C-a M-1` | Even horizontal |
| `C-a M-2` | Even vertical | `C-a M-3` | Main horizontal |
| `C-a M-4` | Main vertical | `C-a M-5` | Tiled |

## Vi Navigation

| From | To | Key |
|------|----|----|
| Vim | tmux pane | `C-h/j/k/l` |
| tmux pane | Vim split | `C-h/j/k/l` |
| Any | Any | Smart navigation |

## Special Keys

| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `C-a C-a` | Send C-a | `C-a r` | Reload config |
| `C-a C-k` | Clear history | `C-a y` | Sync panes |
| `C-a t` | Show time | `C-a ?` | List keys |
| `C-a :` | Command mode | `C-a q` | Pane numbers |

## Tips

- Prefix = `C-a` (Ctrl+a), press then release
- Sessions persist after disconnect/reboot
- Mouse support enabled (scroll, select, resize)
- Copy mode uses system clipboard
- New windows/panes inherit current path
- Seamless navigation with vim (C-h/j/k/l)
- Theme auto-switches with system