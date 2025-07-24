set background=dark
highlight clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name = "tron"

" Tron Color Palette
let s:black = "#000000"
let s:cyan = "#00ffff"
let s:blue = "#00BFFF"
let s:white = "#E0E0E0"
let s:gray = "#808080"
let s:red = "#FF4136"

" Syntax Highlighting
hi Normal       guifg=s:cyan guibg=s:black
hi NonText      guifg=s:gray
hi Comment      guifg=s:gray gui=italic
hi Constant     guifg=s:cyan
hi String       guifg=s:cyan
hi Character    guifg=s:cyan
hi Number       guifg=s:cyan
hi Boolean      guifg=s:cyan
hi Float        guifg=s:cyan
hi Identifier   guifg=s:white
hi Function     guifg=s:blue
hi Statement    guifg=s:white
hi Conditional  guifg=s:white
hi Repeat       guifg=s:white
hi Label        guifg=s:white
hi Operator     guifg=s:white
hi Keyword      guifg=s:blue
hi Exception    guifg=s:white
hi PreProc      guifg=s:blue
hi Include      guifg=s:blue
hi Define       guifg=s:blue
hi Macro        guifg=s:blue
hi PreCondit    guifg=s:blue
hi Type         guifg=s:blue
hi StorageClass guifg=s:blue
hi Structure    guifg=s:blue
hi Typedef      guifg=s:blue
hi Special      guifg=s:cyan
hi SpecialChar  guifg=s:cyan
hi Tag          guifg=s:cyan
hi Delimiter    guifg=s:white
hi SpecialComment guifg=s:gray
hi Debug        guifg=s:white
hi Underlined   guifg=s:white gui=underline
hi Ignore       guifg=s:gray
hi Error        guifg=s:red guibg=s:black
hi Todo         guifg=s:red guibg=s:black

" UI Elements
hi Pmenu        guifg=s:black guibg=s:cyan
hi PmenuSel     guifg=s:black guibg=s:white
hi PmenuSbar    guibg=s:gray
hi PmenuThumb   guibg=s:white
hi CursorLine   guibg="#001f1f"
hi CursorColumn guibg="#001f1f"
hi LineNr       guifg=s:gray guibg=s:black
hi SignColumn   guifg=s:gray guibg=s:black
hi VertSplit    guifg=s:gray guibg=s:black
hi StatusLine   guifg=s:black guibg=s:cyan
hi StatusLineNC guifg=s:black guibg=s:gray
hi WildMenu     guifg=s:black guibg=s:cyan
hi Folded       guifg=s:gray guibg=s:black
hi FoldColumn   guifg=s:gray guibg=s:black
hi DiffAdd      guibg="#003300"
hi DiffChange   guibg="#003333"
hi DiffDelete   guifg=s:cyan guibg="#660000"
hi DiffText     guibg="#004444"

" Airline Theme
let g:airline#themes#tron#palette = {}
let g:airline#themes#tron#palette.normal = [s:black, s:cyan, s:black, s:blue]
let g:airline#themes#tron#palette.insert = [s:black, s:blue, s:black, s:cyan]
let g:airline#themes#tron#palette.visual = [s:black, s:gray, s:black, s:white]
let g:airline#themes#tron#palette.replace = [s:black, s:red, s:black, s:white]