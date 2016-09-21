nmap <leader>m <c-j>

augroup REST
  autocmd!
  autocmd bufwritepost <buffer> :call VrcQuery()
augroup END
