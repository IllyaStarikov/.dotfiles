# ════════════════════════════════════════════════════════════════════════════════════════════════════════════
# 🚀 ZSH ALIASES - Production-Ready Shell Shortcuts
# ════════════════════════════════════════════════════════════════════════════════════════════════════════════
# Carefully curated aliases for maximum productivity and modern tooling integration
# ════════════════════════════════════════════════════════════════════════════════════════════════════════════

# ────────────────────────────────────────────────────────────────────────────────────────────────────────────
# 📝 EDITOR ALIASES
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────

alias vim="nvim"
alias vi="nvim"
alias v="nvim"
alias code="code ."
alias edit="nvim"
alias vimconfig="nvim ~/.config/nvim/init.lua"
alias zshconfig="nvim ~/.zshrc"
alias tmuxconfig="nvim ~/.tmux.conf"

# ────────────────────────────────────────────────────────────────────────────────────────────────────────────
# 📁 FILE MANAGEMENT - Modern ls with eza
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────

# Enhanced eza-based file listing
# Note: --icons temporarily disabled due to font glyph issues
alias ls="eza --group-directories-first"
alias ll="eza -l --group-directories-first --time-style=relative --git"
alias la="eza -la --group-directories-first --time-style=relative --git"
alias lt="eza --tree --level=2"
alias tree="eza --tree"
alias l1="eza --tree --level=1"
alias l2="eza --tree --level=2"
alias l3="eza --tree --level=3"

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
alias gfresh="git checkout main && git pull && git branch --merged | grep -v '\\*\\|main\\|master' | xargs -n 1 git branch -d"

# ────────────────────────────────────────────────────────────────────────────────────────────────────────────
# 🔍 SEARCH & FIND UTILITIES
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────

# Modern search tools
alias find-file="fd"
alias find-content="rg"
alias grep="rg"
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

# Colorful and enhanced utilities
alias diff="colordiff"
alias less="less -R"
alias cat="bat --style=header,grid,numbers"
alias c="bat --style=header,grid,numbers"
alias preview="bat --style=header,grid,numbers --color=always"

# System information
alias df='df -H'
alias du='du -ch'
alias free='vm_stat'
alias top='htop'
alias ps='procs'

# Network utilities
alias ip="curl -s icanhazip.com"
alias localip="ipconfig getifaddr en0 || ipconfig getifaddr en1"
alias ips="ifconfig -a | grep -o 'inet6\\? \\(addr:\\)\\?\\s\\?\\(\\(\\([0-9]\\+\\.\\)\\{3\\}[0-9]\\+\\)\\|[a-fA-F0-9:]\\+\\)' | awk '{ sub(/inet6? (addr:)? ?/, \"\"); print }'"
alias speedtest="curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -"

# ────────────────────────────────────────────────────────────────────────────────────────────────────────────
# 📂 NAVIGATION SHORTCUTS
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

alias theme="~/.dotfiles/src/theme-switcher/switch-theme.sh"
alias install-auto-theme="~/.dotfiles/src/theme-switcher/install-auto-theme.sh"
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
alias node="node"
alias npm="npm"
alias yarn="yarn"

# Docker shortcuts
alias d="docker"
alias dc="docker-compose"
alias dps="docker ps"
alias di="docker images"
alias dex="docker exec -it"
alias dlog="docker logs"
alias dstop="docker stop \$(docker ps -q)"
alias dclean="docker system prune -af"

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

alias cleanup="find . -type f -name '*.DS_Store' -delete && find . -type f -name '*.pyc' -delete"
alias emptytrash="sudo rm -rfv /Volumes/*/.Trashes && sudo rm -rfv ~/.Trash && sudo rm -rfv /private/var/log/asl/*.asl"
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
alias path='echo -e ${PATH//:/\\n}'
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
if command -v duf &> /dev/null; then
    alias df='duf'
fi

# Better du with dust if available
if command -v dust &> /dev/null; then
    alias du='dust'
fi

# Better ping with gping if available
if command -v gping &> /dev/null; then
    alias ping='gping'
fi