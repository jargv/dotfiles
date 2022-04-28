setlocal indentexpr=HTMLIndentCalc(v:lnum)
setlocal indentkeys=o,O,*<Return>,<CR>,{,},/,>

set debug=msg

func! HTMLIndentCalc(lnum)
  let ind = 0

  "gather loads of info
  let lineabove = prevnonblank(a:lnum - 1)
  if !lineabove | return 0 | endif
  let indentAbove = indent(lineabove)
  let codeAbove   = getline(lineabove)
  let codeHere    = getline(a:lnum)

  "setup the regexes needed
  let loneOpenTag    = '^\s*<[^/!][^>]*>\s*$'
  let loneClosingTag = '^\s*<\/[a-zA-Z0-9_-]*\s*>\s*'
  let selfClosing    = '/>\s*$'
  let mustacheOpen   = '\(^\s*{{#[^}]*}}\s*$\)\|\(^\s*{{else}}\s*$\)'
  let mustacheClose  = '\(^\s*{{/[^}]*}}\s*$\)\|\(^\s*{{else}}\s*$\)'
  let attributeLine  = '^\s*\%([-A-Za-z0-9_]*\s*=\s*".*\)\/\?>\?\s*$'
  let unclosedAttribute = '^\s*\%([-A-Za-z0-9_]*\s*=\s*"\)\s*$'
  let singleCharClosing = '^\s*[">]\{1,2\}\s*$'
  let singleGtClosing = '^\s*>\s*$'
  let selfClosingEnd  = '^\s*\/>\s*$'

  "check for open tags right above
  if (codeAbove =~ loneOpenTag && codeAbove !~ selfClosing) || codeAbove =~ mustacheOpen
    let ind += 1
  endif

  "check if the current line is a closing tag
  if codeHere =~ loneClosingTag || codeHere =~ mustacheClose
    let ind -= 1
  endif

  "check for multi-line attribute lists
  if codeHere =~ attributeLine && codeAbove !~ attributeLine
    let ind += 1
  endif

  if codeAbove =~ unclosedAttribute
    let ind += 1
  endif

  if codeHere =~ singleCharClosing || codeHere =~ selfClosingEnd
    let ind -= 1
  endif

  if codeAbove =~ singleGtClosing
    let ind += 1
  endif

  "calculate the indentation
  return indentAbove + (&sw * ind)
endfunc
