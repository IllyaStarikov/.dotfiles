set nocompatible
set completeopt+=noinsert,noselect
set completeopt-=preview

filetype plugin on
filetype indent on

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Plugins
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call plug#begin('~/.vim/plugged')
Plug 'vim-airline/vim-airline'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'junegunn/vim-easy-align'

Plug 'tommcdo/vim-lion'
Plug 'wellle/targets.vim'

Plug 'keith/swift.vim', { 'for': ['Swift'] }
Plug 'kien/ctrlp.vim'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }

Plug 'tyrannicaltoucan/vim-quantum'

Plug 'lervag/vimtex', { 'for': 'tex' }
Plug 'SirVer/ultisnips'
Plug 'IllyaStarikov/vim-snippets'

if v:version >= 800
    Plug 'maralla/completor.vim'
    Plug 'w0rp/ale'
endif

call plug#end()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Sets how many lines of history VIM has to remember
set history=250

" Set 7 lines to the cursor - when moving vertically using j/k
set so=7

" Yank to system clipboard by default
set clipboard=unnamed

" Proper backspace
set backspace=indent,eol,start

fun! TrimWhitespace()
    let l:save = winsaveview()
    %s/\t/    /e
    %s/\s\+$//e
    call winrestview(l:save)
endfun

" Enable mouse support
if has("mouse")
    set mouse=a
endif

autocmd BufWritePre * :call TrimWhitespace()
augroup spaces
    autocmd!

    " Use tabs in makefiles though..
    autocmd FileType make set noexpandtab
augroup END

" Set to auto read when a file is changed from the outside
set autoread

" Tab management
set shiftwidth=4
set tabstop=4

set expandtab
set shiftwidth=4
set softtabstop=4

set smartindent
set autoindent
set linebreak

" Relative line numbers yo
set nu
set relativenumber

" Highlight searches
set hlsearch

" Ignore case in searches
set ignorecase

" Python 3 host
let g:python3_host_prog = '/usr/local/bin/python3'

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => VIM user interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Enable syntax highlighting
syntax on
set re=1

" Cursor stuff
set nocursorcolumn
set nocursorline

set cursorline!
set guicursor=a:hor20-Cursor

" Don't syntax highlight after the 128th column
" Most for performance
set synmaxcol=128

" except for LaTeX and markdown
augroup syntaxmax
    autocmd!
    autocmd FileType tex,latex,markdown set synmaxcol=2048
augroup END

let g:quantum_black = 1
let g:quantum_italics = 1

set background=dark
set termguicolors
colorscheme quantum

let g:airline_theme = 'quantum'

" Nice colors
set t_Co=256

if filereadable(expand("~/.vimrc_background"))
    let base16colorspace=256
endif

set spell spelllang=en_us

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

" if windows gvim, change font
if has('win32')
    set guifont=Fira\ Mono\ for\ Powerline:h11
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Files, backups and undo
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Turn backup off, since most stuff is in SVN, git et.c anyway...
set nobackup
set nowb
set noswapfile

autocmd BufNewFile,BufRead *.tex set syntax=tex
let g:tex_flavor = "xelatex"

augroup filetype
    au BufRead,BufNewFile *.flex,*.jflex    set filetype=jflex
augroup END
au Syntax jflex    so ~/.vim/syntax/jflex.vim

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Autocomplete/Snippets/Linting
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:UltiSnipsExpandTrigger = "<nop>"
let g:ulti_expand_or_jump_res = 0

function! ExpandSnippetOrCarriageReturn()
    let snippet = UltiSnips#ExpandSnippetOrJump()
    if g:ulti_expand_or_jump_res > 0
        return snippet
    else
        return "\<CR>"
    endif
endfunction

inoremap <expr> <CR> pumvisible() ? "<C-R>=ExpandSnippetOrCarriageReturn()<CR>" : "\<CR>"

