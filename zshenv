export PATH=$HOME/bin:/usr/local/bin:$PATH

# Path to your oh-my-zsh installation.
export ZSH=/Users/Illya/.oh-my-zsh

# Faster vim mode
export KEYTIMEOUT=1

# If on SSH, just use vim
if [[ $SSH_CONNECTION ]]; then
   export EDITOR='vim'
fi

export python3="/usr/local/bin/python3"

# If not on SSH, still use vim
export VISUAL=nvim
export EDITOR="$VISUAL"
