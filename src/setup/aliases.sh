# Create symlinks for all the relevant files

# -s | `symbolic` (soft) link
# -f | `force` the symlink if it already exists

# Vim
ln -sf "$HOME/.dotfiles/src/vimrc" "$HOME/.vimrc"
ln -sf "$HOME/.dotfiles/src/vimrc" "$HOME/.config/nvim/init.vim"

# ZSH
ln -sf "$HOME/.dotfiles/src/zshrc" "$HOME/.zshrc"
ln -sf "$HOME/.dotfiles/src/zshenv" "$HOME/.zshenv"

# Terminal
ln -sf "$HOME/.dotfiles/src/alacritty.toml" "$HOME/.config/alacritty/"

# Gitignore
ln -sf "$HOME/.dotfiles/src/gitignore" "$HOME/.gitignore"

# LaTeX
ln -sf "$HOME/.dotfiles/src/latexmkrc" "$HOME/.latexmkrc"

# TMUX
ln -sf "$HOME/.dotfiles/src/tmux.conf" "$HOME/.tmux.conf"
ln -sf "$HOME/.dotfiles/src/tmuxinator" "$HOME/.tmuxinator"
ln -sf "$HOME/.dotfiles/src/tmuxinator" "$HOME/.config/tmuxinator"

# Custom Aliases
ln -sf "$HOME/.dotfiles/src/shortcuts.sh" "$HOME/.shortcuts"
ln -sf "$HOME/.dotfiles/src/scripts" "$HOME/.scripts"

