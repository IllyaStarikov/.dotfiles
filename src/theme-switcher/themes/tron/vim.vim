set background=light
highlight clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name = "tron-light"

" Tron Light Color Palette
let s:bg = "#ffffff"
let s:fg = "#000000"
let s:cyan = "#008080"
let s:blue = "#0000ff"
let s:gray = "#808080"
let s:red = "#ff0000"

" Syntax Highlighting
hi Normal       guifg=s:fg guibg=s:bg
hi NonText      guifg=s:gray
hi Comment      guifg=s:gray gui=italic
hi Constant     guifg=s:blue
hi String       guifg=s:cyan
hi Character    guifg=s:cyan
hi Number       guifg=s:blue
hi Boolean      guifg=s:blue
hi Float        guifg=s:blue
hi Identifier   guifg=s:fg
hi Function     guifg=s:blue
hi Statement    guifg=s:fg
hi Conditional  guifg=s:fg
hi Repeat       guifg=s:fg
hi Label        guifg=s:fg
hi Operator     guifg=s:fg
hi Keyword      guifg=s:blue
hi Exception    guifg=s:fg
hi PreProc      guifg=s:blue
hi Include      guifg=s:blue
hi Define       guifg=s:blue
hi Macro        guifg=s:blue
hi PreCondit    guifg=s:blue
hi Type         guifg=s:blue
hi StorageClass guifg=s:blue
hi Structure    guifg=s:blue
hi Typedef      guifg=s:blue
