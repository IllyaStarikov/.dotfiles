#!/bin/bash

# Dotfiles (+ Linking, but not ZSH because it will get overwritten)
git clone https://github.com/IllyaStarikov/.dotfiles.git ~/.dotfiles

mv ~/.vimrc ~/.vimrc.old # A vimrc might already exist
mkdir -p ~/.config/nvim  # This directory might not exist yet

# ZSH
sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# NOTE/WARNING: Installation might stop here. This is because a new shell is installed, and because the
# shell is switched, the shell script might not be able to proceed.

# Run the following two commands, and in the ZSHRC replace /Users/starikov with where /.../starikov exists
mv ~/.zshrc ~/.zshrc.pre-oh-my-zsh

## Spaceship Theme
git clone https://github.com/denysdovhan/spaceship-prompt.git "$ZSH_CUSTOM/themes/spaceship-prompt"
ln -s "$ZSH_CUSTOM/themes/spaceship-prompt/spaceship.zsh-theme" "$ZSH_CUSTOM/themes/spaceship.zsh-theme"

## ZSH Syntax Highlighting & Auto-suggestions
brew install zsh-syntax-highlighting
brew install zsh-autosuggestions

# Vim
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

xcode-select --install

# Brew (and associated packages)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
chsh -s /bin/zsh

brew install pyenv
brew install neovim
brew install ranger
brew install fzf
brew install tmux
brew install tmuxinator

# Modern CLI tools
brew install eza        # Modern ls replacement
brew install bat        # Better cat with syntax highlighting
brew install ripgrep    # Better grep
brew install fd         # Better find
brew install htop       # Better top
brew install procs      # Modern ps
brew install git-delta  # Better git diff
brew install zoxide     # Smarter cd
brew install starship   # Consider as alternative to spaceship prompt

# Pip Packages
python3 -m pip install neovim
python3 -m pip install ipython

# Global Git Ignore
git config --global core.excludesfile '~/.gitignore'

# Fonts - Install JetBrainsMono Nerd Font as default
brew tap homebrew/cask-fonts
brew install --cask font-jetbrains-mono-nerd-font
brew install --cask font-symbols-only-nerd-font  # For additional glyph coverage

# Also install powerline fonts for compatibility
brew install --cask font-meslo-lg-nerd-font  # Fallback option

