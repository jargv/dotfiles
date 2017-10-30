" distraction-free writing {{{1
let b:writing = 0
noremap <buffer> <leader>;; :call <sid>toggleWriting()<cr>
func! <sid>toggleWriting()
  let width = 55
  exec "set tw=" . width
  PencilToggle
  Limelight!!
  if !b:writing
    let b:colorscheme = g:colors_name
    colorscheme osx_like
    exec "Goyo " . (width + 1)
  else
    exec "colorscheme ".b:colorscheme
    Goyo
  endif
  let b:writing = !b:writing
endfunc

" outline/todos {{{1
inoremap <C-o> <esc>yypVr=o
nnoremap <buffer> <leader>;g :s/^[\ -]*/### /<cr>:nohlsearch<cr>
nnoremap <buffer> <leader>;G :let g:reg=@x<cr>:let @x=''<cr>:%g/^###/d X<cr>gg"xP:let @x = g:reg<cr>
