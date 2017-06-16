inoreab <buffer> += =<SID>opEquals('+', '')<cr>
inoreab <buffer> -= =<SID>opEquals('-', '')<cr>
inoreab <buffer> /= =<SID>opEquals('/', '')<cr>
inoreab <buffer> *= =<SID>opEquals('*', '')<cr>
inoreab <buffer> ++ =<SID>opEquals('+', '')<cr>
func! <SID>opEquals(op, arg)
  let line = getline('.')
  let list = matchlist(line, '^\s*\([a-zA-Z0-9\.]\+\)')
  if len(list) < 2
    return a:op."="
  end
  let result = list[1]
  let arg = ""
  if len(a:arg)
    let arg = " ".a:arg
  endif
  return "= ".result." ".a:op.arg
endfunc
