# Shell Keybindings Reference

> **Zsh with vi-mode and productivity shortcuts**

## Vi Mode

Our shell uses vi-mode for powerful text editing right in the command line.

### Mode Indicators

- **Insert Mode**: Regular prompt
- **Normal Mode**: Cursor changes, vi commands available

### Switching Modes

| Key   | Action               | From Mode |
| ----- | -------------------- | --------- |
| `ESC` | Enter Normal mode    | Insert    |
| `i`   | Enter Insert mode    | Normal    |
| `a`   | Append mode          | Normal    |
| `A`   | Append at line end   | Normal    |
| `I`   | Insert at line start | Normal    |

## Normal Mode Commands

### Movement

| Key | Action          | Description       |
| --- | --------------- | ----------------- |
| `h` | Move left       | Character left    |
| `l` | Move right      | Character right   |
| `w` | Next word       | Word forward      |
| `b` | Previous word   | Word backward     |
| `e` | Word end        | End of word       |
| `0` | Line start      | Beginning of line |
| `$` | Line end        | End of line       |
| `^` | First non-blank | First character   |

### Editing

| Key  | Action           | Description          |
| ---- | ---------------- | -------------------- |
| `x`  | Delete char      | Delete under cursor  |
| `X`  | Delete before    | Delete before cursor |
| `dd` | Delete line      | Clear whole line     |
| `D`  | Delete to end    | Delete to line end   |
| `dw` | Delete word      | Delete word forward  |
| `db` | Delete word back | Delete word backward |
| `cc` | Change line      | Replace whole line   |
| `C`  | Change to end    | Replace to line end  |
| `cw` | Change word      | Replace word         |

### Copy/Paste

| Key  | Action       | Description         |
| ---- | ------------ | ------------------- |
| `yy` | Yank line    | Copy entire line    |
| `yw` | Yank word    | Copy word           |
| `p`  | Paste after  | Paste after cursor  |
| `P`  | Paste before | Paste before cursor |

### Undo/Redo

| Key   | Action | Description        |
| ----- | ------ | ------------------ |
| `u`   | Undo   | Undo last change   |
| `C-r` | Redo   | Redo undone change |

## Insert Mode Shortcuts

### Text Manipulation

| Key   | Action          | Description             |
| ----- | --------------- | ----------------------- |
| `C-w` | Delete word     | Delete word backward    |
| `C-u` | Delete to start | Clear to line beginning |
| `C-k` | Delete to end   | Clear to line end       |
| `C-a` | Move to start   | Jump to line beginning  |
| `C-e` | Move to end     | Jump to line end        |
| `C-f` | Move right      | Forward one character   |
| `C-b` | Move left       | Backward one character  |

### History

| Key   | Action           | Description          |
| ----- | ---------------- | -------------------- |
| `C-r` | History search   | Fuzzy search history |
| `C-p` | Previous command | Up in history        |
| `C-n` | Next command     | Down in history      |
| `↑`   | Previous command | History up           |
| `↓`   | Next command     | History down         |

### Completion

| Key       | Action         | Description          |
| --------- | -------------- | -------------------- |
| `TAB`     | Complete       | Auto-completion      |
| `TAB TAB` | Show options   | List all completions |
| `C-i`     | Complete (alt) | Same as TAB          |
| `C-d`     | List choices   | Show possibilities   |

## Special Features

### FZF Integration

| Key   | Action         | Description          |
| ----- | -------------- | -------------------- |
| `C-r` | History search | Fuzzy history search |
| `C-t` | File picker    | Insert file path     |
| `M-c` | CD widget      | Change directory     |

### Directory Navigation

| Key   | Action            | Description                   |
| ----- | ----------------- | ----------------------------- |
| `M-.` | Last argument     | Insert last arg from previous |
| `M-h` | CD to parent      | Go up one directory           |
| `M-l` | Accept suggestion | Complete autosuggest          |

