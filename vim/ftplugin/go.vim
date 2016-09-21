setlocal nolist

inoremap <buffer> . .
nnoremap <buffer> <leader>;I :GoInfo<cr>
nnoremap <buffer> <leader>;d :GoDoc<cr>
nnoremap <buffer> <leader>;n :GoRename<cr>
nnoremap <buffer> <leader>;m :GoMetaLinter<cr>
nnoremap <buffer> <leader>;i :GoImports<cr>

nmap <buffer> gd <Plug>(go-def)
