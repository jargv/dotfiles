setlocal errorformat=\ %#-->\ %f:%l:%c

nmap <buffer> gd <Plug>(rust-def)
nmap <buffer> gi <Plug>(rust-doc)
inoremap <buffer> . .
inoremap <buffer> :: ::
