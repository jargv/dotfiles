setlocal tabstop=2

setlocal foldmethod=marker
set textwidth=0

nnoremap <buffer> <Leader>;j :call <SID>join()<CR>"{{{
func! <SID>join()
   let pos = getpos('.')
   normal! A | J
   call setpos('.', pos)
endfunc
