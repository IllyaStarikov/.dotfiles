# ════════════════════════════════════════════════════════════════════════════════════════════════════════════
# 🚀 ZSH ALIASES - Production-Ready Shell Shortcuts
# ════════════════════════════════════════════════════════════════════════════════════════════════════════════
# Carefully curated aliases for maximum productivity and modern tooling integration
# ════════════════════════════════════════════════════════════════════════════════════════════════════════════

# ────────────────────────────────────────────────────────────────────────────────────────────────────────────
# 📝 EDITOR ALIASES
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────

alias vi="nvim"
# Platform-aware code command
if command -v code >/dev/null 2>&1; then
    alias code="code ."
elif command -v codium >/dev/null 2>&1; then
    alias code="codium ."
fi
alias edit="nvim"
alias vimconfig="nvim ~/.config/nvim/init.lua"
alias zshconfig="nvim ~/.zshrc"
alias tmuxconfig="nvim ~/.tmux.conf"

# Quick edits
alias zshrc='$EDITOR ~/.zshrc'
alias vimrc='$EDITOR ~/.config/nvim/init.lua'

# ────────────────────────────────────────────────────────────────────────────────────────────────────────────
# 📁 FILE MANAGEMENT - Modern ls with eza
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────

# Enhanced eza-based file listing (with fallback to ls)
if command -v eza >/dev/null 2>&1; then
    alias l='eza --group-directories-first --time-style=relative --git --icons --all --header --long'
    alias ls='eza --group-directories-first'
    alias lt="eza --tree --level=2"
    alias tree="eza --tree"
    alias l1="eza --tree --level=1"
    alias l2="eza --tree --level=2"
    alias l3="eza --tree --level=3"
else
    # Fallback to standard ls
    alias l='ls -la'
    alias ls="ls -G"
    alias tree="find . -print | sed -e 's;[^/]*/;|____;g;s;____|; |;g'"
fi

# Aliases with icons (use when font issues are resolved)
alias lsi="eza --group-directories-first --icons"
alias lli="eza -l --group-directories-first --time-style=relative --icons --git"
alias lai="eza -la --group-directories-first --time-style=relative --icons --git"

# Size-aware listings
alias lh="eza -lah --group-directories-first --time-style=relative --git"  # Human readable
alias lS="eza -laS --group-directories-first --time-style=relative --git"  # Sort by size
alias lt_size="eza --tree --level=2 -s size"

# ────────────────────────────────────────────────────────────────────────────────────────────────────────────
# 🔧 TMUX & SESSION MANAGEMENT
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────

alias tx="tmuxinator"
alias txs="tmuxinator start"
alias txl="tmuxinator list"
alias txe="tmuxinator edit"
alias txn="tmuxinator new"
alias ranger="source ranger"

# Tmux shortcuts
alias tm="tmux"
alias tma="tmux attach"
alias tmn="tmux new-session"
alias tml="tmux list-sessions"
alias tmk="tmux kill-session"

# ────────────────────────────────────────────────────────────────────────────────────────────────────────────
# 🌐 GIT WORKFLOW ENHANCEMENT
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────

# Beautiful git log
alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias gll="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit --all"
alias glo="git log --oneline --graph --decorate --all"

# Git shortcuts
alias g="git"
alias ga="git add"
alias gaa="git add --all"
alias gc="git commit"
alias gcm="git commit -m"
alias gca="git commit --amend"
alias gco="git checkout"
alias gcb="git checkout -b"
alias gd="git diff"
alias gdc="git diff --cached"
alias gf="git fetch"
alias gp="git push"
alias gpl="git pull"
alias gs="git status"
alias gst="git stash"
alias gstp="git stash pop"
alias gb="git branch"
alias gba="git branch -a"
alias gm="git merge"
alias gr="git rebase"
alias gri="git rebase -i"
alias greset="git reset --hard HEAD"
alias gclean="git clean -fd"

# Advanced git workflows
alias gwip="git add -A && git commit -m 'WIP: work in progress'"
alias gunwip="git log -n 1 | grep -q -c 'WIP' && git reset HEAD~1"
alias gundo="git reset --soft HEAD~1"
alias gfresh="git checkout main && git pull && git branch --merged | grep -v '\*\|main\|master' | xargs -n 1 git branch -d"

# ────────────────────────────────────────────────────────────────────────────────────────────────────────────
# 🔍 SEARCH & FIND UTILITIES
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────

# Modern search tools
alias find-file="fd"
alias find-content="rg"
# Modern ripgrep aliases (keeping 'grep' command for compatibility)
alias rgrep="rg"
alias search="rg -i --pretty --context=3"

# Project-specific searches
alias todos="rg -n --no-heading '(TODO|FIX(ME)?|NOTE|HACK|XXX)'"
alias fixmes="rg -n --no-heading '(FIXME|FIX)'"
alias notes="rg -n --no-heading '(NOTE|NOTES)'"

