set expandtab
map <buffer> <F3> :exec "vsplit ".expand('%:r').".css"<cr>

set errorformat=%ATypeScript\ error\ in\ %f(%l\\,%c):
set errorformat+=,%Z\ \ Line\ %l:%c:\ \ %m,%A%f
set errorformat+=,%-GCompiling...%m
set errorformat+=,%-GCompiled\ successfully!
