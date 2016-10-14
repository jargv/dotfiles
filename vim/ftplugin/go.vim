setlocal nolist

inoremap <buffer> . .
nnoremap <buffer> <leader>;i :GoInfo<cr>
nnoremap <buffer> <leader>;d :GoDoc<cr>
nnoremap <buffer> <leader>;b :GoDocBrowser<cr>
nnoremap <buffer> <leader>;l :GoLint<cr>
nnoremap <buffer> <leader>;n :GoRename<cr>
nnoremap <buffer> <leader>;m :GoMetaLinter<cr>
nnoremap <buffer> <leader>;I :GoImports<cr>

nmap <buffer> gd <Plug>(go-def)
