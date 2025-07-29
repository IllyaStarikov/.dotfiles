" Tokyo Night color scheme for Vim
" Based on https://github.com/folke/tokyonight.nvim

set background=dark
hi clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name = "tokyonight_night"

" Tokyo Night Night palette
let s:bg = "#1a1b26"
let s:bg_dark = "#16161e"
let s:bg_highlight = "#292e42"
let s:terminal_black = "#414868"
let s:fg = "#c0caf5"
let s:fg_dark = "#a9b1d6"
let s:fg_gutter = "#3b4261"
let s:dark3 = "#545c7e"
let s:comment = "#565f89"
let s:dark5 = "#737aa2"
let s:blue0 = "#3d59a1"
let s:blue = "#7aa2f7"
let s:cyan = "#7dcfff"
let s:blue1 = "#2ac3de"
let s:blue2 = "#0db9d7"
let s:blue5 = "#89ddff"
let s:blue6 = "#b4f9f8"
let s:blue7 = "#394b70"
let s:magenta = "#bb9af7"
let s:magenta2 = "#ff007c"
let s:purple = "#9d7cd8"
let s:orange = "#ff9e64"
let s:yellow = "#e0af68"
let s:green = "#9ece6a"
let s:green1 = "#73daca"
let s:green2 = "#41a6b5"
let s:teal = "#1abc9c"
let s:red = "#f7768e"
let s:red1 = "#db4b4b"

" Terminal colors
if has('nvim')
  let g:terminal_color_0 = s:terminal_black
  let g:terminal_color_1 = s:red
  let g:terminal_color_2 = s:green
  let g:terminal_color_3 = s:yellow
  let g:terminal_color_4 = s:blue
  let g:terminal_color_5 = s:magenta
  let g:terminal_color_6 = s:cyan
  let g:terminal_color_7 = s:fg_dark
  let g:terminal_color_8 = s:comment
  let g:terminal_color_9 = s:red
  let g:terminal_color_10 = s:green
  let g:terminal_color_11 = s:yellow
  let g:terminal_color_12 = s:blue
  let g:terminal_color_13 = s:magenta
  let g:terminal_color_14 = s:cyan
  let g:terminal_color_15 = s:fg
endif

" Basic highlighting
exe "hi Normal guifg=" . s:fg . " guibg=" . s:bg
exe "hi Comment guifg=" . s:comment
exe "hi Constant guifg=" . s:orange
exe "hi String guifg=" . s:green
exe "hi Character guifg=" . s:green
exe "hi Number guifg=" . s:orange
exe "hi Boolean guifg=" . s:orange
exe "hi Float guifg=" . s:orange
exe "hi Identifier guifg=" . s:magenta
exe "hi Function guifg=" . s:blue
exe "hi Statement guifg=" . s:magenta
exe "hi Conditional guifg=" . s:magenta
exe "hi Repeat guifg=" . s:magenta
exe "hi Label guifg=" . s:blue
exe "hi Operator guifg=" . s:blue5
exe "hi Keyword guifg=" . s:cyan
exe "hi Exception guifg=" . s:magenta
exe "hi PreProc guifg=" . s:blue
exe "hi Include guifg=" . s:blue
exe "hi Define guifg=" . s:cyan
exe "hi Macro guifg=" . s:cyan
exe "hi PreCondit guifg=" . s:cyan
exe "hi Type guifg=" . s:blue
exe "hi StorageClass guifg=" . s:blue
exe "hi Structure guifg=" . s:yellow
exe "hi Typedef guifg=" . s:yellow
exe "hi Special guifg=" . s:blue1
exe "hi SpecialChar guifg=" . s:blue1
exe "hi Tag guifg=" . s:cyan
exe "hi Delimiter guifg=" . s:fg_dark
exe "hi SpecialComment guifg=" . s:dark5
exe "hi Debug guifg=" . s:red
exe "hi Underlined guifg=" . s:blue . " gui=underline"
exe "hi Ignore guifg=" . s:dark3
exe "hi Error guifg=" . s:red1 . " guibg=" . s:bg
exe "hi Todo guifg=" . s:bg . " guibg=" . s:yellow

