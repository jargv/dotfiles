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


