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
  exec "Goyo " . (width + 2)

  let b:colorscheme = g:colors_name
  "colorscheme osx_like
  colorscheme asmdev
  hi EndOfBuffer ctermfg=white guifg=bg

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
  hi EndOfBuffer ctermfg=bg guifg=bg
  augroup Writing
    autocmd!
  augroup END
endfunc

" underline with ==== {{{1
inoremap <C-o> <esc>yypVr=o
" gather todos {{{1
nnoremap <buffer> <leader>;g :s/^[\ -]*/### /<cr>:nohlsearch<cr>
nnoremap <buffer> <leader>;G :let g:reg=@x<cr>:let @x=''<cr>:%g/^###/d X<cr>gg"xP:let @x = g:reg<cr>
" outline folding {{{1

" just use the text for foldtext
set debug=msg

nnoremap <buffer> <leader>;f :set foldmethod=expr<cr>:echo "folding in outline mode"<cr>
setlocal foldexpr=TextOutlineFold(v:lnum)
func! TextOutlineFold(lnum)
  let line = getline(a:lnum)
  let firstNonSpace = match(line, '\S')

  let nextLine = getline(a:lnum+1)
  let nextLineFirstNonSpace = match(nextLine, '\S')

  if firstNonSpace == -1 || nextLineFirstNonSpace <= firstNonSpace
    return "="
  endif

  let indent = firstNonSpace / 2 + 1

  if line[firstNonSpace] == "-" || line[firstNonSpace] == "+"
    return ">".indent
  endif

  return "="
endfunc
