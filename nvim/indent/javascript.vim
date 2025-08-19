source ~/config/vim/indent/html.vim

setlocal indentexpr=JonboyJSIndent(v:lnum)
setlocal indentkeys=o,O,*<Return>,<CR>,{,}

set debug=msg

func! JonboyJSIndent(lnum)
   let ind = 0

   "gather loads of info
   let lineabove = prevnonblank(a:lnum - 1)
   if !lineabove | return 0 | endif
   let codeAbove = getline(lineabove)
   let indentAbove = indent(lineabove)
   let codeHere = getline(a:lnum)
   let lineAboveEnd = matchstr(codeAbove, '\S\s*$')[0]
   let codeHereStart = matchstr(codeHere, '^\s*\S')[-1:]

   "add comment handling as well
   "
   if codeHereStart =~ '[\]})]' && lineAboveEnd !~ '[{(\[]'
      let ind -= 1
   elseif lineAboveEnd =~ '[{(\[]' && codeHereStart !~ '[\]})]'
      let ind += 1
   elseif lineAboveEnd =~ '[{(\[]' && codeHereStart =~ '[\]})]'
      let ind = 0
   elseif lineAboveEnd == ','
      if codeAbove =~ '([^)]*$'
         let ind = 1
      elseif codeAbove =~ '\[[^\]]*$'
         let ind = 1
      elseif codeAbove =~ '\s*\<\(var\|let\|const\)\>'
         let ind = 2
      endif
   else
      "find out if the block above us is the var or let block
      let line = a:lnum - 1
      while line > 0 && (indent(line) == indentAbove || getline(line) == "")
         let line -= 1
      endwhile
      if getline(line) =~ '^\s*\(var\|let\)\s' && (indent(line)/&sw)+2 == (indentAbove/&sw)
         let ind = -2
      endif
   endif

   let jsIndent = indentAbove + (&sw * ind)

   if jsIndent == indentAbove
      return HTMLIndentCalc(a:lnum)
   endif

   return jsIndent
endfunc
