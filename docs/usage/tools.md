# Tools Reference

## Daily Commands
```
FILE OPS              TEXT SEARCH           SYSTEM
ll       List all     rg pattern  Grep      btop     Monitor
lt       Tree         fd name     Find      duf      Disk usage
z dir    Jump         fzf         Fuzzy     procs    Processes

REPLACEMENTS          GIT TOOLS             NETWORK
cat → bat            gh pr create           http GET url
ls  → eza            delta (git diff)       gping host
cd  → z              lazygit                bandwhich
find → fd            gh issue list          curl → httpie
grep → rg
```

## Modern CLI Tools

### eza (ls++)
| Command | Action | Command | Action |
|---------|--------|---------|--------|
| `eza` | List | `eza -l` | Long |
| `eza -la` | All long | `eza -lh` | Human |
| `eza --tree` | Tree | `eza --icons` | Icons |
| `eza --git` | Git status | `eza -s size` | Sort size |

### bat (cat++)
| Command | Action | Command | Action |
|---------|--------|---------|--------|
| `bat file` | View | `bat -n` | Numbers |
| `bat -p` | Plain | `bat -A` | Non-printable |
| `bat --diff` | Diff mode | `bat -r 10:20` | Lines 10-20 |
| `bat -l yaml` | Force syntax | `bat --theme` | Set theme |

### fd (find++)
| Command | Action | Command | Action |
|---------|--------|---------|--------|
| `fd pattern` | Find | `fd -e py` | Extension |
| `fd -t f` | Files only | `fd -t d` | Dirs only |
| `fd -H` | Hidden | `fd -I` | Ignored |
| `fd -d 2` | Max depth | `fd -x cmd` | Execute |

### ripgrep (grep++)
| Command | Action | Command | Action |
|---------|--------|---------|--------|
| `rg pattern` | Search | `rg -i` | Ignore case |
| `rg -w` | Words | `rg -n` | Line nums |
| `rg -c` | Count | `rg -l` | Files only |
| `rg --type py` | File type | `rg -C 3` | Context |

### fzf
| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `Ctrl+R` | History | `Ctrl+T` | Files |
| `Alt+C` | Directories | `**<Tab>` | Complete |
| `Ctrl+J/K` | Navigate | `Enter` | Select |
| `Ctrl+Space` | Toggle | `Esc` | Cancel |

### zoxide (cd++)
| Command | Action | Command | Action |
|---------|--------|---------|--------|
| `z pattern` | Jump | `zi` | Interactive |
| `z -` | Previous | `z ..` | Parent |

## Homebrew

| Command | Action | Command | Action |
|---------|--------|---------|--------|
| `brew install` | Install | `brew update` | Update brew |
| `brew upgrade` | Upgrade pkgs | `brew list` | List |
| `brew search` | Search | `brew info` | Details |
| `brew cleanup` | Clean old | `brew doctor` | Health |

### Services
| Command | Action | Command | Action |
|---------|--------|---------|--------|
| `brew services list` | List | `brew services start` | Start |
| `brew services stop` | Stop | `brew services restart` | Restart |

## Development Tools

### GitHub CLI
| Command | Action | Command | Action |
|---------|--------|---------|--------|
| `gh auth login` | Auth | `gh repo create` | Create |
| `gh pr create` | New PR | `gh pr list` | List PRs |
| `gh pr merge` | Merge | `gh issue create` | New issue |
| `gh workflow run` | Run | `gh release create` | Release |

### httpie
| Command | Action | Command | Action |
|---------|--------|---------|--------|
| `http GET url` | GET | `http POST url` | POST |
| `http --json` | JSON | `http --form` | Form |
| `http --auth` | Auth | `http --download` | Download |

### jq
| Command | Action | Command | Action |
|---------|--------|---------|--------|
| `jq '.'` | Pretty | `jq '.field'` | Field |
| `jq '.[]'` | Array | `jq 'keys'` | Keys |
| `jq 'select()'` | Filter | `jq -r` | Raw |

## System Tools

### btop
| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `q` | Quit | `f` | Filter |
| `t` | Tree | `p` | Sort PID |
| `c` | Sort CPU | `m` | Sort MEM |
| `k` | Kill | `Space` | Tag |

### duf
| Command | Action | Command | Action |
|---------|--------|---------|--------|
| `duf` | Show all | `duf -all` | All fs |
| `duf -json` | JSON | `duf /path` | Specific |

### delta (git diff)
| Command | Action | Command | Action |
|---------|--------|---------|--------|
| `git diff` | Uses delta | `delta file1 file2` | Compare files |
| `git show` | Pretty output | `git log -p` | With delta |
| `git blame` | Enhanced | `git reflog -p` | Pretty reflog |

### ranger
| Key | Action | Key | Action |
|-----|--------|-----|--------|
| `h/j/k/l` | Navigate | `Enter` | Open |
| `q` | Quit | `S` | Shell here |
| `yy` | Copy | `dd` | Cut |
| `pp` | Paste | `dD` | Delete |
| `space` | Select | `v` | Select all |
| `/` | Search | `zh` | Show hidden |

### procs
| Command | Action | Command | Action |
|---------|--------|---------|--------|
| `procs` | List | `procs name` | Search |
| `procs -t` | Tree | `procs -w` | Watch |

## Productivity

### tldr
| Command | Action | Command | Action |
|---------|--------|---------|--------|
| `tldr cmd` | Examples | `tldr -u` | Update |
| `tldr -l` | List all | `tldr -p linux` | Platform |

### navi
| Command | Action | Key | Action |
|---------|--------|-----|--------|
| `navi` | Browse | `Ctrl+G` | Trigger |

## Theme Switcher

| Command | Effect |
|---------|--------|
| `theme` | Auto-detect and switch |
| Updates | Alacritty, tmux, Neovim |
| Detection | `defaults read -g AppleInterfaceStyle` |

## Package Managers

### Homebrew
| Command | Action | Command | Action |
|---------|--------|---------|--------|
| `brew install pkg` | Install | `brew uninstall pkg` | Remove |
| `brew update` | Update brew | `brew upgrade` | Upgrade all |
| `brew upgrade pkg` | Upgrade one | `brew outdated` | List outdated |
| `brew cleanup` | Clean cache | `brew doctor` | Check health |
| `brew search term` | Search | `brew info pkg` | Package info |
| `brew list` | Installed | `brew leaves` | Top-level only |
| `brew deps pkg` | Dependencies | `brew uses pkg` | Dependents |

### pyenv
| Command | Action | Command | Action |
|---------|--------|---------|--------|
| `pyenv install 3.x` | Install Python | `pyenv versions` | List versions |
| `pyenv global 3.x` | Set default | `pyenv local 3.x` | Set for project |
| `pyenv shell 3.x` | Set for session | `pyenv rehash` | Rehash shims |

## Update Script

| Component | Command |
|-----------|---------|
| Homebrew | `brew update && brew upgrade` |
| Oh My Zsh | `omz update` |
| tmux plugins | TPM update |
| npm packages | `npm update -g` |
| pyenv | `pyenv update` |

## Troubleshooting

| Issue | Fix |
|-------|-----|
| Command not found | `brew install tool` |
| Wrong version | `brew upgrade tool` |
| PATH issue | Check `echo $PATH` |
| Alias conflict | Use `\command` |
| Icons missing | Install Nerd Font |

## Tips

- Use `\` to bypass aliases (`\ls` for original)
- `which cmd` to find command location
- `man cmd` or `tldr cmd` for help
- Most tools respect `.gitignore`
- Set `FZF_DEFAULT_COMMAND` for better results