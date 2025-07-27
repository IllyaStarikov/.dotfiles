# Zsh Reference

## Daily Commands
```
NAVIGATION           FILE OPS              GIT                TOOLS
z project    Jump    ll      List all     gs   Status       v file     Edit
cd -         Back    la      Hidden       gaa  Add all      fzf        Find
..           Up      lt      Tree         gcmsg Commit      rg text    Grep
...          Up 2    mkdir -p Create     gp   Push         fd name    Find file
cd           Home    rm -rf  Delete      gl   Pull         btop       Monitor

ALIASES              SYSTEM               HISTORY            SHELL
alias name   Show    reload  Reload zsh  h    History      c     Clear
unalias x    Remove  update  Update all  !!   Last cmd     q     Exit
which cmd    Find    src     Source file !$   Last arg     exec zsh Restart
type cmd     Info    path    Show PATH   !^   First arg    jobs  List jobs
```

## Navigation Aliases

| Alias | Command | Alias | Command |
|-------|---------|---|-------|---------|
| `..` | `cd ..` | `.3` | `cd ../../..` |
| `...` | `cd ../..` | `.4` | `cd ../../../..` |
| `cd-` | `cd -` | `~` | `cd ~` |
| `z` | Autojump to dir | `zi` | Interactive jump |
| `bd` | Jump to parent | `take` | mkdir && cd |

## File Operations

| Alias | Command | Alias | Command |
|-------|---------|---|-------|---------|
| `ll` | `eza -l` | `la` | `eza -la` |
| `lt` | `eza --tree` | `l.` | List hidden |
| `lsd` | List dirs only | `lsf` | List files only |
| `cp` | `cp -i` | `mv` | `mv -i` |
| `rm` | `rm -i` | `md` | `mkdir -p` |
| `rd` | `rmdir` | `rmf` | `rm -rf` |

## Git Aliases

| Alias | Command | Alias | Command |
|-------|---------|---|-------|---------|
| `g` | `git` | `gs` | `git status` |
| `ga` | `git add` | `gaa` | `git add --all` |
| `gc` | `git commit -v` | `gc!` | `git commit -v --amend` |
| `gcmsg` | `git commit -m` | `gca` | `git commit -v -a` |
| `gco` | `git checkout` | `gcb` | `git checkout -b` |
| `gb` | `git branch` | `gba` | `git branch -a` |
| `gbd` | `git branch -d` | `gbD` | `git branch -D` |
| `gd` | `git diff` | `gds` | `git diff --staged` |
| `gf` | `git fetch` | `gfa` | `git fetch --all` |
| `gl` | `git pull` | `gp` | `git push` |
| `gpsup` | Push set upstream | `gpf` | `git push --force` |
| `grb` | `git rebase` | `grbi` | `git rebase -i` |
| `grh` | `git reset` | `grhh` | `git reset --hard` |
| `gsta` | `git stash` | `gstp` | `git stash pop` |
| `glog` | Pretty log | `gloga` | All branches |

## Architecture-Specific Aliases

| Alias | Command | Alias | Command |
|-------|---------|---|----------|---------|
| `brew` | `arch -arm64 brew` | `ibrew` | `arch -x86_64 brew` |
| `pyenv` | `arch -arm64 pyenv` | |

## Lazy-Loaded Node.js

| Alias | Command | Alias | Command |
|-------|---------|---|----------|---------|
| `nvm` | Lazy-load nvm | `node` | Lazy-load node |
| `npm` | Lazy-load npm | `npx` | Lazy-load npx |

## Utility Aliases

| Alias | Command | Alias | Command |
|-------|---------|---|-------|---------|
| `h` | `history` | `help` | `man` |
| `p` | `ps -f` | `path` | Show PATH |
| `reload` | `exec zsh` | `src` | `source` |
| `update` | Update system | `theme` | Switch theme |
| `dark` | Force dark mode | `light` | Force light mode |
| `myip` | Show IP | `localip` | Local IP |
| `ports` | Open ports | `urlencode` | URL encode |

## Editor Shortcuts

| Alias | Command | Alias | Command |
|-------|---------|---|-------|---------|
| `v` | `nvim` | `vi` | `nvim` |
| `vim` | `nvim` | `e` | `$EDITOR` |
| `zshconfig` | Edit ~/.zshrc | `vimconfig` | Edit nvim config |
| `gitconfig` | Edit ~/.gitconfig | `tmuxconfig` | Edit tmux.conf |

## Process Management

| Alias | Command | Alias | Command |
|-------|---------|---|-------|---------|
| `psa` | `ps aux` | `psg` | `ps aux | grep` |
| `ka` | `killall` | `k9` | `kill -9` |
| `jobs` | List jobs | `j` | `jobs -l` |

## Network

| Alias | Command | Alias | Command |
|-------|---------|---|-------|---------|
| `ping` | `ping -c 5` | `fastping` | `ping -c 100 -i 0.2` |
| `ports` | Show open ports | `ips` | Show all IPs |
| `myip` | Public IP | `localip` | Local IP |
| `httpdump` | Dump HTTP traffic | `sniff` | Network sniffer |

## Oh My Zsh Plugins

| Plugin | Features | Key Commands |
|--------|----------|--------------|
| **git** | Git aliases | `gs`, `gco`, `gaa`, `gcmsg` |
| **z** | Directory jumper | `z pattern` |
| **fzf** | Fuzzy search | `Ctrl+R`, `Ctrl+T`, `**<Tab>` |
| **zsh-autosuggestions** | Fish-like suggestions | `→` accept, `Ctrl+Space` accept word |
| **zsh-syntax-highlighting** | Command highlighting | Automatic |
| **vi-mode** | Vi keybindings | `Esc` for normal mode |
| **history-substring-search** | Better history | `↑/↓` with partial command |