## Custom Keybindings

### Quick Commands

| Key       | Action       | Description     |
| --------- | ------------ | --------------- |
| `C-g`     | Git status   | Show git status |
| `C-x C-e` | Edit command | Open in editor  |
| `C-x C-r` | Reload shell | Source ~/.zshrc |

### Productivity

| Key   | Action            | Description           |
| ----- | ----------------- | --------------------- |
| `C-o` | Open file         | Open with default app |
| `C-z` | Toggle background | fg/bg last job        |
| `C-l` | Clear screen      | Clear terminal        |

## Plugin Shortcuts

### zsh-autosuggestions

| Key   | Action            | Description             |
| ----- | ----------------- | ----------------------- |
| `→`   | Accept suggestion | Complete the suggestion |
| `M-f` | Accept word       | Take one word           |
| `M-l` | Accept line       | Take whole suggestion   |
| `C-g` | Clear suggestion  | Dismiss suggestion      |

### zsh-syntax-highlighting

Visual feedback only - no keybindings:

- **Green**: Valid commands
- **Red**: Invalid commands
- **Yellow**: Strings
- **Blue**: Arguments

### z (Directory Jumper)

| Command        | Action              | Example    |
| -------------- | ------------------- | ---------- |
| `z pattern`    | Jump to directory   | `z proj`   |
| `z -l pattern` | List matches        | `z -l doc` |
| `z -c pattern` | Restrict to subdirs | `z -c src` |
| `z -e pattern` | Echo best match     | `z -e dot` |

## Terminal Control

### Job Control

| Key   | Action        | Description            |
| ----- | ------------- | ---------------------- |
| `C-c` | Interrupt     | Kill current process   |
| `C-\` | Quit          | Force quit (SIGQUIT)   |
| `C-s` | Stop output   | Pause terminal output  |
| `C-q` | Resume output | Continue output        |
| `C-z` | Suspend       | Background process     |
| `C-d` | EOF/Exit      | Exit shell or send EOF |

### Screen Control

| Key   | Action         | Description  |
| ----- | -------------- | ------------ |
| `C-l` | Clear          | Clear screen |
| `C-j` | New line       | Enter/Return |
| `C-m` | New line (alt) | Enter/Return |

## Quick Reference Card

### Most Used

```bash
# History search
C-r         # Fuzzy search history

# File/Directory
C-t         # Insert file path
M-c         # Change directory

# Editing
C-w         # Delete word backward
C-u         # Clear to line start
C-k         # Clear to line end

# Navigation
C-a         # Jump to start
C-e         # Jump to end

# Vi mode
ESC         # Normal mode
i           # Insert mode
```

### Power User

```bash
# Vi normal mode
/pattern    # Search in line
n           # Next match
.           # Repeat last

# Advanced editing
ci"         # Change inside quotes
da(         # Delete around parens
yi{         # Yank inside braces

# Marks
ma          # Set mark 'a'
`a          # Jump to mark 'a'
```

## Tips and Tricks

### Efficient Editing

1. **Quick fixes**: Use `ESC` then `b` to go back and fix typos
2. **Clear line**: `C-u` in insert mode or `dd` in normal mode
3. **History search**: `C-r` then type any part of command
4. **Smart completion**: Type few chars then `TAB`

### Navigation

1. **Jump words**: `M-f` forward, `M-b` backward
2. **Directory jump**: `z partial-name` to jump anywhere
3. **Quick parent**: `..` or `...` for parent directories
4. **Last location**: `cd -` to toggle directories

### Integration

1. **FZF everywhere**: `C-r` for history, `C-t` for files
2. **Edit complex**: `C-x C-e` to edit in Neovim
3. **Quick git**: `C-g` for status (custom binding)
4. **Background jobs**: `C-z` to suspend, `fg` to resume

---

<p align="center">
  <a href="README.md">← Back to Keybindings</a>
</p>
