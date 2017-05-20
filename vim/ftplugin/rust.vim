set errorformat=
set errorformat+=%Wwarning:\ %m
set errorformat+=%Eerror:\ %m
set errorformat+=%Eerror[E%n]:\ %m
set errorformat+=%Z\ %#-->\ %f:%l:%c

"don't auto-add single quotes
let b:delimitMate_quotes="\" `"

nmap <buffer> gd <Plug>(rust-def)
nmap <buffer> gi <Plug>(rust-doc)
inoremap <buffer> . .
inoremap <buffer> :: ::

inoremap <buffer> ;; kA;jS

nnoremap <buffer> <leader>;k :call SplitArgs()<cr>
func! SplitArgs()
  let cursor = getpos('.')
  let line = getline('.')
  let indent = repeat(' ', indent('.'))

  let lineParts = split(line, '(')
  if len(lineParts) < 2
    return
  endif
  let before = lineParts[0]
  let line = join(lineParts[1:], '(')

  let lineParts = split(line, ')', 1)
  if len(lineParts) < 2
    return
  endif
  let after = lineParts[len(lineParts) - 1]
  let line = join(lineParts[:len(lineParts)-2], ')')

  let args = split(line, ',\s*')
  let args = map(args, "indent.'  '.v:val.','")
  let args = add(args, indent.')'.after)
  call append('.', args)
  call setline('.', before.'(')
  call setpos('.', cursor)
endfunc
