set nocompatible
filetype off

set runtimepath+=$XDG_CONFIG_HOME/nvim/plugged/deoplete.nvim
set completeopt+=noinsert,noselect
set completeopt-=preview

let g:python3_host_prog = '/usr/local/bin/python3'

call plug#begin('~/.vim/plugged')
Plug 'VundleVim/Vundle.vim'
Plug 'vim-syntastic/syntastic'
Plug 'vim-airline/vim-airline'
Plug 'tpope/vim-fugitive'
Plug 'ajh17/spacegray.vim'
Plug 'xuhdev/vim-latex-live-preview'
Plug 'terryma/vim-multiple-cursors'
Plug 'vim-latex/vim-latex'
Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'rip-rip/clang_complete'

if has('python3')
    Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
    let g:deoplete#enable_at_startup = 1
    let g:deoplete#disable_auto_complete = 0

    " deoplete tab-complete
    inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"

    Plug 'Rip-Rip/clang_complete'
    let g:clang_library_path='/usr/lib/llvm-3.6/lib/'

    Plug 'zchee/deoplete-jedi'
end

call plug#end()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Sets how many lines of history VIM has to remember
set history=250

" Remove trailing whitespace per save
autocmd BufWritePre * %s/\s\+$//e

" Use system clipboard
set clipboard=unnamed

" Set to auto read when a file is changed from the outside
set autoread

" Fast saving
nmap <leader>w :w!<cr>

" Tab management
set shiftwidth=4
set tabstop=4

set expandtab
set shiftwidth=4
set softtabstop=4

" Use tabas in makefiles though..
autocmd FileType make set noexpandtab

set smartindent
set autoindent

" Relative line numbers yo
set nu
set relativenumber

" Highlight searches
set hlsearch

" Ignore case in searches
set ignorecase

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM user interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable syntax highlighting
syntax on

set guicursor=
let g:spacegray_underline_search = 1

colorscheme spacegray
set termguicolors

set t_Co=256

if filereadable(expand("~/.vimrc_background"))
  let base16colorspace=256
endif

set spell spelllang=en_us

" Highlight search results
set hlsearch

" For regular expressions turn magic on
set magic

" No annoying sound on errors
set noerrorbells
set novisualbell
set t_vb=
set tm=500

" Set utf8 as standard encoding and en_US as the standard language
set encoding=utf8

" Use Unix as the standard file type
set ffs=unix,dos,mac

" Use wilmenu
set wildmenu
set wildmode=longest:list,full

" Show the cursor's current line
set number

" Highlight the current line
" Only highlights the active window, and only when vim is in focus
set cursorline
hi CursorLine term=bold cterm=bold guibg=Grey40
augroup CursorLine
  au!
  au VimEnter,WinEnter,BufWinEnter * setlocal cursorline
  au WinLeave * setlocal nocursorline
augroup END

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Files, backups and undo
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Turn backup off, since most stuff is in SVN, git et.c anyway...
set nobackup
set nowb
set noswapfile

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Files, backups and undo
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
cnoreabbrev W w
cnoreabbrev Q q

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Key mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Because I type Wq literally all the time
:command W w
:command Q q
:command Wq wq

noremap <up> <C-w><up>
noremap <down> <C-w><down>
noremap <left> <C-w><left>
noremap <right> <C-w><right>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Syntastic
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

let g:syntastic_cpp_checkers = ['gcc']

let g:syntastic_python_checkers=['flake8']
let g:syntastic_python_flake8_args='--ignore=E501,E225'

if !exists('g:ycm_semantic_triggers')
    let g:ycm_semantic_triggers = {}
endif
let g:ycm_semantic_triggers.tex = [
            \ 're!\\[A-Za-z]*cite[A-Za-z]*(\[[^]]*\]){0,2}{[^}]*',
            \ 're!\\[A-Za-z]*ref({[^}]*|range{([^,{}]*(}{)?))',
            \ 're!\\hyperref\[[^]]*',
            \ 're!\\includegraphics\*?(\[[^]]*\]){0,2}{[^}]*',
            \ 're!\\(include(only)?|input){[^}]*',
            \ 're!\\\a*(gls|Gls|GLS)(pl)?\a*(\s*\[[^]]*\]){0,2}\s*\{[^}]*',
            \ 're!\\includepdf(\s*\[[^]]*\])?\s*\{[^}]*',
            \ 're!\\includestandalone(\s*\[[^]]*\])?\s*\{[^}]*',
            \ 're!\\usepackage(\s*\[[^]]*\])?\s*\{[^}]*',
            \ 're!\\documentclass(\s*\[[^]]*\])?\s*\{[^}]*',
            \ 're!\\[A-Za-z]*',
            \ ]


" Enable mouse support
if has("mouse")
    set mouse=a
endif

" Airline Support
set encoding=utf-8
let g:airline_powerline_fonts = 1
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
let g:airline_symbols.space = "\ua0"

set completeopt-=preview

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Skelton Files
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has("autocmd")
    augroup templates
        autocmd BufNewFile main.* silent! execute '0r ~/.vim/skeleton-files/skeleton-main.'.expand("<afile>:e")
        autocmd BufNewFile *.* silent! execute '0r ~/.vim/skeleton-files/skeleton.'.expand("<afile>:e")

        autocmd BufNewFile * %substitute#\[:VIM_EVAL:\]\(.\{-\}\)\[:END_EVAL:\]#\=eval(submatch(1))#ge
    augroup END
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => LaTeX Stuff
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:livepreview_previewer = 'open -a Skim'

