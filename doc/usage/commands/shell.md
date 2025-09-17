# Shell Commands Reference

> **Zsh aliases and functions for productivity**

## Navigation

### Directory Jumping

| Command | Description                     | Example  |
| ------- | ------------------------------- | -------- |
| `z`     | Jump to directory by frecency   | `z proj` |
| `zi`    | Interactive directory selection | `zi`     |
| `bd`    | Go back to previous directory   | `bd`     |
| `..`    | Go up one level                 | `..`     |
| `...`   | Go up two levels                | `...`    |
| `....`  | Go up three levels              | `....`   |
| `-`     | Previous directory              | `-`      |

### Quick Access

| Command | Directory      |
| ------- | -------------- |
| `1`     | `~/1-projects` |
| `2`     | `~/2-work`     |
| `3`     | `~/3-personal` |
| `4`     | `~/4-archive`  |
| `5`     | `~/5-temp`     |
| `dl`    | `~/Downloads`  |
| `dt`    | `~/Desktop`    |
| `doc`   | `~/Documents`  |

## File Operations

### Modern ls (eza)

| Command | Description            | Flags                         |
| ------- | ---------------------- | ----------------------------- |
| `l`     | Simple list            |                               |
| `ll`    | Long format with git   | `--git --time-style=relative` |
| `la`    | All files              | `-a`                          |
| `lt`    | Tree view              | `--tree`                      |
| `lla`   | All files, long format | `-la`                         |
| `llt`   | Tree with all files    | `--tree -a`                   |

### File Management

| Command   | Description                   | Example            |
| --------- | ----------------------------- | ------------------ |
| `mkd`     | Make directory and enter      | `mkd new-project`  |
| `take`    | Create and enter directory    | `take new-folder`  |
| `trash`   | Move to trash (safer than rm) | `trash file.txt`   |
| `cleanup` | Remove all .DS_Store files    | `cleanup`          |
| `extract` | Extract any archive           | `extract file.zip` |

### Finding Files

| Command | Description             | Example      |
| ------- | ----------------------- | ------------ |
| `ff`    | Interactive file finder | `ff`         |
| `fd`    | Find files/directories  | `fd pattern` |
| `fif`   | Find in files           | `fif "TODO"` |

## System Commands

### Process Management

| Command     | Description                   |
| ----------- | ----------------------------- |
| `ps`        | Modern process viewer (procs) |
| `top`       | System monitor (btop)         |
| `killport`  | Kill process on port          |
| `fkill`     | Fuzzy process killer          |
| `listening` | Show listening ports          |
| `ports`     | Show all open ports           |

### System Information

| Command     | Description         |
| ----------- | ------------------- |
| `myip`      | Show external IP    |
| `localip`   | Show local IP       |
| `ips`       | Show all IPs        |
| `df`        | Disk usage (duf)    |
| `du`        | Directory usage     |
| `speedtest` | Internet speed test |

### Updates & Maintenance

| Command           | Description           |
| ----------------- | --------------------- |
| `update-dotfiles` | Update everything     |
| `reload`          | Reload shell config   |
| `cleanup`         | Clean .DS_Store files |
| `brewup`          | Update Homebrew       |
| `npmup`           | Update npm packages   |

## Development

### Editors & Tools

| Command | Description  |
| ------- | ------------ |
| `v`     | Open Neovim  |
| `vim`   | Neovim alias |
| `c`     | Clear screen |
| `q`     | Exit shell   |
| `h`     | Show history |

### Python

| Command    | Description                  |
| ---------- | ---------------------------- |
| `py`       | Python 3                     |
| `python`   | Python 3                     |
| `pip`      | pip3                         |
| `pyenv`    | Python version manager       |
| `venv`     | Create virtual environment   |
| `activate` | Activate venv in current dir |

### Node.js

| Command | Description          |
| ------- | -------------------- |
| `npm`   | Node package manager |
| `npx`   | Execute npm packages |
| `yarn`  | Yarn package manager |
| `pnpm`  | Fast npm alternative |
| `nvm`   | Node version manager |

## Text Processing

### Modern Tools

| Command | Original | Description               |
| ------- | -------- | ------------------------- |
| `cat`   | cat      | Syntax highlighting (bat) |
| `grep`  | grep     | Fast search (ripgrep)     |
| `find`  | find     | User-friendly (fd)        |
| `sed`   | sed      | Find and replace (sd)     |
| `diff`  | diff     | Beautiful diffs (delta)   |

### Search Commands

| Command  | Description     | Example        |
| -------- | --------------- | -------------- |
| `rg`     | Ripgrep search  | `rg "pattern"` |
| `ag`     | Silver searcher | `ag "pattern"` |
| `todos`  | Find TODO/FIXME | `todos`        |
| `fixmes` | Find FIXME only | `fixmes`       |

## Network

### HTTP Tools

| Command | Description    | Example                |
| ------- | -------------- | ---------------------- |
| `http`  | HTTPie client  | `http GET example.com` |
| `curl`  | Transfer data  | `curl -O file.zip`     |
| `wget`  | Download files | `wget url`             |

### Network Info

| Command    | Description       |
| ---------- | ----------------- |
| `ping`     | Test connectivity |
| `gping`    | Graphical ping    |
| `dig`      | DNS lookup        |
| `nslookup` | Query DNS         |
| `netstat`  | Network stats     |

## Configuration

### Quick Edits

| Command      | Opens                     |
| ------------ | ------------------------- |
| `zshconfig`  | `~/.zshrc`                |
| `vimconfig`  | `~/.config/nvim/init.lua` |
| `tmuxconfig` | `~/.tmux.conf`            |
| `gitconfig`  | `~/.gitconfig`            |
| `sshconfig`  | `~/.ssh/config`           |

### Theme Management

| Command       | Description              |
| ------------- | ------------------------ |
| `theme`       | Auto-detect system theme |
| `theme dark`  | Force dark mode          |
| `theme light` | Force light mode         |

## Custom Functions

### Productivity

| Function | Description           | Usage         |
| -------- | --------------------- | ------------- |
| `mcd`    | mkdir and cd          | `mcd new-dir` |
| `fh`     | Fuzzy history search  | `fh`          |
| `fco`    | Fuzzy checkout branch | `fco`         |
| `fcoc`   | Fuzzy checkout commit | `fcoc`        |

### Development

| Function | Description         | Usage               |
| -------- | ------------------- | ------------------- |
| `gi`     | Generate .gitignore | `gi python node`    |
| `server` | Start HTTP server   | `server 8080`       |
| `json`   | Pretty print JSON   | `echo '{}' \| json` |

## Environment Variables

### Key Variables

| Variable   | Description           |
| ---------- | --------------------- |
| `$EDITOR`  | Default editor (nvim) |
| `$VISUAL`  | Visual editor (nvim)  |
| `$PAGER`   | Default pager (less)  |
| `$BROWSER` | Default browser       |
| `$TERM`    | Terminal type         |
| `$SHELL`   | Current shell         |
| `$PATH`    | Executable paths      |

### Custom Variables

| Variable       | Description        |
| -------------- | ------------------ |
| `$DOTFILES`    | Dotfiles directory |
| `$PROJECTS`    | Projects directory |
| `$MACOS_THEME` | Current theme      |

---

<p align="center">
  <a href="../README.md">← Back to Usage</a>
</p>
