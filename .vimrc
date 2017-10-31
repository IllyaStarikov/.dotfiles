set nocompatible
filetype off

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Plugins
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set completeopt+=noinsert,noselect
set completeopt-=preview

filetype plugin on

call plug#begin('~/.vim/plugged')
Plug 'vim-syntastic/syntastic'
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

if has('nvim')
    set runtimepath+="~/.vim/plugged/deoplete.nvim"
    Plug 'Shougo/neosnippet.vim'
    Plug 'IllyaStarikov/neosnippet-snippets'
    Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
    Plug 'rip-rip/clang_complete', { 'for': ['c', 'cpp'], 'do': 'nvim -c \"r! git ls-files autoload bin doc plugin\" -c \"$$,$$d _\" -c \"%MkVimball! $@ .\" -c \"q!\" && nvim &< -c \"so %\" -c \"q\"' }
    Plug 'zchee/deoplete-jedi', { 'for': ['python'] }
elseif v:version >= 800
    Plug 'maralla/completor.vim'
endif

call plug#end()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Sets how many lines of history VIM has to remember
set history=250

fun! TrimWhitespace()
    let l:save = winsaveview()
    %s/\t/    /e
    %s/\s\+$//e
    call winrestview(l:save)
endfun


autocmd BufWritePre * :call TrimWhitespace()
augroup spaces
    autocmd!

    " Use tabas in makefiles though..
    autocmd FileType make set noexpandtab
augroup END

" Use system clipboard
set clipboard=unnamed

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

let g:quantum_italics = 1
let g:quantum_black = 1

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
    set guifont=Space\ Mono\ for\ Powerline:h11
endif

" Go up and down properly on wrapped text
nnoremap <Down> gj
nnoremap <Up> gk
vnoremap <Down> gj
vnoremap <Up> gk
inoremap <Down> <C-o>gj
inoremap <Up> <C-o>gk

" I actually like the curose in middle of the screen at the bottom
noremap G Gzz

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
" => Syntastic
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 1
let g:syntastic_check_on_wq = 0

let g:syntastic_cpp_checkers = ['clang']
let g:syntastic_cpp_compiler = 'clang++'
let g:syntastic_cpp_compiler_options = ' -std=c++11 -stdlib=libc++'

let g:syntastic_python_checkers=['flake8']
let g:syntastic_python_flake8_args='--ignore=E501,E225'

" gVim yells at this
if !has('win32')
    au filetype tex syntax region texZone start='\\begin{lstlisting}' end='\\end{lstlisting}'
endif

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
let g:Tex_CompileRule_pdf = 'xelatex --interaction=nonstopmode $*'

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
if has('nvim')
    inoremap <expr><tab> pumvisible() ? "\<c-n>" : "\<tab>"

    " To prevent enter from from not inserting newline
    inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
    function! s:my_cr_function() abort
        return deoplete#close_popup() . "\<CR>"
    endfunction

    let g:deoplete#auto_complete_delay = 150
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
        set conceallevel=0 concealcursor=i
    endif

    " Enable snipMate compatibility feature.
    let g:neosnippet#enable_snipmate_compatibility = 1
    let g:neosnippet#snippets_directory = '$HOME/vimfiles/bundle/vim-snippets/snippets, $HOME/snippets'

    " clang complete stuff
    let g:clang_library_path = '/Applications/Xcode.app/Contents/Developer/Toolchains/XcodeDefault.xctoolchain/usr/lib/libclang.dylib'

    let g:clang_complete_auto = 0
    let g:clang_auto_select = 0
    let g:clang_omnicppcomplete_compliance = 0
    let g:clang_make_default_keymappings = 0

    au FileType c,cpp,objc,objcpp setl omnifunc=clang_complete#ClangComplete

elseif v:version >= 800
    inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
    inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
    inoremap <expr> <cr> pumvisible() ? "\<C-y>\<cr>" : "\<cr>"
endif



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Key mappings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Because I type Wq literally all the time
:command! W w
:command! Q q
:command! Wq wq

" Because i use word wrap like a sane human
nnoremap <expr> k (v:count == 0 ? 'gk' : 'k')
nnoremap <expr> j (v:count == 0 ? 'gj' : 'j')
noremap  <buffer> <silent> 0 g0
noremap  <buffer> <silent> $ g$

nnoremap <Down> gj
nnoremap <Up> gk
vnoremap <Down> gj
vnoremap <Up> gk

" Because who needs arrow keys
noremap <up> <C-w><up>
noremap <down> <C-w><down>
noremap <left> <C-w><left>
noremap <right> <C-w><right>

nnoremap x "_x
nnoremap d "_d
nnoremap D "_D
vnoremap d "_d

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => Leader Key Shortcuts
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let mapleader = "\<Space>"

" Fast saving
nnoremap <leader>w :w<CR>

" Fast Closing
nnoremap <leader>q :q<CR>

" Fast saving and closing
noremap <leader>x :x<CR>

" fast opening
nnoremap <leader>o <C-P>

" Fast opening and closing vim
nnoremap <leader>s <C-Z>

" Fast visual mode
nmap <leader><leader> V

" Fast commenting (From tpope's commentary plugin)
nmap <leader>c gc

" true vim deleting
nnoremap <leader>d ""d
nnoremap <leader>D ""D
vnoremap <leader>d ""d

" nerdtree toggle
noremap <silent> <leader>n :NERDTreeToggle<cr>
let g:NERDTreeWinPos = "right"

" Start interactive EasyAlign in visual mode (e.g. vipga)
xmap ga <Plug>(EasyAlign)

" Start interactive EasyAlign for a motion/text object (e.g. gaip)
nmap ga <Plug>(EasyAlign)

" execute stuff
function! MakeIfAvailable()
    if filereadable("./makefile")
        make
    elseif (&filetype == "cpp")
        execute("!clang++ -std=c++14" + bufname("%"))
        execute("!./a.out")
    elseif (&filetype == "c")
        execute("!clang -std=c11" + bufname("%"))
        execute("!./a.out")
    elseif (&filetype == "tex")
        execute("!xelatex" + bufname("%"))
    endif
endfunction

augroup run
    autocmd!
    autocmd FileType c nnoremap <buffer><leader>r :call MakeIfAvailable()<cr>
    autocmd FileType cpp nnoremap <buffer><leader>r :call MakeIfAvailable()<cr>
    autocmd FileType tex nnoremap <buffer><leader>r :call MakeIfAvailable()<cr>
    autocmd FileType python nnoremap <buffer><leader>r :exec '!python3' shellescape(@%, 1)<cr>
    autocmd FileType perl nnoremap <buffer><leader>r :exec '!perl' shellescape(@%, 1)<cr>
    autocmd FileType sh nnoremap <buffer><leader>r :exec '!bash' shellescape(@%, 1)<cr>
    autocmd FileType swift nnoremap <buffer><leader>r :exec '!swift' shellescape(@%, 1)<cr>
    nnoremap <leader>R :!<Up><CR>
augroup END
