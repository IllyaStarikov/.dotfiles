"
" .vimrc
" .dotfiles
"
" Created by Illya Starikov on March 5th, 2017
" Copyright 2017. Illya Starikov. All rights reserved.
"

" Table of Contents
" 1  .................... Plugins
" 2  .................... General
" 3  .................... User Interface
" 4  .................... Autocomplete/Snippets/Linting
" 5  .................... Airline
" 6  .................... Skeleton Files
" 7  .................... Key Mappings
" 8  .................... Leader Key
" 9  .................... Code Runner
" 10 .................... Functions

set nocompatible
set completeopt+=noinsert,noselect
set completeopt-=preview

filetype plugin on
filetype indent on

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => 1. Plugins
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

Plug 'dracula/vim'

Plug 'SirVer/ultisnips'
Plug 'IllyaStarikov/vim-snippets'

if v:version >= 800
    Plug 'skywind3000/asyncrun.vim'
    Plug 'maralla/completor.vim'
    Plug 'w0rp/ale'

    Plug 'Rip-Rip/clang_complete', { 'for': ['cpp'] }
endif

call plug#end()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => 2. General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set history=250                " Sets how many lines of history VIM has to remember
set so=7                       " Set 7 lines to the cursor - when moving vertically using j/k
set clipboard=unnamed          " Yank to system clipboard by default
set backspace=indent,eol,start " Proper backspace

set autoread                   " Set to auto read when a file is changed from the outside

set expandtab                  " tabs => spaces
set shiftwidth=4
set tabstop=4
set softtabstop=4

set smartindent                " autoindent on newlines
set autoindent                 " copy indentation from previous lines
set linebreak                  " word wrap like a sane human being

set number                     " Show current line number
set relativenumber             " Relative line numbers yo
set hlsearch                   " Highlight searches

set nobackup                   " Turn backup off
set nowb
set noswapfile

let g:tex_flavor = "latex"

augroup makefiles
    autocmd!
    autocmd FileType make,makefile set noexpandtab

    let blacklist = ['make', 'makefile']
    autocmd BufWritePre * if index(blacklist, &ft) < 0 | :call TrimWhitespace()
augroup END

" Enable mouse support
if has("mouse")
    set mouse=a
endif

" This is needed for.. something
let g:python3_host_prog = '/usr/local/bin/python3' " Python 3 host

" NerdTree Stuff
let g:NERDTreeWinPos = "right"
let NERDTreeMapOpenInTab = "<CR>"
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => 3. User Interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
syntax on                    " Syntax highlighting
syntax enable
set spell spelllang=en_us    " set english as standard language
set encoding=utf8            " Set utf8 as standard encoding

set t_Co=256                 " 256 colors for terminal
set termguicolors
set background=dark

colorscheme dracula
let g:airline_theme = 'dracula'
hi SpellBad cterm=bold,underline
let g:dracula_italics = 1

set nocursorcolumn           " Don't highlight column
set nocursorline             " I need this for cursorline
set cursorline!              " Turn on the cursorline
set guicursor=a:hor20-Cursor " Set it to something reasonable
set synmaxcol=128            " Don't syntax highlight after the 128th column

set magic                    " For regular expressions

set ffs=unix,dos,mac         " Use Unix as the standard file type

set wildmenu                 " Use wild-menu
set wildmode=longest:list,full

set noerrorbells             " no annoying error noises
set novisualbell
set t_vb=
set tm=500

" Syntax highlighting for latex/markdown as infinite
augroup syntax
    autocmd!
    autocmd FileType tex,latex,markdown set synmaxcol=2048

    autocmd BufNewFile,BufRead *.tex set syntax=tex
augroup END


" if windows gvim, change font
if has('win32')
    set guifont=Fira\ Mono\ for\ Powerline:h11
endif

let NERDTreeMapOpenInTab='\r'

set list
set showbreak=↪\
set listchars=tab:→\ ,nbsp:␣,trail:•,extends:⟩,precedes:⟨

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => 4. Autocomplete/Snippets/Linting
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:completor_python_binary = '/usr/local/bin/python3'

let g:UltiSnipsExpandTrigger = "<nop>"
inoremap <expr> <CR> pumvisible() ? "<C-R>=ExpandSnippetOrCarriageReturn()<CR>" : "\<CR>"

let g:UltiSnipsJumpForwardTrigger = "<tab>"
let g:UltiSnipsJumpBackwardTrigger = "<s-tab>"
set shortmess+=c

if v:version >= 800
    inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
    inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

    let g:clang_library_path = "/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/"

    let g:ale_linters = {
                \   'tex': ['chktex'],
                \}

    let g:ale_vim_chktex_options = "--nwarn 24"
    let g:ale_python_flake8_options = "--max-line-length=200"

    let g:ale_echo_msg_error_str = 'E'
    let g:ale_echo_msg_warning_str = 'W'
    let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
    let g:ale_lint_delay = 500
endif

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => 5. Airline
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
" => 6. Skeleton Files
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
" => 7. Key Mappings
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
" => 8. Leader Key
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let mapleader = "\<Space>"

nnoremap <leader>w :w<cr>
noremap <leader>q :q<cr>
noremap <leader>x :x<cr>
nnoremap <leader>s <C-Z>
nnoremap <leader>d "_d
noremap <leader>m `
nnoremap <leader>p :CtrlP<cr>
nmap <leader><leader> 0v$h
nmap <leader>c gc
noremap <silent> <leader>n :NERDTreeToggle<cr>

xmap ga <Plug>(EasyAlign)
nmap ga <Plug>(EasyAlign)

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => 9. Code Runner
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! RunCode(runCommand)
    if filereadable("makefile") || filereadable("Makefile")
        :execute 'AsyncRun make'
    else
        :execute 'AsyncRun ' a:runCommand
    endif
endfunction

augroup run
    autocmd!
    let windowopen = 1
    autocmd FileType tex,plaintex let windowopen = 0
    autocmd QuickFixCmdPost * call asyncrun#quickfix_toggle(8, windowopen)

    autocmd FileType python   nnoremap <buffer><leader>r :call RunCode("python3 %")<cr>
    autocmd FileType c        nnoremap <buffer><leader>r :call RunCode("clang *.c -o driver && ./driver")<cr>
    autocmd FileType cpp      nnoremap <buffer><leader>r :call RunCode("clang++ *.cpp -std=c++14 -o driver && ./driver")<cr>
    autocmd FileType tex      nnoremap <buffer><leader>r :call RunCode("latexmk")<cr>
    autocmd FileType plaintex nnoremap <buffer><leader>r :call RunCode("latexmk")<cr>
    autocmd FileType perl     nnoremap <buffer><leader>r :call RunCode("perl %")<cr>
    autocmd FileType sh       nnoremap <buffer><leader>r :call RunCode("!bash %")<cr>
    autocmd FileType swift    nnoremap <buffer><leader>r :call RunCode("swift %") <cr>

    nnoremap <leader>R :Async<Up><CR>
augroup END

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => 10. Functions
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
function! TrimWhitespace()
    let l:save = winsaveview()
    %s/\t/    /e
    %s/\s\+$//e
    call winrestview(l:save)
endfunction

function! ExpandSnippetOrCarriageReturn()
    let snippet = UltiSnips#ExpandSnippetOrJump()
    if g:ulti_expand_or_jump_res > 0
        return snippet
    else
        return "\<CR>"
    endif
endfunction