let g:UltiSnipsJumpForwardTrigger = "<tab>"
let g:UltiSnipsJumpBackwardTrigger = "<s-tab>"
set shortmess+=c

if v:version >= 800
    inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
    inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

    let g:ale_linters = {
    \   'tex': ['chktex --nwarn 24'],
    \}

    let g:ale_echo_msg_error_str = 'E'
    let g:ale_echo_msg_warning_str = 'W'
    let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
    let g:ale_lint_delay = 500
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Airline
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:airline_powerline_fonts = 1
if !exists('g:airline_symbols')
    let g:airline_symbols = {}
endif
let g:airline#extensions#whitespace#enabled = 0
set lazyredraw
let g:airline_symbols_ascii = 1
let g:airline#extensions#ale#enabled = 1
let g:airline_detect_spell = 0

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
let g:Tex_CompileRule_pdf = 'xelatex --interaction=nonstopmode $*'

set grepprg=grep\ -nH\ $*
let g:vimtex_enabled = 1
let g:vimtex_complete_close_braces = 1
let g:vimtex_fold_comments = 1

let g:vimtex_disable_version_warning = 1
let g:vimtex_compiler_latexmk = {'callback' : 0}

autocmd BufNewFile,BufRead *.tex set syntax=tex
let g:tex_flavor = "xelatex"

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Key mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Because I type Wq literally all the time
:command! W w
:command! Q q
:command! Wq wq

" Go up and down properly on wrapped text
nnoremap <Down> gj
nnoremap <Up> gk
vnoremap <Down> gj
vnoremap <Up> gk
inoremap <Down> <C-o>gj
inoremap <Up> <C-o>gk

" I actually like the cursor in middle of the screen at the bottom
noremap G Gzz

" Because i use word wrap like a sane human
nnoremap <expr> k (v:count == 0 ? 'gk' : 'k')
nnoremap <expr> j (v:count == 0 ? 'gj' : 'j')
noremap  <buffer> <silent> 0 g0
noremap  <buffer> <silent> $ g$

" Because who needs arrow keys
noremap <up> <C-w><up>
noremap <down> <C-w><down>
noremap <left> <C-w><left>
noremap <right> <C-w><right>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Leader Key Shortcuts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let mapleader = "\<Space>"

nnoremap <leader>w :w<CR>
noremap <leader>q :q<CR>
noremap <leader>x :x<CR>
nnoremap <leader>o <C-P>
nnoremap <leader>s <C-Z>
nnoremap <leader>d "_d
nmap <leader><leader> 0v$h
nmap <leader>c gc
noremap <silent> <leader>n :NERDTreeToggle<cr>

xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Background Code
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
augroup run
    autocmd!
    autocmd FileType tex nnoremap <buffer><leader>r :AsyncRun! latexmk<cr>
    autocmd FileType c nnoremap <buffer><leader>r :RunBackgroundCommand make<cr>
    autocmd FileType cpp nnoremap <buffer><leader>r :RunBackgroundCommand make<cr>
    autocmd FileType python nnoremap <buffer><leader>r :AsyncRun! -raw=1 python %<cr>
    autocmd FileType perl nnoremap <buffer><leader>r :exec '!perl' shellescape(@%, 1)<cr>
    autocmd FileType sh nnoremap <buffer><leader>r :exec '!bash' shellescape(@%, 1)<cr>
    autocmd FileType swift nnoremap <buffer><leader>r :exec '!swift' shellescape(@%, 1)<cr>
    nnoremap <leader>R :!<Up><CR>
augroup END

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
fun! TrimWhitespace()
    let l:save = winsaveview()
    %s/\t/    /e
    %s/\s\+$//e
    call winrestview(l:save)
endfun

function! ExpandSnippetOrCarriageReturn()
    let snippet = UltiSnips#ExpandSnippetOrJump()
    if g:ulti_expand_or_jump_res > 0
        return snippet
    else
        return "\<CR>"
    endif
endfunction
