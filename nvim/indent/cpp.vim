"todo: check out searchpair
setlocal indentexpr=CppIndentCalc(v:lnum)
setlocal indentkeys=o,O,*<Return>,<CR>,{,},:

func! CppIndentCalc(lnum)
   let ind = 0

   "gather loads of info
   let lineAbove = prevnonblank(a:lnum - 1)
   if !lineAbove | return 0 | endif
   let codeAbove = getline(lineAbove)
   let indentAbove = indent(lineAbove)
   let codeHere = getline(a:lnum)
   let lineAboveEnd = matchstr(codeAbove, '\S\s*$')[0]
   let codeHereStart = matchstr(codeHere, '^\s*\S')[-1:]

   "todo: add comment handling as well
   "
   if codeHereStart =~ '[\]})]' && lineAboveEnd !~ '[{(\[]'
      let ind -= 1
   elseif codeHere =~ '^\s*->'
     let ind += 1
   elseif codeAbove =~ '^\s*->'
     if lineAboveEnd != '{'
       let ind -= 1
     endif
   elseif lineAboveEnd =~ '[{(\[]' && codeHereStart !~ '[\]})]'
      let ind += 1
   elseif lineAboveEnd =~ '[{(\[]' && codeHereStart =~ '[\]})]'
      let ind = 0
   elseif lineAboveEnd == ','
      if codeAbove =~ '([^)]*$'
         let ind = 1
      elseif codeAbove =~ '\[[^\]]*$'
         let ind = 1
      endif
    elseif codeHere =~ '^\s*[:\?]' && codeAbove !~ '^\s*[:\?]'
     let ind += 1
    elseif codeHere =~ '^\s*{' && codeAbove =~ '^\s*[,:\?]'
      let ind -= 1
   endif

   if codeHere =~ '^\s*\%(public\|private\|protected\):\s*$'
     let ind -= 1
   endif

   if codeAbove =~ '^\s*\%(public\|private\|protected\):\s*$'
     let ind += 1
   endif

   return indentAbove + (&sw * ind)
endfunc
