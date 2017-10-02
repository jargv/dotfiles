inoremap <C-o> <esc>yypVr=o

noremap <buffer> <leader>;; :PencilToggle<cr> :set tw=45<cr>

nnoremap <buffer> <leader>;g :s/^[\ -]*/### /<cr>:nohlsearch<cr>
nnoremap <buffer> <leader>;G :let g:reg=@x<cr>:let @x=''<cr>:%g/^###/d X<cr>gg"xP:let @x = g:reg<cr>
