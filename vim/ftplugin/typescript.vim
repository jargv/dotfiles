set expandtab
map <buffer> <F3> :exec "vsplit ".expand('%:r').".css"<cr>

set errorformat=%f(%l\\,%c):\ error\ TS%n:\ %m
