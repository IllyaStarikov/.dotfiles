set background=dark
highlight clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name = "iceberg"

hi Normal ctermbg=234 ctermfg=252 guibg=#161821 guifg=#c6c8d1
hi ColorColumn cterm=NONE ctermbg=235 ctermfg=NONE guibg=#1e2132 guifg=NONE
hi CursorColumn cterm=NONE ctermbg=235 ctermfg=NONE guibg=#1e2132 guifg=NONE
hi CursorLine cterm=NONE ctermbg=235 ctermfg=NONE guibg=#1e2132 guifg=NONE
hi Comment ctermfg=242 guifg=#6b7089
hi Conceal ctermbg=234 ctermfg=242 guibg=#161821 guifg=#6b7089
hi Constant ctermfg=140 guifg=#a093c7
hi Cursor ctermbg=252 ctermfg=234 guibg=#c6c8d1 guifg=#161821
hi CursorLineNr cterm=NONE ctermbg=237 ctermfg=253 guibg=#2a3158 guifg=#cdd1e6
hi Delimiter ctermfg=252 guifg=#c6c8d1
hi DiffAdd ctermbg=29 ctermfg=158 guibg=#45493e guifg=#c0c5b9
hi DiffChange ctermbg=23 ctermfg=159 guibg=#384851 guifg=#b3c3cc
hi DiffDelete cterm=NONE ctermbg=95 ctermfg=224 gui=NONE guibg=#53343b guifg=#ceb0b6
hi DiffText cterm=NONE ctermbg=30 ctermfg=195 gui=NONE guibg=#5b7881 guifg=#c6c8d1
hi Directory ctermfg=109 guifg=#89b8c2
hi Error ctermbg=234 ctermfg=203 guibg=#161821 guifg=#e27878
hi ErrorMsg ctermbg=234 ctermfg=203 guibg=#161821 guifg=#e27878
hi WarningMsg ctermbg=234 ctermfg=203 guibg=#161821 guifg=#e27878
hi EndOfBuffer ctermfg=236 guifg=#242940
hi NonText ctermfg=236 guifg=#242940
hi Whitespace ctermfg=236 guifg=#242940
hi Folded ctermbg=235 ctermfg=245 guibg=#1e2132 guifg=#686f9a
hi FoldColumn ctermbg=235 ctermfg=239 guibg=#1e2132 guifg=#444b71
hi Function ctermfg=110 guifg=#84a0c6
hi Identifier cterm=NONE ctermfg=109 guifg=#89b8c2
hi Ignore ctermbg=NONE ctermfg=NONE guibg=NONE guifg=NONE
hi Include ctermfg=110 guifg=#84a0c6
hi IncSearch cterm=reverse ctermfg=NONE gui=reverse guifg=NONE term=reverse
hi LineNr ctermbg=235 ctermfg=239 guibg=#1e2132 guifg=#444b71
hi MatchParen ctermbg=237 ctermfg=255 guibg=#3e445e guifg=#ffffff
hi ModeMsg ctermfg=242 guifg=#6b7089
hi MoreMsg ctermfg=150 guifg=#b4be82
hi Operator ctermfg=110 guifg=#84a0c6
hi Pmenu ctermbg=236 ctermfg=251 guibg=#3d425b guifg=#c6c8d1
hi PmenuSbar ctermbg=236 ctermfg=NONE guibg=#3d425b guifg=NONE
hi PmenuSel ctermbg=240 ctermfg=255 guibg=#5b6389 guifg=#eff0f4
hi PmenuThumb ctermbg=251 ctermfg=NONE guibg=#c6c8d1 guifg=NONE
hi PreProc ctermfg=150 guifg=#b4be82
hi Question ctermfg=150 guifg=#b4be82
hi QuickFixLine ctermbg=236 ctermfg=252 guibg=#272c42 guifg=#c6c8d1
hi Search ctermbg=216 ctermfg=234 guibg=#e4aa80 guifg=#392313
hi SignColumn ctermbg=235 ctermfg=239 guibg=#1e2132 guifg=#444b71
hi Special ctermfg=150 guifg=#b4be82
hi SpecialKey ctermfg=240 guifg=#515e97
hi SpellBad ctermbg=95 ctermfg=252 gui=undercurl guifg=NONE guisp=#e27878
hi SpellCap ctermbg=24 ctermfg=252 gui=undercurl guifg=NONE guisp=#84a0c6
hi SpellLocal ctermbg=23 ctermfg=252 gui=undercurl guifg=NONE guisp=#89b8c2
hi SpellRare ctermbg=97 ctermfg=252 gui=undercurl guifg=NONE guisp=#a093c7
hi Statement ctermfg=110 gui=NONE guifg=#84a0c6
hi StatusLine cterm=reverse ctermbg=234 ctermfg=245 gui=reverse guibg=#17171b guifg=#818596 term=reverse
hi StatusLineTerm cterm=reverse ctermbg=234 ctermfg=245 gui=reverse guibg=#17171b guifg=#818596 term=reverse
hi StatusLineNC cterm=reverse ctermbg=238 ctermfg=233 gui=reverse guibg=#3e445e guifg=#0f1117
hi StatusLineTermNC cterm=reverse ctermbg=238 ctermfg=233 gui=reverse guibg=#3e445e guifg=#0f1117
hi StorageClass ctermfg=110 guifg=#84a0c6
hi String ctermfg=109 guifg=#89b8c2
hi Structure ctermfg=110 guifg=#84a0c6
hi TabLine cterm=NONE ctermbg=233 ctermfg=238 gui=NONE guibg=#0f1117 guifg=#3e445e
hi TabLineFill cterm=reverse ctermbg=238 ctermfg=233 gui=reverse guibg=#3e445e guifg=#0f1117
hi TabLineSel cterm=NONE ctermbg=234 ctermfg=252 gui=NONE guibg=#161821 guifg=#9a9ca5
hi TermCursorNC ctermbg=242 ctermfg=234 guibg=#6b7089 guifg=#161821
hi Title ctermfg=216 gui=NONE guifg=#e2a478
hi Todo ctermbg=234 ctermfg=150 guibg=#45493e guifg=#b4be82
hi Type ctermfg=110 gui=NONE guifg=#84a0c6
hi Underlined cterm=underline ctermfg=110 gui=underline guifg=#84a0c6 term=underline
hi VertSplit cterm=NONE ctermbg=233 ctermfg=233 gui=NONE guibg=#0f1117 guifg=#0f1117
hi Visual ctermbg=236 ctermfg=NONE guibg=#272c42 guifg=NONE
hi VisualNOS ctermbg=236 ctermfg=NONE guibg=#272c42 guifg=NONE
hi WildMenu ctermbg=255 ctermfg=234 guibg=#d4d5db guifg=#17171b
hi icebergNormalFg ctermfg=252 guifg=#c6c8d1
hi diffAdded ctermfg=150 guifg=#b4be82
hi diffRemoved ctermfg=203 guifg=#e27878
hi ALEErrorSign ctermbg=235 ctermfg=203 guibg=#1e2132 guifg=#e27878
hi ALEWarningSign ctermbg=235 ctermfg=216 guibg=#1e2132 guifg=#e2a478
hi ALEVirtualTextError ctermfg=203 guifg=#e27878
hi ALEVirtualTextWarning ctermfg=216 guifg=#e2a478
hi CtrlPMode1 ctermbg=236 ctermfg=242 guibg=#2e313f guifg=#6b7089
hi EasyMotionShade ctermfg=239 guifg=#3d425b
hi EasyMotionTarget ctermfg=150 guifg=#b4be82
hi EasyMotionTarget2First ctermfg=216 guifg=#e2a478
hi EasyMotionTarget2Second ctermfg=216 guifg=#e2a478
hi GitGutterAdd ctermbg=235 ctermfg=150 guibg=#1e2132 guifg=#b4be82
hi GitGutterChange ctermbg=235 ctermfg=109 guibg=#1e2132 guifg=#89b8c2
hi GitGutterChangeDelete ctermbg=235 ctermfg=109 guibg=#1e2132 guifg=#89b8c2
hi GitGutterDelete ctermbg=235 ctermfg=203 guibg=#1e2132 guifg=#e27878
hi gitmessengerEndOfBuffer ctermbg=235 ctermfg=239 guibg=#1e2132 guifg=#444b71
hi gitmessengerPopupNormal ctermbg=235 ctermfg=252 guibg=#1e2132 guifg=#c6c8d1
hi Sneak ctermbg=140 ctermfg=234 guibg=#a093c7 guifg=#161821
hi SneakScope ctermbg=236 ctermfg=242 guibg=#272c42 guifg=#6b7089
hi SyntasticErrorSign ctermbg=235 ctermfg=203 guibg=#1e2132 guifg=#e27878
hi SyntasticStyleErrorSign ctermbg=235 ctermfg=203 guibg=#1e2132 guifg=#e27878
hi SyntasticStyleWarningSign ctermbg=235 ctermfg=216 guibg=#1e2132 guifg=#e2a478
hi SyntasticWarningSign ctermbg=235 ctermfg=216 guibg=#1e2132 guifg=#e2a478
hi ZenSpace ctermbg=203 guibg=#e27878
hi TSFunction ctermfg=252 guifg=#a3adcb
hi TSFunctionBuiltin ctermfg=252 guifg=#a3adcb
hi TSFunctionMacro ctermfg=252 guifg=#a3adcb
hi TSMethod ctermfg=252 guifg=#a3adcb
hi TSURI cterm=underline ctermfg=109 gui=underline guifg=#89b8c2 term=underline
hi DiagnosticUnderlineInfo cterm=underline ctermfg=109 gui=underline guisp=#89b8c2 term=underline
hi DiagnosticInfo ctermfg=109 guifg=#89b8c2
hi DiagnosticSignInfo ctermbg=235 ctermfg=109 guibg=#1e2132 guifg=#89b8c2
hi DiagnosticUnderlineHint cterm=underline ctermfg=242 gui=underline guisp=#6b7089 term=underline
hi DiagnosticHint ctermfg=242 guifg=#6b7089
hi DiagnosticSignHint ctermbg=235 ctermfg=242 guibg=#1e2132 guifg=#6b7089
hi DiagnosticUnderlineWarn cterm=underline ctermfg=216 gui=underline guisp=#e2a478 term=underline
hi DiagnosticWarn ctermfg=216 guifg=#e2a478
hi DiagnosticSignWarn ctermbg=235 ctermfg=216 guibg=#1e2132 guifg=#e2a478
hi DiagnosticUnderlineError cterm=underline ctermfg=203 gui=underline guisp=#e27878 term=underline
hi DiagnosticError ctermfg=203 guifg=#e27878
hi DiagnosticSignError ctermbg=235 ctermfg=203 guibg=#1e2132 guifg=#e27878
hi DiagnosticFloatingHint ctermbg=236 ctermfg=251 guibg=#3d425b guifg=#c6c8d1
hi icebergALAccentRed ctermfg=203 guifg=#e27878

