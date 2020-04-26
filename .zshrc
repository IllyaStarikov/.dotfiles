# Set name of the theme to load. Optionally, if you set this to "random"
# it'll load a random theme each time that oh-my-zsh is loaded.
# See https://github.com/robbyrussell/oh-my-zsh/wiki/Themes
# ZSH_THEME="spaceship"
ZSH_THEME="spaceship"
SPACESHIP_VI_MODE_INSERT="[λ]"
SPACESHIP_VI_MODE_NORMAL="[µ]"
SPACESHIP_BATTERY_SHOW=false

# Which plugins would you like to load? (plugins can be found in ~/.oh-my-zsh/plugins/*)
# Custom plugins may be added to ~/.oh-my-zsh/custom/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
#
# Note: zsh-syntax-highlighting must be installed first.
# https://github.com/zsh-users/zsh-syntax-highlighting/blob/master/INSTALL.md#oh-my-zsh
plugins=(vi-mode git brew history-substring-search python osx zsh-syntax-highlighting)

# Faster Vim Mode
export KEYTIMEOUT=1

# Enable command correction
ENABLE_CORRECTION="true"

# Display red dots whilst waiting for completion.
COMPLETION_WAITING_DOTS="true"

# Disable marking untracked files under VCS as dirty.
DISABLE_UNTRACKED_FILES_DIRTY="true"

# Change the command execution time
HIST_STAMPS="mm/dd/yyyy"

export ZSH=/Users/starikov/.oh-my-zsh
export ZSH_CUSTOM=/Users/starikov/.oh-my-zsh/custom/
source $ZSH/oh-my-zsh.sh

BASE16_SCHEME="default"
BASE16_BACKGROUND="dark"
BASE16_SHELL="$HOME/.config/base16-shell/base16-$BASE16_SCHEME.$BASE16_BACKGROUND.sh"
[[ -s $BASE16_SHELL ]] && . $BASE16_SHELL

# Aliases
alias vim="nvim -O"
alias vi="nvim -O"
alias ranger="source ranger"
alias python="python3"
alias ipython="python3 -m IPython"
alias pip="python3 -m pip"

alias haskell="ghci"
alias haskellcc="ghc"

alias diff="colordiff"
alias grep="grep --color=always"
alias reset="source ~/.zshrc && reset"

alias pandoc="pandoc --wrap=none --listings"
alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"

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
alias todos="ack -n --nogroup '(TODO|FIX(ME)?|NOTE|HACK)'"

## disk stuff...
alias df='df -H'
alias du='du -ch'

# Man autocomplete
zstyle ':completion:*:manuals'    separate-sections true
zstyle ':completion:*:manuals.*'  insert-sections   true
zstyle ':completion:*:man:*'      menu yes select

# Search Through History with arrow
bindkey "^[[A" history-substring-search-up
bindkey "^[[B" history-substring-search-down

# map delete line (iTerm thing)
bindkey "^X\x7f" backward-kill-line

# Add colors to Terminal
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

export EDITOR=nvim
export VISUAL=nvim

export TERM=xterm-256color

[ -d ~/.localrc ]   && source ~/.localrc
[ -d ~/.shortcuts ] && source ~/.shortcuts
[ -d ~/.programs ]  && export PATH=$PATH:~/.programs/

[ -f ~/.fzf.zsh ]   && source ~/.fzf.zsh
