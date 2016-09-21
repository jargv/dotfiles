func! SnipFoldExpr(lnum)
   let line = getline(a:lnum)

   if line =~ '^snippet'
      return ">1"
   else
      return '='
   endif
endfunc

setlocal foldexpr=SnipFoldExpr(v:lnum)
setlocal foldmethod=expr
setlocal foldlevel=0
setlocal expandtab