if has('nvim')
  let g:terminal_color_0 = '#1e2132'
  let g:terminal_color_1 = '#e27878'
  let g:terminal_color_2 = '#b4be82'
  let g:terminal_color_3 = '#e2a478'
  let g:terminal_color_4 = '#84a0c6'
  let g:terminal_color_5 = '#a093c7'
  let g:terminal_color_6 = '#89b8c2'
  let g:terminal_color_7 = '#c6c8d1'
  let g:terminal_color_8 = '#6b7089'
  let g:terminal_color_9 = '#e98989'
  let g:terminal_color_10 = '#c0ca8e'
  let g:terminal_color_11 = '#e9b189'
  let g:terminal_color_12 = '#91acd1'
  let g:terminal_color_13 = '#ada0d3'
  let g:terminal_color_14 = '#95c4ce'
  let g:terminal_color_15 = '#d2d4de'
else
  let g:terminal_ansi_colors = ['#1e2132', '#e27878', '#b4be82', '#e2a478', '#84a0c6', '#a093c7', '#89b8c2', '#c6c8d1', '#6b7089', '#e98989', '#c0ca8e', '#e9b189', '#91acd1', '#ada0d3', '#95c4ce', '#d2d4de']
endif

hi! link TermCursor Cursor
hi! link ToolbarButton TabLineSel
hi! link ToolbarLine TabLineFill
hi! link cssBraces Delimiter
hi! link cssClassName Special
hi! link cssClassNameDot icebergNormalFg
hi! link cssPseudoClassId Special
hi! link cssTagName Statement
hi! link helpHyperTextJump Constant
hi! link htmlArg Constant
hi! link htmlEndTag Statement
hi! link htmlTag Statement
hi! link jsonQuote icebergNormalFg
hi! link phpVarSelector Identifier
hi! link pythonFunction Title
hi! link rubyDefine Statement
hi! link rubyFunction Title
hi! link rubyInterpolationDelimiter String
hi! link rubySharpBang Comment
hi! link rubyStringDelimiter String
hi! link rustFuncCall icebergNormalFg
hi! link rustFuncName Title
hi! link rustType Constant
hi! link sassClass Special
hi! link shFunction icebergNormalFg
hi! link vimContinue Comment
hi! link vimFuncSID vimFunction
hi! link vimFuncVar icebergNormalFg
hi! link vimFunction Title
hi! link vimGroup Statement
hi! link vimHiGroup Statement
hi! link vimHiTerm Identifier
hi! link vimMapModKey Special
hi! link vimOption Identifier
hi! link vimVar icebergNormalFg
hi! link xmlAttrib Constant
hi! link xmlAttribPunct Statement
hi! link xmlEndTag Statement
hi! link xmlNamespace Statement
hi! link xmlTag Statement
hi! link xmlTagName Statement
hi! link yamlKeyValueDelimiter Delimiter
hi! link CtrlPPrtCursor Cursor
hi! link CtrlPMatch Title
hi! link CtrlPMode2 StatusLine
hi! link deniteMatched icebergNormalFg
hi! link deniteMatchedChar Title
hi! link elixirBlockDefinition Statement
hi! link elixirDefine Statement
hi! link elixirDocSigilDelimiter String
hi! link elixirDocTest String
hi! link elixirExUnitMacro Statement
hi! link elixirExceptionDefine Statement
hi! link elixirFunctionDeclaration Title
hi! link elixirKeyword Statement
hi! link elixirModuleDeclaration icebergNormalFg
hi! link elixirModuleDefine Statement
hi! link elixirPrivateDefine Statement
hi! link elixirStringDelimiter String
hi! link jsFlowMaybe icebergNormalFg
hi! link jsFlowObject icebergNormalFg
hi! link jsFlowType PreProc
hi! link graphqlName icebergNormalFg
hi! link graphqlOperator icebergNormalFg
hi! link gitmessengerHash Comment
hi! link gitmessengerHeader Statement
hi! link gitmessengerHistory Constant
hi! link jsArrowFunction Operator
hi! link jsClassDefinition icebergNormalFg
hi! link jsClassFuncName Title
hi! link jsExport Statement
hi! link jsFuncName Title
hi! link jsFutureKeys Statement
hi! link jsFuncCall icebergNormalFg
hi! link jsGlobalObjects Statement
hi! link jsModuleKeywords Statement
hi! link jsModuleOperators Statement
hi! link jsNull Constant
hi! link jsObjectFuncName Title
hi! link jsObjectKey Identifier
hi! link jsSuper Statement
hi! link jsTemplateBraces Special
hi! link jsUndefined Constant
hi! link markdownBold Special
hi! link markdownCode String
hi! link markdownCodeDelimiter String
hi! link markdownHeadingDelimiter Comment
hi! link markdownRule Comment
hi! link ngxDirective Statement
hi! link plug1 icebergNormalFg
hi! link plug2 Identifier
hi! link plugDash Comment
hi! link plugMessage Special
hi! link SignifySignAdd GitGutterAdd
hi! link SignifySignChange GitGutterChange
hi! link SignifySignChangeDelete GitGutterChangeDelete
hi! link SignifySignDelete SignifySignDelete
hi! link SignifySignDeleteFirstLine SignifySignDelete
hi! link StartifyBracket Comment
hi! link StartifyFile Identifier
hi! link StartifyFooter Constant
hi! link StartifyHeader Constant
hi! link StartifyNumber Special
hi! link StartifyPath Comment
hi! link StartifySection Statement
hi! link StartifySlash Comment
hi! link StartifySpecial icebergNormalFg
hi! link svssBraces Delimiter
hi! link swiftIdentifier icebergNormalFg
hi! link TSAttribute Special
hi! link TSBoolean Constant
hi! link TSCharacter Constant
hi! link TSComment Comment
hi! link TSConstructor icebergNormalFg
hi! link TSConditional Statement
hi! link TSConstant Constant
hi! link TSConstBuiltin Constant
hi! link TSConstMacro Constant
hi! link TSError Error
hi! link TSException Statement
hi! link TSField icebergNormalFg
hi! link TSFloat Constant
hi! link TSFunction Function
hi! link TSFunctionBuiltin Function
hi! link TSFunctionMacro Function
hi! link TSInclude Statement
hi! link TSKeyword Statement
hi! link TSKeywordFunction Function
hi! link TSLabel Special
hi! link TSNamespace Statement
hi! link TSNumber Constant
hi! link TSOperator icebergNormalFg
hi! link TSParameter icebergNormalFg
hi! link TSParameterReference icebergNormalFg
hi! link TSProperty icebergNormalFg
hi! link TSPunctDelimiter icebergNormalFg
hi! link TSPunctBracket icebergNormalFg
hi! link TSPunctSpecial Special
hi! link TSRepeat Statement
hi! link TSString String
hi! link TSStringRegex String
hi! link TSStringEscape Special
hi! link TSTag htmlTagName
hi! link TSTagAttribute htmlArg
hi! link TSTagDelimiter htmlTagName
hi! link TSText icebergNormalFg
hi! link TSTitle Title
hi! link TSURI htmlArg
hi! link TSType Type
hi! link TSTypeBuiltin Type
hi! link TSVariable icebergNormalFg
hi! link TSVariableBuiltin Statement
hi! link typescriptAjaxMethods icebergNormalFg
hi! link typescriptBraces icebergNormalFg
hi! link typescriptEndColons icebergNormalFg
hi! link typescriptFuncKeyword Statement
hi! link typescriptGlobalObjects Statement
hi! link typescriptHtmlElemProperties icebergNormalFg
hi! link typescriptIdentifier Statement
hi! link typescriptMessage icebergNormalFg
hi! link typescriptNull Constant
hi! link typescriptParens icebergNormalFg

