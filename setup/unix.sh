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

# Vim
curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim

# Pip Packages
python3 -m pip install neovim
python3 -m pip install ipython

# Global Git Ignore
git config --global core.excludesfile '~/.gitignore'

# Fonts
git clone https://github.com/ryanoasis/nerd-fonts.git fonts
source fonts/install.sh IBMPlexMono
rm -rf fonts
