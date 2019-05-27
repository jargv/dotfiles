set expandtab
map <buffer> <F3> :exec "vsplit ".expand('%:r').".css"<cr>
set errorformat=%EERROR\ in\ %f,%C(%l\\,%c):\ error\ TS%n%m
set errorformat+=%f(%l\\,%c):\ error\ TS%n:\ %m

