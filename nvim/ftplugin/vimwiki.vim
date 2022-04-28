
if expand('%:t:r') =~ '^[0-9-]*$'
   setlocal tw=45
endif

nnoremap <silent> <buffer> <leader>d :call <SID>Toggle_task_status()<CR>
func! <SID>Toggle_task_status()
   echo "workin on it"
   let line = getline('.')
   if match(line, '^\(\s*\)-') == 0
      let line = substitute(line, '^\(\s*\)-', '\1✓', '')
   elseif match(line, '^\(\s*\)✓') == 0
      let line = substitute(line, '^\(\s*\)✓\s\=\<', '\1', '')
   else
      let line = substitute(line, '^\(\s\{-}\)\(\s\=\)\<', '\2\1- ', '')
   endif
   call setline('.', line) 
endfunc

