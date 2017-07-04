# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="spaceship"

# Enable command correction
ENABLE_CORRECTION="true"

# Display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Disable marking untracked files under VCS as dirty.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Change the command execution time
HIST_STAMPS="mm/dd/yyyy"

# Whiddch plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(git brew catimg gitfast git-extras osx history-substring-search python vi-mode git-open)
source $ZSH/oh-my-zsh.sh

BASE16_SCHEME="default"
BASE16_BACKGROUND="dark"
BASE16_SHELL="$HOME/.config/base16-shell/base16-$BASE16_SCHEME.$BASE16_BACKGROUND.sh"
[[ -s $BASE16_SHELL ]] && . $BASE16_SHELL

# Aliases
alias python="python3"
alias pip="python -m pip"
alias vim="nvim -O -u ~/.dotfiles/.vimrc"
alias diff="colordiff"
alias grep="grep --color=auto -E"
alias pandoc="pandoc --smart --normalize --wrap=none --listings"
alias reset="source ~/.zshrc && reset"
alias ianvim="nvim -O -v -u ~/.ian-dotfiles/vimrc"
alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

## Because I need to get in the habit of not rming
alias del="rmtrash"
alias rm="echo Use 'del', or the full path i.e. '/bin/rm'"

## get rid of command not found
alias cd..="cd .."

## a quick way to get out of current directory
alias ..="cd .."
alias ...="cd ../../"
alias ....="cd ../../../"
alias .....="cd ../../../../"
alias .4="cd ../../../../"
alias .5="cd ../../../../.."

## get current public IP
alias ip="curl icanhazip.com"

## list TODO/FIX lines from the current project
alias todos="ack -n --nogroup '(TODO|FIX(ME)?):'"

## disk stuff...
alias df='df -H'
alias du='du -ch'

## because i have a habit of running git add -A
git() {
    if [[ $@ == "add -A" ]]; then
        command git add -p
    else
        command git "$@"
    fi
}

# Man autocomplete
zstyle ':completion:*:manuals'    separate-sections true
zstyle ':completion:*:manuals.*'  insert-sections   true
zstyle ':completion:*:man:*'      menu yes select

# Search Through History with arrow
bindkey "^[[A" history-substring-search-up
bindkey "^[[B" history-substring-search-down

# map delete line (iTerm thing)
bindkey "^X\x7f" backward-kill-line


source "/Users/Illya/.oh-my-zsh/custom/themes/spaceship.zsh-theme"
