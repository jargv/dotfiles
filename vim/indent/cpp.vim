setlocal indentexpr=CppIndentCalc(v:lnum)
setlocal indentkeys=o,O,*<Return>,<CR>,{,},:

func! CppIndentCalc(lnum)
   let ind = 0

   "gather loads of info
   let lineabove = prevnonblank(a:lnum - 1)
   if !lineabove | return 0 | endif
   let codeAbove = getline(lineabove)
   let indentAbove = indent(lineabove)
   let codeHere = getline(a:lnum)
   let lineAboveEnd = matchstr(codeAbove, '\S\s*$')[0]
   let codeHereStart = matchstr(codeHere, '^\s*\S')[-1:]

   " add comment handling as well
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
      elseif codeAbove =~ '\s*var'
         let ind = 2
      endif
   elseif codeHere =~ '^\s*:'
     let ind += 1
    elseif codeHere =~ '^\s*{' && codeAbove =~ '^\s*[,:]'
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
