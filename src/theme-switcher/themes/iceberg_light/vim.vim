" Iceberg Light Theme for Vim
" https://github.com/cocopon/iceberg.vim

set background=light
highlight clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name = "iceberg"

hi Normal ctermbg=254 ctermfg=237 guibg=#e8e9ec guifg=#33374c
hi ColorColumn cterm=NONE ctermbg=253 ctermfg=NONE guibg=#dcdfe7 guifg=NONE
hi CursorColumn cterm=NONE ctermbg=253 ctermfg=NONE guibg=#dcdfe7 guifg=NONE
hi CursorLine cterm=NONE ctermbg=253 ctermfg=NONE guibg=#dcdfe7 guifg=NONE
hi Comment ctermfg=244 guifg=#8389a3
hi Conceal ctermbg=254 ctermfg=244 guibg=#e8e9ec guifg=#8389a3
hi Constant ctermfg=97 guifg=#7759b4
hi Cursor ctermbg=237 ctermfg=254 guibg=#33374c guifg=#e8e9ec
hi CursorLineNr cterm=NONE ctermbg=251 ctermfg=236 guibg=#c6c8d1 guifg=#262a3f
hi Delimiter ctermfg=237 guifg=#33374c
hi DiffAdd ctermbg=150 ctermfg=22 guibg=#b8c5b9 guifg=#22371f
hi DiffChange ctermbg=109 ctermfg=31 guibg=#8bb5c0 guifg=#0f2a2c
hi DiffDelete cterm=NONE ctermbg=181 ctermfg=52 gui=NONE guibg=#c8b8b2 guifg=#512016
hi DiffText cterm=NONE ctermbg=73 ctermfg=16 gui=NONE guibg=#5fb3a1 guifg=#05232b
hi Directory ctermfg=31 guifg=#3f83a6
hi Error ctermbg=254 ctermfg=161 guibg=#e8e9ec guifg=#cc517a
hi ErrorMsg ctermbg=254 ctermfg=161 guibg=#e8e9ec guifg=#cc517a
hi WarningMsg ctermbg=254 ctermfg=161 guibg=#e8e9ec guifg=#cc517a
hi EndOfBuffer ctermfg=250 guifg=#c6c8d1
hi NonText ctermfg=250 guifg=#c6c8d1
hi Whitespace ctermfg=250 guifg=#c6c8d1
hi Folded ctermbg=253 ctermfg=244 guibg=#dcdfe7 guifg=#788098
hi FoldColumn ctermbg=253 ctermfg=248 guibg=#dcdfe7 guifg=#9ca0b0
hi Function ctermfg=25 guifg=#2d539e
hi Identifier cterm=NONE ctermfg=31 guifg=#3f83a6
hi Ignore ctermbg=NONE ctermfg=NONE guibg=NONE guifg=NONE
hi Include ctermfg=25 guifg=#2d539e
hi IncSearch cterm=reverse ctermfg=NONE gui=reverse guifg=NONE term=reverse
hi LineNr ctermbg=253 ctermfg=248 guibg=#dcdfe7 guifg=#9ca0b0
hi MatchParen ctermbg=250 ctermfg=16 guibg=#c6c8d1 guifg=#161821
hi ModeMsg ctermfg=244 guifg=#8389a3
hi MoreMsg ctermfg=64 guifg=#668e3d
hi Operator ctermfg=25 guifg=#2d539e
hi Pmenu ctermbg=251 ctermfg=238 guibg=#c9cdd7 guifg=#33374c
hi PmenuSbar ctermbg=251 ctermfg=NONE guibg=#c9cdd7 guifg=NONE
hi PmenuSel ctermbg=247 ctermfg=235 guibg=#a7adb8 guifg=#161821
hi PmenuThumb ctermbg=237 ctermfg=NONE guibg=#33374c guifg=NONE
hi PreProc ctermfg=64 guifg=#668e3d
hi Question ctermfg=64 guifg=#668e3d
hi QuickFixLine ctermbg=251 ctermfg=237 guibg=#c6c8d1 guifg=#33374c
hi Search ctermbg=180 ctermfg=52 guibg=#e4aa80 guifg=#392313
hi SignColumn ctermbg=253 ctermfg=248 guibg=#dcdfe7 guifg=#9ca0b0
hi Special ctermfg=64 guifg=#668e3d
hi SpecialKey ctermfg=247 guifg=#a7adb8
hi SpellBad ctermbg=181 ctermfg=237 gui=undercurl guifg=NONE guisp=#cc517a
hi SpellCap ctermbg=117 ctermfg=237 gui=undercurl guifg=NONE guisp=#2d539e
hi SpellLocal ctermbg=116 ctermfg=237 gui=undercurl guifg=NONE guisp=#3f83a6
hi SpellRare ctermbg=183 ctermfg=237 gui=undercurl guifg=NONE guisp=#7759b4
hi Statement ctermfg=25 gui=NONE guifg=#2d539e
hi StatusLine cterm=reverse ctermbg=254 ctermfg=243 gui=reverse guibg=#e8e9ec guifg=#757ca3 term=reverse
hi StatusLineTerm cterm=reverse ctermbg=254 ctermfg=243 gui=reverse guibg=#e8e9ec guifg=#757ca3 term=reverse
hi StatusLineNC cterm=reverse ctermbg=248 ctermfg=253 gui=reverse guibg=#9ca0b0 guifg=#dcdfe7
hi StatusLineTermNC cterm=reverse ctermbg=248 ctermfg=253 gui=reverse guibg=#9ca0b0 guifg=#dcdfe7
hi StorageClass ctermfg=25 guifg=#2d539e
hi String ctermfg=31 guifg=#3f83a6
hi Structure ctermfg=25 guifg=#2d539e
hi TabLine cterm=NONE ctermbg=253 ctermfg=248 gui=NONE guibg=#dcdfe7 guifg=#9ca0b0
hi TabLineFill cterm=reverse ctermbg=248 ctermfg=253 gui=reverse guibg=#9ca0b0 guifg=#dcdfe7
hi TabLineSel cterm=NONE ctermbg=254 ctermfg=237 gui=NONE guibg=#e8e9ec guifg=#515970
hi TermCursorNC ctermbg=244 ctermfg=254 guibg=#8389a3 guifg=#e8e9ec
hi Title ctermfg=130 gui=NONE guifg=#c57339
hi Todo ctermbg=150 ctermfg=64 guibg=#b8c5b9 guifg=#668e3d
hi Type ctermfg=25 gui=NONE guifg=#2d539e
hi Underlined cterm=underline ctermfg=25 gui=underline guifg=#2d539e term=underline
hi VertSplit cterm=NONE ctermbg=253 ctermfg=253 gui=NONE guibg=#dcdfe7 guifg=#dcdfe7
hi Visual ctermbg=251 ctermfg=NONE guibg=#c9cdd7 guifg=NONE
hi VisualNOS ctermbg=251 ctermfg=NONE guibg=#c9cdd7 guifg=NONE
hi WildMenu ctermbg=235 ctermfg=254 guibg=#262a3f guifg=#e8e9ec
hi icebergLightNormalFg ctermfg=237 guifg=#33374c
hi diffAdded ctermfg=64 guifg=#668e3d
hi diffRemoved ctermfg=161 guifg=#cc517a
hi ALEErrorSign ctermbg=253 ctermfg=161 guibg=#dcdfe7 guifg=#cc517a
hi ALEWarningSign ctermbg=253 ctermfg=130 guibg=#dcdfe7 guifg=#c57339
hi ALEVirtualTextError ctermfg=161 guifg=#cc517a
hi ALEVirtualTextWarning ctermfg=130 guifg=#c57339
hi CtrlPMode1 ctermbg=251 ctermfg=244 guibg=#c6c8d1 guifg=#8389a3
hi EasyMotionShade ctermfg=251 guifg=#c9cdd7
hi EasyMotionTarget ctermfg=64 guifg=#668e3d
hi EasyMotionTarget2First ctermfg=130 guifg=#c57339
hi EasyMotionTarget2Second ctermfg=130 guifg=#c57339
hi GitGutterAdd ctermbg=253 ctermfg=64 guibg=#dcdfe7 guifg=#668e3d
hi GitGutterChange ctermbg=253 ctermfg=31 guibg=#dcdfe7 guifg=#3f83a6
hi GitGutterChangeDelete ctermbg=253 ctermfg=31 guibg=#dcdfe7 guifg=#3f83a6
hi GitGutterDelete ctermbg=253 ctermfg=161 guibg=#dcdfe7 guifg=#cc517a
hi gitmessengerEndOfBuffer ctermbg=253 ctermfg=248 guibg=#dcdfe7 guifg=#9ca0b0
hi gitmessengerPopupNormal ctermbg=253 ctermfg=237 guibg=#dcdfe7 guifg=#33374c
hi Sneak ctermbg=97 ctermfg=254 guibg=#7759b4 guifg=#e8e9ec
hi SneakScope ctermbg=251 ctermfg=244 guibg=#c9cdd7 guifg=#8389a3
hi SyntasticErrorSign ctermbg=253 ctermfg=161 guibg=#dcdfe7 guifg=#cc517a
hi SyntasticStyleErrorSign ctermbg=253 ctermfg=161 guibg=#dcdfe7 guifg=#cc517a
hi SyntasticStyleWarningSign ctermbg=253 ctermfg=130 guibg=#dcdfe7 guifg=#c57339
hi SyntasticWarningSign ctermbg=253 ctermfg=130 guibg=#dcdfe7 guifg=#c57339
hi ZenSpace ctermbg=161 guibg=#cc517a
hi TSFunction ctermfg=237 guifg=#5a5f72
hi TSFunctionBuiltin ctermfg=237 guifg=#5a5f72
hi TSFunctionMacro ctermfg=237 guifg=#5a5f72
hi TSMethod ctermfg=237 guifg=#5a5f72
hi TSURI cterm=underline ctermfg=31 gui=underline guifg=#3f83a6 term=underline
hi DiagnosticUnderlineInfo cterm=underline ctermfg=31 gui=underline guisp=#3f83a6 term=underline
hi DiagnosticInfo ctermfg=31 guifg=#3f83a6
hi DiagnosticSignInfo ctermbg=253 ctermfg=31 guibg=#dcdfe7 guifg=#3f83a6
hi DiagnosticUnderlineHint cterm=underline ctermfg=244 gui=underline guisp=#8389a3 term=underline
hi DiagnosticHint ctermfg=244 guifg=#8389a3
hi DiagnosticSignHint ctermbg=253 ctermfg=244 guibg=#dcdfe7 guifg=#8389a3
hi DiagnosticUnderlineWarn cterm=underline ctermfg=130 gui=underline guisp=#c57339 term=underline
hi DiagnosticWarn ctermfg=130 guifg=#c57339
hi DiagnosticSignWarn ctermbg=253 ctermfg=130 guibg=#dcdfe7 guifg=#c57339
hi DiagnosticUnderlineError cterm=underline ctermfg=161 gui=underline guisp=#cc517a term=underline
hi DiagnosticError ctermfg=161 guifg=#cc517a
hi DiagnosticSignError ctermbg=253 ctermfg=161 guibg=#dcdfe7 guifg=#cc517a
hi DiagnosticFloatingHint ctermbg=251 ctermfg=238 guibg=#c9cdd7 guifg=#33374c
hi icebergLightAccentRed ctermfg=161 guifg=#cc517a

