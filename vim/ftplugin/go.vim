" settings {{{1
setlocal nolist

" key maps {{{1
inoremap <buffer> . .
nnoremap <buffer> <leader>;i :GoInfo<cr>
nnoremap <buffer> <leader>;d :GoDoc<cr>
nnoremap <buffer> <leader>;b :GoDocBrowser<cr>
nnoremap <buffer> <leader>;l :GoLint<cr>
nnoremap <buffer> <leader>;n :GoRename<cr>
nnoremap <buffer> <leader>;m :GoMetaLinter<cr>
nnoremap <buffer> <leader>;I :GoImports<cr>
nnoremap <buffer> gd :GoDef<cr>

" <leader>;j = JoinVars() {{{1
nnoremap <buffer> <leader>;j :call JoinVars()<cr>
func! JoinVars()
  let startline = line('.')
  let line = startline
  while getline(line) =~ '^\s*var\s\+'
    let line += 1
  endwhile
  let endline = line - 1
  if endline < startline
    return
  endif
  exec startline.','.endline.'s/\s*var\s*/\t/'
  call append(endline, ')')
  call append(startline-1, 'var (')
endfunc

" <leader>;k = SplitArgs() {{{1
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

" <leader>;s[sh] = embedded highlighting {{{1
nnoremap <buffer> <leader>;ss :call HighlightEmbedded('sql', '`', '`')<cr>
nnoremap <buffer> <leader>;sh :call HighlightEmbedded('html', '`', '`')<cr>
