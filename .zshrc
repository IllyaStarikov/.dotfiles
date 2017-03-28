export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=/Users/Illya/.oh-my-zsh

# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
ZSH_THEME="robbyrussell"

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
plugins=(git brew catimg gitfast git-extras osx pod python vi-mode)

source $ZSH/oh-my-zsh.sh

# If on SSH, just use vim
if [[ $SSH_CONNECTION ]]; then
   export EDITOR='vim'
fi

# Aliases
alias python="python3"
alias vim="mvim -O -v -u ~/.dotfiles/.vimrc"
alias diff="colordiff"
alias grep="grep --color=auto -E"

## get rid of command not found
alias cd..="cd .."

## a quick way to get out of current directory
alias ..="cd .."
alias ...="cd ../../../"
alias ....="cd ../../../../"
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

echo 'bindkey "^X\\x7f" backward-kill-line' >> ~/.zshrc
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
bindkey "^X\x7f" backward-kill-line