" Markview-specific highlight groups for proper symbol rendering
hi MarkviewTaskUnchecked guifg=#cc517a ctermfg=161
hi MarkviewTaskChecked guifg=#668e3d ctermfg=64
hi MarkviewTaskPending guifg=#c57339 ctermfg=130
hi MarkviewListItemMinus guifg=#c57339 ctermfg=130
hi MarkviewListItemStar guifg=#3f83a6 ctermfg=31
hi MarkviewListItemPlus guifg=#668e3d ctermfg=64
hi MarkviewLink guifg=#2d539e ctermfg=25 gui=underline cterm=underline
hi MarkviewImage guifg=#3f83a6 ctermfg=31
hi MarkviewCode guifg=#2d539e guibg=#dcdfe7 ctermfg=25 ctermbg=253
hi MarkviewInlineCode guifg=#2d539e guibg=#dcdfe7 ctermfg=25 ctermbg=253
hi MarkviewCodeInfo guifg=#c57339 guibg=#dcdfe7 ctermfg=130 ctermbg=253
hi MarkviewCodeBorder guifg=#9ca0b0 ctermfg=248
hi MarkviewHeading1 guifg=#7759b4 ctermfg=97 gui=bold cterm=bold
hi MarkviewHeading2 guifg=#cc517a ctermfg=161 gui=bold cterm=bold
hi MarkviewHeading3 guifg=#3f83a6 ctermfg=31 gui=bold cterm=bold
hi MarkviewHeading4 guifg=#668e3d ctermfg=64 gui=bold cterm=bold
hi MarkviewHeading5 guifg=#c57339 ctermfg=130 gui=bold cterm=bold
hi MarkviewHeading6 guifg=#2d539e ctermfg=25 gui=bold cterm=bold
hi MarkviewHeading1Sign guifg=#7759b4 ctermfg=97
hi MarkviewHeading2Sign guifg=#cc517a ctermfg=161
hi MarkviewBlockQuoteDefault guifg=#3f83a6 ctermfg=31 gui=italic cterm=italic
hi MarkviewBlockQuoteNote guifg=#2d539e ctermfg=25
hi MarkviewBlockQuoteOk guifg=#668e3d ctermfg=64
hi MarkviewBlockQuoteWarn guifg=#c57339 ctermfg=130
hi MarkviewBlockQuoteError guifg=#cc517a ctermfg=161
hi MarkviewBlockQuoteSpecial guifg=#7759b4 ctermfg=97
hi MarkviewRule guifg=#9ca0b0 ctermfg=248
hi MarkviewTable guifg=#33374c ctermfg=237
hi MarkviewTableBorder guifg=#9ca0b0 ctermfg=248
hi MarkviewCheckboxChecked guifg=#668e3d ctermfg=64
hi MarkviewCheckboxUnchecked guifg=#cc517a ctermfg=161
hi MarkviewCheckboxProgress guifg=#c57339 ctermfg=130
hi MarkviewCheckboxImportant guifg=#7759b4 ctermfg=97
hi MarkviewEmail guifg=#2d539e ctermfg=25
hi MarkviewBold guifg=#33374c ctermfg=237 gui=bold cterm=bold
hi MarkviewItalic guifg=#33374c ctermfg=237 gui=italic cterm=italic
hi MarkviewStrikethrough guifg=#8389a3 ctermfg=244 gui=strikethrough cterm=strikethrough
hi MarkviewDiffAdd guifg=#668e3d ctermfg=64
hi MarkviewDiffDelete guifg=#cc517a ctermfg=161

if has('nvim')
  let g:terminal_color_0 = '#dcdfe7'
  let g:terminal_color_1 = '#cc517a'
  let g:terminal_color_2 = '#668e3d'
  let g:terminal_color_3 = '#c57339'
  let g:terminal_color_4 = '#2d539e'
  let g:terminal_color_5 = '#7759b4'
  let g:terminal_color_6 = '#3f83a6'
  let g:terminal_color_7 = '#33374c'
  let g:terminal_color_8 = '#8389a3'
  let g:terminal_color_9 = '#cc3768'
  let g:terminal_color_10 = '#598030'
  let g:terminal_color_11 = '#b6662d'
  let g:terminal_color_12 = '#22478e'
  let g:terminal_color_13 = '#6845ad'
  let g:terminal_color_14 = '#327698'
  let g:terminal_color_15 = '#262a3f'
else
  let g:terminal_ansi_colors = ['#dcdfe7', '#cc517a', '#668e3d', '#c57339', '#2d539e', '#7759b4', '#3f83a6', '#33374c', '#8389a3', '#cc3768', '#598030', '#b6662d', '#22478e', '#6845ad', '#327698', '#262a3f']
endif