if has('nvim-0.8')
  hi! link @attribute TSAttribute
  hi! link @boolean TSBoolean
  hi! link @character TSCharacter
  hi! link @comment TSComment
  hi! link @constructor TSConstructor
  hi! link @conditional TSConditional
  hi! link @constant TSConstant
  hi! link @constant.builtin TSConstBuiltin
  hi! link @constant.macro TSConstMacro
  hi! link @error TSError
  hi! link @exception TSException
  hi! link @field TSField
  hi! link @float TSFloat
  hi! link @function TSFunction
  hi! link @function.builtin TSFunctionBuiltin
  hi! link @function.macro TSFunctionMacro
  hi! link @include TSInclude
  hi! link @keyword TSKeyword
  hi! link @keyword.function TSKeywordFunction
  hi! link @label TSLabel
  hi! link @method TSMethod
  hi! link @namespace TSNamespace
  hi! link @number TSNumber
  hi! link @operator TSOperator
  hi! link @parameter TSParameter
  hi! link @parameter.reference TSParameterReference
  hi! link @property TSProperty
  hi! link @punctuation.delimiter TSPunctDelimiter
  hi! link @punctuation.bracket TSPunctBracket
  hi! link @punctuation.special TSPunctSpecial
  hi! link @repeat TSRepeat
  hi! link @string TSString
  hi! link @string.regex TSStringRegex
  hi! link @string.escape TSStringEscape
  hi! link @tag TSTag
  hi! link @tag.attribute TSTagAttribute
  hi! link @tag.delimiter TSTagDelimiter
  hi! link @text TSText
  hi! link @text.note Todo
  hi! link @text.title TSTitle
  hi! link @text.uri TSURI
  hi! link @type TSType
  hi! link @type.builtin TSTypeBuiltin
  hi! link @variable TSVariable
  hi! link @variable.builtin TSVariableBuiltin
endif

if !has('nvim')
  hi! link SpecialKey Whitespace
endif