## FZF Integration

| Shortcut | Action | Example |
|----------|--------|---------|
| `Ctrl+T` | File search | Insert file path |
| `Ctrl+R` | History search | Search command history |
| `Alt+C` | Directory search | cd to directory |
| `**<Tab>` | Trigger completion | `vim **<Tab>` |
| `kill -9 <Tab>` | Process completion | Select process |
| `ssh **<Tab>` | Host completion | SSH hosts |
| `unset **<Tab>` | Variable completion | Environment vars |

## Vi Mode

| Mode | Key | Action | Mode | Key | Action |
|------|-----|--------|------|-----|--------|
| Insert | `Esc` | Normal mode | Normal | `i` | Insert mode |
| Normal | `a` | Append | Normal | `A` | Append EOL |
| Normal | `o` | Open below | Normal | `O` | Open above |
| Normal | `dd` | Delete line | Normal | `yy` | Yank line |
| Normal | `p` | Paste | Normal | `u` | Undo |
| Normal | `/` | Search | Normal | `n` | Next match |
| Normal | `v` | Visual | Visual | `y` | Yank |

## Suffix Aliases

| Extension | Opens With | Extension | Opens With |
|-----------|------------|-----------|------------|
| `*.md` | Neovim | `*.txt` | Neovim |
| `*.py` | Python | `*.rb` | Ruby |
| `*.pdf` | Preview | `*.jpg` | Preview |
| `*.tar.gz` | tar -xzvf | `*.zip` | unzip |

## Global Aliases

| Alias | Expands To | Usage |
|-------|------------|-------|
| `G` | `| grep` | `ls G pattern` |
| `L` | `| less` | `cat file L` |
| `NE` | `2> /dev/null` | `find / NE` |
| `NUL` | `> /dev/null 2>&1` | `command NUL` |
| `H` | `| head` | `ls H` |
| `T` | `| tail` | `log T` |
| `F` | `| fzf` | `ls F` |

## Functions

| Function | Usage | Description |
|----------|-------|-------------|
| `mkd()` | `mkd dirname` | mkdir && cd |
| `mkcd()` | `mkcd dirname` | mkdir -p && cd |
| `cdf()` | `cdf` | cd to Finder dir |
| `extract()` | `extract file.zip` | Extract any archive |
| `fs()` | `fs` | File size of dir |
| `gz()` | `gz file` | gzip size |
| `json()` | `json < file.json` | Pretty print JSON |
| `digga()` | `digga domain.com` | DNS lookup all |
| `ff()` | `ff pattern` | Find files with fd |
| `search()` | `search pattern` | Smart grep with rg |
| `git_clean_branches()` | `git_clean_branches` | Clean merged branches |
| `project()` | `project name` | cd to project dir |
| `sysinfo()` | `sysinfo` | System information |
| `myip()` | `myip` | Show public IP |
| `serve()` | `serve [port]` | Start HTTP server |

## Environment Variables

| Variable | Value | Purpose |
|----------|-------|---------|
| `EDITOR` | nvim | Default editor |
| `PAGER` | less | Default pager |
| `LANG` | en_US.UTF-8 | Locale |
| `PATH` | Multiple | Executable paths |
| `FZF_DEFAULT_COMMAND` | rg --files | FZF file source |
| `FZF_DEFAULT_OPTS` | --height 40% | FZF options |

## Completion System

| Key | Action | Context |
|-----|--------|---------|
| `Tab` | Complete | After partial command |
| `Shift+Tab` | Reverse complete | Cycle backwards |
| `Ctrl+Space` | Accept suggestion | Autosuggestions |
| `Tab Tab` | Show options | Multiple matches |
| `Ctrl+X Ctrl+F` | File completion | Force file complete |
| `Ctrl+X Ctrl+D` | Directory completion | Force dir complete |

## History

| Key/Command | Action | Key/Command | Action |
|-------------|--------|-------------|--------|
| `!!` | Last command | `!$` | Last argument |
| `!^` | First argument | `!*` | All arguments |
| `!-n` | n commands ago | `!string` | Last starting with |
| `^old^new` | Replace in last | `fc` | Fix command |
| `history` | Show history | `h` | History alias |
| `Ctrl+R` | Search history | `↑/↓` | Browse history |

## Options

| Option | Effect | Set With |
|--------|--------|----------|
| `AUTO_CD` | cd without typing cd | `setopt AUTO_CD` |
| `HIST_IGNORE_DUPS` | No duplicate history | `setopt HIST_IGNORE_DUPS` |
| `SHARE_HISTORY` | Share between sessions | `setopt SHARE_HISTORY` |
| `EXTENDED_HISTORY` | Timestamps in history | `setopt EXTENDED_HISTORY` |
| `CORRECT` | Command correction | `setopt CORRECT` |
| `NO_CASE_GLOB` | Case insensitive glob | `setopt NO_CASE_GLOB` |

## Prompt Customization

| Element | Variable | Example |
|---------|----------|---------|
| Username | `%n` | `user` |
| Hostname | `%m` | `macbook` |
| Directory | `%~` | `~/projects` |
| Git branch | `$(git_prompt_info)` | `(main)` |
| Time | `%T` | `14:30:00` |
| Return code | `%?` | `0` |
| Privileges | `%#` | `$` or `#` |

## Tips

- `bindkey -v` for vi mode, `bindkey -e` for emacs mode
- `which alias` to see alias definition
- `unalias name` to remove alias
- `alias -g` for global aliases
- `alias -s` for suffix aliases
- Use `\command` to bypass alias
- `exec zsh` to reload shell
- `echo $0` to check current shell
- `chsh -s /bin/zsh` to set default shell