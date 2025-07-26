alias vim="nvim"
alias vi="nvim"
alias ranger="source ranger"
alias tx="tmuxinator"
alias txs="tmuxinator start"

# Modern ls replacement with better defaults
alias ls="eza --group-directories-first"
alias ll="eza -l --group-directories-first --time-style=relative"
alias la="eza -la --group-directories-first --time-style=relative"
alias tree="eza --tree"

alias haskell="ghci"
alias haskellcc="ghc"

alias diff="colordiff"
alias grep="grep --color=always"
alias reset="source ~/.zshrc && reset"

alias pandoc="pandoc --wrap=none --listings"
alias gl="git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit"
alias theme="~/.dotfiles/src/theme-switcher/switch-theme.sh"
alias install-auto-theme="~/.dotfiles/src/theme-switcher/install-auto-theme.sh"

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
# Modern ripgrep-based search (faster than ack)
alias todos="rg -n --no-heading '(TODO|FIX(ME)?|NOTE|HACK)'"
alias find-file="fd"
alias find-content="rg"

## disk stuff...
alias df='df -H'
alias du='du -ch'