# File type specific searches
alias pygrep="rg --type py"
alias jsgrep="rg --type js"
alias tsgrep="rg --type ts"
alias cssgrep="rg --type css"
alias htmlgrep="rg --type html"
alias mdgrep="rg --type md"
alias luagrep="rg --type lua"

# ────────────────────────────────────────────────────────────────────────────────────────────────────────────
# 🌈 ENHANCED SYSTEM UTILITIES
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────

# Modern replacements (with command checks)
command -v bat &>/dev/null && alias cat='bat' || alias cat='cat'
command -v rg &>/dev/null && alias grep='rg' || alias grep='grep'

# Colorful and enhanced utilities
alias diff="colordiff"
alias less="less -R"
alias c="bat --style=header,grid,numbers"
alias preview="bat --style=header,grid,numbers --color=always"

# Safety aliases
alias rn='trash'  # Move files to trash instead of permanent deletion
alias cp='cp -i'
alias mv='mv -i'

# System information
alias df='df -H'
alias du='du -ch'
alias free='vm_stat'
alias top='htop'
alias ps='procs'

# Network utilities
alias ip="curl -s icanhazip.com"
alias localip="ipconfig getifaddr en0 || ipconfig getifaddr en1"
alias ips="ifconfig -a | grep -o 'inet6\? \(addr:\)\?\s\?\(\(\([0-9]\+\.\)\{3\}[0-9]\+\)\|[a-fA-F0-9:]\+\)' | awk '{ sub(/inet6? (addr:)? ?/, ""); print }'"
# Install speedtest-cli safely: brew install speedtest-cli
alias speedtest="speedtest-cli"

# ────────────────────────────────────────────────────────────────────────────────────────────────────────────
# 📂NAVIGATION SHORTCUTS
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────

# Directory navigation
alias cd..="cd .."
alias ..="cd .."
alias ...="cd ../../"
alias ....="cd ../../../"
alias .....="cd ../../../../"
alias .4="cd ../../../../"
alias .5="cd ../../../../.."

# Quick directory access
alias home="cd ~"
alias desktop="cd ~/Desktop"
alias downloads="cd ~/Downloads"
alias documents="cd ~/Documents"
alias projects="cd ~/Projects"
alias dotfiles="cd ~/.dotfiles"

# ────────────────────────────────────────────────────────────────────────────────────────────────────────────
# 🎨 THEME & APPEARANCE
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────

# alias theme="~/.dotfiles/src/theme-switcher/switch-theme.sh" # Replaced with function in .zshrc
alias reload-alacritty="theme reload"
alias dark="theme dark"
alias light="theme light"

# ────────────────────────────────────────────────────────────────────────────────────────────────────────────
# 🛠️ DEVELOPMENT TOOLS
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────

# Programming language shortcuts
alias haskell="ghci"
alias haskellcc="ghc"
alias py="python3"
alias py2="python2"
alias pip="pip3"
# Node/npm/yarn are handled by NVM lazy loading - no aliases needed

# Docker shortcuts
if command -v docker &>/dev/null; then
    alias d="docker"
    alias dc="docker-compose"
    alias dps="docker ps"
    alias di="docker images"
    alias dex="docker exec -it"
    alias dlog="docker logs"
    # Use single quotes to prevent command substitution at alias definition time
    alias dstop='docker stop $(docker ps -q 2>/dev/null)'
    alias dclean="docker system prune -af"
    
    # Function to safely run docker commands only when daemon is running
    docker_safe() {
        if docker info &>/dev/null; then
            docker "$@"
        else
            echo "Docker daemon is not running. Start Docker or Colima first."
            return 1
        fi
    }
fi

# Kubernetes shortcuts
alias k="kubectl"
alias kgp="kubectl get pods"
alias kgs="kubectl get services"
alias kgd="kubectl get deployments"
alias kdesc="kubectl describe"
alias klogs="kubectl logs"
alias kexec="kubectl exec -it"

# ────────────────────────────────────────────────────────────────────────────────────────────────────────────
# 📄 DOCUMENT PROCESSING
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────

alias pandoc="pandoc --wrap=none --listings"
alias md2pdf="pandoc --pdf-engine=xelatex -o"
alias md2html="pandoc -t html5 -o"
alias md2docx="pandoc -o"

# ────────────────────────────────────────────────────────────────────────────────────────────────────────────
# 🧹 CLEANUP & MAINTENANCE
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────

# Safer cleanup with confirmation
cleanup() {
    echo "This will delete all .DS_Store and .pyc files recursively from current directory."
    echo -n "Are you sure? [y/N] "
    read -r response
    if [[ "$response" =~ ^[Yy]$ ]]; then
        find . -type f -name '*.DS_Store' -delete
        find . -type f -name '*.pyc' -delete
        echo "Cleanup complete."
    else
        echo "Cleanup cancelled."
    fi
}

