set nocompatible
filetype off

set runtimepath+="~/.vim/plugged/deoplete.nvim"
set completeopt+=noinsert,noselect
set completeopt-=preview

let g:python3_host_prog = '/usr/local/bin/python3'

filetype plugin on

call plug#begin('~/.vim/plugged')
Plug 'vim-syntastic/syntastic'
Plug 'vim-airline/vim-airline'
Plug 'tpope/vim-fugitive'
Plug 'ajh17/spacegray.vim'
Plug 'rip-rip/clang_complete', { 'for': ['C', 'C++'] }
Plug 'lervag/vimtex', { 'for': 'tex' }
Plug 'Shougo/neosnippet.vim'
Plug 'IllyaStarikov/neosnippet-snippets'

Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'Rip-Rip/clang_complete', { 'do': 'nvim -c \"r! git ls-files autoload bin doc plugin\" -c \"$$,$$d _\" -c \"%MkVimball! $@ .\" -c \"q!\" && nvim &< -c \"so %\" -c \"q\"' }
Plug 'zchee/deoplete-jedi'
call plug#end()


" => General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Sets how many lines of history VIM has to remember
set history=250

augroup spaces
  autocmd!

" Remove trailing whitespace per save
    autocmd BufWritePre * %s/\s\+$//e

" Use tabas in makefiles though..
autocmd FileType make set noexpandtab

augroup END

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
set re=1

set nocursorcolumn
set nocursorline
syntax sync minlines=256

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

" To stop yanking everytime I delete
nnoremap <leader>d "_d
vnoremap <leader>d "_d
vnoremap <leader>p "_dP

" Because who needs arrow keys
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
let g:airline_powerline_fonts = 1
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
let g:airline#extensions#whitespace#enabled = 0
set lazyredraw
let g:airline_symbols_ascii = 1

set completeopt-=preview

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Skelton Files
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has("autocmd")
    augroup templates
        autocmd!
        autocmd BufNewFile main.* silent! execute '0r ~/.vim/skeleton-files/skeleton-main.'.expand("<afile>:e")
        autocmd BufNewFile *.* silent! execute '0r ~/.vim/skeleton-files/skeleton.'.expand("<afile>:e")

        autocmd BufNewFile * %substitute#\[:VIM_EVAL:\]\(.\{-\}\)\[:END_EVAL:\]#\=eval(submatch(1))#ge
    augroup END
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => LaTeX Stuff
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:livepreview_previewer = 'open -a Skim'

set grepprg=grep\ -nH\ $*
filetype indent on
let g:vimtex_enabled = 1
let g:vimtex_complete_close_braces = 1
let g:vimtex_fold_comments = 1

set completeopt+=noinsert
set completeopt-=preview

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Autocomplete
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" deoplete stuff
inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"

let g:deoplete#enable_at_startup = 1
let g:deoplete#auto_completion_start_length = 1
let g:deoplete#enable_smart_case = 1
let g:deoplete#disable_auto_complete = 0

" neosnippet
imap <expr><TAB> neosnippet#expandable_or_jumpable() ?
            \ "\<Plug>(neosnippet_expand_or_jump)"
            \: pumvisible() ? "\<C-n>" : "\<TAB>"
smap <expr><TAB> neosnippet#expandable_or_jumpable() ?
            \ "\<Plug>(neosnippet_expand_or_jump)"
            \: "\<TAB>"

" For snippet_complete marker.
if has('conceal')
    set conceallevel=2 concealcursor=i
endif

" Enable snipMate compatibility feature.
let g:neosnippet#enable_snipmate_compatibility = 1
let g:neosnippet#snippets_directory = '$HOME/vimfiles/bundle/vim-snippets/snippets, $HOME/snippets'

" clang complete stuff
let g:clang_library_path = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/libclang.dylib"

let g:clang_complete_auto = 0
let g:clang_auto_select = 0
let g:clang_omnicppcomplete_compliance = 0
let g:clang_make_default_keymappings = 0

au FileType c,cpp,objc,objcpp setl omnifunc=clang_complete#ClangComplete

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Key mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Because I type Wq literally all the time
:command W w
:command Q q
:command Wq wq

" To stop yanking everytime I delete
nnoremap <leader>d "_d
vnoremap <leader>d "_d
vnoremap <leader>p "_dP

" Because who needs arrow keys
noremap <up> <C-w><up>
noremap <down> <C-w><down>
noremap <left> <C-w><left>
noremap <right> <C-w><right>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Leader Key Shortcuts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let mapleader = "\<Space>"

" Fast saving
nnoremap <Leader>w :w<CR>

" Fast Closing
nnoremap <Leader>q :q<CR>

" fast opening
nnoremap <Leader>o <C-P>

" Fast opening and closing vim
nnoremap <Leader>s <C-Z>

" Fast visual mode
nmap <Leader><Leader> V

" Copy/past to system clipboard
vmap <Leader>y "+y
vmap <Leader>d "+d
nmap <Leader>p "+p
nmap <Leader>P "+P
vmap <Leader>p "+p
vmap <Leader>P "+P
