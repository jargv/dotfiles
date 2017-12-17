inoreab <buffer> += =<SID>opEquals('+')<cr>
inoreab <buffer> -= =<SID>opEquals('-')<cr>
inoreab <buffer> /= =<SID>opEquals('/')<cr>
inoreab <buffer> *= =<SID>opEquals('*')<cr>
inoreab <buffer> or= =<SID>opEquals('or')<cr>
inoreab <buffer> and= =<SID>opEquals('and')<cr>
func! <SID>opEquals(op)
  let line = getline('.')
  let list = matchlist(line, '^\s*\([a-zA-Z0-9\.]\+\)')
  if len(list) < 2
    return a:op."="
  end
  let result = list[1]
  return "= ".result." ".a:op
endfunc

inoreab <buffer> != ~=

nnoremap <leader>;a :call AssertToIf()<cr>
func! AssertToIf()
  let line_num = line('.')
  let line = getline('.')
  let matches = matchlist(line, '^\(\s*\)assert(\(.*\))\s*$')
  if len(matches) < 3
    return
  endif

  let indent = matches[1]
  let cond = matches[2]

  let cond = "not(".cond.")"

  let lines = [
  \ indent."if ".cond." then",
  \ indent."  error(('failed: %s'):fmt('".escape(cond, "'")."'), 1)",
  \ indent."end"
  \]
  call setline('.', lines[0])
  call append('.', lines[1:])
endfunc

nnoremap <leader>;n :call SwapNotExpression()<cr>
func! SwapNotExpression()
  s/not//e
  s/and/or/e
  s/or/and/e
  s/\~=/==/e
  s/==/\~=/e
endfunc

