"
" .vimrc
" .dotfiles
"
" Created by Illya Starikov on March 5th, 2017
" Copyright 2017. Illya Starikov. All rights reserved.
"
" NOTE: This only works in Neovim, not Vim.
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
" 10 .................... FZF
" 11 .................... Functions
" 12 .................... Work-specific overrides

let g:vimrc_type = 'work' " options are: work / personal

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => 1. Plugins
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call plug#begin('~/.vim/plugged')

if has('macunix')                               " macOS
    Plug '/usr/local/opt/fzf'
else                                            " linux. I have no idea why another install
    Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
endif

Plug 'airblade/vim-gitgutter'                  " UI/UX For code
Plug 'dracula/vim', { 'as': 'dracula' }
Plug 'ryanoasis/vim-devicons'
Plug 'tpope/vim-fugitive'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'yggdroot/indentLine'
                                                " Language specific code
Plug 'deoplete-plugins/deoplete-jedi', { 'for': 'python' }
Plug 'justinmk/vim-syntax-extra'
Plug 'keith/swift.vim', { 'for': 'swift' }
Plug 'vim-pandoc/vim-pandoc-syntax', { 'for': 'markdown' }

Plug 'illyastarikov/vim-snippets'               " Write code
Plug 'junegunn/vim-easy-align'
Plug 'shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
Plug 'sirVer/ultisnips'
Plug 'skywind3000/asyncrun.vim'
Plug 'tommcdo/vim-lion'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'w0rp/ale'
Plug 'wellle/targets.vim'

Plug 'junegunn/fzf.vim'                         " Explore Code
Plug 'ludovicchabant/vim-gutentags'
Plug 'majutsushi/tagbar'
Plug 'mhinz/vim-grepper'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }

call plug#end()

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => 2. General
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set history=250                                 " Sets how many lines of history VIM has to remember
set so=7                                        " Set 7 lines to the cursor - when moving vertically using j/k
set clipboard=unnamed                           " Yank to system clipboard by default
set backspace=indent,eol,start                  " Proper backspace

set autoread                                    " Set to auto read when a file is changed from the outside

set virtualedit=block                           " freedom of movement

set expandtab                                   " tabs => spaces
set shiftwidth=4                                " set number of spaces to 4
set tabstop=4                                   " if i has to use tabs, make it look like 4 spaces
set softtabstop=4                               " same as above idk
set shiftwidth=4                                " when indenting with '>', use 4 spaces width

set smartindent                                 " autoindent on newlines
set autoindent                                  " copy indentation from previous lines
set linebreak                                   " word wrap like a sane human being
set conceallevel=0                              " don't try to conceal things

let g:indentLine_concealcursor = 'inc'          " Because indentLine for some reason wants to override the
let g:indentLine_conceallevel = 0               " default concceallevel.

set number                                      " Show current line number
set relativenumber                              " Relative line numbers yo
set hlsearch                                    " Highlight searches

set nobackup                                    " Turn backup off
set nowb
set noswapfile

set completeopt+=noinsert,noselect
set completeopt-=preview

filetype plugin indent on                       " filetype specific indents and plugins

let g:tex_flavor = "latex"                      " because the default is tex for some reason

augroup makefiles                               " special rules for makefiles (like don't delete tabs/use tabs)
    autocmd!
    autocmd FileType make,makefile set noexpandtab

    let blacklist = ['make', 'makefile', 'snippets']
    autocmd BufWritePre * if index(blacklist, &ft) < 0 | :call TrimWhitespace()
augroup END

if has("mouse")                                 " Enable mouse support
    set mouse=a
endif

if has('macunix')                               " For deoplete
    let g:python3_host_prog = '/usr/local/bin/python3' " macOS
else
    let g:python3_host_prog = '/usr/bin/python3'       " Linux
endif

augroup projects                                " Treat headers as C
    autocmd!
    autocmd BufRead,BufNewFile *.h,*.c set filetype=c
augroup END

let g:NERDTreeWinPos = "right"                  " NerdTree Stuff
let NERDTreeMapOpenInTab='\r'
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif

                                                " Grep defaults
