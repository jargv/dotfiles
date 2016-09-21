syntax region Mustache start=/{{/ end=/}}/
highlight link Mustache Statement

syntax match MustacheBlockBegin /\(#\w*\)\|\(\/\w*\)/ containedin=Mustache
highlight link MustacheBlockBegin PreProc

syntax region InlineStyle start=/^\s*[-a-z]*:/ end=/$/ containedin=htmlString
highlight link InlineStyle String

syntax match InlineStyleAttribute /^\s*[-a-z]*:/ containedin=InlineStyle
highlight link InlineStyleAttribute PreProc

syntax match InlineStyleNumber /[0-9][0-9.]*\%(px\)\?/ containedin=InlineStyle
highlight link InlineStyleNumber htmlTagN

syntax region InlineStyleMustache start=/{{/ end=/}}/ containedin=InlineStyle contains=InlineStyleNumber
highlight link InlineStyleMustache Statement
