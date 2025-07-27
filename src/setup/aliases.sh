# Create symlinks for all the relevant files

# -s | `symbolic` (soft) link
# -f | `force` the symlink if it already exists

# Neovim (modern Lua configuration)
rm -f "$HOME/.config/nvim/init.vim"  # Remove any conflicting init.vim
ln -sf "$HOME/.dotfiles/src/init.lua" "$HOME/.config/nvim/init.lua"
ln -sf "$HOME/.dotfiles/src/lua" "$HOME/.config/nvim/lua"

# Legacy Vim compatibility (VimScript wrapper)
ln -sf "$HOME/.dotfiles/src/vimrc" "$HOME/.vimrc"


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

# Spell files for Neovim
mkdir -p "$HOME/.config/nvim"
ln -sf "$HOME/.dotfiles/src/spell" "$HOME/.config/nvim/spell"

