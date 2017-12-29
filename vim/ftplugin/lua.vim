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
  let cond = s:invert(cond)

  let lines = [
  \ indent."if ".cond." then",
  \ indent."  error('failed: ".escape(cond, "'")."', 1)",
  \ indent."end"
  \]
  call setline('.', lines[0])
  call append('.', lines[1:])
endfunc

func! s:invert(code)
  let parts = matchlist(a:code, '\v^\s*(.{-})(and|or)\s*(.*)$')
  if len(parts)
    let first = s:invertSegment(parts[1])
    let rest = s:invert(parts[3])
    let operator = parts[2] == "and" ? "or" : "and"
    return s:trim(first) . " " . operator . " " . rest
  else
    return s:trim(s:invertSegment(a:code))
  endif
endfunc

func! s:invertSegment(code)
  " not(.*)
  let parts = matchlist(a:code, "\v^\s*not\s*\((.*)\)\s*$")
  if len(parts)
    return parts[1]
  endif

  " not .*
  let parts = matchlist(a:code, "\v^\s*not\s*(.*)\s*$")
  if len(parts)
    return parts[1]
  endif

  " ~=
  let parts = matchlist(a:code, '\v^\s*(.+)(\=\=|\~\=)(.+)\s*$')
  if len(parts)
    let op = parts[2] == '==' ? '~=' : '=='
    return parts[1] . "~=" . parts[3]
  endif

  return "not ".a:code
endfunc

func! s:trim(code)
  " {-} is non-greedy * in vimscript 0.o
  let parts = matchlist(a:code, '\v^\s*(.{-})\s*$')
  return parts[1]
endfunc