let grepper = {
    \ 'grep': {
    \     'grepprg': 'grep -Rn --color --exclude=\*.{o,exe,out,dll,obj} --exclude-dir=bin $*'
    \ }
\ }

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => 3. User Interface
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
syntax on                                       " Syntax highlighting
syntax enable
set spell spelllang=en_us                       " set english as standard language

set t_Co=256                                    " 256 colors for terminal

colorscheme dracula                             " This will throw an error until :PlugInstall is ran
set background=dark
let g:airline_theme = 'dracula'
let g:dracula_italic = 1

set cursorline!                                 " Turn on the cursorline
set guicursor=
set synmaxcol=200                               " Don't syntax highlight after the 200th column

set magic                                       " For regular expressions

set ffs=unix,dos,mac                            " Use Unix as the standard file type

set wildmenu                                    " Use wild-menu
set wildmode=longest:list,full

set hidden                                      " Don't warn me about unsaved buffers

set noerrorbells                                " no annoying error noises
set novisualbell                                " or error visuals
set t_vb=
set tm=500

augroup syntax                                  " Syntax highlighting for latex/markdown as infinite
    autocmd!
    autocmd FileType tex,latex,markdown,pandoc set synmaxcol=2048

    autocmd BufNewFile,BufRead *.tex set syntax=tex
augroup END

set list                                        " Show spaces, line breaks, the like
set showbreak=↪\
set listchars=tab:→\ ,nbsp:␣,trail:•,extends:⟩,precedes:⟨

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => 4. Autocomplete/Snippets/Linting
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:UltiSnipsExpandTrigger = "<nop>"
inoremap <expr> <CR> pumvisible() ? "<C-R>=ExpandSnippetOrCarriageReturn()<CR>" : "\<CR>"

let g:ale_linters = {
      \ 'python': ['flake8', 'pylint']
      \ }

let g:ale_python_flake8_options = "--max-line-length=200"
let g:ale_python_pylint_options = "--max-line-length=200 --errors-only"

let g:UltiSnipsJumpForwardTrigger = "<tab>"
let g:UltiSnipsJumpBackwardTrigger = "<s-tab>"
set shortmess+=c

inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"

let g:ale_sign_error = '>>'                     " Cool >> for errors
let g:ale_sign_warning = '>'                    " and > for warnings

let g:ale_echo_msg_error_str = 'E'
let g:ale_echo_msg_warning_str = 'W'
let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'
let g:ale_lint_delay = 500

let g:deoplete#enable_at_startup = 1

let g:jedi#auto_vim_configuration = 0           " Don't remap keyboard shortcuts

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => 5. Airline
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let g:airline#extensions#whitespace#enabled = 0

set lazyredraw                                  " lazy drawing
set ttyfast

let g:airline_symbols_ascii = 1
let g:airline#extensions#ale#enabled = 1
let g:airline_detect_spell = 0
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#fnamemod = ':t'
let g:airline#extensions#tabline#tab_nr_type = 2

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

" Because I use word wrap
nnoremap <expr> k (v:count == 0 ? 'gk' : 'k')
nnoremap <expr> j (v:count == 0 ? 'gj' : 'j')
noremap  <buffer> <silent> 0 g0
noremap  <buffer> <silent> $ g$

" Because who needs arrow keys
noremap <up> <C-w><up>
noremap <down> <C-w><down>
noremap <left> <C-w><left>
noremap <right> <C-w><right>

" Buffers
nnoremap <Tab> :bnext<cr>
nnoremap <S-Tab> :bprevious<cr>

" ALE Errors
nmap <silent> [W <Plug>(ale_first)
nmap <silent> [w <Plug>(ale_previous)
nmap <silent> ]w <Plug>(ale_next)
nmap <silent> ]W <Plug>(ale_last)

" Copy Filename
nmap ,cs :let @+=expand("%")<CR>
nmap ,cl :let @+=expand("%:p")<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => 8. Leader Key
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let mapleader = "\<Space>"

nnoremap <leader>w :w<cr>
noremap <leader>q :q<cr>
noremap <leader>c :Kwbd<cr>
noremap <leader>x :x<cr>
nnoremap <leader>s <C-Z>
nnoremap <leader>d "_d