# Safer trash emptying function with confirmation
emptytrash() {
    echo "WARNING: This will permanently delete:"
    echo "  - All items in Trash"
    echo "  - System trash folders"
    echo "  - ASL log files"
    echo -n "Are you ABSOLUTELY sure? Type 'yes' to confirm: "
    read -r response
    if [[ "$response" == "yes" ]]; then
        # Use specific paths instead of wildcards with sudo
        sudo rm -rfv ~/.Trash
        # Only clear Trashes on mounted volumes if they exist
        for volume in /Volumes/*; do
            if [[ -d "$volume/.Trashes" ]]; then
                sudo rm -rfv "$volume/.Trashes"
            fi
        done
        # Clear ASL logs safely
        sudo rm -rfv /private/var/log/asl/*.asl 2>/dev/null || true
        echo "Trash emptied."
    else
        echo "Operation cancelled."
    fi
}
alias reset="source ~/.zshrc && clear"
alias reload="source ~/.zshrc"
alias reloadzsh="source ~/.zshrc"

# System maintenance
alias update="brew update && brew upgrade && brew cleanup"
alias updateall="update && npm update -g && pip3 list --outdated --format=freeze | grep -v '^\\-e' | cut -d = -f 1 | xargs -n1 pip3 install -U"

# ────────────────────────────────────────────────────────────────────────────────────────────────────────────
# 📊 MONITORING & DIAGNOSTICS
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────

# Process monitoring
alias psg="ps aux | grep"
alias cpu='top -o cpu'
alias mem='top -o mem'

# Disk usage
alias disk='du -h --max-depth=1 | sort -hr'
alias biggest='du -h --max-depth=1 | sort -hr | head -20'

# Port monitoring
alias ports='netstat -tulanp'
alias listening='lsof -i -P | grep LISTEN'

# ────────────────────────────────────────────────────────────────────────────────────────────────────────────
# 🚀 PRODUCTIVITY SHORTCUTS
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────

# Quick edits
alias zshconfig="nvim ~/.zshrc"
alias zshreload="source ~/.zshrc"
alias vimconfig="nvim ~/.config/nvim/init.lua"
alias tmuxconfig="nvim ~/.tmux.conf"
alias gitconfig="nvim ~/.gitconfig"
alias sshconfig="nvim ~/.ssh/config"
alias alacrittyconfig="nvim ~/.dotfiles/src/alacritty.toml"
alias ripgrepconfig="nvim ~/.dotfiles/src/ripgreprc"

# Time savers
alias h="history"
alias j="jobs"
alias path='echo -e ${PATH//:/\n}'
alias now='date +"%T"'
alias nowtime=now
alias nowdate='date +"%d-%m-%Y"'

# Fun utilities
alias weather='curl wttr.in'
alias moon='curl wttr.in/Moon'
alias crypto='curl rate.sx'
alias chuck='curl -s https://api.chucknorris.io/jokes/random | jq -r .value'

# ────────────────────────────────────────────────────────────────────────────────────────────────────────────
# 🎯 POWER USER SHORTCUTS
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────

# Quick server - using function in zshrc instead of aliases
# The serve() function in zshrc is more flexible and handles missing python
alias serve8000="serve 8000"
alias serve3000="serve 3000"

# Copy utilities (macOS)
alias copy="pbcopy"
alias paste="pbpaste"
alias copyfile="pbcopy <"

# URL encoding/decoding
alias urlencode='python3 -c "import sys, urllib.parse as ul; print(ul.quote_plus(sys.argv[1]))"'
alias urldecode='python3 -c "import sys, urllib.parse as ul; print(ul.unquote_plus(sys.argv[1]))"'

# Base64 encoding/decoding
alias b64encode='base64'
alias b64decode='base64 -D'

# JSON formatting
alias json='python3 -m json.tool'
alias jsonpp='python3 -m json.tool'

# Hash utilities
alias md5sum='md5'
alias sha1sum='shasum -a 1'
alias sha256sum='shasum -a 256'

# ────────────────────────────────────────────────────────────────────────────────────────────────────────────
# 🔒 SECURITY & PERMISSIONS
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────

# Fix common permission issues
alias fix-permissions="find . -type f -exec chmod 644 {} \; && find . -type d -exec chmod 755 {} \;"
alias fix-ssh="chmod 700 ~/.ssh && chmod 600 ~/.ssh/* && chmod 644 ~/.ssh/*.pub 2>/dev/null || true"

# ────────────────────────────────────────────────────────────────────────────────────────────────────────────
# 📱 MODERN UTILITIES
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────

# Quick file sharing
alias share="python3 -m http.server 8000"

# Lazy git - interactive git UI
alias lg="lazygit"

# Better df with duf if available
if command -v duf &> /dev/null;
then
    alias df='duf'
fi

# Better du with dust if available
if command -v dust &> /dev/null;
then
    alias du='dust'
fi

# Better ping with gping if available
if command -v gping &> /dev/null;
then
    alias ping='gping'
fi