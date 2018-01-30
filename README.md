# .dotfiles

All of my frequently used dotfiles, including:

- [Vim](http://www.vim.org) config (`.vimrc`) and spell file (`spell-file.add`)
- [Z-Shell](https://github.com/robbyrussell/oh-my-zsh) config (`.zhsrc`)
- [iTerm](https://www.iterm2.com) profile (`itermrc.json`) as JSON
- [LaTeX](https://www.latex-project.org/) make config  (`latexmkrc`)

Currently, I am using [Vim 8](https://github.com/vim/vim). My package manager of choice is [Plug](https://github.com/junegunn/vim-plug); after installation, run `PlugInstall`. The skeleton files are in a separate repository, you can find them [here](https://github.com/IllyaStarikov/skeleton-files).

My zsh setup is managed by [oh-my-zsh](https://github.com/robbyrussell/oh-my-zsh). Aliases are also in `.zshrc`. Theme is [Spaceship](https://github.com/denysdovhan/spaceship-prompt).

iTerm is a great alternative to macOS Terminal.app. The profile is a JSON export of my profile settings; to import `Preferences -> General -> Load preferences from a custom folder or URL`.

The `latexmkrc` is the default settings for `latexmk`. Useful for cleaning output files, setting a default previewer, etc.