noremap <silent> <leader>n :NERDTreeToggle<cr>
noremap <leader>f :Files<cr>
noremap <leader>b :Buffers<cr>
noremap <leader>T :Tagbar<cr>
noremap <leader>g :Grepper -tool grep<cr>
nmap <leader><leader> v$h

nmap ga <Plug>(EasyAlign)
nnoremap <Leader>p :let @+=expand('%:p')<CR>

nnoremap <leader>t :terminal<cr> " fast opening of terminal
tnoremap <Esc> <C-\><C-n> " fast entering normal mode in terminal


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => 9. Code Runner
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" I know this is garbage but this is my garbage.
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
" => 10. FZF
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" This is the default extra key bindings
let g:fzf_action = {
  \ 'ctrl-t': 'tab split',
  \ 'ctrl-x': 'split',
  \ 'ctrl-v': 'vsplit' }

" Default fzf layout
" - down / up / left / right
let g:fzf_layout = { 'down': '~40%' }

" Customize fzf colors to match your color scheme
let g:fzf_colors =
\ { 'fg':      ['fg', 'Normal'],
  \ 'bg':      ['bg', 'Normal'],
  \ 'hl':      ['fg', 'Comment'],
  \ 'fg+':     ['fg', 'CursorLine', 'CursorColumn', 'Normal'],
  \ 'bg+':     ['bg', 'CursorLine', 'CursorColumn'],
  \ 'hl+':     ['fg', 'Statement'],
  \ 'info':    ['fg', 'PreProc'],
  \ 'border':  ['fg', 'Ignore'],
  \ 'prompt':  ['fg', 'Conditional'],
  \ 'pointer': ['fg', 'Exception'],
  \ 'marker':  ['fg', 'Keyword'],
  \ 'spinner': ['fg', 'Label'],
  \ 'header':  ['fg', 'Comment'] }

" Enable per-command history.
" CTRL-N and CTRL-P will be automatically bound to next-history and
" previous-history instead of down and up. If you don't like the change,
" explicitly bind the keys to down and up in your $FZF_DEFAULT_OPTS.
let g:fzf_history_dir = '~/.local/share/fzf-history'

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => 11. Functions
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

"delete the buffer; keep windows; create a scratch buffer if no buffers left
function! s:Kwbd(kwbdStage)
  if(a:kwbdStage == 1)
    if(!buflisted(winbufnr(0)))
      bd!
      return
    endif
    let s:kwbdBufNum = bufnr("%")
    let s:kwbdWinNum = winnr()
    windo call s:Kwbd(2)
    execute s:kwbdWinNum . 'wincmd w'
    let s:buflistedLeft = 0
    let s:bufFinalJump = 0
    let l:nBufs = bufnr("$")
    let l:i = 1
    while(l:i <= l:nBufs)
      if(l:i != s:kwbdBufNum)
        if(buflisted(l:i))
          let s:buflistedLeft = s:buflistedLeft + 1
        else
          if(bufexists(l:i) && !strlen(bufname(l:i)) && !s:bufFinalJump)
            let s:bufFinalJump = l:i
          endif
        endif
      endif
      let l:i = l:i + 1
    endwhile
    if(!s:buflistedLeft)
      if(s:bufFinalJump)
        windo if(buflisted(winbufnr(0))) | execute "b! " . s:bufFinalJump | endif
      else
        enew
        let l:newBuf = bufnr("%")
        windo if(buflisted(winbufnr(0))) | execute "b! " . l:newBuf | endif
      endif
      execute s:kwbdWinNum . 'wincmd w'
    endif
    if(buflisted(s:kwbdBufNum) || s:kwbdBufNum == bufnr("%"))
      execute "bd! " . s:kwbdBufNum
    endif
    if(!s:buflistedLeft)
      set buflisted
      set bufhidden=delete
      set buftype=
      setlocal noswapfile
    endif
  else
    if(bufnr("%") == s:kwbdBufNum)
      let prevbufvar = bufnr("#")
      if(prevbufvar > 0 && buflisted(prevbufvar) && prevbufvar != s:kwbdBufNum)
        b #
      else
        bn
      endif
    endif
  endif
endfunction

command! Kwbd call s:Kwbd(1)

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" => 12. Work-specific overrides
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if vimrc_type == 'work'
    source ~/.vimrc.work
endif
