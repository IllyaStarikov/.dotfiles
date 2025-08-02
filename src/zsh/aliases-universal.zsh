# ════════════════════════════════════════════════════════════════════════════════════════════════════════════
# 🚀 UNIVERSAL ZSH ALIASES - Works on macOS and Linux
# ════════════════════════════════════════════════════════════════════════════════════════════════════════════
# Carefully curated aliases for maximum productivity and modern tooling integration
# ════════════════════════════════════════════════════════════════════════════════════════════════════════════

# ────────────────────────────────────────────────────────────────────────────────────────────────────────────
# 📝 EDITOR ALIASES
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────

alias vi="nvim"
alias edit="nvim"
alias vimconfig="nvim ~/.config/nvim/init.lua"
alias zshconfig="nvim ~/.zshrc"
alias tmuxconfig="nvim ~/.tmux.conf"

# Platform-aware code command
if [[ "$OS_TYPE" == "macos" ]]; then
    alias code="code ."
elif command -v code >/dev/null 2>&1; then
    alias code="code ."
elif command -v codium >/dev/null 2>&1; then
    alias code="codium ."
fi

# ────────────────────────────────────────────────────────────────────────────────────────────────────────────
# 📁 FILE MANAGEMENT - Modern ls with eza
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────

# Enhanced eza-based file listing (if available)
if command -v eza >/dev/null 2>&1; then
    alias l="eza --group-directories-first --time-style=relative --git --icons --all --header --long"
    alias ls="eza --group-directories-first"
    alias lt="eza --tree --level=2"
    alias tree="eza --tree"
    alias l1="eza --tree --level=1"
    alias l2="eza --tree --level=2"
    alias l3="eza --tree --level=3"
    
    # Aliases with icons
    alias lsi="eza --group-directories-first --icons"
    alias lli="eza -l --group-directories-first --time-style=relative --icons --git"
    alias lai="eza -la --group-directories-first --time-style=relative --icons --git"
    
    # Size-aware listings
    alias lh="eza -lah --group-directories-first --time-style=relative --git"
    alias lS="eza -laS --group-directories-first --time-style=relative --git"
    alias lt_size="eza --tree --level=2 -s size"
else
    # Fallback to standard ls with color support
    if [[ "$OS_TYPE" == "macos" ]]; then
        alias ls='ls -G'
        alias l='ls -lahG'
        alias ll='ls -lhG'
        alias la='ls -laG'
    else
        alias ls='ls --color=auto'
        alias l='ls -lah --color=auto'
        alias ll='ls -lh --color=auto'
        alias la='ls -la --color=auto'
    fi
fi

# ────────────────────────────────────────────────────────────────────────────────────────────────────────────
# 🔧 TMUX & SESSION MANAGEMENT
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────

alias tx="tmuxinator"
alias txs="tmuxinator start"
alias txl="tmuxinator list"
alias txe="tmuxinator edit"
alias txn="tmuxinator new"
alias ta="tmux attach"
alias tn="tmux new-session -s"
alias ts="tmux switch -t"
alias tls="tmux list-sessions"
alias tkill="tmux kill-session -t"
alias tks="tmux kill-server"

# ────────────────────────────────────────────────────────────────────────────────────────────────────────────
# 📂 NAVIGATION & DIRECTORY SHORTCUTS
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────

alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."
alias .....="cd ../../../.."
alias ~="cd ~"
alias -- -="cd -"

# Quick directory access
alias dl="cd ~/Downloads"
alias dt="cd ~/Desktop"
alias docs="cd ~/Documents"
alias projects="cd ~/projects"
alias dotfiles="cd ~/.dotfiles"
alias config="cd ~/.config"

# Create and enter directory
mkd() {
    mkdir -p "$@" && cd "$_"
}

# ────────────────────────────────────────────────────────────────────────────────────────────────────────────
# 🔍 SEARCH & FIND - Modern replacements
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────

# Use ripgrep if available
if command -v rg >/dev/null 2>&1; then
    alias grep="rg"
    alias rgi="rg -i"
    alias rgf="rg --files | rg"
fi

# Use fd if available
if command -v fd >/dev/null 2>&1; then
    alias find="fd"
    alias fdi="fd -i"
    alias fdh="fd -H"
fi

# fzf integration
if command -v fzf >/dev/null 2>&1; then
    alias fzfp="fzf --preview 'bat --style=numbers --color=always --line-range :500 {}' --preview-window=right:60%"
fi

# ────────────────────────────────────────────────────────────────────────────────────────────────────────────
# 🌐 NETWORK & SYSTEM INFO
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────

# IP addresses - cross-platform
alias ip="curl -s https://ipinfo.io/ip"
alias localip="hostname -I 2>/dev/null || ifconfig | grep 'inet ' | grep -v '127.0.0.1' | awk '{print \$2}'"