" UI highlighting
exe "hi ColorColumn guibg=" . s:bg_highlight
exe "hi Cursor guifg=" . s:bg . " guibg=" . s:fg
exe "hi CursorColumn guibg=" . s:bg_highlight
exe "hi CursorLine guibg=" . s:bg_highlight
exe "hi CursorLineNr guifg=" . s:dark5
exe "hi DiffAdd guifg=" . s:green . " guibg=" . s:bg
exe "hi DiffChange guifg=" . s:yellow . " guibg=" . s:bg
exe "hi DiffDelete guifg=" . s:red . " guibg=" . s:bg
exe "hi DiffText guifg=" . s:blue . " guibg=" . s:bg
exe "hi Directory guifg=" . s:blue
exe "hi ErrorMsg guifg=" . s:red
exe "hi FoldColumn guifg=" . s:comment . " guibg=" . s:bg
exe "hi Folded guifg=" . s:blue . " guibg=" . s:fg_gutter
exe "hi IncSearch guifg=" . s:bg . " guibg=" . s:orange
exe "hi LineNr guifg=" . s:fg_gutter
exe "hi MatchParen guifg=" . s:orange . " gui=bold"
exe "hi ModeMsg guifg=" . s:fg_dark . " gui=bold"
exe "hi MoreMsg guifg=" . s:blue
exe "hi NonText guifg=" . s:dark3
exe "hi Pmenu guifg=" . s:fg . " guibg=" . s:bg_highlight
exe "hi PmenuSel guifg=" . s:fg . " guibg=" . s:blue0
exe "hi PmenuSbar guibg=" . s:bg_highlight
exe "hi PmenuThumb guibg=" . s:fg_gutter
exe "hi Question guifg=" . s:blue
exe "hi Search guifg=" . s:bg . " guibg=" . s:yellow
exe "hi SignColumn guifg=" . s:fg_gutter . " guibg=" . s:bg
exe "hi SpecialKey guifg=" . s:dark3
exe "hi StatusLine guifg=" . s:fg . " guibg=" . s:bg_highlight . " gui=none"
exe "hi StatusLineNC guifg=" . s:fg_gutter . " guibg=" . s:bg_highlight . " gui=none"
exe "hi TabLine guifg=" . s:fg_gutter . " guibg=" . s:bg_highlight . " gui=none"
exe "hi TabLineFill guibg=" . s:bg
exe "hi TabLineSel guifg=" . s:bg . " guibg=" . s:blue
exe "hi Title guifg=" . s:blue . " gui=bold"
exe "hi VertSplit guifg=" . s:bg_highlight . " guibg=" . s:bg
exe "hi Visual guibg=" . s:bg_highlight
exe "hi WarningMsg guifg=" . s:yellow
exe "hi WildMenu guifg=" . s:bg . " guibg=" . s:blue

" Language-specific highlighting
exe "hi pythonBuiltin guifg=" . s:cyan
exe "hi pythonBuiltinObj guifg=" . s:cyan
exe "hi pythonBuiltinFunc guifg=" . s:cyan
exe "hi pythonFunction guifg=" . s:blue
exe "hi pythonDecorator guifg=" . s:red
exe "hi pythonInclude guifg=" . s:blue
exe "hi pythonImport guifg=" . s:blue
exe "hi pythonRun guifg=" . s:blue
exe "hi pythonCoding guifg=" . s:blue
exe "hi pythonOperator guifg=" . s:red
exe "hi pythonException guifg=" . s:red
exe "hi pythonExceptions guifg=" . s:yellow
exe "hi pythonBoolean guifg=" . s:orange
exe "hi pythonDot guifg=" . s:fg_dark
exe "hi pythonConditional guifg=" . s:red
exe "hi pythonRepeat guifg=" . s:red
exe "hi pythonDottedName guifg=" . s:green1