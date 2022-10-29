set expandtab
map <buffer> <F3> :exec "vsplit ".expand('%:r').".css"<cr>

setlocal errorformat=%f(%l\\,%c):\ error\ TS%n:\ %m
