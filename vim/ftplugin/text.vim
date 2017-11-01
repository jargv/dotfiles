" distraction-free writing {{{1
let b:writing = 0
noremap <buffer> <leader>;; :call <sid>toggleWriting()<cr>

func! <sid>toggleWriting()
  if b:writing
    call <sid>writingOff()
  else
    call <sid>writingOn()
  endif
endfunc

func! <sid>writingOn()
  let b:writing = 1
  let width = 55
  exec "set tw=" . width
  PencilHard
  Limelight
  exec "Goyo " . (width + 1)

  let b:colorscheme = g:colors_name
  colorscheme osx_like

  augroup Writing
    autocmd!
    autocmd BufLeave <buffer> call <sid>writingOff()
  augroup END
endfunc


func! <sid>writingOff()
  let b:writing = 0
  PencilOff
  Limelight!
  Goyo!
  exec "colorscheme ".b:colorscheme
  augroup Writing
    autocmd!
  augroup END
endfunc

" outline/todos {{{1
inoremap <C-o> <esc>yypVr=o
nnoremap <buffer> <leader>;g :s/^[\ -]*/### /<cr>:nohlsearch<cr>
nnoremap <buffer> <leader>;G :let g:reg=@x<cr>:let @x=''<cr>:%g/^###/d X<cr>gg"xP:let @x = g:reg<cr>