# Speed test (if installed)
if command -v speedtest-cli >/dev/null 2>&1; then
    alias speedtest="speedtest-cli"
fi

# ────────────────────────────────────────────────────────────────────────────────────────────────────────────
# 🛠️ DEVELOPMENT TOOLS
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────

# Git (provided by git plugin, but adding essentials)
alias g="git"
alias gs="git status"
alias gd="git diff"
alias gc="git commit"
alias gco="git checkout"
alias gb="git branch"
alias gp="git push"
alias gl="git pull"
alias glog="git log --oneline --graph --decorate"

# Docker
if command -v docker >/dev/null 2>&1; then
    alias dps="docker ps"
    alias dpsa="docker ps -a"
    alias di="docker images"
    alias dex="docker exec -it"
    alias dlog="docker logs"
    alias dstop="docker stop"
    alias drm="docker rm"
    alias drmi="docker rmi"
    alias dprune="docker system prune -a"
fi

# Python
alias py="python3"
alias pip="pip3"
alias venv="python3 -m venv"
alias activate="source venv/bin/activate"

# ────────────────────────────────────────────────────────────────────────────────────────────────────────────
# 📋 CLIPBOARD - Platform aware
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────

# These are defined in zshrc.universal based on platform detection
# Just document them here for reference:
# clip - copy to clipboard
# paste - paste from clipboard

# Copy file contents to clipboard
copyfile() {
    if [[ -f "$1" ]]; then
        clip < "$1"
        echo "Copied $1 to clipboard"
    else
        echo "File not found: $1"
    fi
}

# ────────────────────────────────────────────────────────────────────────────────────────────────────────────
# 🔧 SYSTEM MAINTENANCE
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────

# Universal update command (uses update-universal script)
alias update="update"

# Clean common temporary files
alias cleanup="find . -type f -name '*.DS_Store' -ls -delete 2>/dev/null; find . -type f -name '*~' -ls -delete 2>/dev/null"

# ────────────────────────────────────────────────────────────────────────────────────────────────────────────
# 🎨 MISC UTILITIES
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────

# Reload shell configuration
alias reload="exec $SHELL"
alias src="source ~/.zshrc"

# Make common commands interactive for safety
alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'

# Human-readable sizes
alias df='df -h'
alias du='du -h'
alias free='free -h 2>/dev/null || vm_stat'

# URL encoding/decoding
alias urlencode='python3 -c "import sys, urllib.parse as ul; print(ul.quote_plus(sys.argv[1]))"'
alias urldecode='python3 -c "import sys, urllib.parse as ul; print(ul.unquote_plus(sys.argv[1]))"'

# Archive extraction
extract() {
    if [[ -f "$1" ]]; then
        case "$1" in
            *.tar.bz2) tar xjf "$1" ;;
            *.tar.gz)  tar xzf "$1" ;;
            *.tar.xz)  tar xJf "$1" ;;
            *.bz2)     bunzip2 "$1" ;;
            *.rar)     unrar x "$1" ;;
            *.gz)      gunzip "$1" ;;
            *.tar)     tar xf "$1" ;;
            *.tbz2)    tar xjf "$1" ;;
            *.tgz)     tar xzf "$1" ;;
            *.zip)     unzip "$1" ;;
            *.Z)       uncompress "$1" ;;
            *.7z)      7z x "$1" ;;
            *) echo "'$1' cannot be extracted" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Quick HTTP server
serve() {
    local port="${1:-8000}"
    if command -v python3 >/dev/null 2>&1; then
        python3 -m http.server "$port"
    elif command -v python >/dev/null 2>&1; then
        python -m SimpleHTTPServer "$port"
    else
        echo "Python not found"
    fi
}

# ────────────────────────────────────────────────────────────────────────────────────────────────────────────
# 📱 QUICK ACCESS
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────

# Weather (requires curl)
weather() {
    curl -s "wttr.in/${1:-}"
}

# Cheat sheet
cheat() {
    curl -s "cheat.sh/$1"
}

# ────────────────────────────────────────────────────────────────────────────────────────────────────────────
# 🔐 SAFETY ALIASES
# ────────────────────────────────────────────────────────────────────────────────────────────────────────────

# Safer rm with trash-cli if available
if command -v trash >/dev/null 2>&1; then
    alias rm='trash'
    alias rmf='/bin/rm'  # Force real rm when needed
fi

# Create backup of file
backup() {
    if [[ -f "$1" ]]; then
        cp "$1" "$1.$(date +%Y%m%d_%H%M%S).bak"
        echo "Backup created: $1.$(date +%Y%m%d_%H%M%S).bak"
    else
        echo "File not found: $1"
    fi
}